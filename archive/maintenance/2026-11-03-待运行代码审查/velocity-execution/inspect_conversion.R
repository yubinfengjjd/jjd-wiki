# Keep genuine computed AnnData before diagnosing the R conversion boundary.
args <- commandArgs(TRUE)
config <- jsonlite::read_json(args[[1]], simplifyVector = FALSE)
report <- list(state = "not_run", stage = "setup", checks = list())
tryCatch(withCallingHandlers({
  load(config$fixture)
  srt <- pancreas_sub[, seq_len(80L)]
  before <- serialize(srt, NULL)
  module <- new.env(parent = globalenv())
  source(file.path(config$module_dir, "code/analysis.R"), local = module)
  set.seed(11L)
  parameters <- list(assay_X = "RNA", assay_layers = c("spliced", "unspliced"),
    group_by = "CellType", linear_reduction = "PCA", basis = "PCA", return_seurat = FALSE)
  report$stage <- "native velocity calculation"
  actual <- module$run_rna_velocity(srt, parameters = parameters)
  adata <- actual$result
  adata$write_h5ad(file.path(config$output, "computed-velocity.h5ad"))
  py <- reticulate::py
  py$velocity_audit_adata <- adata
  reticulate::py_run_string(paste(
    "import numpy as np",
    "a = velocity_audit_adata",
    "velocity_audit_checks = {'cells': int(a.n_obs), 'genes': int(a.n_vars),",
    "'finite_velocity': bool(np.isfinite(a.layers['stochastic']).all()),",
    "'finite_graph': bool(np.isfinite(a.uns['stochastic_graph'].data).all()),",
    "'velocity_graph_computed': bool(a.uns['stochastic_graph'].shape == (80, 80)),",
    "'finite_embedded_velocity': bool(np.isfinite(a.obsm['stochastic_PCA']).all())}", sep = "\n"))
  report$python_checks <- reticulate::py_eval("velocity_audit_checks", convert = TRUE)
  report$checks$actual_velocity_calculation <- TRUE
  report$checks$input_object_unchanged <- identical(before, serialize(srt, NULL))
  impl <- environment(module$run_rna_velocity)$impl
  report$stage <- "adata_to_srt"
  converted <- impl$adata_to_srt(adata)
  report$checks$adata_to_srt <- TRUE
  saveRDS(converted, file.path(config$output, "converted.rds"))
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
}), error = function(error) report$error <<- conditionMessage(error))
jsonlite::write_json(report, file.path(config$output, "result.json"), auto_unbox = TRUE,
  pretty = TRUE, null = "null", digits = NA)
if (!identical(report$state, "executed")) quit(status = 1L)
