# Corrected invocation only: set RNG seed before calling, never forward seed.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L)
config <- jsonlite::read_json(args[[1]], simplifyVector = FALSE)
report <- list(state = "not_run", checks = list(), error = NULL)
tryCatch({
  for (package in c("Seurat", "SeuratObject", "Matrix", "rlang", "scDblFinder")) {
    if (!requireNamespace(package, quietly = TRUE)) stop("Missing R dependency: ", package)
  }
  data_env <- new.env(parent = globalenv())
  load(config$fixture, envir = data_env)
  srt <- data_env$pancreas_sub[, seq_len(80L)]
  before <- serialize(srt, NULL)
  module <- new.env(parent = globalenv())
  source(file.path(config$module_dir, "code/analysis.R"), local = module)
  set.seed(11L)
  out <- module$run_doublet_detection(srt, parameters = list(
    assay = "RNA", db_method = "scDblFinder", db_rate = 0.01))
  result <- out$result
  stopifnot(inherits(result, "Seurat"), identical(before, serialize(srt, NULL)))
  metadata <- result[[]]
  score <- metadata[["db.scDblFinder_score"]]
  classification <- metadata[["db.scDblFinder_class"]]
  checks <- list(
    actual_invocation = TRUE,
    input_object_unchanged = identical(before, serialize(srt, NULL)),
    cell_order_and_identifiers_preserved = identical(colnames(result), colnames(srt)),
    metadata_order_preserved = identical(rownames(metadata), colnames(srt)),
    score_per_cell = is.numeric(score) && length(score) == 80L && all(is.finite(score)),
    classification_per_cell = length(classification) == 80L && !anyNA(classification) &&
      all(as.character(classification) %in% c("singlet", "doublet")))
  if (!all(unlist(checks))) stop("Actual scDblFinder output assertions failed")
  saveRDS(result, config$result_path)
  report$checks <- c(checks, list(output_assertions = TRUE))
  report$parameters <- list(cells = 80L, seed_before_call = 11L,
    forwarded_parameters = list(assay = "RNA", db_method = "scDblFinder", db_rate = 0.01))
  report$classification_counts <- as.list(table(classification))
  report$score_range <- range(score)
  report$diagnostics <- out$diagnostics
  report$state <- "executed"
}, error = function(error) {
  report$error <<- conditionMessage(error)
})
packages <- loadedNamespaces()
report$environment <- list(R = as.character(getRversion()), platform = R.version$platform,
  packages = setNames(lapply(packages, function(package) as.character(utils::packageVersion(package))), packages),
  automatic_installation = FALSE)
jsonlite::write_json(report, config$child_path, auto_unbox = TRUE, pretty = TRUE, null = "null")
if (!identical(report$state, "executed")) quit(status = 1L)
