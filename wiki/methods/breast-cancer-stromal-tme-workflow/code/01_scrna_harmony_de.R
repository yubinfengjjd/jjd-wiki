# 01_scrna_harmony_de.R
# Step 01: Harmony integration, UMAP dimensionality reduction, clustering, and marker/DotPlot verification
# Faithful to upstream_repo/breastcancer-stromal-cell/{Fig1_stromal_annotation_and_subset.R,
# CAF_scRNA_integration_annotation_pipeline.R, Endo_Analysis_FullPipeline_Complete.R, PVL_Analysis_Final.R}
# Seed: 42

r_libs <- strsplit(Sys.getenv("RWIKI_R_LIBS", ""), .Platform$path.sep)[[1]]
r_libs <- r_libs[nzchar(r_libs)]
if (length(r_libs)) {
  .libPaths(unique(c(r_libs, .libPaths())))
}

suppressPackageStartupMessages({
  library(Seurat)
  library(harmony)
  library(qs)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(tibble)
  library(jsonlite)
})

t0 <- proc.time()
set.seed(42)

paper_root <- Sys.getenv("PAPER_ROOT", ".")
paper_dir <- paper_root
in_qs     <- file.path(paper_dir, "data_small", "scrna_stromal_small.qs")
moesm_dir <- file.path(paper_dir, "data_small", "moesm")
out_dir   <- file.path(paper_dir, "runs", "step01_harmony_de")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Canonical subcluster mapping (MOESM3/script IDs -> Fig 2C/4C/5C/MOESM5 IDs) ----
fib_levels <- c(
  "C1_mFib_ACTA2", "C2_ifnFib_HSPA6", "C3_lpFib_PLA2G2A", "C4_iFib_BNC2",
  "C5_iFib_CXCL8", "C6_iFib_NFKB1", "C7_lpFib_APOD", "C8_iFib_CCL19",
  "C9_mFib_COL12A1", "C10_lpFib_ABCA8", "C11_tFib_ENO1", "C12_apFib_CD74",
  "C13_lpFib_LUM", "C14_tFib_A2M"
)
ec_levels <- c(
  "C1_ArtEC_SEMA3G", "C2_ArtEC_DLL4", "C3_CapEC_CD36", "C4_TipEC_PGF",
  "C5_VenEC_HIF1A", "C6_VenEC_CD74", "C7_tEC_DOCK4", "C8_emtEC_CD24",
  "C9_emtEC_COL1A1", "C10_nEC_IL6", "C11_nEC_HMOX1", "C12_LEC_CCL21"
)
mural_levels <- c(
  "C1_tPC_COL3A1", "C2_tPC_CCL19", "C3_tPC_CD74", "C4_tPC_SEPT7",
  "C5_tPC_PRKG1", "C6_nPC_CXCL8", "C7_nPC_GJA5",
  "C1_SMC_MLY9", "C2_SMC_FN1", "C3_SMC_MYH11"
)

subcluster_to_canonical <- c(
  # Fib (14)
  "C1_Fib_ACTA2"   = "C1_mFib_ACTA2",
  "C2_Fib_HSPA6"   = "C2_ifnFib_HSPA6",
  "C3_Fib_PLA2G2A" = "C3_lpFib_PLA2G2A",
  "C4_Fib_BNC2"    = "C4_iFib_BNC2",
  "C5_Fib_CXCL8"   = "C5_iFib_CXCL8",
  "C6_Fib_NFKB1"   = "C6_iFib_NFKB1",
  "C7_Fib_APOD"    = "C7_lpFib_APOD",
  "C8_Fib_CCL19"   = "C8_iFib_CCL19",
  "C9_Fib_COL12A1" = "C9_mFib_COL12A1",
  "C10_Fib_ABCA8"  = "C10_lpFib_ABCA8",
  "C11_Fib_ENO1"   = "C11_tFib_ENO1",
  "C12_Fib_CD74"   = "C12_apFib_CD74",
  "C13_Fib_LUM"    = "C13_lpFib_LUM",
  "C14_Fib_A2M"    = "C14_tFib_A2M",
  # EC (12)
  "C1_ArtECs_SEMA3G+" = "C1_ArtEC_SEMA3G",
  "C2_ArtECs_DLL4+"   = "C2_ArtEC_DLL4",
  "C3_CapECs_CD36+"   = "C3_CapEC_CD36",
  "C4_tips_PGF+"      = "C4_TipEC_PGF",
  "C5_VenECs_HIF1A+"  = "C5_VenEC_HIF1A",
  "C6_VenECs_CD74+"   = "C6_VenEC_CD74",
  "C7_tECs_DOCK4+"    = "C7_tEC_DOCK4",
  "C8_emtECs_CD24+"   = "C8_emtEC_CD24",
  "C9_emtECs_COL1A1+" = "C9_emtEC_COL1A1",
  "C10_nECs_IL6+"     = "C10_nEC_IL6",
  "C11_nECs_HMOX1+"   = "C11_nEC_HMOX1",
  "C12_LECs_CCL21+"   = "C12_LEC_CCL21",
  # Mural (10)
  "C1_MLY9+SMC"  = "C1_SMC_MLY9",
  "C2_FN1+SMC"   = "C2_SMC_FN1",
  "C3_MYH11+SMC" = "C3_SMC_MYH11",
  "C1_COL3A1+PC" = "C1_tPC_COL3A1",
  "C2_CCL19+PC"  = "C2_tPC_CCL19",
  "C3_CD74+PC"   = "C3_tPC_CD74",
  "C4_SEPT7+PC"  = "C4_tPC_SEPT7",
  "C5_PRKG1+PC"  = "C5_tPC_PRKG1",
  "C6_CXCL8+PC"  = "C6_nPC_CXCL8",
  "C7_GJA5+PC"   = "C7_nPC_GJA5"
)

# ---- Load inputs ----
srt <- qread(in_qs)
DefaultAssay(srt) <- "RNA"
srt$subcluster <- as.character(srt@meta.data$subcluster)
srt$canonical_subcluster <- unname(subcluster_to_canonical[srt$subcluster])
if (any(is.na(srt$canonical_subcluster))) {
  stop("Unmapped subclusters found: ", paste(unique(srt$subcluster[is.na(srt$canonical_subcluster)]), collapse = ", "))
}

deg_fib   <- read_csv(file.path(moesm_dir, "deg_fib.csv"), show_col_types = FALSE)
deg_ec    <- read_csv(file.path(moesm_dir, "deg_ec.csv"), show_col_types = FALSE)
deg_mural <- read_csv(file.path(moesm_dir, "deg_mural.csv"), show_col_types = FALSE)

# ---- Helper: Standard Seurat + Harmony + UMAP + Clustering pipeline ----
run_harmony_umap <- function(obj, resolution = 0.6, dims_use = 1:20, npcs = 30) {
  DefaultAssay(obj) <- "RNA"
  obj <- NormalizeData(obj, normalization.method = "LogNormalize", scale.factor = 10000, verbose = FALSE)
  n_feats <- nrow(obj)
  obj <- FindVariableFeatures(obj, selection.method = "vst", nfeatures = n_feats, verbose = FALSE)
  obj <- ScaleData(obj, features = rownames(obj), vars.to.regress = "nCount_RNA", verbose = FALSE)
  npcs_actual <- min(npcs, ncol(obj) - 1L, length(VariableFeatures(obj)) - 1L)
  obj <- RunPCA(obj, features = VariableFeatures(obj), npcs = npcs_actual, verbose = FALSE)
  dims_actual <- dims_use[dims_use <= npcs_actual]
  obj <- harmony::RunHarmony(
    object = obj,
    group.by.vars = "batch",
    reduction.use = "pca",
    dims.use = dims_actual,
    verbose = FALSE
  )
  obj <- RunUMAP(obj, reduction = "harmony", dims = dims_actual, verbose = FALSE)
  obj <- FindNeighbors(obj, reduction = "harmony", dims = dims_actual, k.param = 30, verbose = FALSE)
  obj <- FindClusters(obj, resolution = resolution, verbose = FALSE)
  obj
}

export_umap_csv <- function(obj, out_path) {
  emb <- as.data.frame(Embeddings(obj, reduction = "umap"))
  colnames(emb)[1:2] <- c("UMAP_1", "UMAP_2")
  md <- obj@meta.data
  df <- tibble::tibble(
    cell = rownames(emb),
    UMAP_1 = emb$UMAP_1,
    UMAP_2 = emb$UMAP_2,
    major_type = as.character(md$major_type),
    subcluster = as.character(md$subcluster),
    canonical_subcluster = as.character(md$canonical_subcluster),
    batch = as.character(md$batch),
    tissue = as.character(md$tissue),
    subtype = as.character(md$subtype),
    seurat_clusters = as.character(md$seurat_clusters)
  )
  write_csv(df, out_path)
  df
}

# ---- 1. Run full small stromal atlas (1,800 cells, resolution = 0.9 per Methods) ----
srt_all <- run_harmony_umap(srt, resolution = 0.9, dims_use = 1:20, npcs = 30)
umap_all <- export_umap_csv(srt_all, file.path(out_dir, "umap_all.csv"))

# ---- 2. Run Fib (res = 0.6), EC (res = 0.6), Mural (res = 0.3) per Methods & author scripts ----
srt_fib <- subset(srt, subset = major_type == "Fib")
srt_fib <- run_harmony_umap(srt_fib, resolution = 0.6, dims_use = 1:20, npcs = 30)
srt_fib$canonical_subcluster <- factor(srt_fib$canonical_subcluster, levels = fib_levels)
# Add Fib functional module scores from Fig2_CAF_program_distribution_progeny.R
caf_programs <- list(
  iCAF   = c("PLA2G2A", "CFD", "C3", "CD34", "CXCL12", "CXCL14", "IL6", "CD248"),
  mCAF   = c("MMP11", "COL1A2", "POSTN", "CDH11", "COL10A1", "COL11A1", "COL8A1",
             "COL12A1", "COL3A1", "COL5A2", "COMP", "LRRC15", "LRRC17", "ASPN",
             "SULF1", "INHBA", "VCAN", "CTHRC1", "MGP"),
  tCAF   = c("PDPN", "MME", "TMEM158", "NDRG1", "ENO1", "VEGFA", "CA9", "CAIX",
             "HSPH1", "GAPDH", "HSP90AA1"),
  ifnCAF = c("IDO1", "IL32", "CXCL9", "CXCL10", "CXCL11"),
  lpCAF  = c("APOA2", "FABP1", "FABP4", "FRZB", "CFD", "APOD", "ABCA8", "LUM")
)
for (pn in names(caf_programs)) {
  gs <- intersect(caf_programs[[pn]], rownames(srt_fib))
  if (length(gs) >= 1) {
    srt_fib <- AddModuleScore(srt_fib, features = list(gs), name = paste0("mod_", pn), nbin = 8, ctrl = 10, verbose = FALSE)
    raw_col <- paste0("mod_", pn, "1")
    srt_fib[[paste0("score_", pn)]] <- srt_fib@meta.data[[raw_col]]
    srt_fib@meta.data[[raw_col]] <- NULL
  }
}
umap_fib <- export_umap_csv(srt_fib, file.path(out_dir, "umap_fib.csv"))
# Append module scores to umap_fib.csv for Fig 2B reuse
score_cols_fib <- grep("^score_", colnames(srt_fib@meta.data), value = TRUE)
umap_fib <- bind_cols(umap_fib, as_tibble(srt_fib@meta.data[, score_cols_fib, drop = FALSE]))
write_csv(umap_fib, file.path(out_dir, "umap_fib.csv"))

srt_ec <- subset(srt, subset = major_type == "EC")
srt_ec <- run_harmony_umap(srt_ec, resolution = 0.6, dims_use = 1:20, npcs = 30)
srt_ec$canonical_subcluster <- factor(srt_ec$canonical_subcluster, levels = ec_levels)
umap_ec <- export_umap_csv(srt_ec, file.path(out_dir, "umap_ec.csv"))

srt_mural <- subset(srt, subset = major_type == "Mural cell")
srt_mural <- run_harmony_umap(srt_mural, resolution = 0.3, dims_use = 1:20, npcs = 30)
srt_mural$canonical_subcluster <- factor(srt_mural$canonical_subcluster, levels = mural_levels)
umap_mural <- export_umap_csv(srt_mural, file.path(out_dir, "umap_mural.csv"))

# ---- 3. DotPlot + MOESM3 DEG + small-scale DE verification tables ----
build_dotplot_table <- function(obj, group_col, marker_genes, moesm_df = NULL, is_major = FALSE) {
  avail <- intersect(unique(marker_genes), rownames(obj))
  if (length(avail) == 0) stop("No marker genes found in object!")

  Idents(obj) <- obj@meta.data[[group_col]]
  dp <- DotPlot(obj, features = avail, group.by = group_col)
  dp_df <- dp$data %>%
    as_tibble() %>%
    transmute(
      cluster = as.character(id),
      gene = as.character(features.plot),
      avg_exp = as.numeric(avg.exp),
      pct_exp = as.numeric(pct.exp),
      avg_exp_scaled = as.numeric(avg.exp.scaled)
    )

  # Small-scale FindAllMarkers verification (Wilcoxon, consistent with Methods)
  de_small <- FindAllMarkers(
    obj,
    features = avail,
    only.pos = TRUE,
    min.pct = 0.1,
    logfc.threshold = 0.25,
    verbose = FALSE
  ) %>%
    as_tibble() %>%
    transmute(
      cluster = as.character(cluster),
      gene = as.character(gene),
      small_p_val = as.numeric(p_val),
      small_avg_log2FC = as.numeric(avg_log2FC),
      small_pct_1 = as.numeric(pct.1),
      small_pct_2 = as.numeric(pct.2),
      small_p_val_adj = as.numeric(p_val_adj)
    )

  out <- dp_df %>%
    left_join(de_small, by = c("cluster", "gene"))

  if (!is.null(moesm_df)) {
    moesm_clean <- moesm_df %>%
      mutate(
        canonical_subcluster = unname(subcluster_to_canonical[as.character(cluster)]),
        cluster_key = ifelse(is.na(canonical_subcluster), as.character(cluster), canonical_subcluster)
      ) %>%
      group_by(cluster_key, gene) %>%
      slice_min(order_by = p_val_adj, n = 1, with_ties = FALSE) %>%
      ungroup() %>%
      transmute(
        cluster = cluster_key,
        gene = as.character(gene),
        moesm_p_val = as.numeric(p_val),
        moesm_avg_log2FC = as.numeric(avg_log2FC),
        moesm_pct_1 = as.numeric(pct.1),
        moesm_pct_2 = as.numeric(pct.2),
        moesm_p_val_adj = as.numeric(p_val_adj)
      )
    out <- out %>% left_join(moesm_clean, by = c("cluster", "gene"))
  }

  out %>%
    mutate(gene = factor(gene, levels = avail)) %>%
    arrange(cluster, gene) %>%
    mutate(gene = as.character(gene))
}

# Major cell types DotPlot (Fig 1 / sFig 1B markers)
major_markers <- c(
  "COL1A1", "COL1A2", "DCN", "FGF7", "MME",
  "PECAM1", "VWF", "CD34", "PLVAP",
  "ACTA2", "PDGFRB", "MCAM", "RGS5", "MYH11", "TAGLN", "MYL9"
)
srt_all$major_type <- factor(as.character(srt_all$major_type), levels = c("Fib", "EC", "Mural cell"))
dotplot_major <- build_dotplot_table(srt_all, group_col = "major_type", marker_genes = major_markers, moesm_df = NULL, is_major = TRUE)
write_csv(dotplot_major, file.path(out_dir, "dotplot_major.csv"))

# Fib markers (CAF_scRNA_integration_annotation_pipeline.R + top MOESM3 DEGs per cluster)
fib_script_markers <- c(
  "ACTA2", "TAGLN", "MYL9", "POSTN",
  "HAS1", "BAG3", "HSPA6",
  "CLEC3B", "PLA2G2A", "PI16", "CD248",
  "RORA", "BNC2", "KCND2", "PRKG1",
  "CXCL8", "CXCL3", "CXCL1",
  "CXCL2", "NFKB1", "ZSWIM6",
  "APOD", "APOE", "ITM2A", "PTGDS",
  "CCL19", "CXCL10", "CXCL9",
  "COL12A1", "COL10A1", "SULF1",
  "ABCA8", "SVEP1", "ABCA10",
  "ENO1", "TGFBI", "CA9", "PGK1",
  "CD74", "HLA-DRA", "HLA-DRB1",
  "LUM", "SFRP2", "CCN5",
  "NOTCH3", "F2R", "A2M"
)
fib_moesm_top <- deg_fib %>%
  filter(gene %in% rownames(srt_fib)) %>%
  group_by(cluster) %>%
  slice_max(order_by = avg_log2FC, n = 3, with_ties = FALSE) %>%
  pull(gene)
fib_markers_all <- unique(c(fib_script_markers, fib_moesm_top))
dotplot_fib <- build_dotplot_table(srt_fib, group_col = "canonical_subcluster", marker_genes = fib_markers_all, moesm_df = deg_fib)
write_csv(dotplot_fib, file.path(out_dir, "dotplot_fib.csv"))

# EC markers (Endo_Analysis_FullPipeline_Complete.R + top MOESM3 DEGs)
ec_script_markers <- c(
  "GJA4", "SEMA3G", "GJA5", "FBLN5",
  "NOTCH4", "NOTCH1", "DLL4", "IGFBP3", "CXCL12",
  "CD36", "RGCC", "FABP4", "FABP5", "CA4",
  "ESM1", "VWA1", "PGF", "KDR", "APLNR",
  "SELE", "MCTP1", "CNKSR3", "HIF1A",
  "ACKR1", "CD74", "CCL14", "VWF",
  "RASAL2", "DOCK4", "MAGI1",
  "CD24", "KRT19", "AZGP1",
  "ACTA2", "APOE", "COL1A1",
  "IL6", "CXCL8", "CSF3", "JUN", "FOS",
  "HMOX1", "MT1A", "CYP1A1",
  "PROX1", "LYVE1", "CCL21", "PDPN"
)
ec_moesm_top <- deg_ec %>%
  filter(gene %in% rownames(srt_ec)) %>%
  group_by(cluster) %>%
  slice_max(order_by = avg_log2FC, n = 3, with_ties = FALSE) %>%
  pull(gene)
ec_markers_all <- unique(c(ec_script_markers, ec_moesm_top))
dotplot_ec <- build_dotplot_table(srt_ec, group_col = "canonical_subcluster", marker_genes = ec_markers_all, moesm_df = deg_ec)
write_csv(dotplot_ec, file.path(out_dir, "dotplot_ec.csv"))

# Mural markers (PVL_Analysis_Final.R + top MOESM3 DEGs)
mural_script_markers <- c(
  "MYL9", "RERGL", "MUSTN1",
  "FN1", "EGFL6", "IFI27",
  "MYH11", "GADD45B", "SORBS2",
  "COL3A1", "LUM", "POSTN",
  "CCL19", "CCL21", "C1S",
  "CD74", "APOD", "AZGP1",
  "SEPT7", "H3F3A", "SEPT4",
  "PRKG1", "DLC1", "CCDC102B",
  "CXCL8", "CXCL3", "CXCL2",
  "CRYAB", "LDLR", "GJA5"
)
mural_moesm_top <- deg_mural %>%
  filter(gene %in% rownames(srt_mural)) %>%
  group_by(cluster) %>%
  slice_max(order_by = avg_log2FC, n = 3, with_ties = FALSE) %>%
  pull(gene)
mural_markers_all <- unique(c(mural_script_markers, mural_moesm_top))
dotplot_mural <- build_dotplot_table(srt_mural, group_col = "canonical_subcluster", marker_genes = mural_markers_all, moesm_df = deg_mural)
write_csv(dotplot_mural, file.path(out_dir, "dotplot_mural.csv"))

# ---- 4. Save processed Seurat objects? Not required; save receipt.json ----
elapsed_sec <- as.numeric((proc.time() - t0)[["elapsed"]])

receipt <- list(
  step = "step01_harmony_de",
  script = "src/01_scrna_harmony_de.R",
  seed = 42L,
  elapsed_seconds = round(elapsed_sec, 3),
  input_object = "data_small/scrna_stromal_small.qs",
  scale_down_boundary = paste0(
    "Stratified small-scale verification dataset: 1,800 cells (50 cells/subcluster x 36 subclusters: ",
    "14 Fib = 700 cells, 12 EC = 600 cells, 10 Mural = 500 cells) x 289 MOESM3-seeded marker/pathway genes ",
    "across 4 simulated batch cohorts (GSE161529, GSE176078, GSE195861, in_house), vs. the full paper atlas ",
    "of >200,000 stromal cells and >20,000 genes."
  ),
  counts = list(
    all = list(cells = ncol(srt_all), genes = nrow(srt_all), annotated_subclusters = length(unique(srt_all$canonical_subcluster)), harmony_louvain_clusters = length(unique(srt_all$seurat_clusters))),
    fib = list(cells = ncol(srt_fib), genes = nrow(srt_fib), annotated_subclusters = length(unique(srt_fib$canonical_subcluster)), harmony_louvain_clusters = length(unique(srt_fib$seurat_clusters))),
    ec = list(cells = ncol(srt_ec), genes = nrow(srt_ec), annotated_subclusters = length(unique(srt_ec$canonical_subcluster)), harmony_louvain_clusters = length(unique(srt_ec$seurat_clusters))),
    mural = list(cells = ncol(srt_mural), genes = nrow(srt_mural), annotated_subclusters = length(unique(srt_mural$canonical_subcluster)), harmony_louvain_clusters = length(unique(srt_mural$seurat_clusters)))
  ),
  outputs = list(
    umap_all      = list(rows = nrow(umap_all), cols = ncol(umap_all)),
    umap_fib      = list(rows = nrow(umap_fib), cols = ncol(umap_fib)),
    umap_ec       = list(rows = nrow(umap_ec), cols = ncol(umap_ec)),
    umap_mural    = list(rows = nrow(umap_mural), cols = ncol(umap_mural)),
    dotplot_major = list(rows = nrow(dotplot_major), cols = ncol(dotplot_major), genes = length(unique(dotplot_major$gene))),
    dotplot_fib   = list(rows = nrow(dotplot_fib), cols = ncol(dotplot_fib), genes = length(unique(dotplot_fib$gene)), moesm_matched_rows = sum(!is.na(dotplot_fib$moesm_avg_log2FC))),
    dotplot_ec    = list(rows = nrow(dotplot_ec), cols = ncol(dotplot_ec), genes = length(unique(dotplot_ec$gene)), moesm_matched_rows = sum(!is.na(dotplot_ec$moesm_avg_log2FC))),
    dotplot_mural = list(rows = nrow(dotplot_mural), cols = ncol(dotplot_mural), genes = length(unique(dotplot_mural$gene)), moesm_matched_rows = sum(!is.na(dotplot_mural$moesm_avg_log2FC)))
  ),
  parameters = list(
    normalization = "LogNormalize (scale.factor = 10000)",
    scale_vars_to_regress = "nCount_RNA",
    pca_npcs = 30L,
    harmony_group_by = "batch",
    harmony_dims = "1:20",
    umap_dims = "1:20",
    neighbor_k = 30L,
    resolutions = list(all = 0.9, fib = 0.6, ec = 0.6, mural = 0.3)
  )
)

write_json(receipt, file.path(out_dir, "receipt.json"), auto_unbox = TRUE, pretty = TRUE)
cat("Step 01 completed in", round(elapsed_sec, 2), "seconds.\n")
