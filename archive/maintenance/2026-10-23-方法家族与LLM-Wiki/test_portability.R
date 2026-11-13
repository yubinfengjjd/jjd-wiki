# Copy the reusable code AND the SCP-local bundle to a fresh directory, then
# run representative calls. No path under the wiki is used by the copied code.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) stop("usage: test_portability.R <wiki-root> <pancreas_sub.rda> <temp-root>")
root <- normalizePath(args[1], mustWork = TRUE)
data_file <- normalizePath(args[2], mustWork = TRUE)
tmp <- normalizePath(args[3], mustWork = FALSE)
dir.create(tmp, recursive = TRUE, showWarnings = FALSE)
tmp <- normalizePath(tmp, mustWork = TRUE)
load(data_file)

failures <- character()
check <- function(ok, label) {
  if (isTRUE(ok)) cat("PASS:", label, "\n")
  else { cat("FAIL:", label, "\n"); failures <<- c(failures, label) }
}
expect_error <- function(expr, pattern, label) {
  message <- tryCatch({ force(expr); NA_character_ }, error = function(e) conditionMessage(e))
  check(!is.na(message) && grepl(pattern, message, ignore.case = TRUE), label)
}

copy_file <- function(family, file) {
  dest <- file.path(tmp, family, "code")
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  target <- file.path(dest, basename(file))
  stopifnot(file.copy(file.path(root, "methods", family, "code", file), target, overwrite = TRUE))
  target
}
copy_bundle <- function() {
  dest <- file.path(tmp, "SCP-local")
  if (!dir.exists(dest)) {
    stopifnot(file.copy(file.path(root, "methods/scp-local-source/code/SCP-local"), tmp, recursive = TRUE))
  }
  normalizePath(dest)
}
bundle <- copy_bundle()

# QC
source(copy_file("cell-quality-control", "analysis.R"))
srt20 <- pancreas_sub[, seq_len(20)]
qc <- run_cell_quality_control(srt20, bundle, list(
  qc_metrics = c("umi", "gene", "mito"), UMI_threshold = 0, gene_threshold = 0,
  mito_threshold = 100, return_filtered = FALSE, assay = "RNA", seed = 11))
check(inherits(qc$result, "Seurat") && ncol(qc$result) == 20, "QC runs from copied code and copied bundle")

# Doublet (expected missing dependency, same precise reason)
source(copy_file("doublet-detection", "analysis.R"))
expect_error(run_doublet_detection(srt20, bundle, list(
  assay = "RNA", db_method = "scDblFinder", db_rate = 0.01)),
  "scDblFinder|Missing R dependency", "doublet copied code reports missing scDblFinder")

# Batch Seurat branch
source(copy_file("batch-integration", "analysis.R"))
srt_batch <- pancreas_sub[, seq_len(120)]
srt_batch$batch <- rep(c("A", "B"), each = 60)
batch <- run_seurat_integration(srt_batch, "batch", bundle, list(
  nHVF = 300, linear_reduction_dims = 20, nonlinear_reduction_dims = 2,
  cluster_resolution = 0.5, IntegrateData_params = list(k.weight = 30), seed = 11))
check(inherits(batch$result, "Seurat") && ncol(batch$result) == 120,
      "Seurat integration runs from copied code and copied bundle")

# DE
source(copy_file("differential-expression", "analysis.R"))
srt_de <- Seurat::NormalizeData(pancreas_sub[, seq_len(300)], verbose = FALSE)
de <- run_differential_expression(srt_de, bundle, list(
  group_by = "CellType", group1 = "Ductal", group2 = "Endocrine",
  test.use = "wilcox", only.pos = FALSE, fc.threshold = 1.0, min.pct = 0.1,
  p.adjust.method = "bonferroni", slot = "data", assay = "RNA", verbose = FALSE))
check(is.data.frame(de$result@tools$DEtest_custom$AllMarkers_wilcox),
      "DE runs from copied code and copied bundle")

# Enrichment
source(copy_file("gene-set-enrichment", "analysis.R"))
term2gene <- data.frame(term = rep(c("T1", "T2"), each = 3),
                        gene = c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam"))
term2name <- data.frame(term = c("T1", "T2"), name = c("Endocrine", "Ductal"))
enr <- run_gene_set_enrichment(c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam", "Mki67"),
  bundle, list(geneID_groups = NULL, IDtype = "symbol", species = "Homo_sapiens",
    TERM2GENE = term2gene, TERM2NAME = term2name, minGSSize = 1, maxGSSize = 500,
    db_update = FALSE, seed = 11))
check(is.data.frame(enr$result$results[[1]]@result),
      "ORA runs from copied code and copied bundle")

# Scoring
source(copy_file("gene-set-scoring", "analysis.R"))
score <- run_gene_set_scoring(srt20, bundle, list(
  features = list(Endocrine = c("Gcg", "Sst"), Ductal = c("Krt19", "Krt8", "Epcam")),
  method = "Seurat", classification = FALSE, name = "X", slot = "data", assay = "RNA", seed = 11))
check(all(c("X_Endocrine", "X_Ductal") %in% colnames(score$result@meta.data)),
      "gene-set scoring runs from copied code and copied bundle")

# Trajectory
source(copy_file("trajectory-inference", "analysis.R"))
srt_qc <- pancreas_sub[, seq_len(80)]
traj <- run_trajectory_inference(srt_qc, bundle, list(
  group.by = "CellType", reduction = "UMAP", dims = 1:2, show_plot = FALSE, seed = 11))
check("Lineage1" %in% colnames(traj$result@meta.data),
      "Slingshot runs from copied code and copied bundle")

# RNA velocity (expected missing Python backend)
source(copy_file("rna-velocity", "analysis.R"))
expect_error(run_rna_velocity(srt20, bundle, list(
  assay_X = "RNA", assay_layers = c("spliced", "unspliced"),
  group_by = "CellType", linear_reduction = "PCA")),
  "RETICULATE|scvelo|Python", "RNA velocity copied code reports missing Python backend")

# Annotation (expected missing SingleR)
source(copy_file("cell-type-annotation", "analysis.R"))
ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(200)], verbose = FALSE)
qry <- Seurat::NormalizeData(pancreas_sub[, 201:250], verbose = FALSE)
expect_error(run_cell_type_annotation(qry, ref, bundle, list(
  ref_group = "CellType", query_assay = "RNA", ref_assay = "RNA")),
  "SingleR|Missing R dependency", "annotation copied code reports missing SingleR")

# Reference label transfer
source(copy_file("reference-mapping", "transfer.R"))
map <- run_reference_label_transfer(qry, ref, "CellType", dims = 1:20, k_weight = 30)
check(nrow(map$table) == ncol(qry), "reference label transfer runs from copied code")

# Dimension reduction
source(copy_file("dimensionality-reduction", "analysis.R"))
srt_dim <- Seurat::NormalizeData(pancreas_sub[, seq_len(100)], verbose = FALSE)
srt_dim <- Seurat::FindVariableFeatures(srt_dim, nfeatures = 300, verbose = FALSE)
srt_dim <- Seurat::ScaleData(srt_dim, verbose = FALSE)
dimred <- run_dimensionality_reduction(srt_dim, bundle, list(
  features = Seurat::VariableFeatures(srt_dim)[1:50],
  linear_reduction = "pca", nonlinear_reduction = "umap",
  linear_reduction_dims = 10, reduction_use = "pca", reduction_dims = 1:10,
  force_linear_reduction = TRUE, force_nonlinear_reduction = TRUE, verbose = FALSE))
check(all(c("PCA", "UMAP") %in% SeuratObject::Reductions(dimred$result)),
      "PCA/UMAP runs from copied code and copied bundle")

# Clustering
source(copy_file("cell-clustering", "clustering.R"))
clusters <- run_seurat_clustering(dimred$result, reduction = "PCA", dims = 1:10, resolution = 0.5)
check(nrow(clusters) == ncol(dimred$result), "clustering runs from copied code")

# Dynamic features
source(copy_file("dynamic-feature-analysis", "analysis.R"))
srt_dyn <- srt_qc
srt_dyn$fixture_time <- rank(SeuratObject::Embeddings(srt_dyn, "PCA")[, 1]) / ncol(srt_dyn)
dyn <- run_dynamic_feature_analysis(srt_dyn, bundle, list(
  lineages = "fixture_time", features = c("Gcg", "Krt19"), slot = "data",
  n_candidates = NULL, seed = 11))
check(is.data.frame(dyn$result@tools$DynamicFeatures_fixture_time$DynamicFeatures),
      "dynamic features run from copied code and copied bundle")

# Table adapters, run from their copied directory.
copy_file("scp-visualization-interface", "scp_tables.R")
copy_file("scp-visualization-interface", "test_scp_tables.R")
adapter_dir <- file.path(tmp, "scp-visualization-interface", "code")
status <- system2("D:/R-4.5.0/bin/Rscript.exe",
                  c("--vanilla", file.path(adapter_dir, "test_scp_tables.R")),
                  stdout = FALSE, stderr = FALSE)
check(status == 0, "SCP table adapters run from copied code")

cat("\n", length(failures), " failure(s)\n", sep = "")
if (length(failures)) quit(status = 1)
