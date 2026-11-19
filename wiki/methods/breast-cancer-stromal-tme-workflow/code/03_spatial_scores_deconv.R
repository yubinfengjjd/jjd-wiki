# 03_spatial_scores_deconv.R
# Spatial transcriptomics cell-type weighting, module scoring, and spatial zone annotation
# Input:
#   - data_small/st/caa_st_spots_scores.csv (2,241 Visium spots from Zenodo 19562239 CAA_ST-umap.qs)
#   - data_small/st/caa_st_scored.qs
#   - data_small/moesm/deg_fib.csv (for 14 Fib subcluster spatial signatures in Fig 2J)
# Output (runs/step03_spatial/):
#   - st_spots_fig2j.csv
#   - st_spots_fig3be.csv
#   - st_spots_fig4j.csv
#   - st_spots_fig6degh.csv
#   - st_spots_sfig3.csv
#   - st_spots_sfig6abc.csv
#   - receipt.json

r_libs <- strsplit(Sys.getenv("RWIKI_R_LIBS", ""), .Platform$path.sep)[[1]]
r_libs <- r_libs[nzchar(r_libs)]
if (length(r_libs)) {
  .libPaths(unique(c(r_libs, .libPaths())))
}
suppressPackageStartupMessages({
  library(Seurat)
  library(qs)
  library(dplyr)
  library(readr)
  library(jsonlite)
  library(tibble)
})

t0 <- proc.time()[["elapsed"]]
set.seed(42)

paper_root <- Sys.getenv("PAPER_ROOT", ".")
paper_dir <- paper_root
st_csv_path <- file.path(paper_dir, "data_small", "st", "caa_st_spots_scores.csv")
st_qs_path  <- file.path(paper_dir, "data_small", "st", "caa_st_scored.qs")
deg_fib_path <- file.path(paper_dir, "data_small", "moesm", "deg_fib.csv")
out_dir <- file.path(paper_dir, "runs", "step03_spatial")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Check spacexr / RCTD availability honestly
has_spacexr <- requireNamespace("spacexr", quietly = TRUE)
has_rctd    <- requireNamespace("RCTD", quietly = TRUE)
rctd_status <- if (has_spacexr || has_rctd) {
  "available"
} else {
  "not_run (spacexr not compiled)"
}
cat("RCTD / spacexr status:", rctd_status, "\n")

# Load pre-scored spot CSV and real Visium Seurat object
st_df  <- read_csv(st_csv_path, show_col_types = FALSE)
st_obj <- qread(st_qs_path)
DefaultAssay(st_obj) <- "Spatial"

# Extract additional genes needed for Fig 2J / Fig 3E / Fig 6 / SFig 6 directly from normalized Spatial assay
req_genes <- c("COL1A1", "COL1A2", "DCN", "ABCA8", "CCL19", "CXCL13",
               "CD8A", "CD79A", "CD19", "CD3E", "HAVCR2", "CD86", "CTLA4",
               "CCL14", "CCR1", "PGF", "CCR7", "LGALS9", "FLT1")
avail_genes <- rownames(st_obj)
present_genes <- intersect(req_genes, avail_genes)
missing_genes <- setdiff(req_genes, avail_genes)
cat("Spatial genes present:", length(present_genes), "/", length(req_genes),
    "| missing:", ifelse(length(missing_genes) == 0, "none", paste(missing_genes, collapse = ", ")), "\n")

expr_mat <- as.matrix(GetAssayData(st_obj, assay = "Spatial", layer = "data")[present_genes, , drop = FALSE])
expr_extra <- as.data.frame(t(expr_mat)) %>% rownames_to_column("spot")
for (mg in missing_genes) {
  expr_extra[[mg]] <- NA_real_
}

# Merge with spot metadata/scores (avoid duplicate gene columns)
non_gene_cols <- setdiff(colnames(st_df), colnames(expr_extra)[-1])
st_merged <- st_df[, non_gene_cols, drop = FALSE] %>%
  left_join(expr_extra, by = "spot")

# Compute 14 Fib subcluster spatial scores for Fig 2J using top 10 MOESM3 Fib DEGs
deg_fib <- read_csv(deg_fib_path, show_col_types = FALSE)
fib_clusters <- c(
  "C1_Fib_ACTA2", "C2_Fib_HSPA6", "C3_Fib_PLA2G2A", "C4_Fib_BNC2",
  "C5_Fib_CXCL8", "C6_Fib_NFKB1", "C7_Fib_APOD", "C8_Fib_CCL19",
  "C9_Fib_COL12A1", "C10_Fib_ABCA8", "C11_Fib_ENO1", "C12_Fib_CD74",
  "C13_Fib_LUM", "C14_Fib_A2M"
)

fib_sub_scores <- tibble(spot = colnames(st_obj))
for (cl in fib_clusters) {
  gs <- deg_fib %>%
    filter(cluster == cl, p_val_adj < 0.05, avg_log2FC > 0.5) %>%
    slice_max(order_by = avg_log2FC, n = 10, with_ties = FALSE) %>%
    pull(gene) %>%
    intersect(avail_genes)
  if (length(gs) >= 2) {
    tmp_obj <- AddModuleScore(st_obj, features = list(gs), name = paste0("tmp_", cl), ctrl = 50, verbose = FALSE)
    fib_sub_scores[[paste0("score_", cl)]] <- tmp_obj@meta.data[[paste0("tmp_", cl, "1")]]
  } else {
    fib_sub_scores[[paste0("score_", cl)]] <- NA_real_
  }
}

st_merged <- st_merged %>% left_join(fib_sub_scores, by = "spot")

# Non-negative signature-based spatial cell-type weighting (fallback for RCTD full-mode)
# Uses all 16 cell-type signature scores (excluding aggregate score_Fib_core to avoid double counting)
ct_score_cols <- c(
  "score_C10_lpFib_ABCA8", "score_C8_iFib_CCL19",
  "score_C4_TipEC_PGF", "score_C5_VenEC_HIF1A", "score_C9_emtEC_COL1A1",
  "score_Tumor_cell", "score_CD8_Cytotoxic_T", "score_Exhausted_T",
  "score_CD4_Effector_T", "score_CD4_Exhausted_T", "score_Treg",
  "score_Transitory_T", "score_M1", "score_M2", "score_GC_B", "score_Memory_B"
)

score_mat <- as.matrix(st_merged[, ct_score_cols, drop = FALSE])
# Shift each signature by its 5th percentile and clip at 0 so weights are strictly non-negative, then L1-normalize per spot
nn_mat <- apply(score_mat, 2, function(v) pmax(v - as.numeric(quantile(v, 0.05, na.rm = TRUE)), 0))
row_sums <- rowSums(nn_mat)
row_sums[row_sums == 0] <- 1e-6
weight_mat <- sweep(nn_mat, 1, row_sums, "/")
colnames(weight_mat) <- sub("^score_", "weight_", ct_score_cols)

st_all <- bind_cols(st_merged, as_tibble(weight_mat))

# Fig 3E spatial zone classification (Methods criterion: top 25% of ABCA8+ lpFib and top 25% of Exhausted T / T cells)
q75_abca8 <- as.numeric(quantile(st_all$weight_C10_lpFib_ABCA8, 0.75, na.rm = TRUE))
# Composite T-cell exhaustion/T-cell abundance score using Exhausted_T + CD8_Cytotoxic_T + CD4_Exhausted_T weights
st_all <- st_all %>%
  mutate(
    weight_Tcell_composite = weight_Exhausted_T + weight_CD8_Cytotoxic_T + weight_CD4_Exhausted_T,
    score_Tcell_composite  = (score_Exhausted_T + score_CD8_Cytotoxic_T + score_CD4_Exhausted_T) / 3,
    abca8_high = weight_C10_lpFib_ABCA8 >= q75_abca8,
    tcell_high = weight_Tcell_composite >= as.numeric(quantile(weight_Tcell_composite, 0.75, na.rm = TRUE)),
    spatial_zone_fig3e = case_when(
      abca8_high & tcell_high ~ "ABCA8_lpFib_Tcell_joint_high",
      abca8_high & !tcell_high ~ "ABCA8_lpFib_high_only",
      !abca8_high & tcell_high ~ "Tcell_high_only",
      TRUE ~ "Other_low"
    ),
    score_TAM = (score_M1 + score_M2) / 2,
    weight_TAM = weight_M1 + weight_M2,
    LR_CD86_CTLA4   = sqrt(pmax(CD86, 0) * pmax(CTLA4, 0)),
    LR_LGALS9_HAVCR2 = ifelse(is.na(LGALS9), NA_real_, sqrt(pmax(LGALS9, 0) * pmax(HAVCR2, 0))),
    LR_CCL19_CCR7   = sqrt(pmax(CCL19, 0) * pmax(CCR7, 0)),
    LR_CCL14_CCR1   = sqrt(pmax(CCL14, 0) * pmax(CCR1, 0))
  )

# Export Fig 2J table
fig2j_cols <- c("spot", "imagecol", "imagerow", "nCount_Spatial",
                "score_Fib_core", paste0("score_", fib_clusters))
df_fig2j <- st_all[, fig2j_cols]
write_csv(df_fig2j, file.path(out_dir, "st_spots_fig2j.csv"))

# Export Fig 3B & 3E table
fig3be_cols <- c(
  "spot", "imagecol", "imagerow", "nCount_Spatial",
  "score_Tumor_cell", "score_C10_lpFib_ABCA8", "score_CD8_Cytotoxic_T", "score_Exhausted_T",
  "score_Tcell_composite",
  "weight_Tumor_cell", "weight_C10_lpFib_ABCA8", "weight_CD8_Cytotoxic_T", "weight_Exhausted_T",
  "weight_Tcell_composite",
  "abca8_high", "tcell_high", "spatial_zone_fig3e",
  "ABCA8", "CD8A", "CD3E", "HAVCR2", "CD86", "CTLA4", "LGALS9",
  "LR_CD86_CTLA4", "LR_LGALS9_HAVCR2"
)
df_fig3be <- st_all[, fig3be_cols]
write_csv(df_fig3be, file.path(out_dir, "st_spots_fig3be.csv"))

# Export Fig 4J table
fig4j_cols <- c(
  "spot", "imagecol", "imagerow", "nCount_Spatial",
  "score_C4_TipEC_PGF", "score_C5_VenEC_HIF1A", "score_C9_emtEC_COL1A1",
  "weight_C4_TipEC_PGF", "weight_C5_VenEC_HIF1A", "weight_C9_emtEC_COL1A1",
  "PGF"
)
df_fig4j <- st_all[, fig4j_cols]
write_csv(df_fig4j, file.path(out_dir, "st_spots_fig4j.csv"))

# Export Fig 6D, 6E, 6G, 6H table
fig6degh_cols <- c(
  "spot", "imagecol", "imagerow", "nCount_Spatial",
  "score_C8_iFib_CCL19", "score_CD8_Cytotoxic_T", "score_GC_B", "score_Memory_B",
  "score_C4_TipEC_PGF", "score_M1", "score_M2", "score_TAM",
  "weight_C8_iFib_CCL19", "weight_CD8_Cytotoxic_T", "weight_GC_B", "weight_Memory_B",
  "weight_C4_TipEC_PGF", "weight_M1", "weight_M2", "weight_TAM",
  "CD19", "CD79A", "CCL19", "CXCL13", "CCL14", "CCR1", "PGF", "LR_CCL14_CCR1"
)
df_fig6degh <- st_all[, fig6degh_cols]
write_csv(df_fig6degh, file.path(out_dir, "st_spots_fig6degh.csv"))

# Export SFig 3 table
sfig3_cols <- c(
  "spot", "imagecol", "imagerow", "nCount_Spatial",
  "COL1A1", "COL1A2", "DCN", "ABCA8", "CD8A",
  "score_Fib_core", "score_C10_lpFib_ABCA8", "score_CD8_Cytotoxic_T",
  "weight_C10_lpFib_ABCA8", "weight_CD8_Cytotoxic_T"
)
df_sfig3 <- st_all[, sfig3_cols]
write_csv(df_sfig3, file.path(out_dir, "st_spots_sfig3.csv"))

# Export SFig 6A, 6B, 6C table
sfig6abc_cols <- c(
  "spot", "imagecol", "imagerow", "nCount_Spatial",
  "score_C8_iFib_CCL19", "score_C4_TipEC_PGF", "score_M1", "score_M2",
  "score_CD4_Effector_T", "score_CD4_Exhausted_T", "score_CD8_Cytotoxic_T",
  "score_Treg", "score_Transitory_T",
  "CCL19", "CCR7", "LR_CCL19_CCR7",
  "CD8A", "CD79A", "CD19", "CD3E"
)
df_sfig6abc <- st_all[, sfig6abc_cols]
write_csv(df_sfig6abc, file.path(out_dir, "st_spots_sfig6abc.csv"))

elapsed <- round(proc.time()[["elapsed"]] - t0, 3)

zone_counts <- as.list(table(st_all$spatial_zone_fig3e))
outputs_list <- list(
  st_spots_fig2j.csv   = list(path = file.path(out_dir, "st_spots_fig2j.csv"),   rows = nrow(df_fig2j),   cols = ncol(df_fig2j)),
  st_spots_fig3be.csv  = list(path = file.path(out_dir, "st_spots_fig3be.csv"),  rows = nrow(df_fig3be),  cols = ncol(df_fig3be)),
  st_spots_fig4j.csv   = list(path = file.path(out_dir, "st_spots_fig4j.csv"),   rows = nrow(df_fig4j),   cols = ncol(df_fig4j)),
  st_spots_fig6degh.csv= list(path = file.path(out_dir, "st_spots_fig6degh.csv"),rows = nrow(df_fig6degh),cols = ncol(df_fig6degh)),
  st_spots_sfig3.csv   = list(path = file.path(out_dir, "st_spots_sfig3.csv"),   rows = nrow(df_sfig3),   cols = ncol(df_sfig3)),
  st_spots_sfig6abc.csv= list(path = file.path(out_dir, "st_spots_sfig6abc.csv"),rows = nrow(df_sfig6abc),cols = ncol(df_sfig6abc))
)

receipt <- list(
  step = "step03_spatial",
  script = "src/03_spatial_scores_deconv.R",
  seed = 42L,
  status = "completed",
  rctd_status = rctd_status,
  fallback_method = "Non-negative 5th-percentile-shifted L1-normalized signature weighting across 16 cell types on real Visium Spatial normalized data",
  scale_down_boundary = "Single real Visium sample (CAA_ST, n = 2,241 spots from Zenodo 19562239) used instead of 8 in-house ST slides; LGALS9 and FLT1 absent in CAA_ST-umap.qs gene matrix (recorded as NA).",
  n_spots = nrow(st_all),
  spatial_genes_present = present_genes,
  spatial_genes_missing = missing_genes,
  fig3e_zone_counts = zone_counts,
  outputs = outputs_list,
  elapsed_seconds = elapsed
)

write_json(receipt, file.path(out_dir, "receipt.json"), pretty = TRUE, auto_unbox = TRUE)
cat("Step 03 completed in", elapsed, "sec. Outputs written to", out_dir, "\n")
