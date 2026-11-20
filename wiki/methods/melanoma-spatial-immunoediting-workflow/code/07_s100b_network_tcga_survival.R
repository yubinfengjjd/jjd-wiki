#!/usr/bin/env Rscript
# Step 07: S100B co-expression network (Fig 6I, 6J) from PickSeq log2 normalized counts
# and TCGA-SKCM survival analysis (Fig S6F) via survival::survfit/survdiff/coxph.

suppressPackageStartupMessages({
  rwiki_libs <- Sys.getenv("RWIKI_R_LIBS", ""); if (nzchar(rwiki_libs)) .libPaths(c(strsplit(rwiki_libs, .Platform$path.sep)[[1]], .libPaths()))))
  library(survival)
  library(igraph)
  library(jsonlite)
})

set.seed(42)
t0 <- proc.time()[["elapsed"]]

root <- "."
small_dir <- file.path(root, "data_small")
step06_dir <- file.path(root, "runs", "step06_mrseq_deseq2")
out_dir <- file.path(root, "runs", "step07_network_survival")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("[step07] Loading DESeq2 symbol-mapped log2 normalized counts and mROI metadata...\n")
log2_norm <- as.matrix(read.csv(file.path(step06_dir, "deseq2_log2_norm_counts_symbol.csv"), row.names = 1, check.names = FALSE))
meta <- read.csv(file.path(small_dir, "mrseq_meta_small.csv"), stringsAsFactors = FALSE)
rownames(meta) <- meta$sample_id
log2_norm <- log2_norm[, meta$sample_id, drop = FALSE]

# Load Table S6 S100B module reference column if available
s6_ref_path <- file.path(step06_dir, "table_s6_mis_vs_emim_ref.csv")
s6_s100b_ref <- character(0)
if (file.exists(s6_ref_path)) {
  s6_df <- read.csv(s6_ref_path, stringsAsFactors = FALSE, check.names = FALSE)
  col_mod <- grep("S100B", colnames(s6_df), value = TRUE)
  if (length(col_mod) > 0) {
    s6_s100b_ref <- unique(s6_df$gene_symbol[toupper(trimws(as.character(s6_df[[col_mod[1]]]))) == "YES"])
  }
}

# 1. Exact S100B Pearson correlation across all genes (memory-safe vector dot product)
cat("[step07] Computing S100B 1-step co-expression neighborhood (r >= 0.6)...\n")
row_sd <- apply(log2_norm, 1, sd, na.rm = TRUE)
valid_idx <- which(!is.na(row_sd) & row_sd > 0)
mat_v <- log2_norm[valid_idx, , drop = FALSE]
sd_v <- row_sd[valid_idx]
z_all <- sweep(mat_v, 1, rowMeans(mat_v), "-")
z_all <- sweep(z_all, 1, sd_v, "/")

if (!("S100B" %in% rownames(z_all))) {
  stop("S100B not found in deseq2_log2_norm_counts_symbol.csv")
}

n_mroi <- ncol(z_all)
r_s100b <- as.numeric(z_all %*% z_all["S100B", ]) / (n_mroi - 1)
names(r_s100b) <- rownames(z_all)
r_s100b_sorted <- sort(r_s100b, decreasing = TRUE)

s100b_neighbors <- names(r_s100b_sorted)[r_s100b_sorted >= 0.6 & names(r_s100b_sorted) != "S100B"]
s100b_module <- unique(c("S100B", s100b_neighbors))

# Export S100B correlation table (top 150 + all r >= 0.6 + Table S6 ref genes)
top_genes <- unique(c(s100b_module, names(r_s100b_sorted)[1:min(150, length(r_s100b_sorted))], intersect(s6_s100b_ref, names(r_s100b))))
s100b_cor_df <- data.frame(
  gene_symbol = top_genes,
  pearson_r_with_S100B = round(unname(r_s100b[top_genes]), 5),
  in_local_r06_module = top_genes %in% s100b_module,
  in_table_s6_module = top_genes %in% s6_s100b_ref,
  stringsAsFactors = FALSE
)
s100b_cor_df <- s100b_cor_df[order(-s100b_cor_df$pearson_r_with_S100B), ]
write.csv(s100b_cor_df, file.path(out_dir, "fig6i_s100b_neighbors.csv"), row.names = FALSE)

# 2. Induced & broader expressed co-expression graph (r >= 0.6) for Fig 6I
# Filter to expressed genes (mean log2 >= 1.5, non-zero in >= 15 mROIs, sd >= 0.4) plus s100b_module & Table S6 ref
cat("[step07] Constructing co-expression graph (r >= 0.6) among expressed variable genes...\n")
rmean <- rowMeans(mat_v)
n_det <- rowSums(mat_v > 0)
keep_net <- (rmean >= 1.5 & n_det >= 15 & sd_v >= 0.4) | (rownames(mat_v) %in% c(s100b_module, s6_s100b_ref))
z_net <- z_all[keep_net, , drop = FALSE]
# Cap at top 5000 by sd if larger, while retaining all s100b_module + s6_s100b_ref
if (nrow(z_net) > 5000) {
  must_keep <- rownames(z_net) %in% c(s100b_module, s6_s100b_ref)
  rem <- setdiff(rownames(z_net), rownames(z_net)[must_keep])
  rem_ord <- rem[order(sd_v[rem], decreasing = TRUE)][1:(5000 - sum(must_keep))]
  z_net <- z_net[c(rownames(z_net)[must_keep], rem_ord), , drop = FALSE]
}
cat(sprintf("[step07] Computing correlation matrix on %d expressed genes...\n", nrow(z_net)))
cor_mat <- tcrossprod(z_net) / (n_mroi - 1)
diag(cor_mat) <- 0

# Extract edges r >= 0.6
idx_upper <- which(cor_mat >= 0.6 & upper.tri(cor_mat), arr.ind = TRUE)
g_names <- rownames(cor_mat)
edges_all <- data.frame(
  from = g_names[idx_upper[, 1]],
  to = g_names[idx_upper[, 2]],
  weight = round(cor_mat[idx_upper], 4),
  stringsAsFactors = FALSE
)

# Restrict to connected component containing S100B (or 2-hop neighborhood around S100B if giant component)
g_full <- graph_from_data_frame(edges_all, directed = FALSE)
if ("S100B" %in% V(g_full)$name) {
  comp <- components(g_full)
  s100b_cid <- comp$membership["S100B"]
  comp_nodes <- names(comp$membership)[comp$membership == s100b_cid]
  # Also export 2-hop S100B subgraph for clear visual Fig 6I rendering if component > 300 nodes
  hop2_nodes <- names(unlist(ego(g_full, order = 2, nodes = "S100B")))
  if (length(comp_nodes) <= 250) {
    plot_nodes <- comp_nodes
    graph_scope <- "s100b_connected_component"
  } else {
    hop1_nodes <- names(unlist(ego(g_full, order = 1, nodes = "S100B")))
    plot_nodes <- if (length(hop2_nodes) <= 250) hop2_nodes else hop1_nodes
    graph_scope <- if (length(hop2_nodes) <= 250) "s100b_2hop_subgraph" else "s100b_1hop_subgraph"
  }
} else {
  plot_nodes <- s100b_module
  graph_scope <- "s100b_1hop_fallback"
}

g_sub <- induced_subgraph(g_full, vids = intersect(plot_nodes, V(g_full)$name))
# Compute deterministic Fruchterman-Reingold layout coordinates for plotting scripts
lay <- layout_with_fr(g_sub)
key_labels <- c("S100B", "SERPINE2", "CTSL", "ETV5", "SCD", "NRP2", "TBC1D7", "PMEL", "SOX10", "TYR", "MITF", "MLANA")
nodes_df <- data.frame(
  gene_symbol = V(g_sub)$name,
  x = round(lay[, 1], 4),
  y = round(lay[, 2], 4),
  degree = degree(g_sub),
  pearson_r_S100B = round(unname(r_s100b[V(g_sub)$name]), 4),
  in_s100b_1step = V(g_sub)$name %in% s100b_module,
  in_table_s6_module = V(g_sub)$name %in% s6_s100b_ref,
  is_key_label = V(g_sub)$name %in% key_labels,
  stringsAsFactors = FALSE
)
edges_sub <- as_data_frame(g_sub, what = "edges")
write.csv(nodes_df, file.path(out_dir, "fig6i_network_nodes.csv"), row.names = FALSE)
write.csv(edges_sub, file.path(out_dir, "fig6i_network_edges.csv"), row.names = FALSE)
rm(cor_mat, z_net)
gc()

# 3. Fig 6J: S100B module expression profile across all 120 mROIs
cat("[step07] Computing Fig 6J S100B module expression curve across 120 mROIs...\n")
mod_genes_use <- if (length(s100b_module) >= 5) s100b_module else intersect(s6_s100b_ref, rownames(log2_norm))
mod_mat <- log2_norm[mod_genes_use, meta$sample_id, drop = FALSE]
mod_z <- t(scale(t(mod_mat)))
curve_df <- data.frame(
  sample_id = meta$sample_id,
  site = as.character(meta$site),
  slide_id = as.character(meta$slide_id),
  mean_log2_norm = round(colMeans(mod_mat, na.rm = TRUE), 4),
  mean_zscore = round(colMeans(mod_z, na.rm = TRUE), 4),
  s100b_log2 = round(as.numeric(log2_norm["S100B", meta$sample_id]), 4),
  stringsAsFactors = FALSE
)
curve_df <- curve_df[order(curve_df$mean_log2_norm), ]
curve_df$rank_order <- seq_len(nrow(curve_df))
write.csv(curve_df, file.path(out_dir, "fig6j_s100b_module_curve.csv"), row.names = FALSE)

# 4. Fig S6F: TCGA-SKCM Kaplan-Meier & Cox survival analysis
cat("[step07] Running TCGA-SKCM survival analysis (Fig S6F)...\n")
tcga <- read.csv(file.path(small_dir, "tcga_skcm_s100b_120.csv"), stringsAsFactors = FALSE)
tcga_genes <- intersect(c("BRI3", "CDK2", "PMEL", "SOX10", "TBC1D7", "TSPAN10", "TYR", "S100B"), colnames(tcga))
missing_tcga_genes <- setdiff(c("BRI3", "CDK2", "MT-ND2", "PMEL", "SOX10", "TBC1D7", "TSPAN10", "TYR", "S100B"), tcga_genes)

km_rows <- list()
stat_rows <- list()

for (g in tcga_genes) {
  sub <- tcga[!is.na(tcga[[g]]) & !is.na(tcga$OS.time) & !is.na(tcga$OS) & tcga$OS.time > 0, ]
  med <- median(sub[[g]], na.rm = TRUE)
  sub$group <- factor(ifelse(sub[[g]] >= med, "High", "Low"), levels = c("Low", "High"))
  sub$time_years <- sub$OS.time / 365.25

  sf <- survfit(Surv(time_years, OS) ~ group, data = sub)
  sd_test <- survdiff(Surv(time_years, OS) ~ group, data = sub)
  lr_p <- 1 - pchisq(sd_test$chisq, df = length(sd_test$n) - 1)
  cx <- coxph(Surv(time_years, OS) ~ group, data = sub)
  cx_sum <- summary(cx)
  hr <- cx_sum$conf.int[1, "exp(coef)"]
  hr_low <- cx_sum$conf.int[1, "lower .95"]
  hr_high <- cx_sum$conf.int[1, "upper .95"]
  cox_p <- cx_sum$coefficients[1, "Pr(>|z|)"]

  stat_rows[[g]] <- data.frame(
    gene = g,
    n_samples = nrow(sub),
    n_events = sum(sub$OS == 1),
    n_high = sum(sub$group == "High"),
    n_low = sum(sub$group == "Low"),
    median_expr = round(med, 4),
    logrank_chisq = round(sd_test$chisq, 4),
    logrank_p = signif(lr_p, 4),
    cox_hr_high_vs_low = round(hr, 4),
    cox_hr_ci95_low = round(hr_low, 4),
    cox_hr_ci95_high = round(hr_high, 4),
    cox_p = signif(cox_p, 4),
    stringsAsFactors = FALSE
  )

  # Extract KM step data per stratum
  s_names <- names(sf$strata)
  idx_start <- 1
  for (i in seq_along(sf$strata)) {
    k <- sf$strata[i]
    idx <- idx_start:(idx_start + k - 1)
    idx_start <- idx_start + k
    grp_lbl <- sub("^group=", "", s_names[i])
    km_rows[[length(km_rows) + 1]] <- data.frame(
      gene = g,
      group = grp_lbl,
      time_years = c(0, sf$time[idx]),
      surv = c(1, sf$surv[idx]),
      lower = c(1, sf$lower[idx]),
      upper = c(1, sf$upper[idx]),
      n_risk = c(sf$n[i], sf$n.risk[idx]),
      n_event = c(0, sf$n.event[idx]),
      n_censor = c(0, sf$n.censor[idx]),
      stringsAsFactors = FALSE
    )
  }
}

km_df <- do.call(rbind, km_rows)
stat_df <- do.call(rbind, stat_rows)
write.csv(km_df, file.path(out_dir, "figs6f_tcga_km_curves.csv"), row.names = FALSE)
write.csv(stat_df, file.path(out_dir, "figs6f_tcga_survival_stats.csv"), row.names = FALSE)

overlap_s6 <- intersect(s100b_module, s6_s100b_ref)
elapsed <- round(proc.time()[["elapsed"]] - t0, 2)
summary_obj <- list(
  step = "07_s100b_network_tcga_survival",
  n_mrois = n_mroi,
  n_genes_tested = nrow(z_all),
  s100b_1step_module_size = length(s100b_module),
  table_s6_s100b_module_size = length(s6_s100b_ref),
  overlap_with_table_s6_module = length(overlap_s6),
  overlap_genes = overlap_s6,
  graph_scope = graph_scope,
  fig6i_exported_nodes = nrow(nodes_df),
  fig6i_exported_edges = nrow(edges_sub),
  fig6j_module_genes_used = length(mod_genes_use),
  tcga_n_samples = nrow(tcga),
  tcga_genes_tested = tcga_genes,
  tcga_genes_missing_in_hiseqv2 = missing_tcga_genes,
  tcga_survival_summary = stat_df,
  elapsed_sec = elapsed
)
write_json(summary_obj, file.path(out_dir, "step07_summary.json"), auto_unbox = TRUE, pretty = TRUE)
cat(sprintf("[step07] Done in %.2fs -> %s\n", elapsed, out_dir))

rm(list = ls())
gc()
