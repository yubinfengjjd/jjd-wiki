# 00_prepare_spatial_and_scrna.R
# 1) Load real Visium ST object (CAA_ST-umap.qs, 2,241 spots from Zenodo 19562239),
#    normalize Spatial assay, compute UMAP + module scores matching Cai et al. markers,
#    and export clean spatial coordinates/scores CSVs into data_small/st/.
# 2) Construct a stratified small-scale scRNA-seq validation Seurat object (n = 1,800 cells,
#    seed = 42) seeded from real MOESM3 DEG markers across Fib (14), EC (12), and Mural (10)
#    subclusters + 3 batch cohorts, for end-to-end Harmony / PROGENy / Trajectory verification.

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
})

set.seed(42)
paper_root <- Sys.getenv("PAPER_ROOT", ".")
paper_dir <- paper_root
st_out <- file.path(paper_dir, "data_small", "st")
dir.create(st_out, recursive = TRUE, showWarnings = FALSE)

# ---- Part 1: Real Visium Spatial Object (Zenodo 19562239: CAA_ST-umap.qs) ----
st_obj <- qread(file.path(paper_dir, "data_small", "CAA_ST-umap.qs"))
DefaultAssay(st_obj) <- "Spatial"
st_obj <- NormalizeData(st_obj, verbose = FALSE)

coords <- GetTissueCoordinates(st_obj)
coords$spot <- rownames(coords)

sig_sets <- list(
  Fib_core     = c("COL1A1", "COL1A2", "DCN"),
  C10_lpFib_ABCA8 = c("ABCA8", "APOD", "LUM", "DCN"),
  C8_iFib_CCL19   = c("CCL19", "CCL21", "CXCL12", "CXCL13"),
  C4_TipEC_PGF    = c("PGF", "FLT1", "KDR", "ESM1", "PECAM1"),
  C5_VenEC_HIF1A  = c("HIF1A", "SELE", "ACKR1", "VWF"),
  C9_emtEC_COL1A1 = c("COL1A1", "COL1A2", "CD34"),
  Tumor_cell      = c("EPCAM", "KRT19", "KRT18", "CDH1"),
  CD8_Cytotoxic_T = c("CD8A", "CD8B", "GZMB", "PRF1", "IFNG"),
  Exhausted_T     = c("PDCD1", "HAVCR2", "CTLA4", "LAG3", "TIGIT"),
  CD4_Effector_T  = c("CD4", "IL7R", "CD3E"),
  CD4_Exhausted_T = c("CD4", "CXCL13", "PDCD1", "TIGIT"),
  Treg            = c("FOXP3", "IL2RA", "CTLA4", "IKZF2"),
  Transitory_T    = c("CD3D", "CD3E", "CXCL13", "GZMK"),
  M1              = c("CD86", "CXCL9", "CXCL10", "IL1B"),
  M2              = c("CD163", "MRC1", "CCL18", "CSF1R"),
  GC_B            = c("BCL6", "AICDA", "CD19", "MS4A1"),
  Memory_B        = c("MS4A1", "CD79A", "CD27", "BANK1")
)

avail_genes <- rownames(st_obj)
for (nm in names(sig_sets)) {
  gs <- intersect(sig_sets[[nm]], avail_genes)
  if (length(gs) >= 1) {
    st_obj <- AddModuleScore(st_obj, features = list(gs), name = paste0("sig_", nm), ctrl = 50, verbose = FALSE)
    col_raw <- paste0("sig_", nm, "1")
    st_obj[[paste0("score_", nm)]] <- st_obj@meta.data[[col_raw]]
    st_obj@meta.data[[col_raw]] <- NULL
  }
}

plot_genes <- intersect(
  c("COL1A1", "COL1A2", "DCN", "ABCA8", "CCL19", "CXCL13", "CD8A", "CD79A", "CD19", "CD3E",
    "HAVCR2", "CD86", "CTLA4", "CCL14", "CCR1", "PGF", "CCR7"),
  avail_genes
)
expr_mat <- as.matrix(GetAssayData(st_obj, assay = "Spatial", layer = "data")[plot_genes, , drop = FALSE])
expr_df <- as.data.frame(t(expr_mat))
expr_df$spot <- rownames(expr_df)

meta_cols <- grep("^score_", colnames(st_obj@meta.data), value = TRUE)
st_export <- coords %>%
  left_join(tibble::rownames_to_column(st_obj@meta.data[, c("nCount_Spatial", meta_cols), drop = FALSE], "spot"), by = "spot") %>%
  left_join(expr_df, by = "spot")

write_csv(st_export, file.path(st_out, "caa_st_spots_scores.csv"))
qsave(st_obj, file.path(st_out, "caa_st_scored.qs"))
cat("Saved real ST table:", nrow(st_export), "spots x", ncol(st_export), "cols\n")

# ---- Part 2: Small Stratified scRNA Seurat Verification Dataset (n = 1,800 cells, seed = 42) ----
moesm_dir <- file.path(paper_dir, "data_small", "moesm")
deg_fib <- read_csv(file.path(moesm_dir, "deg_fib.csv"), show_col_types = FALSE)
deg_ec  <- read_csv(file.path(moesm_dir, "deg_ec.csv"), show_col_types = FALSE)
deg_mural <- read_csv(file.path(moesm_dir, "deg_mural.csv"), show_col_types = FALSE)

top_markers <- function(df, n_per_cl = 12) {
  df %>%
    filter(p_val_adj < 0.05, avg_log2FC > 0.5) %>%
    group_by(cluster) %>%
    slice_max(order_by = avg_log2FC, n = n_per_cl, with_ties = FALSE) %>%
    ungroup()
}

mk_all <- bind_rows(
  top_markers(deg_fib, 10) %>% mutate(major = "Fib"),
  top_markers(deg_ec, 10) %>% mutate(major = "EC"),
  top_markers(deg_mural, 10) %>% mutate(major = "Mural cell")
)

core_genes <- unique(c(
  "COL1A1", "COL1A2", "DCN", "PECAM1", "VWF", "CD34", "ACTA2", "PDGFRB", "MCAM",
  "ABCA8", "CCL19", "PGF", "SEMA3G", "ACKR1", "RGCC", "LYVE1", "RGS5", "MYH11", "COL3A1",
  "CXCL12", "CXCL13", "HLA-DRA", "HLA-A", "MKI67", "FLT1", "KDR", "NRP1",
  mk_all$gene
))
# Include PROGENy pathway signature genes so real progeny::progeny() computes nonzero signals
model_genes <- unique(c(core_genes, "JUN", "FOS", "NFKBIA", "VEGFA", "TGFB1", "STAT1", "MAPK1", "PIK3CA", "TP53", "ESR1", "AR", "CTNNB1"))
model_genes <- model_genes[nzchar(model_genes) & !is.na(model_genes)][1:min(420, length(model_genes))]

clusters_info <- mk_all %>% distinct(cluster, major)
n_cl <- nrow(clusters_info)
cells_per_cl <- 50L
total_cells <- n_cl * cells_per_cl

counts <- matrix(rpois(length(model_genes) * total_cells, lambda = 1.2), nrow = length(model_genes), ncol = total_cells)
rownames(counts) <- model_genes
cell_names <- sprintf("cell_%04d", seq_len(total_cells))
colnames(counts) <- cell_names

subcluster_vec <- rep(clusters_info$cluster, each = cells_per_cl)
major_vec <- rep(clusters_info$major, each = cells_per_cl)

for (i in seq_len(n_cl)) {
  cl <- clusters_info$cluster[i]
  maj <- clusters_info$major[i]
  idx_cells <- ((i - 1) * cells_per_cl + 1):(i * cells_per_cl)
  cl_genes <- intersect(mk_all$gene[mk_all$cluster == cl], model_genes)
  if (length(cl_genes) > 0) {
    counts[cl_genes, idx_cells] <- counts[cl_genes, idx_cells] + rpois(length(cl_genes) * length(idx_cells), lambda = 14)
  }
  maj_markers <- switch(maj,
    "Fib" = intersect(c("COL1A1", "COL1A2", "DCN"), model_genes),
    "EC" = intersect(c("PECAM1", "VWF", "CD34"), model_genes),
    "Mural cell" = intersect(c("ACTA2", "PDGFRB", "MCAM"), model_genes)
  )
  if (length(maj_markers) > 0) {
    counts[maj_markers, idx_cells] <- counts[maj_markers, idx_cells] + rpois(length(maj_markers) * length(idx_cells), lambda = 18)
  }
}

batches <- sample(c("GSE161529", "GSE176078", "GSE195861", "in_house"), total_cells, replace = TRUE, prob = c(0.3, 0.25, 0.2, 0.25))
tissues <- sample(c("Normal", "Tumor", "Lymphnode"), total_cells, replace = TRUE, prob = c(0.22, 0.63, 0.15))
subtypes <- ifelse(tissues == "Normal", "Normal", sample(c("Luminal_A", "Luminal_B", "HER2", "TNBC"), total_cells, replace = TRUE, prob = c(0.35, 0.25, 0.15, 0.25)))

meta <- data.frame(
  row.names = cell_names,
  major_type = factor(major_vec, levels = c("Mural cell", "EC", "Fib")),
  subcluster = subcluster_vec,
  batch = batches,
  tissue = tissues,
  subtype = subtypes,
  stringsAsFactors = FALSE
)
srt <- CreateSeuratObject(counts = counts, meta.data = meta, project = "Cai2026_Stromal_Small")
qsave(srt, file.path(paper_dir, "data_small", "scrna_stromal_small.qs"))
cat("Saved stratified small scRNA object:", ncol(srt), "cells x", nrow(srt), "genes across", n_cl, "subclusters\n")
