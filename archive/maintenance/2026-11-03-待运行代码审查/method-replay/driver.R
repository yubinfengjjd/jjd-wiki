# Execute only a reviewed historical case; never install or infer missing inputs.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("usage: driver.R <case.json>")
if (!requireNamespace("jsonlite", quietly = TRUE)) stop("Missing R dependency: jsonlite")
config <- jsonlite::read_json(args[[1]], simplifyVector = FALSE)
report <- list(state = "not_run", checks = list(), error = NULL)
finish <- function() {
  versions <- setNames(lapply(loadedNamespaces(), function(name) as.character(utils::packageVersion(name))), loadedNamespaces())
  report$environment <<- list(R = as.character(getRversion()), platform = R.version$platform,
                             packages = versions, automatic_installation = FALSE)
  jsonlite::write_json(report, config$child_path, auto_unbox = TRUE, pretty = TRUE, null = "null")
}
tryCatch({
  required <- unlist(config$required_packages$R, use.names = FALSE)
  missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Missing declared R dependencies: ", paste(missing, collapse = ", "))
  if (identical(config$driver$kind, "historical_portable")) {
    sidecar <- sub("[.]rds$", ".json", config$result_path)
    result <- readRDS(config$result_path)
    detail <- jsonlite::read_json(sidecar, simplifyVector = FALSE)
    if (!identical(detail$state, "passed")) stop("Historical invocation did not complete: ", detail$error)
    stopifnot(isTRUE(result$input_unchanged), isTRUE(detail$input_unchanged))
    meaningful <- (!is.null(result$seurat) && length(result$seurat$cells) > 0L) || !is.null(result$raw)
    if (!meaningful) stop("No actual method result saved")
    report$checks <- list(actual_invocation = TRUE, input_object_unchanged = TRUE,
                          output_assertions = TRUE, nonempty_result = meaningful)
    report$parameters <- detail$case
  } else if (identical(config$driver$kind, "recorded_velocity")) {
    data_env <- new.env(parent = globalenv())
    load(config$fixture, envir = data_env)
    stopifnot(inherits(data_env$pancreas_sub, "Seurat"))
    if (!all(c("RNA", "spliced", "unspliced") %in% names(data_env$pancreas_sub@assays))) stop("Pinned input unexpectedly lacks real RNA/spliced/unspliced assays")
    case <- config$driver$case
    srt <- data_env$pancreas_sub[, seq_len(as.integer(case$cells))]
    # Preserve observed cell identifiers and metadata; no artificial velocity/time.
    before <- serialize(srt, NULL)
    module <- new.env(parent = globalenv())
    source(file.path(config$module_dir, config$entry), local = module)
    parameters <- case$parameters
    parameters$assay_layers <- unlist(parameters$assay_layers, use.names = FALSE)
    set.seed(as.integer(case$seed))
    future::plan("sequential")
    options(future.globals.maxSize = 4 * 1024^3)
    fn <- get(config$entry_function, envir = module, inherits = FALSE)
    out <- fn(srt, parameters = parameters)
    result <- out$result
    stopifnot(inherits(result, "Seurat"), identical(before, serialize(srt, NULL)))
    if (!identical(colnames(result), colnames(srt))) stop("Velocity output changed input cell order/identifiers")
    velocity_assays <- grep("velocity|stochastic", names(result@assays), value = TRUE)
    if (!length(velocity_assays)) stop("Actual backend returned no computed velocity assay")
    for (assay in velocity_assays) {
      values <- SeuratObject::GetAssayData(result, assay = assay, layer = "counts")
      if (!length(values) || !all(is.finite(values))) stop("Computed velocity assay is empty or nonfinite: ", assay)
    }
    # Keep the actual full object for downstream VelocityPlot/grid replay.
    saveRDS(result, config$result_path)
    report$velocity_assays <- velocity_assays
    report$diagnostics <- out$diagnostics
    report$backend_python <- Sys.getenv("RETICULATE_PYTHON")
    report$backend_scope <- "Current source uses installed SCP's Python backend; this audit does not establish standalone backend closure."
    report$checks <- list(actual_invocation = TRUE, input_object_unchanged = TRUE,
                          output_assertions = TRUE, actual_velocity_assay = TRUE)
  } else if (identical(config$driver$kind, "recorded_plot")) {
    data_env <- new.env(parent = globalenv())
    load(config$fixture, envir = data_env)
    if (!inherits(data_env$pancreas_sub, "Seurat")) stop("Public fixture has no pancreas_sub Seurat object")
    before <- serialize(data_env$pancreas_sub, NULL)
    resolve <- function(value) {
      if (is.character(value) && length(value) == 1L && startsWith(value, "@")) {
        if (!identical(value, "@pancreas_sub")) stop("Unsupported input token; no evaluation allowed")
        return(data_env$pancreas_sub)
      }
      if (is.list(value)) {
        if (is.null(names(value)) && all(vapply(value, function(x) is.atomic(x) && length(x) == 1L, logical(1)))) return(unlist(value))
        return(lapply(value, resolve))
      }
      value
    }
    module <- new.env(parent = globalenv())
    source(file.path(config$module_dir, config$entry), local = module)
    fn <- get(config$entry_function, envir = module, inherits = FALSE)
    case <- config$driver$case
    if (!is.null(case$seed)) set.seed(as.integer(case$seed))
    result <- do.call(fn, lapply(case$args, resolve))
    if (is.null(result)) stop("Plot invocation returned NULL")
    stopifnot(identical(before, serialize(data_env$pancreas_sub, NULL)))
    saveRDS(result, config$result_path)
    plot <- if (is.list(result) && !inherits(result, c("gg", "ggplot", "patchwork")) && !is.null(result$plot)) result$plot else result
    if (inherits(plot, "htmlwidget")) {
      htmlwidgets::saveWidget(plot, "plot.html", selfcontained = FALSE)
      stopifnot(file.info("plot.html")$size > 0)
    } else {
      grDevices::pdf("plot.pdf", width = 8, height = 6)
      tryCatch({
        if (inherits(plot, c("Heatmap", "HeatmapList"))) ComplexHeatmap::draw(plot)
        else if (inherits(plot, c("grob", "gTree", "gtable"))) grid::grid.draw(plot)
        else if (inherits(plot, c("gg", "ggplot", "patchwork"))) print(plot)
        else stop("Unsupported plot result class: ", paste(class(plot), collapse = ", "))
      }, finally = grDevices::dev.off())
      stopifnot(file.info("plot.pdf")$size > 0)
    }
    report$result_class <- class(result)
    report$checks <- list(actual_invocation = TRUE, input_object_unchanged = TRUE,
                          output_assertions = TRUE, rendered_nonempty_plot = TRUE,
                          visual_review = "pending")
  } else stop("Unknown reviewed driver kind")
  report$state <- "executed"
}, error = function(error) {
  report$error <<- conditionMessage(error)
})
finish()
if (!identical(report$state, "executed")) quit(status = 1L)
