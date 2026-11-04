# Reuse the recorded 300/100 public case and capture a symbolic failure stack.
args <- commandArgs(TRUE)
report <- list(state = "not_run")
tryCatch(withCallingHandlers({
  load(args[[1]])
  ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(300L)], verbose = FALSE)
  qry <- Seurat::NormalizeData(pancreas_sub[, 301:400], verbose = FALSE)
  before <- serialize(list(qry, ref), NULL)
  module <- new.env(parent = globalenv())
  source(file.path(args[[2]], "code/analysis.R"), local = module)
  set.seed(11L)
  result <- module$run_reference_mapping(qry, ref, parameters = list(
    ref_pca = "PCA", ref_umap = "UMAP", ref_group = "CellType", ref_dims = 1:20,
    projection_method = "knn", k = 10, distance_metric = "cosine", vote_fun = "mean"))
  stopifnot(identical(before, serialize(list(qry, ref), NULL)))
  saveRDS(result$result, file.path(args[[3]], "result.rds"))
  report <- list(state = "executed", input_unchanged = TRUE)
}, error = function(error) {
  report$error_calls <<- lapply(sys.calls(), function(call)
    substr(paste(deparse(call[[1]]), collapse = " "), 1L, 120L))
  report$condition_call <<- substr(paste(deparse(conditionCall(error)), collapse = " "), 1L, 300L)
}), error = function(error) report$error <<- conditionMessage(error))
jsonlite::write_json(report, file.path(args[[3]], "trace.json"), auto_unbox = TRUE, pretty = TRUE)
if (!identical(report$state, "executed")) quit(status = 1L)
