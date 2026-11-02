# Reference run: the immutable before/ wrapper with the pinned full bundle.
# This is comparison-only; new modules never read the bundle.
# Usage: Rscript --vanilla reference_run.R <before_methods_dir> <bundle> <fixture> <method> <out_rds>
args <- commandArgs(trailingOnly = TRUE)
before <- normalizePath(args[1], mustWork = TRUE)
bundle <- normalizePath(args[2], mustWork = TRUE)
fixture <- args[3]
method <- args[4]
out_file <- args[5]
load(fixture)
stopifnot(inherits(pancreas_sub, "Seurat"))
Serial <- BiocParallel::SerialParam()
set.seed(11)
options(future.globals.maxSize = 4 * 1024^3)
future::plan("sequential")

# Compatibility shims for SeuratObject >= 5; they restore the older API that
# the pinned SCP code was written against, without changing values.
GetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, ...) {
  if (is.null(layer) && !is.null(slot)) layer <- slot
  SeuratObject::GetAssayData(object = object, assay = assay, layer = layer, ...)
}
Assays <- function(object, slot = NULL, ...) {
  if (!is.null(slot)) return(methods::slot(object = object, name = "assays")[[slot]])
  SeuratObject::Assays(object = object, ...)
}

env <- new.env(parent = globalenv())
sys.source(file.path(before, method, "code/analysis.R"), envir = env)

state <- "passed"
error <- NULL
out <- NULL
tryCatch({
  if (method == "cell-quality-control") {
    srt <- pancreas_sub[, seq_len(80)]
    out <- env$run_cell_quality_control(srt, bundle, list(
      qc_metrics = c("umi", "gene", "mito"), UMI_threshold = 0, gene_threshold = 0,
      mito_threshold = 100, return_filtered = FALSE, assay = "RNA", seed = 11))
  } else if (method == "dimensionality-reduction") {
    srt <- Seurat::NormalizeData(pancreas_sub[, seq_len(200)], verbose = FALSE)
    srt <- Seurat::FindVariableFeatures(srt, nfeatures = 500, verbose = FALSE)
    srt <- Seurat::ScaleData(srt, verbose = FALSE)
    out <- env$run_dimensionality_reduction(srt, bundle, list(
      features = Seurat::VariableFeatures(srt)[1:100],
      linear_reduction = "pca", nonlinear_reduction = "umap",
      linear_reduction_dims = 20, reduction_use = "pca", reduction_dims = 1:20,
      force_linear_reduction = TRUE, force_nonlinear_reduction = TRUE, verbose = FALSE))
  } else if (method == "batch-integration") {
    srt <- pancreas_sub[, seq_len(120)]
    srt$batch <- rep(c("A", "B"), each = 60)
    out <- env$run_seurat_integration(srt, "batch", bundle, list(
      nHVF = 300, linear_reduction_dims = 20, nonlinear_reduction_dims = 2,
      cluster_resolution = 0.5, IntegrateData_params = list(k.weight = 30), seed = 11))
  } else if (method == "differential-expression") {
    srt <- Seurat::NormalizeData(pancreas_sub, verbose = FALSE)
    out <- env$run_differential_expression(srt, bundle, list(
      group_by = "CellType", group1 = "Ductal", group2 = "Endocrine",
      test.use = "wilcox", only.pos = FALSE, fc.threshold = 1.0, min.pct = 0.1,
      p.adjust.method = "bonferroni", slot = "data", assay = "RNA",
      verbose = FALSE, BPPARAM = Serial, seed = 11))
  } else if (method == "gene-set-enrichment") {
    term2gene <- data.frame(term = rep(c("T1", "T2"), each = 3),
                            gene = c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam"))
    term2name <- data.frame(term = c("T1", "T2"), name = c("Endocrine", "Ductal"))
    out <- env$run_gene_set_enrichment(
      c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam", "Mki67"), bundle,
      list(geneID_groups = NULL, IDtype = "symbol", species = "Homo_sapiens",
        TERM2GENE = term2gene, TERM2NAME = term2name, minGSSize = 1, maxGSSize = 500,
        db_update = FALSE, BPPARAM = Serial, seed = 11))
  } else if (method == "gene-set-scoring") {
    srt <- pancreas_sub[, seq_len(80)]
    out <- env$run_gene_set_scoring(srt, bundle, list(
      features = list(Endocrine = c("Gcg", "Sst"), Ductal = c("Krt19", "Krt8", "Epcam")),
      method = "Seurat", classification = FALSE, name = "X", slot = "data",
      assay = "RNA", BPPARAM = Serial, seed = 11))
  } else if (method == "trajectory-inference") {
    srt <- pancreas_sub[, seq_len(80)]
    out <- env$run_trajectory_inference(srt, bundle, list(
      group.by = "CellType", reduction = "UMAP", dims = 1:2, show_plot = FALSE, seed = 11))
  } else if (method == "dynamic-feature-analysis") {
    srt <- pancreas_sub[, seq_len(80)]
    srt$fixture_time <- rank(SeuratObject::Embeddings(srt, "PCA")[, 1]) / ncol(srt)
    out <- env$run_dynamic_feature_analysis(srt, bundle, list(
      lineages = "fixture_time", features = c("Gcg", "Krt19"), slot = "data",
      n_candidates = NULL, BPPARAM = Serial, seed = 11))
  } else {
    stop("unknown method")
  }
}, error = function(e) {
  state <<- "not_run"
  error <<- conditionMessage(e)
})

result <- list(method = method, state = state, error = error)
if (state == "passed") {
  res <- out$result
  if (inherits(res, "Seurat")) {
    result$seurat <- list(
      cells = colnames(res),
      meta = res[[]],
      reductions = names(res@reductions),
      embeddings = lapply(res@reductions, function(x) x@cell.embeddings)
    )
    result$tools <- lapply(res@tools, function(x) if (is.data.frame(x)) x else x)
  } else {
    result$raw <- res
  }
}
saveRDS(result, out_file)
cat(if (state == "passed") "REFERENCE_PASS " else "REFERENCE_NOT_RUN ", method,
    if (!is.null(error)) paste0(" :: ", error) else "", "\n", sep = "")
