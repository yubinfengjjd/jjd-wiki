# Standalone minimal module: SCP CellScoring.
# GPL (>= 3). Extracted from SCP-local v0.5.6. Algorithm logic is copied
# verbatim; see runtime.json for the source map and verified scope.
#
# Copy this code/ directory only. No SCP-local bundle is required or read.
# Source-time side effects: function definitions only. Runtime packages are
# checked and attached per call, then detached if this call attached them.
# Automatic installation is disabled. The deprecated `bundle` argument is
# accepted for compatibility and is never read.

.scp_impl <- new.env(parent = globalenv())
.scp_impl_dir <- local({
  file <- NULL
  for (i in seq_len(sys.nframe())) {
    candidate <- tryCatch(sys.frame(i)$ofile, error = function(e) NULL)
    if (!is.null(candidate) && nzchar(candidate)) {
      file <- candidate
      break
    }
  }
  if (!is.null(file)) dirname(normalizePath(file, mustWork = TRUE)) else normalizePath(getwd(), mustWork = TRUE)
})
sys.source(file.path(.scp_impl_dir, "scoring_native.R"), envir = .scp_impl)

# Compatibility shim: SeuratObject >= 5 makes the `slot` argument of
# GetAssayData defunct. SCP 0.5.6 calls GetAssayData(slot = ...); map the same
# layer name explicitly. No value or default changes.
.scp_impl$GetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, ...) {
  if (is.null(layer) && !is.null(slot)) layer <- slot
  SeuratObject::GetAssayData(object = object, assay = assay, layer = layer, ...)
}

# Compatibility shim: SeuratObject >= 5 makes Assays(object, <assay name>)
# defunct. SCP 0.5.6 uses it to fetch one Assay object. Restore the old
# behavior without changing the object or defaults.
.scp_impl$Assays <- function(object, slot = NULL, ...) {
  if (!is.null(slot)) return(methods::slot(object = object, name = 'assays')[[slot]])
  SeuratObject::Assays(object = object, ...)
}

# Fail-only replacements for the upstream installation helpers.
.scp_impl$check_R <- function(packages, ...) {
  for (spec in packages) {
    parts <- strsplit(spec, '@|==')[[1]]
    package <- sub('^.*/', '', parts[1])
    if (!requireNamespace(package, quietly = TRUE)) {
      stop('Missing R dependency: ', package, '; automatic installation is disabled', call. = FALSE)
    }
    if (length(parts) > 1 && utils::packageVersion(package) < package_version(parts[2])) {
      stop('R dependency too old: ', package, '; requires >= ', parts[2], call. = FALSE)
    }
  }
  invisible(NULL)
}
.scp_impl$check_Python <- function(packages, ...) {
  if (!nzchar(Sys.getenv('RETICULATE_PYTHON'))) {
    stop('Set RETICULATE_PYTHON to an existing project interpreter; installation disabled', call. = FALSE)
  }
  for (package in packages) {
    module <- sub('[-].*', '', sub('==.*', '', package))
    if (!reticulate::py_module_available(module)) {
      stop('Missing Python dependency: ', package, '; automatic installation is disabled', call. = FALSE)
    }
  }
  invisible(NULL)
}
.scp_impl$PrepareEnv <- function(...) {
  stop('Automatic environment creation disabled', call. = FALSE)
}
.scp_impl$conda_install <- function(...) {
  stop('Automatic environment installation disabled', call. = FALSE)
}

.scp_check_packages <- function(packages) {
  for (package in unique(packages)) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop('Missing R dependency: ', package, '; automatic installation is disabled', call. = FALSE)
    }
  }
}
.scp_attach <- function(packages) {
  packages <- unique(packages)
  attached <- vapply(packages, function(p) paste0('package:', p) %in% search(), logical(1))
  new <- packages[!attached]
  for (package in new) {
    suppressPackageStartupMessages(library(package, character.only = TRUE, quietly = TRUE))
  }
  new
}
.scp_detach <- function(packages) {
  for (package in rev(packages)) {
    try(detach(paste0('package:', package), character.only = TRUE, unload = FALSE), silent = TRUE)
  }
}
.scp_load_plot_data <- function() {
  file <- file.path(.scp_impl_dir, 'data', 'palette_list.rda')
  if (file.exists(file)) load(file, envir = .scp_impl)
  invisible(NULL)
}

.scp_run <- function(name, arguments, required, optional = list(), features = character()) {
  use <- required
  for (feature in features) {
    add <- optional[[feature]]
    if (!is.null(add)) use <- c(use, add)
  }
  .scp_check_packages(use)
  newly <- .scp_attach(use)
  old_options <- options()
  on.exit(.scp_detach(newly), add = TRUE)
  on.exit(options(old_options), add = TRUE)
  if ('plot' %in% features) .scp_load_plot_data()
  warnings <- character()
  result <- withCallingHandlers(
    do.call(.scp_impl[[name]], arguments),
    warning = function(w) warnings <<- c(warnings, conditionMessage(w))
  )
  packages <- loadedNamespaces()
  versions <- setNames(lapply(packages, function(x) as.character(utils::packageVersion(x))), packages)
  list(
    result = result,
    diagnostics = list(
      upstream_function = name,
      source_version = 'SCP-local 0.5.6; minimal call closure',
      parameters = arguments[setdiff(names(arguments), c('srt', 'srtMerge', 'srt_query', 'srt_ref'))],
      warnings = unique(warnings),
      dependency_versions = versions,
      automatic_installation = FALSE,
      loader_side_effects = 'none; only packages needed by this call are attached, and detached if newly attached',
      rng = 'upstream function may set/change global RNG state'
    )
  )
}

.scp_features <- function(parameters) {
  features <- character()
  method <- parameters$method
  if (!is.null(method) && method %in% c('AUCell', 'UCell')) features <- c(features, paste0('method:', method))
  if (is.null(parameters$features)) features <- c(features, 'database')
  features
}

# Source mapping: SCP-local/R/SCP-analysis.R:CellScoring (+ AddModuleScore2); no algorithm rewritten.
run_gene_set_scoring <- function(srt, bundle = NULL, parameters = list()) {
  if (!is.null(bundle)) {
    warning('`bundle` is deprecated and ignored; this module uses only its local call closure', call. = FALSE)
  }
  if (!is.list(parameters) || (length(parameters) &&
      (is.null(names(parameters)) || any(!nzchar(names(parameters))) || anyDuplicated(names(parameters))))) {
    stop('parameters must be a uniquely named list')
  }
  .scp_run(
    'CellScoring',
    c(list(srt = srt), parameters),
    required = c('Seurat', 'SeuratObject', 'Matrix', 'BiocParallel', 'rlang', 'ggplot2'),
    optional = list('method:AUCell' = c('AUCell'), 'method:UCell' = c('UCell'), 'database' = c('clusterProfiler', 'biomaRt', 'R.cache', 'AnnotationDbi', 'reshape2')),
    features = .scp_features(parameters)
  )
}
