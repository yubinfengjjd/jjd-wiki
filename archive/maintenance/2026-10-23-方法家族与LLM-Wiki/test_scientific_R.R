# Real calls against the preserved SCP-local source and the packaged pancreas_sub
# example. Synthetic fixtures are not used to claim an analysis passed.
# Run:
#   Rscript --vanilla test_scientific_R.R <wiki-root> <pancreas_sub.rda>

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) stop("usage: test_scientific_R.R <wiki-root> <pancreas_sub.rda>")
root <- normalizePath(args[1], mustWork = TRUE)
bundle <- normalizePath(file.path(root, "methods/scp-local-source/code/SCP-local"), mustWork = TRUE)
data_file <- normalizePath(args[2], mustWork = TRUE)
load(data_file)
stopifnot(inherits(pancreas_sub, "Seurat"))

failures <- character()
not_run <- character()
check <- function(ok, label) {
  if (isTRUE(ok)) cat("PASS:", label, "\n")
  else { cat("FAIL:", label, "\n"); failures <<- c(failures, label) }
}
expect_error <- function(expr, pattern, label) {
  message <- tryCatch({ force(expr); NA_character_ },
                      error = function(e) conditionMessage(e))
  ok <- !is.na(message) && grepl(pattern, message, ignore.case = TRUE)
  check(ok, label)
  if (ok) not_run <<- c(not_run, paste0(label, " :: ", message))
  invisible(message)
}
same <- function(a, b, tol = 1e-10) isTRUE(all.equal(a, b, tolerance = tol, check.attributes = FALSE))

source(file.path(root, "methods/cell-quality-control/code/analysis.R"))
srt_qc <- pancreas_sub[, seq_len(80)]
before_qc <- serialize(srt_qc, NULL)
qc <- run_cell_quality_control(srt_qc, bundle, list(
  qc_metrics = c("umi", "gene", "mito"), UMI_threshold = 0, gene_threshold = 0,
  mito_threshold = 100, return_filtered = FALSE, assay = "RNA", seed = 11))
check(is.list(qc) && inherits(qc$result, "Seurat"), "QC returns a Seurat result")
check(ncol(qc$result) == ncol(srt_qc) && identical(before_qc, serialize(srt_qc, NULL)),
      "QC keeps all requested cells and does not mutate the input")
check(all(c("nCount_RNA", "nFeature_RNA", "CellQC") %in% colnames(qc$result@meta.data)),
      "QC writes count, feature and CellQC fields")
engine <- load_scp_engine(bundle)
qc_direct <- engine$RunCellQC(srt_qc, qc_metrics = c("umi", "gene", "mito"),
  UMI_threshold = 0, gene_threshold = 0, mito_threshold = 100,
  return_filtered = FALSE, assay = "RNA", seed = 11)
check(identical(as.character(qc$result$CellQC), as.character(qc_direct$CellQC)),
      "QC wrapper matches the preserved upstream call")

source(file.path(root, "methods/doublet-detection/code/analysis.R"))
expect_error(run_doublet_detection(pancreas_sub[, seq_len(80)], bundle, list(
  assay = "RNA", db_method = "scDblFinder", db_rate = 0.01, seed = 11)),
  "scDblFinder|Missing R dependency", "doublet branch reports the missing scDblFinder without installing")

source(file.path(root, "methods/batch-integration/code/analysis.R"))
srt_batch <- pancreas_sub[, seq_len(120)]
srt_batch$batch <- rep(c("A", "B"), each = 60)
batch <- run_seurat_integration(srt_batch, "batch", bundle, list(
  nHVF = 300, linear_reduction_dims = 20, nonlinear_reduction_dims = 2,
  cluster_resolution = 0.5, IntegrateData_params = list(k.weight = 30), seed = 11))
check(is.list(batch) && inherits(batch$result, "Seurat"), "Seurat integration returns a Seurat result")
check(ncol(batch$result) == 120 && "SeuratUMAP2D" %in% SeuratObject::Reductions(batch$result),
      "Seurat integration keeps cells and writes an integrated UMAP")
check(any(grepl("cluster", colnames(batch$result@meta.data), ignore.case = TRUE)),
      "Seurat integration writes a cluster field")
batch_direct <- engine$Seurat_integrate(srtMerge = srt_batch, batch = "batch",
  nHVF = 300, linear_reduction_dims = 20, nonlinear_reduction_dims = 2,
  cluster_resolution = 0.5, IntegrateData_params = list(k.weight = 30), seed = 11)
check(same(SeuratObject::Embeddings(batch$result, "SeuratUMAP2D"),
           SeuratObject::Embeddings(batch_direct, "SeuratUMAP2D")),
      "Seurat integration wrapper matches the preserved upstream call")
expect_error(run_batch_integration(srt_batch, bundle, list(
  batch = "batch", nHVF = 300, seed = 11)),
  "harmony|Missing R dependency", "Harmony branch reports the missing harmony package without installing")

source(file.path(root, "methods/differential-expression/code/analysis.R"))
srt_de <- Seurat::NormalizeData(pancreas_sub, verbose = FALSE)
de <- run_differential_expression(srt_de, bundle, list(
  group_by = "CellType", group1 = "Ductal", group2 = "Endocrine",
  test.use = "wilcox", only.pos = FALSE, fc.threshold = 1.0, min.pct = 0.1,
  p.adjust.method = "bonferroni", slot = "data", assay = "RNA", verbose = FALSE))
check(inherits(de$result, "Seurat"), "DE returns the upstream Seurat result")
de_table <- de$result@tools$DEtest_custom$AllMarkers_wilcox
check(is.data.frame(de_table) && nrow(de_table) > 0 &&
      all(c("gene", "group1", "group2", "avg_log2FC", "p_val", "p_val_adj") %in% colnames(de_table)),
      "DE stores a gene-level table with effect size and adjusted p values")
de_direct <- engine$RunDEtest(srt_de, group_by = "CellType", group1 = "Ductal",
  group2 = "Endocrine", test.use = "wilcox", only.pos = FALSE, fc.threshold = 1.0,
  min.pct = 0.1, p.adjust.method = "bonferroni", slot = "data", assay = "RNA", verbose = FALSE)
check(identical(de_table, de_direct@tools$DEtest_custom$AllMarkers_wilcox),
      "DE wrapper matches the preserved upstream call")

source(file.path(root, "methods/gene-set-enrichment/code/analysis.R"))
term2gene <- data.frame(term = rep(c("T1", "T2"), each = 3),
                        gene = c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam"))
term2name <- data.frame(term = c("T1", "T2"), name = c("Endocrine", "Ductal"))
enrichment <- run_gene_set_enrichment(c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam", "Mki67"),
  bundle, list(geneID_groups = NULL, IDtype = "symbol", species = "Homo_sapiens",
    TERM2GENE = term2gene, TERM2NAME = term2name, minGSSize = 1, maxGSSize = 500,
    db_update = FALSE, seed = 11))
ora <- enrichment$result$results[[1]]@result
check(is.data.frame(ora) && nrow(ora) > 0 && all(c("ID", "pvalue", "p.adjust", "Count") %in% colnames(ora)),
      "ORA returns an enrichment result table")
enrichment_direct <- engine$RunEnrichment(geneID = c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam", "Mki67"),
  geneID_groups = NULL, IDtype = "symbol", species = "Homo_sapiens",
  TERM2GENE = term2gene, TERM2NAME = term2name, minGSSize = 1, maxGSSize = 500,
  db_update = FALSE, seed = 11)
check(identical(ora, enrichment_direct$results[[1]]@result),
      "ORA wrapper matches the preserved upstream call")

source(file.path(root, "methods/gene-set-scoring/code/analysis.R"))
score <- run_gene_set_scoring(srt_qc, bundle, list(
  features = list(Endocrine = c("Gcg", "Sst"), Ductal = c("Krt19", "Krt8", "Epcam")),
  method = "Seurat", classification = FALSE, name = "X", slot = "data", assay = "RNA", seed = 11))
check(inherits(score$result, "Seurat") &&
      all(c("X_Endocrine", "X_Ductal") %in% colnames(score$result@meta.data)),
      "gene-set scoring writes one score column per named set")
score_direct <- engine$CellScoring(srt_qc,
  features = list(Endocrine = c("Gcg", "Sst"), Ductal = c("Krt19", "Krt8", "Epcam")),
  method = "Seurat", classification = FALSE, name = "X", slot = "data", assay = "RNA", seed = 11)
check(same(score$result@meta.data[, c("X_Endocrine", "X_Ductal")],
           score_direct@meta.data[, c("X_Endocrine", "X_Ductal")]),
      "gene-set scoring wrapper matches the preserved upstream call")

source(file.path(root, "methods/trajectory-inference/code/analysis.R"))
traj <- run_trajectory_inference(srt_qc, bundle, list(
  group.by = "CellType", reduction = "UMAP", dims = 1:2, show_plot = FALSE, seed = 11))
check(inherits(traj$result, "Seurat") && "Lineage1" %in% colnames(traj$result@meta.data) &&
      "BranchID" %in% colnames(traj$result@meta.data),
      "Slingshot returns lineage pseudotime and branch labels")
traj_direct <- engine$RunSlingshot(srt_qc, group.by = "CellType", reduction = "UMAP",
  dims = 1:2, show_plot = FALSE, seed = 11)
check(same(traj$result$Lineage1, traj_direct$Lineage1, tol = 1e-12) &&
      identical(traj$result$BranchID, traj_direct$BranchID),
      "Slingshot wrapper matches the preserved upstream call")

source(file.path(root, "methods/rna-velocity/code/analysis.R"))
expect_error(run_rna_velocity(pancreas_sub[, seq_len(80)], bundle, list(
  assay_X = "RNA", assay_layers = c("spliced", "unspliced"),
  group_by = "CellType", linear_reduction = "PCA")),
  "RETICULATE|reticulate|scvelo|Python dependency|Missing Python",
  "RNA velocity reports the missing Python backend without installing")

source(file.path(root, "methods/cell-type-annotation/code/analysis.R"))
ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(300)], verbose = FALSE)
qry <- Seurat::NormalizeData(pancreas_sub[, 301:400], verbose = FALSE)
expect_error(run_cell_type_annotation(qry, ref, bundle, list(
  ref_group = "CellType", query_assay = "RNA", ref_assay = "RNA")),
  "SingleR|Missing R dependency", "annotation reports the missing SingleR package without installing")

source(file.path(root, "methods/reference-mapping/code/analysis.R"))
expect_error(run_reference_mapping(qry, ref, bundle, list(
  ref_pca = "PCA", ref_umap = "UMAP", ref_group = "CellType", ref_dims = 1:20,
  projection_method = "knn", k = 10, distance_metric = "cosine", vote_fun = "mean")),
  "dim\\.|integer vector of length two",
  "SCP RunSeuratMap UMAP-projection branch reports its Seurat 5 projection error")

source(file.path(root, "methods/reference-mapping/code/transfer.R"))
transfer <- run_reference_label_transfer(qry, ref, "CellType", dims = 1:20, k_weight = 50)
check(is.data.frame(transfer$table) && nrow(transfer$table) == ncol(qry) &&
      all(c("cell_id", "predicted_id", "max_score", "margin") %in% colnames(transfer$table)),
      "reference label transfer returns one prediction per query cell")
check(all(transfer$table$cell_id == colnames(qry)) && transfer$anchors > 0,
      "reference label transfer preserves query order and reports anchor count")

source(file.path(root, "methods/dimensionality-reduction/code/analysis.R"))
srt_dim <- Seurat::NormalizeData(pancreas_sub[, seq_len(200)], verbose = FALSE)
srt_dim <- Seurat::FindVariableFeatures(srt_dim, nfeatures = 500, verbose = FALSE)
srt_dim <- Seurat::ScaleData(srt_dim, verbose = FALSE)
dimred <- run_dimensionality_reduction(srt_dim, bundle, list(
  features = Seurat::VariableFeatures(srt_dim)[1:100],
  linear_reduction = "pca", nonlinear_reduction = "umap",
  linear_reduction_dims = 20, reduction_use = "pca", reduction_dims = 1:20,
  force_linear_reduction = TRUE, force_nonlinear_reduction = TRUE, verbose = FALSE))
check(is.list(dimred) && all(c("PCA", "UMAP") %in% SeuratObject::Reductions(dimred$result)),
      "dimension reduction writes PCA and UMAP")
check(nrow(SeuratObject::Embeddings(dimred$result, "UMAP")) == ncol(srt_dim),
      "UMAP has one row per cell")
dim_direct <- engine$RunDimReduction(srt_dim,
  features = Seurat::VariableFeatures(srt_dim)[1:100],
  linear_reduction = "pca", nonlinear_reduction = "umap",
  linear_reduction_dims = 20, reduction_use = "pca", reduction_dims = 1:20,
  force_linear_reduction = TRUE, force_nonlinear_reduction = TRUE, verbose = FALSE)
check(same(SeuratObject::Embeddings(dimred$result, "UMAP"),
           SeuratObject::Embeddings(dim_direct, "UMAP")),
      "dimension-reduction wrapper matches the preserved upstream call")

source(file.path(root, "methods/cell-clustering/code/clustering.R"))
clusters <- run_seurat_clustering(dimred$result, reduction = "PCA", dims = 1:20, resolution = 0.5)
check(is.data.frame(clusters) && nrow(clusters) == ncol(dimred$result) &&
      all(c("cell_id", "cluster") %in% colnames(clusters)),
      "clustering returns one cluster label per cell")
check(all(clusters$cell_id == colnames(dimred$result)), "clustering preserves cell order")
set.seed(11)
manual <- Seurat::FindNeighbors(dimred$result, reduction = "PCA", dims = 1:20, verbose = FALSE)
manual <- Seurat::FindClusters(manual, resolution = 0.5, algorithm = 1, verbose = FALSE)
check(identical(clusters$cluster, as.character(SeuratObject::Idents(manual))),
      "clustering matches the same explicit Seurat FindNeighbors/FindClusters calls")

source(file.path(root, "methods/dynamic-feature-analysis/code/analysis.R"))
srt_dyn <- srt_qc
srt_dyn$fixture_time <- rank(SeuratObject::Embeddings(srt_dyn, "PCA")[, 1]) / ncol(srt_dyn)
dynamic <- run_dynamic_feature_analysis(srt_dyn, bundle, list(
  lineages = "fixture_time", features = c("Gcg", "Krt19"), slot = "data",
  n_candidates = NULL, seed = 11))
dynamic_table <- dynamic$result@tools$DynamicFeatures_fixture_time$DynamicFeatures
check(is.data.frame(dynamic_table) && nrow(dynamic_table) == 2 &&
      all(c("features", "pvalue") %in% colnames(dynamic_table)),
      "dynamic features return a per-gene GAM table")
dynamic_direct <- engine$RunDynamicFeatures(srt_dyn, lineages = "fixture_time",
  features = c("Gcg", "Krt19"), slot = "data", n_candidates = NULL, seed = 11)
check(identical(dynamic_table,
                dynamic_direct@tools$DynamicFeatures_fixture_time$DynamicFeatures),
      "dynamic-feature wrapper matches the preserved upstream call")

cat("\n", length(failures), " failure(s); ", length(not_run), " expected not_run branch(es)\n", sep = "")
if (length(not_run)) cat(paste0("NOT_RUN: ", not_run, collapse = "\n"), "\n")
if (length(failures)) quit(status = 1)
