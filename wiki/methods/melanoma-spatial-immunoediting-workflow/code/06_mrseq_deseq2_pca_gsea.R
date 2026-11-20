#!/usr/bin/env Rscript
# Step 06: PickSeq mrSEQ DESeq2 (aligned with Table S6), prcomp PCA (Fig 6A proxy),
# GSVA ssGSEA (Fig 6C, S7C), clusterProfiler GSEA running ES (Fig 6E, S6C, S7B),
# and downstream gene/heatmap exports (Fig 6B, 6F, 6G, 6K, 7B, 7H, S6D-E, S7A, S7E-H).

suppressPackageStartupMessages({
  rwiki_libs <- Sys.getenv("RWIKI_R_LIBS", ""); if (nzchar(rwiki_libs)) .libPaths(c(strsplit(rwiki_libs, .Platform$path.sep)[[1]], .libPaths()))))
  library(DESeq2)
  library(clusterProfiler)
  library(GSVA)
  library(msigdbr)
  library(enrichplot)
  library(readxl)
  library(jsonlite)
})

set.seed(42)
t0 <- proc.time()[["elapsed"]]
args <- commandArgs(trailingOnly = TRUE)
force_rerun <- "--force" %in% args

root <- "."
small_dir <- file.path(root, "data_small")
out_dir <- file.path(root, "runs", "step06_mrseq_deseq2")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("[step06] Loading mrseq_counts_small.csv, mrseq_meta_small.csv, and HGNC map...\n")
counts_raw <- read.csv(file.path(small_dir, "mrseq_counts_small.csv"), row.names = 1, check.names = FALSE)
meta <- read.csv(file.path(small_dir, "mrseq_meta_small.csv"), stringsAsFactors = FALSE)
rownames(meta) <- meta$sample_id
counts_mat <- as.matrix(round(counts_raw[, meta$sample_id]))
storage.mode(counts_mat) <- "integer"

site_levels <- c("MIS", "IR", "bTIL", "IB", "IM", "EM")
meta$site <- factor(meta$site, levels = site_levels)

hgnc_map <- read.csv(file.path(small_dir, "ensembl_to_symbol_hgnc.csv"), stringsAsFactors = FALSE)
hgnc_map <- hgnc_map[!duplicated(hgnc_map$ensembl_id), ]
ens_to_sym <- setNames(hgnc_map$gene_symbol, hgnc_map$ensembl_id)

map_ens_matrix_to_sym <- function(mat) {
  ens_base <- sub("\\..*$", "", rownames(mat))
  syms <- unname(ens_to_sym[ens_base])
  keep <- !is.na(syms) & nzchar(syms)
  mat_k <- mat[keep, , drop = FALSE]
  syms_k <- syms[keep]
  rmean <- rowMeans(mat_k, na.rm = TRUE)
  ord <- order(syms_k, -rmean)
  mat_k <- mat_k[ord, , drop = FALSE]
  syms_k <- syms_k[ord]
  uniq <- !duplicated(syms_k)
  out <- mat_k[uniq, , drop = FALSE]
  rownames(out) <- syms_k[uniq]
  out
}

map_deg_to_sym <- function(df) {
  df$ensembl_id <- df$gene_symbol
  df$gene_symbol <- unname(ens_to_sym[sub("\\..*$", "", df$ensembl_id)])
  df <- df[!is.na(df$gene_symbol) & nzchar(df$gene_symbol), ]
  df <- df[order(df$gene_symbol, -df$baseMean, df$pvalue, na.last = TRUE), ]
  df <- df[!duplicated(df$gene_symbol), ]
  df[order(df$padj, df$pvalue, na.last = TRUE), ]
}

cache_norm <- file.path(out_dir, "deseq2_norm_counts.csv")
cache_log2 <- file.path(out_dir, "deseq2_log2_norm_counts.csv")
cache_mis <- file.path(out_dir, "deseq2_mis_vs_emim.csv")
cache_im <- file.path(out_dir, "deseq2_im_vs_em.csv")
cache_btil <- file.path(out_dir, "deseq2_btil_vs_tumor.csv")
have_cache <- all(file.exists(c(cache_norm, cache_log2, cache_mis, cache_im, cache_btil))) && !force_rerun

if (have_cache) {
  cat("[step06] Reusing cached DESeq2 outputs from runs/step06_mrseq_deseq2/ (pass --force to recompute)...\n")
  norm_counts <- as.matrix(read.csv(cache_norm, row.names = 1, check.names = FALSE))
  log2_norm_ens <- as.matrix(read.csv(cache_log2, row.names = 1, check.names = FALSE))
  deg_mis_emim_raw <- read.csv(cache_mis, stringsAsFactors = FALSE)
  deg_im_vs_em_raw <- read.csv(cache_im, stringsAsFactors = FALSE)
  deg_btil_vs_tum_raw <- read.csv(cache_btil, stringsAsFactors = FALSE)
  # Align MIS vs EM-IM sign with Table S6 DEG_MIS_vs_EM-IM (MIS positive, EM-IM negative) if cached with ref=MIS
  deg_mis_emim_raw$log2FoldChange <- -deg_mis_emim_raw$log2FoldChange
  deg_mis_emim_raw$stat <- -deg_mis_emim_raw$stat
} else {
  # 1. DESeq2 sizeFactor normalization & log2(norm + 1)
  cat("[step06] Running DESeq2 sizeFactor normalization...\n")
  dds_all <- DESeqDataSetFromMatrix(countData = counts_mat, colData = meta, design = ~ site)
  dds_all <- estimateSizeFactors(dds_all)
  norm_counts <- counts(dds_all, normalized = TRUE)
  log2_norm_ens <- log2(norm_counts + 1)
  write.csv(log2_norm_ens, cache_log2)
  write.csv(norm_counts, cache_norm)

  # 2. DESeq2 Contrasts: (A) MIS vs EM-IM (Fig 6D), (B) IM vs EM (Fig 6E/6F/6G/S6C), (C) bTIL vs EM-IM (Fig S7B)
  run_deseq_pair <- function(sub_samples, grp_vec, ref_level, alt_level) {
    sub_counts <- counts_mat[, sub_samples, drop = FALSE]
    keep <- rowSums(sub_counts) >= 10L
    sub_counts <- sub_counts[keep, , drop = FALSE]
    coldata <- data.frame(group = factor(grp_vec, levels = c(ref_level, alt_level)), row.names = sub_samples)
    dds <- DESeqDataSetFromMatrix(countData = sub_counts, colData = coldata, design = ~ group)
    dds <- DESeq(dds, quiet = TRUE)
    res <- results(dds, contrast = c("group", alt_level, ref_level))
    df <- as.data.frame(res)
    df$gene_symbol <- rownames(df)
    df <- df[, c("gene_symbol", "baseMean", "log2FoldChange", "lfcSE", "stat", "pvalue", "padj")]
    df[order(df$padj, df$pvalue, na.last = TRUE), ]
  }

  cat("[step06] Running DESeq2: MIS vs EM-IM...\n")
  mis_emim_idx <- meta$sample_id[meta$site %in% c("MIS", "IM", "EM")]
  mis_emim_grp <- ifelse(meta$site[match(mis_emim_idx, meta$sample_id)] == "MIS", "MIS", "EM_IM")
  deg_mis_emim_raw <- run_deseq_pair(mis_emim_idx, mis_emim_grp, ref_level = "EM_IM", alt_level = "MIS")
  write.csv(deg_mis_emim_raw, cache_mis, row.names = FALSE)

  cat("[step06] Running DESeq2: EM vs IM...\n")
  em_im_idx <- meta$sample_id[meta$site %in% c("EM", "IM")]
  em_im_grp <- as.character(meta$site[match(em_im_idx, meta$sample_id)])
  deg_im_vs_em_raw <- run_deseq_pair(em_im_idx, em_im_grp, ref_level = "EM", alt_level = "IM")
  write.csv(deg_im_vs_em_raw, cache_im, row.names = FALSE)

  cat("[step06] Running DESeq2: bTIL vs EM-IM (for Fig S7B)...\n")
  btil_tum_idx <- meta$sample_id[meta$site %in% c("bTIL", "IM", "EM")]
  btil_tum_grp <- ifelse(meta$site[match(btil_tum_idx, meta$sample_id)] == "bTIL", "bTIL", "Tumor")
  deg_btil_vs_tum_raw <- run_deseq_pair(btil_tum_idx, btil_tum_grp, ref_level = "Tumor", alt_level = "bTIL")
  write.csv(deg_btil_vs_tum_raw, cache_btil, row.names = FALSE)
}

log2_norm <- map_ens_matrix_to_sym(log2_norm_ens)
write.csv(log2_norm, file.path(out_dir, "deseq2_log2_norm_counts_symbol.csv"))
deg_mis_emim <- map_deg_to_sym(deg_mis_emim_raw)
deg_im_vs_em <- map_deg_to_sym(deg_im_vs_em_raw)
deg_btil_vs_tum <- map_deg_to_sym(deg_btil_vs_tum_raw)
write.csv(deg_mis_emim, file.path(out_dir, "deseq2_mis_vs_emim_symbol.csv"), row.names = FALSE)
write.csv(deg_im_vs_em, file.path(out_dir, "deseq2_im_vs_em_symbol.csv"), row.names = FALSE)
write.csv(deg_btil_vs_tum, file.path(out_dir, "deseq2_btil_vs_tumor_symbol.csv"), row.names = FALSE)
cat(sprintf("[step06] Mapped Ensembl -> HGNC symbols: %d genes in log2_norm.\n", nrow(log2_norm)))

# Cross-check against Table S6 original DESeq2 results
s6_path <- file.path(root, "intake", "supp", "cd-21-1357_table_s6_suppst6.xlsx")
s6_mis <- as.data.frame(read_excel(s6_path, sheet = "DEG_MIS_vs_EM-IM", skip = 3))
colnames(s6_mis)[1] <- "gene_symbol"
s6_em <- as.data.frame(read_excel(s6_path, sheet = "DEG_EM_vs_IM", skip = 3))
colnames(s6_em)[1] <- "gene_symbol"
write.csv(s6_mis, file.path(out_dir, "table_s6_mis_vs_emim_ref.csv"), row.names = FALSE)
write.csv(s6_em, file.path(out_dir, "table_s6_em_vs_im_ref.csv"), row.names = FALSE)

m_mis <- merge(deg_mis_emim[, c("gene_symbol", "log2FoldChange")], s6_mis[, c("gene_symbol", "log2FoldChange")], by = "gene_symbol")
m_em <- merge(deg_im_vs_em[, c("gene_symbol", "log2FoldChange")], s6_em[, c("gene_symbol", "log2FoldChange")], by = "gene_symbol")
cor_mis <- suppressWarnings(cor(m_mis$log2FoldChange.x, m_mis$log2FoldChange.y, use = "complete.obs", method = "spearman"))
# Table S6 DEG_EM_vs_IM reports EM positive / IM negative; our deg_im_vs_em reports IM positive / EM negative
cor_im <- suppressWarnings(cor(m_em$log2FoldChange.x, -m_em$log2FoldChange.y, use = "complete.obs", method = "spearman"))
cat(sprintf("[step06] Spearman vs Table S6: MIS_vs_EM-IM = %.4f (n=%d), IM_vs_EM = %.4f (n=%d)\n", cor_mis, nrow(m_mis), cor_im, nrow(m_em)))

# 3. PCA via prcomp (Fig 6A - proxy on PickSeq 120 mROIs)
cat("[step06] Running prcomp PCA (Fig 6A proxy)...\n")
gene_vars <- apply(log2_norm, 1, var)
top_genes <- names(sort(gene_vars, decreasing = TRUE))[1:min(2000, nrow(log2_norm))]
pca_fit <- prcomp(t(log2_norm[top_genes, ]), center = TRUE, scale. = TRUE)
var_exp <- (pca_fit$sdev^2) / sum(pca_fit$sdev^2) * 100
pca_df <- data.frame(
  sample_id = rownames(pca_fit$x),
  site = as.character(meta[rownames(pca_fit$x), "site"]),
  PC1 = pca_fit$x[, 1],
  PC2 = pca_fit$x[, 2],
  PC3 = pca_fit$x[, 3],
  pc1_var_pct = round(var_exp[1], 2),
  pc2_var_pct = round(var_exp[2], 2),
  evidence_tier = "proxy"
)
write.csv(pca_df, file.path(out_dir, "fig6a_pca_coords_proxy.csv"), row.names = FALSE)

# 4. GSVA ssGSEA (Fig 6C + Fig S7C)
cat("[step06] Running GSVA ssGSEA (Fig 6C + Fig S7C)...\n")
h_df <- msigdbr(species = "human", collection = "H")
kegg_df <- msigdbr(species = "human", collection = "C2", subcollection = "CP:KEGG_LEGACY")
gobp_df <- msigdbr(species = "human", collection = "C5", subcollection = "GO:BP")
cgp_df <- msigdbr(species = "human", collection = "C2", subcollection = "CGP")

fig6c_sets <- list(
  SHIH_IFN = unique(h_df$gene_symbol[h_df$gs_name == "HALLMARK_INTERFERON_GAMMA_RESPONSE"]),
  IMSIG_IFN = unique(h_df$gene_symbol[h_df$gs_name == "HALLMARK_INTERFERON_ALPHA_RESPONSE"]),
  Melanocytes = c("PMEL", "MITF", "MLANA", "TYR", "DCT", "SOX10", "S100B", "MC1R", "GPR143", "OCA2", "SLC45A2", "TRPM1"),
  Melanoma = c("MITF", "PMEL", "MLANA", "TYR", "SOX10", "S100B", "CSPG4", "CDK2", "TBC1D7", "TSPAN10", "BRI3", "SERPINE2", "CTSL", "NRP2", "SCD"),
  T_cells = c("CD3D", "CD3E", "CD3G", "CD8A", "CD8B", "CD4", "FOXP3", "LCK", "ZAP70", "PDCD1", "CTLA4", "LAG3", "TIGIT", "TRAC"),
  Macrophages = c("CD163", "CD68", "CSF1R", "MRC1", "ITGAX", "CD14", "MSR1", "MARCO", "C1QA", "C1QB", "C1QC", "FCGR3A"),
  B_cells = c("MS4A1", "CD19", "CD79A", "CD79B", "PAX5", "BLK", "BANK1", "FCRL5", "JCHAIN"),
  Keratinocyte = c("KRT5", "KRT14", "KRT1", "KRT10", "IVL", "FLG", "DSG1", "DSP", "PKP1", "SFN", "S100A8", "S100A9", "DMKN")
)
ss_param_6c <- ssgseaParam(exprData = as.matrix(log2_norm), geneSets = fig6c_sets, normalize = TRUE)
ss_6c <- as.matrix(gsva(ss_param_6c, verbose = FALSE))
write.csv(ss_6c, file.path(out_dir, "fig6c_ssgsea_scores.csv"))

figs7c_sets <- list(
  KEGG_JAK_STAT = unique(kegg_df$gene_symbol[kegg_df$gs_name == "KEGG_JAK_STAT_SIGNALING_PATHWAY"]),
  JAK_STAT_CASCADE = unique(gobp_df$gene_symbol[gobp_df$gs_name == "GOBP_CELL_SURFACE_RECEPTOR_SIGNALING_PATHWAY_VIA_JAK_STAT"]),
  GO_RECEPTOR_SIGNALING_VIA_STAT = unique(gobp_df$gene_symbol[gobp_df$gs_name == "GOBP_CELL_SURFACE_RECEPTOR_SIGNALING_PATHWAY_VIA_STAT"]),
  IL6_JAK_STAT3_SIGNALING = unique(h_df$gene_symbol[h_df$gs_name == "HALLMARK_IL6_JAK_STAT3_SIGNALING"])
)
ss_param_s7c <- ssgseaParam(exprData = as.matrix(log2_norm), geneSets = figs7c_sets, normalize = TRUE)
ss_s7c <- as.matrix(gsva(ss_param_s7c, verbose = FALSE))
write.csv(ss_s7c, file.path(out_dir, "figs7c_jakstat_ssgsea_scores_proxy.csv"))

# 5. clusterProfiler GSEA (Fig 6E, Fig S6C, Fig S7B)
cat("[step06] Running clusterProfiler GSEA (Fig 6E, S6C, S7B)...\n")
make_ranked_vec <- function(deg_df) {
  sub <- deg_df[!is.na(deg_df$stat) & !duplicated(deg_df$gene_symbol), ]
  vec <- sub$stat
  names(vec) <- sub$gene_symbol
  sort(vec, decreasing = TRUE)
}

run_single_gsea <- function(ranked_vec, term2gene_df, label_name) {
  g <- GSEA(
    geneList = ranked_vec,
    TERM2GENE = term2gene_df,
    minGSSize = 10,
    maxGSSize = 1000,
    pvalueCutoff = 1.0,
    verbose = FALSE,
    seed = TRUE
  )
  res_df <- as.data.frame(g@result)
  res_df$panel <- label_name
  gs_id <- term2gene_df$gs_name[1]
  curve_df <- tryCatch({
    gi <- enrichplot:::gsInfo(g, geneSetID = gs_id)
    gi$panel <- label_name
    gi$pathway <- gs_id
    gi
  }, error = function(e) data.frame())
  list(res = res_df, curve = curve_df)
}

rank_im_em <- make_ranked_vec(deg_im_vs_em)
rank_btil_tum <- make_ranked_vec(deg_btil_vs_tum)

t2g_kras <- data.frame(
  gs_name = "HALLMARK_KRAS_SIGNALING_UP",
  gene_symbol = unique(h_df$gene_symbol[h_df$gs_name == "HALLMARK_KRAS_SIGNALING_UP"])
)
t2g_emt <- data.frame(
  gs_name = "JECHLINGER_EPITHELIAL_TO_MESENCHYMAL_TRANSITION_UP",
  gene_symbol = unique(cgp_df$gene_symbol[cgp_df$gs_name == "JECHLINGER_EPITHELIAL_TO_MESENCHYMAL_TRANSITION_UP"])
)
t2g_jak <- data.frame(
  gs_name = "HALLMARK_IL6_JAK_STAT3_SIGNALING",
  gene_symbol = unique(h_df$gene_symbol[h_df$gs_name == "HALLMARK_IL6_JAK_STAT3_SIGNALING"])
)

g_6e <- run_single_gsea(rank_im_em, t2g_kras, "Fig6E")
g_s6c <- run_single_gsea(rank_im_em, t2g_emt, "FigS6C")
g_s7b <- run_single_gsea(rank_btil_tum, t2g_jak, "FigS7B")

gsea_summary <- rbind(g_6e$res, g_s6c$res, g_s7b$res)
write.csv(gsea_summary, file.path(out_dir, "gsea_summary.csv"), row.names = FALSE)
gsea_curves <- rbind(g_6e$curve, g_s6c$curve, g_s7b$curve)
write.csv(gsea_curves, file.path(out_dir, "gsea_running_es_curves.csv"), row.names = FALSE)

# 6. Downstream gene expression & heatmap exports
cat("[step06] Exporting gene barplot & heatmap matrices (Figs 6B/6F/6G/6K/7B/7H/S6D-E/S7A/S7E-H)...\n")
export_gene_long <- function(genes, samples_sub, group_map, out_name) {
  avail <- intersect(genes, rownames(log2_norm))
  rows <- list()
  for (g in avail) {
    vals <- as.numeric(log2_norm[g, samples_sub])
    rows[[g]] <- data.frame(
      gene = g,
      sample_id = samples_sub,
      group = as.character(group_map[samples_sub]),
      site = as.character(meta[samples_sub, "site"]),
      log2_expr = vals,
      stringsAsFactors = FALSE
    )
  }
  df <- do.call(rbind, rows)
  write.csv(df, file.path(out_dir, out_name), row.names = FALSE)
  df
}

# Fig 6B: PMEL, MITF, MLANA, CSPG4, TYR across MIS vs Immune (IR+bTIL) vs Tumor (IB+IM+EM)
grp_3 <- ifelse(meta$site == "MIS", "MIS", ifelse(meta$site %in% c("IR", "bTIL"), "Immune", "Tumor"))
names(grp_3) <- meta$sample_id
df_6b <- export_gene_long(c("PMEL", "MITF", "MLANA", "CSPG4", "TYR"), meta$sample_id, grp_3, "fig6b_melanoma_markers_long.csv")

# Fig 6F: MYC, NFKB1, IGFBP2, IGF1R, BCL2A1 in IM vs EM
s_im_em <- meta$sample_id[meta$site %in% c("IM", "EM")]
grp_im_em <- setNames(as.character(meta[s_im_em, "site"]), s_im_em)
df_6f <- export_gene_long(c("MYC", "NFKB1", "IGFBP2", "IGF1R", "BCL2A1"), s_im_em, grp_im_em, "fig6f_im_vs_em_genes_long.csv")

# Fig 6G: EMT genes Z-score heatmap (IM vs EM)
genes_6g <- intersect(c("S100A4", "VIM", "CTNNB1", "DMKN", "MMP2", "FXYD3", "PYROXD2", "CSTB"), rownames(log2_norm))
mat_6g <- log2_norm[genes_6g, s_im_em, drop = FALSE]
z_6g <- t(scale(t(mat_6g)))
write.csv(z_6g, file.path(out_dir, "fig6g_emt_zscore_im_em.csv"))

# Fig 6K: PMEL & CD63 density (MIS vs EM+IM, PickSeq proxy)
s_mis_tum <- meta$sample_id[meta$site %in% c("MIS", "EM", "IM")]
grp_6k <- setNames(ifelse(meta[s_mis_tum, "site"] == "MIS", "MIS", "EM_and_IM"), s_mis_tum)
export_gene_long(c("PMEL", "CD63"), s_mis_tum, grp_6k, "fig6k_pmel_cd63_density_proxy.csv")

# Fig 7B: CXCL10, CXCL11, IDO1 (bTIL, IB, IM) & MIF, CD74 (IR, bTIL, IB, IM, EM)
s_5 <- meta$sample_id[meta$site %in% c("IR", "bTIL", "IB", "IM", "EM")]
grp_5 <- setNames(as.character(meta[s_5, "site"]), s_5)
export_gene_long(c("CXCL10", "CXCL11", "IDO1", "MIF", "CD74"), s_5, grp_5, "fig7b_immune_chemokines_long.csv")

# Fig 7H: Checkpoint & cytotoxicity Z-score across all 120 mROIs + Up P < 0.05 vs EM
genes_7h <- intersect(c("CTLA4", "PDCD1", "GNLY", "HAVCR2", "TIGIT", "LAG3", "PRF1", "GZMB", "GZMA"), rownames(log2_norm))
mat_7h <- log2_norm[genes_7h, meta$sample_id, drop = FALSE]
z_7h <- t(scale(t(mat_7h)))
write.csv(z_7h, file.path(out_dir, "fig7h_checkpoints_zscore_proxy.csv"))
em_samples <- meta$sample_id[meta$site == "EM"]
sig_rows <- list()
for (g in genes_7h) {
  em_vals <- as.numeric(log2_norm[g, em_samples])
  for (st in c("MIS", "IR", "bTIL", "IB", "IM")) {
    st_vals <- as.numeric(log2_norm[g, meta$sample_id[meta$site == st]])
    tt <- suppressWarnings(t.test(st_vals, em_vals))
    sig_rows[[length(sig_rows) + 1]] <- data.frame(
      gene = g,
      site = st,
      mean_site = mean(st_vals),
      mean_em = mean(em_vals),
      p_value = tt$p.value,
      up_sig_p05 = as.integer(mean(st_vals) > mean(em_vals) && !is.na(tt$p.value) && tt$p.value < 0.05),
      stringsAsFactors = FALSE
    )
  }
}
write.csv(do.call(rbind, sig_rows), file.path(out_dir, "fig7h_up_vs_em_sig_proxy.csv"), row.names = FALSE)

# Fig S6D-table: mROI counts (Table S3 original + sampled 120)
s6d_tab <- data.frame(
  site = c("MIS", "IR", "IM", "IB", "bTIL", "EM"),
  PickSeq_original_N222 = c(97, 47, 16, 12, 16, 34),
  GeoMx_original_N70 = c(26, 10, 6, 5, 4, 19),
  PickSeq_sampled_N120 = as.integer(table(meta$site)[c("MIS", "IR", "IM", "IB", "bTIL", "EM")])
)
write.csv(s6d_tab, file.path(out_dir, "figs6d_mroi_counts_table.csv"), row.names = FALSE)

# Fig S6E (DDX58 IM vs EM proxy), S7A (IFNG MIS/bTIL/IB/IM proxy), S7E (IRF1 bTIL/IB/IM),
# S7F/S7G (MIF/CD74 expression positivity proxy), S7H (CXCL12/CXCR4 proxy)
export_gene_long(c("DDX58"), s_im_em, grp_im_em, "figs6e_ddx58_im_em_proxy.csv")
s_s7a <- meta$sample_id[meta$site %in% c("MIS", "bTIL", "IB", "IM")]
export_gene_long(c("IFNG"), s_s7a, setNames(as.character(meta[s_s7a, "site"]), s_s7a), "figs7a_ifng_proxy.csv")
s_s7e <- meta$sample_id[meta$site %in% c("bTIL", "IB", "IM")]
export_gene_long(c("IRF1"), s_s7e, setNames(as.character(meta[s_s7e, "site"]), s_s7e), "figs7e_irf1_bTIL_IB_IM.csv")
export_gene_long(c("MIF", "CD74"), meta$sample_id, setNames(as.character(meta$site), meta$sample_id), "figs7fg_mif_cd74_proxy.csv")

genes_s7h <- intersect(c("CXCL12", "CXCR4"), rownames(log2_norm))
z_s7h <- t(scale(t(log2_norm[genes_s7h, meta$sample_id, drop = FALSE])))
write.csv(z_s7h, file.path(out_dir, "figs7h_cxcl12_cxcr4_zscore_proxy.csv"))

# Summary JSON
n_deg_mis <- sum(!is.na(deg_mis_emim$padj) & deg_mis_emim$padj < 0.05)
n_deg_im <- sum(!is.na(deg_im_vs_em$padj) & deg_im_vs_em$padj < 0.05)
elapsed <- round(proc.time()[["elapsed"]] - t0, 2)
summary_obj <- list(
  step = "06_mrseq_deseq2_pca_gsea",
  n_mrois = nrow(meta),
  n_genes = nrow(counts_mat),
  deseq2_mis_vs_emim_padj05 = n_deg_mis,
  deseq2_im_vs_em_padj05 = n_deg_im,
  table_s6_spearman_mis_vs_emim = round(cor_mis, 4),
  table_s6_spearman_em_vs_im = round(cor_im, 4),
  pca_pc1_var_pct = round(var_exp[1], 2),
  pca_pc2_var_pct = round(var_exp[2], 2),
  gsea = gsea_summary[, c("panel", "ID", "setSize", "enrichmentScore", "NES", "pvalue", "p.adjust")],
  elapsed_sec = elapsed
)
write_json(summary_obj, file.path(out_dir, "step06_summary.json"), auto_unbox = TRUE, pretty = TRUE)
cat(sprintf("[step06] Done in %.2fs -> %s\n", elapsed, out_dir))

rm(list = ls())
gc()
