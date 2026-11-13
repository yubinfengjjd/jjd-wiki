# Real public data: compare metadata assignment against direct SingleR values.
args <- commandArgs(TRUE)
stopifnot(length(args) == 3L)
input <- readRDS(args[[1]])
module_dir <- args[[2]]
output <- args[[3]]
report <- list(state = "not_run", checks = list())
tryCatch({
  stopifnot(requireNamespace("SingleCellExperiment", quietly = TRUE))
  query <- input[[1]]
  reference <- input[[2]]
  before <- serialize(input, NULL)
  sce <- function(object) {
    assay <- list(
      counts = SeuratObject::GetAssayData(object, assay = "RNA", layer = "counts"),
      logcounts = SeuratObject::GetAssayData(object, assay = "RNA", layer = "data"))
    value <- as(SummarizedExperiment::SummarizedExperiment(assays = assay), "SingleCellExperiment")
    SummarizedExperiment::colData(value) <- S4Vectors::DataFrame(object[[]])
    value
  }
  query_sce <- sce(query)
  reference_sce <- sce(reference)
  set.seed(11L)
  native <- SingleR::SingleR(
    test = query_sce, ref = reference_sce,
    labels = factor(reference$CellType), clusters = NULL,
    de.method = "wilcox", genes = "de", sd.thresh = 1, de.n = NULL,
    aggr.ref = FALSE, aggr.args = list(), quantile = 0.8,
    fine.tune = TRUE, tune.thresh = 0.05, prune = TRUE,
    BPPARAM = BiocParallel::SerialParam())
  # This is the unchanged upstream score expression, including its label names.
  expected_scores <- sapply(seq_len(ncol(query)), function(index) {
    label <- native$pruned.labels[index]
    if (is.na(label)) NA else native$scores[index, label]
  })
  stopifnot(identical(rownames(native), colnames(query)))
  module <- new.env(parent = globalenv())
  source(file.path(module_dir, "code/analysis.R"), local = module)
  set.seed(11L)
  actual <- module$run_cell_type_annotation(query, reference, parameters = list(
    ref_group = "CellType", query_assay = "RNA", ref_assay = "RNA",
    BPPARAM = BiocParallel::SerialParam()))
  metadata <- actual$result[[]]
  checks <- list(
    actual_invocation = TRUE,
    input_object_unchanged = identical(before, serialize(input, NULL)),
    cell_ids_preserved = identical(colnames(actual$result), colnames(query)),
    metadata_ids_preserved = identical(rownames(metadata), colnames(query)),
    labels_equal_direct_SingleR = identical(metadata$singler_annotation, native$pruned.labels),
    scores_equal_unchanged_upstream_expression = identical(metadata$singler_score, unname(expected_scores)),
    expected_score_names_are_labels = all(names(expected_scores)[!is.na(native$pruned.labels)] ==
      native$pruned.labels[!is.na(native$pruned.labels)]),
    result_length = nrow(metadata) == 100L && ncol(reference) == 300L)
  stopifnot(all(unlist(checks)))
  saveRDS(actual$result, file.path(output, "result.rds"))
  saveRDS(native, file.path(output, "direct-SingleR.rds"))
  actual$diagnostics$parameters$BPPARAM <- class(actual$diagnostics$parameters$BPPARAM)
  report <- list(state = "executed", checks = checks, cells = 100L,
    reference_cells = 300L, seed = 11L, parallel_backend = "SerialParam",
    pruned_cells = sum(is.na(native$pruned.labels)),
    score_range = range(metadata$singler_score, na.rm = TRUE),
    comparison_scope = "Direct SingleR plus unchanged upstream score expression; full unmodified SCP fails at its deprecated Seurat API.",
    diagnostics = actual$diagnostics)
}, error = function(error) report$error <<- conditionMessage(error))
report$environment <- list(R = as.character(getRversion()), packages = setNames(
  lapply(loadedNamespaces(), function(name) as.character(utils::packageVersion(name))), loadedNamespaces()))
jsonlite::write_json(report, file.path(output, "result.json"), auto_unbox = TRUE,
  pretty = TRUE, null = "null", digits = NA)
if (!identical(report$state, "executed")) quit(status = 1L)
