# Independent original or wrapper call; never patch the installed original.
args <- commandArgs(trailingOnly = TRUE)
config <- jsonlite::read_json(args[[1]], simplifyVector = FALSE)
report <- list(state = "not_run", checks = list(), error = NULL, error_calls = list())
input_before <- NULL
input_current <- function() {
  if (identical(config$method, "doublet-detection")) serialize(srt, NULL)
  else serialize(list(qry, ref), NULL)
}
tryCatch(withCallingHandlers({
  for (package in c("Seurat", "SeuratObject", "Matrix", "rlang", "SingleR", "scDblFinder", "BiocParallel", "future")) {
    if (!requireNamespace(package, quietly = TRUE)) stop("Missing dependency; installation forbidden: ", package)
  }
  data_env <- new.env(parent = globalenv())
  load(config$fixture, envir = data_env)
  set.seed(11L)
  future::plan("sequential")
  if (identical(config$method, "doublet-detection")) {
    srt <- data_env$pancreas_sub[, seq_len(80L)]
    input_before <- serialize(srt, NULL)
    parameters <- list(assay = "RNA", db_method = "scDblFinder", db_rate = 0.01)
  } else {
    ref <- Seurat::NormalizeData(data_env$pancreas_sub[, seq_len(300L)], verbose = FALSE)
    qry <- Seurat::NormalizeData(data_env$pancreas_sub[, 301:400], verbose = FALSE)
    input_before <- serialize(list(qry, ref), NULL)
    parameters <- list(ref_group = "CellType", query_assay = "RNA", ref_assay = "RNA")
  }
  saveRDS(unserialize(input_before), config$input_path)
  report$input_serialized_sha256 <- digest::digest(input_before, algo = "sha256", serialize = FALSE)
  report$parameters <- parameters
  report$parallel_backend <- list(class = class(BiocParallel::bpparam()), workers = BiocParallel::bpworkers(BiocParallel::bpparam()))
  if (identical(config$mode, "original")) {
    original <- getFromNamespace(if (identical(config$method, "doublet-detection")) "RunDoubletCalling" else "RunSingleR", "SCP")
    # Helpers resolve only through the unchanged installed SCP namespace.
    report$function_environment <- environmentName(environment(original))
    set.seed(11L)
    if (identical(config$method, "doublet-detection")) result <- do.call(original, c(list(srt = srt), parameters))
    else result <- do.call(original, c(list(srt_query = qry, srt_ref = ref), parameters))
  } else {
    module <- new.env(parent = globalenv())
    source(file.path(config$module_dir, "code/analysis.R"), local = module)
    set.seed(11L)
    if (identical(config$method, "doublet-detection")) result <- module$run_doublet_detection(srt, parameters = parameters)$result
    else result <- module$run_cell_type_annotation(qry, ref, parameters = parameters)$result
  }
  report$checks$actual_invocation <- TRUE
  stopifnot(inherits(result, "Seurat"))
  original_cells <- if (identical(config$method, "doublet-detection")) colnames(srt) else colnames(qry)
  stopifnot(identical(colnames(result), original_cells), identical(input_before, input_current()))
  metadata <- result[[]]
  columns <- if (identical(config$method, "doublet-detection")) c("db.scDblFinder_class", "db.scDblFinder_score")
             else c("singler_annotation", "singler_score")
  if (!all(columns %in% colnames(metadata))) stop("Original/wrapper result lacks expected metadata columns: ", paste(columns, collapse = ", "))
  keys <- list(cell_ids = colnames(result), metadata_cell_ids = rownames(metadata), metadata = metadata[, columns, drop = FALSE])
  stopifnot(nrow(keys$metadata) == length(original_cells), identical(rownames(keys$metadata), original_cells))
  saveRDS(result, config$result_path)
  saveRDS(keys, config$keys_path)
  report$key_arrays <- keys
  report$checks <- list(actual_invocation = TRUE, input_object_unchanged = TRUE,
                       cell_order_and_identifiers_preserved = TRUE, output_assertions = TRUE)
  report$state <- "executed"
}, error = function(error) {
  report$error_calls <<- lapply(sys.calls(), function(call) paste(deparse(call, width.cutoff = 500L), collapse = " "))
  report$error_condition_call <<- paste(deparse(conditionCall(error), width.cutoff = 500L), collapse = " ")
}), error = function(error) {
  report$error <<- conditionMessage(error)
})
if (!is.null(input_before)) {
  report$checks$input_object_unchanged <- identical(input_before, input_current())
}
packages <- loadedNamespaces()
report$environment <- list(R = as.character(getRversion()), platform = R.version$platform,
  packages = setNames(lapply(packages, function(package) as.character(utils::packageVersion(package))), packages),
  automatic_installation = FALSE)
report$mode <- config$mode
report$method <- config$method
jsonlite::write_json(report, config$child_path, auto_unbox = TRUE, pretty = TRUE, null = "null", digits = NA)
if (!identical(report$state, "executed")) quit(status = 1L)
