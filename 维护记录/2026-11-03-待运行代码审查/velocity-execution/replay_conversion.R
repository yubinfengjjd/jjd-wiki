# Replay only conversion of an already-computed public velocity object.
args <- commandArgs(TRUE)
config <- jsonlite::read_json(args[[1]], simplifyVector = FALSE)
report <- list(state = "not_run", stage = "setup", checks = list())
tryCatch(withCallingHandlers({
  for (package in c("reticulate", "Seurat", "SeuratObject", "Matrix", "rlang")) {
    suppressPackageStartupMessages(library(package, character.only = TRUE))
  }
  module <- new.env(parent = globalenv())
  source(file.path(config$module_dir, "code/analysis.R"), local = module)
  impl <- environment(module$run_rna_velocity)$impl
  adata <- reticulate::import("scanpy", convert = FALSE)$read_h5ad(config$h5ad)
  if (isTRUE(config$legacy_assay_trial)) options(Seurat.object.assay.version = "v3")
  report$stage <- "adata_to_srt"
  converted <- impl$adata_to_srt(adata)
  report$checks$adata_to_srt <- TRUE
  saveRDS(converted, file.path(config$output, "converted.rds"))
  load(config$fixture)
  srt <- pancreas_sub[, seq_len(80L)]
  report$stage <- "SrtAppend first"
  first <- impl$SrtAppend(srt_raw = srt, srt_append = converted)
  report$checks$first_append <- TRUE
  report$stage <- "SrtAppend second"
  result <- impl$SrtAppend(srt_raw = first, srt_append = converted,
    pattern = "(velocity)|(distances)|(connectivities)|(Ms)|(Mu)|(stochastic)|(paga)",
    overwrite = TRUE, verbose = FALSE)
  saveRDS(result, file.path(config$output, "result.rds"))
  report$checks$final_cells_unchanged <- identical(colnames(result), colnames(srt))
  report$state <- "executed"
  report$stage <- "completed"
}, error = function(error) {
  report$error_call_symbols <<- lapply(sys.calls(), function(call) as.character(call[[1]])[[1]])
  report$condition_call <<- substr(paste(deparse(conditionCall(error)), collapse = " "), 1L, 300L)
}), error = function(error) report$error <<- conditionMessage(error))
jsonlite::write_json(report, file.path(config$output, "conversion.json"), auto_unbox = TRUE,
  pretty = TRUE, null = "null", digits = NA)
if (!identical(report$state, "executed")) quit(status = 1L)
