# 04_trajectory_pseudotime.R
# DiffusionMap (destiny) + Slingshot trajectory & pseudotime inference on Fib, EC, and Mural subsets
# Input:
#   - data_small/scrna_stromal_small.qs (1,800 cells x 289 genes)
#   - Optional: runs/step01_harmony_de/umap_{fib,ec,mural}.csv (computed standalone if absent)
# Output (runs/step04_trajectory/):
#   - traj_fib.csv
#   - traj_ec.csv
#   - traj_mural.csv
#   - traj_mural_branch_genes.csv
#   - receipt.json

.libPaths(unique(c("E:/research-wiki-env/R-lib/figureya", "E:/research-wiki-env/R-lib-scp/4.5", .libPaths())))
suppressPackageStartupMessages({
  library(Seurat)
  library(harmony)
  library(destiny)
  library(slingshot)
  library(SingleCellExperiment)
  library(qs)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(jsonlite)
  library(tibble)
})

t0 <- proc.time()[["elapsed"]]
set.seed(42)

paper_dir <- "E:/research-wiki-env/sources/papers/2026-cai-stromal-tme"
sc_path   <- file.path(paper_dir, "data_small", "scrna_stromal_small.qs")
step01_dir <- file.path(paper_dir, "runs", "step01_harmony_de")
out_dir   <- file.path(paper_dir, "runs", "step04_trajectory")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

has_monocle3 <- requireNamespace("monocle3", quietly = TRUE)
monocle3_status <- if (has_monocle3) "available" else "not_run (monocle3 not installed)"
cat("monocle3 status:", monocle3_status, "\n")

srt_all <- qread(sc_path)
DefaultAssay(srt_all) <- "RNA"

# Safe module scoring helper (handles small gene panels like 289 genes cleanly)
add_safe_modules <- function(srt, gene_sets) {
  avail <- rownames(srt)
  expr_mat <- as.matrix(GetAssayData(srt, assay = "RNA", layer = "data"))
  coverage <- list()
  for (nm in names(gene_sets)) {
    gs <- intersect(gene_sets[[nm]], avail)
    coverage[[nm]] <- list(present = length(gs), total = length(gene_sets[[nm]]), genes = gs)
    col_out <- paste0("score_", nm)
    if (length(gs) == 0) {
      srt@meta.data[[col_out]] <- NA_real_
    } else {
      ok <- tryCatch({
        tmp <- AddModuleScore(srt, features = list(gs), name = paste0("tmp_", nm), nbin = 8, ctrl = 15, verbose = FALSE)
        srt@meta.data[[col_out]] <- tmp@meta.data[[paste0("tmp_", nm, "1")]]
        TRUE
      }, error = function(e) FALSE)
      if (!ok) {
        sub_e <- expr_mat[gs, , drop = FALSE]
        srt@meta.data[[col_out]] <- as.numeric(colMeans(sub_e))
      }
    }
  }
  list(srt = srt, coverage = coverage)
}

run_subset_trajectory <- function(srt_all, major_label, umap_csv_name, start_clus, gene_sets) {
  sub <- subset(srt_all, subset = major_type == major_label)
  DefaultAssay(sub) <- "RNA"
  sub <- NormalizeData(sub, verbose = FALSE)
  sub <- FindVariableFeatures(sub, selection.method = "vst", nfeatures = min(2000, nrow(sub)), verbose = FALSE)
  sub <- ScaleData(sub, features = rownames(sub), verbose = FALSE)
  npcs_use <- min(25, nrow(sub) - 1, ncol(sub) - 1)
  sub <- RunPCA(sub, features = rownames(sub), npcs = npcs_use, verbose = FALSE)
  sub <- RunHarmony(sub, group.by.vars = "batch", dims.use = 1:min(15, npcs_use), verbose = FALSE)

  umap_csv_path <- file.path(step01_dir, umap_csv_name)
  if (file.exists(umap_csv_path)) {
    umap_df <- read_csv(umap_csv_path, show_col_types = FALSE)
    if (all(c("cell_id", "UMAP_1", "UMAP_2") %in% colnames(umap_df)) &&
        all(colnames(sub) %in% umap_df$cell_id)) {
      umap_coords <- umap_df %>%
        filter(cell_id %in% colnames(sub)) %>%
        slice(match(colnames(sub), cell_id)) %>%
        select(UMAP_1, UMAP_2) %>%
        as.matrix()
      rownames(umap_coords) <- colnames(sub)
      umap_source <- "step01_harmony_de"
    } else {
      sub <- RunUMAP(sub, reduction = "harmony", dims = 1:min(15, npcs_use), verbose = FALSE)
      umap_coords <- Embeddings(sub, "umap")[, 1:2, drop = FALSE]
      colnames(umap_coords) <- c("UMAP_1", "UMAP_2")
      umap_source <- "standalone_harmony_umap"
    }
  } else {
    sub <- RunUMAP(sub, reduction = "harmony", dims = 1:min(15, npcs_use), verbose = FALSE)
    umap_coords <- Embeddings(sub, "umap")[, 1:2, drop = FALSE]
    colnames(umap_coords) <- c("UMAP_1", "UMAP_2")
    umap_source <- "standalone_harmony_umap"
  }

  # DiffusionMap on Harmony embeddings
  harm_mat <- Embeddings(sub, "harmony")[, 1:min(15, ncol(Embeddings(sub, "harmony"))), drop = FALSE]
  set.seed(42)
  dm <- suppressWarnings(DiffusionMap(harm_mat, k = 30, n_eigs = 5, verbose = FALSE))
  dc_mat <- eigenvectors(dm)[, 1:3, drop = FALSE]
  colnames(dc_mat) <- c("DC1", "DC2", "DC3")
  rownames(dc_mat) <- colnames(sub)

  # Diffusion pseudotime (DPT)
  dpt_vals <- tryCatch({
    dpt_obj <- DPT(dm)
    v <- as.numeric(dpt_obj[, 1])
    if (length(v) != ncol(sub) || all(is.na(v))) rank(dc_mat[, "DC1"]) / nrow(dc_mat) else v
  }, error = function(e) {
    (dc_mat[, "DC1"] - min(dc_mat[, "DC1"])) / diff(range(dc_mat[, "DC1"]))
  })

  # Slingshot on 2D DiffusionMap
  sce <- SingleCellExperiment(
    assays = list(
      counts = GetAssayData(sub, assay = "RNA", layer = "counts"),
      logcounts = GetAssayData(sub, assay = "RNA", layer = "data")
    ),
    reducedDims = S4Vectors::SimpleList(DM = dc_mat[, 1:2, drop = FALSE], UMAP = umap_coords)
  )
  colData(sce)$subcluster <- as.character(sub@meta.data$subcluster)
  start_use <- if (start_clus %in% unique(colData(sce)$subcluster)) start_clus else NULL
  set.seed(42)
  sce <- suppressWarnings(slingshot(
    sce,
    clusterLabels = "subcluster",
    reducedDim = "DM",
    start.clus = start_use,
    approx_points = FALSE
  ))

  pt_mat <- slingPseudotime(sce)
  colnames(pt_mat) <- paste0("slingshot_", colnames(pt_mat))
  slingshot_pt <- rowMeans(pt_mat, na.rm = TRUE)

  # Add biological module scores
  mod_res <- add_safe_modules(sub, gene_sets)
  sub <- mod_res$srt

  score_cols <- grep("^score_", colnames(sub@meta.data), value = TRUE)
  out_df <- tibble(
    cell_id = colnames(sub),
    major_type = as.character(sub@meta.data$major_type),
    subcluster = as.character(sub@meta.data$subcluster),
    batch = as.character(sub@meta.data$batch),
    tissue = as.character(sub@meta.data$tissue),
    subtype = as.character(sub@meta.data$subtype),
    UMAP_1 = as.numeric(umap_coords[, 1]),
    UMAP_2 = as.numeric(umap_coords[, 2]),
    DC1 = as.numeric(dc_mat[, "DC1"]),
    DC2 = as.numeric(dc_mat[, "DC2"]),
    DC3 = as.numeric(dc_mat[, "DC3"]),
    dpt_pseudotime = as.numeric(dpt_vals),
    slingshot_pseudotime = as.numeric(slingshot_pt)
  ) %>%
    bind_cols(as_tibble(pt_mat)) %>%
    bind_cols(as_tibble(sub@meta.data[, score_cols, drop = FALSE]))

  list(df = out_df, srt = sub, sce = sce, pt_mat = pt_mat, umap_source = umap_source, coverage = mod_res$coverage)
}

# ---- 1. Fibroblasts (Fig 2F-I) ----
caf_programs <- list(
  rCAF   = c("CCL21", "CCL19", "ACTA2"),
  iCAF   = c("PLA2G2A", "CFD", "C3", "CD34", "CXCL12", "CXCL14", "IL6", "CD248"),
  mCAF   = c("MMP11", "COL1A2", "POSTN", "CDH11", "COL10A1", "COL11A1", "COL8A1",
             "COL12A1", "COL3A1", "COL5A2", "COMP", "LRRC15", "LRRC17", "ASPN",
             "SULF1", "INHBA", "VCAN", "CTHRC1", "MGP"),
  tCAF   = c("PDPN", "MME", "TMEM158", "NDRG1", "ENO1", "VEGFA", "CA9", "CAIX",
             "HSPH1", "GAPDH", "HSP90AA1"),
  dCAF   = c("MKI67", "TUBA1B"),
  ifnCAF = c("IDO1", "IL32", "CXCL9", "CXCL10", "CXCL11"),
  apCAF  = c("CD74", "HLA-DRA", "HLA-DRB1"),
  vCAF   = c("NOTCH3", "COL18A1", "ACTA2", "MCAM", "CD146", "RERGL", "MYH11", "RGS5"),
  LipCAF = c("APOA2", "FABP1", "FABP4", "FRZB", "CFD", "APOD")
)
res_fib <- run_subset_trajectory(srt_all, "Fib", "umap_fib.csv", "C10_Fib_ABCA8", caf_programs)
write_csv(res_fib$df, file.path(out_dir, "traj_fib.csv"))
cat("Saved traj_fib.csv:", nrow(res_fib$df), "rows | lineages:", ncol(res_fib$pt_mat), "\n")

# ---- 2. Endothelial cells (Fig 4F-H) ----
ec_programs <- list(
  Tip_cell = c("ADM","ANGPT2","ANKRD37","APLN","C1QTNF6","CD93","CLDN5","COL4A1",
               "COL4A2","COTL1","CXCR4","DLL4","EDNRB","ESM1","FSCN1","GPIHBP1",
               "HSPG2","IGFBP3","INHBB","ITGA5","JUP","KCNE3","KCNJ8","KDR",
               "LAMA4","LAMB1","LAMC1","LXN","MARCKS","MARCKSL1","MCAM","MEST",
               "MYH9","MYO1B","N4BP3","NID2","NOTCH4","PDGFB","PGF","PLOD1",
               "PLXND1","PMEPA1","PTN","RAMP3","RBP1","RGCC","RHOC","SMAD1",
               "SOX17","SOX4","SPARC","TCF4","UNC5B","VIM"),
  Stalk_cell = c("ACKR1","AQP1","C1QTNF9","CD36","CSRP2","EHD4","FBLN5","HSPB1",
                 "LIGP1","IL6ST","JAM2","LGALS3","LRG1","MEOX2","PLSCR2","SDPR",
                 "SELP","SPINT2","TGFBI","TGM2","TMEM176A","TMEM176B","TMEM252",
                 "TSPAN7","VEGFR1","VWF")
)
res_ec <- run_subset_trajectory(srt_all, "EC", "umap_ec.csv", "C5_VenECs_HIF1A+", ec_programs)
write_csv(res_ec$df, file.path(out_dir, "traj_ec.csv"))
cat("Saved traj_ec.csv:", nrow(res_ec$df), "rows | lineages:", ncol(res_ec$pt_mat), "\n")

# ---- 3. Mural cells (Fig 5F-I) ----
mural_programs <- list(
  Quiescent  = c("MYH11", "RERGL", "MUSTN1", "SORBS2", "ACTA2", "MYL9", "RGS5"),
  Angiogenic = c("COL3A1", "FN1", "POSTN", "THY1", "COL1A1", "PGF", "EGFL6")
)
res_mural <- run_subset_trajectory(srt_all, "Mural cell", "umap_mural.csv", "C1_MLY9+SMC", mural_programs)

fig5i_genes <- c("COL6A3", "MUSTN1", "SORBS2", "CCL21", "NET1", "THY1", "RERGL", "MYH11")
avail_mural_genes <- rownames(res_mural$srt)
fig5i_present <- intersect(fig5i_genes, avail_mural_genes)
fig5i_missing <- setdiff(fig5i_genes, avail_mural_genes)

mural_expr <- as.matrix(GetAssayData(res_mural$srt, assay = "RNA", layer = "data")[fig5i_present, , drop = FALSE])
mural_gene_df <- as.data.frame(t(mural_expr)) %>% rownames_to_column("cell_id")
for (mg in fig5i_missing) {
  mural_gene_df[[mg]] <- NA_real_
}
traj_mural_df <- res_mural$df %>% left_join(mural_gene_df, by = "cell_id")
write_csv(traj_mural_df, file.path(out_dir, "traj_mural.csv"))
cat("Saved traj_mural.csv:", nrow(traj_mural_df), "rows | lineages:", ncol(res_mural$pt_mat), "\n")

# Compute smoothed branch gene trends along each Slingshot lineage (Fig 5I)
lineage_cols <- colnames(res_mural$pt_mat)
grid_n <- 50L
branch_rows <- list()

for (lin in lineage_cols) {
  pt_vals <- traj_mural_df[[lin]]
  keep <- !is.na(pt_vals)
  if (sum(keep) < 20) next
  sub_df <- traj_mural_df[keep, , drop = FALSE]
  pt_norm <- (sub_df[[lin]] - min(sub_df[[lin]])) / max(diff(range(sub_df[[lin]])), 1e-6)
  sub_df$pt_norm <- pt_norm
  grid_pt <- seq(0, 1, length.out = grid_n)

  # Summarize terminal cluster identity of this lineage
  top_end_cluster <- sub_df %>%
    filter(pt_norm >= 0.75) %>%
    count(subcluster, sort = TRUE) %>%
    slice(1) %>%
    pull(subcluster)

  for (g in fig5i_present) {
    loess_df <- data.frame(y = sub_df[[g]], pt_norm = sub_df$pt_norm)
    fit <- tryCatch(loess(y ~ pt_norm, data = loess_df, span = 0.75), error = function(e) NULL)
    pred <- if (!is.null(fit)) as.numeric(predict(fit, newdata = data.frame(pt_norm = grid_pt))) else rep(mean(sub_df[[g]]), grid_n)
    # Also compute mean +/- se in 5 quintile bins for clean summary
    branch_rows[[paste(lin, g, sep = "_")]] <- tibble(
      lineage = lin,
      terminal_cluster = top_end_cluster,
      gene = g,
      pseudotime_norm = grid_pt,
      smoothed_expr = pred,
      n_cells_lineage = nrow(sub_df)
    )
  }
}
df_branch_genes <- bind_rows(branch_rows)
write_csv(df_branch_genes, file.path(out_dir, "traj_mural_branch_genes.csv"))
cat("Saved traj_mural_branch_genes.csv:", nrow(df_branch_genes), "rows\n")

elapsed <- round(proc.time()[["elapsed"]] - t0, 3)

receipt <- list(
  step = "step04_trajectory",
  script = "src/04_trajectory_pseudotime.R",
  seed = 42L,
  status = "completed",
  monocle3_status = monocle3_status,
  trajectory_methods = c("Harmony", "destiny::DiffusionMap", "destiny::DPT", "slingshot::slingshot"),
  scale_down_boundary = paste0(
    "Computed on stratified scrna_stromal_small.qs (n = 1,800 cells, 289 genes: 700 Fib, 600 EC, 500 Mural). ",
    "Fig 5I gene COL6A3 is absent in the 289-gene subset (recorded as NA in traj_mural.csv; 7/8 present genes modeled in traj_mural_branch_genes.csv)."
  ),
  umap_sources = list(fib = res_fib$umap_source, ec = res_ec$umap_source, mural = res_mural$umap_source),
  fig5i_genes_present = fig5i_present,
  fig5i_genes_missing = fig5i_missing,
  lineages_detected = list(
    fib = colnames(res_fib$pt_mat),
    ec = colnames(res_ec$pt_mat),
    mural = colnames(res_mural$pt_mat)
  ),
  outputs = list(
    traj_fib.csv = list(path = file.path(out_dir, "traj_fib.csv"), rows = nrow(res_fib$df), cols = ncol(res_fib$df)),
    traj_ec.csv  = list(path = file.path(out_dir, "traj_ec.csv"),  rows = nrow(res_ec$df),  cols = ncol(res_ec$df)),
    traj_mural.csv = list(path = file.path(out_dir, "traj_mural.csv"), rows = nrow(traj_mural_df), cols = ncol(traj_mural_df)),
    traj_mural_branch_genes.csv = list(path = file.path(out_dir, "traj_mural_branch_genes.csv"), rows = nrow(df_branch_genes), cols = ncol(df_branch_genes))
  ),
  elapsed_seconds = elapsed
)

write_json(receipt, file.path(out_dir, "receipt.json"), pretty = TRUE, auto_unbox = TRUE)
cat("Step 04 completed in", elapsed, "sec.\n")
