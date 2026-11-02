# Standalone minimal module: SCP RunEnrichment.
# GPL (>= 3). Extracted from SCP-local v0.5.6. Algorithm logic is copied
# verbatim; see runtime.json for the source map and verified scope.
#
# Copy this code/ directory only. No SCP-local bundle is required or read.
# Source-time side effects: function definitions and the native module source
# only. Runtime packages are checked and attached per call; the search path
# and options are restored before returning. Automatic installation and
# environment creation are disabled. The deprecated `bundle` argument is
# accepted for compatibility and is never read.
run_gene_set_enrichment <- local({
  .scp_dir <- local({
    file <- NULL
    for (i in rev(seq_len(sys.nframe()))) {
      candidate <- tryCatch(sys.frame(i)$ofile, error = function(e) NULL)
      if (!is.null(candidate) && nzchar(candidate)) {
        file <- candidate
        break
      }
    }
    if (!is.null(file)) dirname(normalizePath(file, mustWork = TRUE)) else normalizePath(getwd(), mustWork = TRUE)
  })
  impl <- new.env(parent = globalenv())
  sys.source(file.path(.scp_dir, 'enrichment_native.R'), envir = impl)
  impl$GetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, ...) {{
    if (is.null(layer) && !is.null(slot)) layer <- slot
    SeuratObject::GetAssayData(object = object, assay = assay, layer = layer, ...)
  }}
  impl$Assays <- function(object, slot = NULL, ...) {{
    if (!is.null(slot)) return(methods::slot(object = object, name = 'assays')[[slot]])
    SeuratObject::Assays(object = object, ...)
  }}
  impl$check_R <- function(packages, ...) {{
    for (spec in packages) {{
      parts <- strsplit(spec, '@|==')[[1]]
      package <- sub('^.*/', '', parts[1])
      if (!requireNamespace(package, quietly = TRUE)) {{
        stop('Missing R dependency: ', package, '; automatic installation is disabled', call. = FALSE)
      }}
      if (length(parts) > 1 && utils::packageVersion(package) < package_version(parts[2])) {{
        stop('R dependency too old: ', package, '; requires >= ', parts[2], call. = FALSE)
      }}
    }}
    invisible(NULL)
  }}
  impl$check_Python <- function(packages, ...) {{
    if (!nzchar(Sys.getenv('RETICULATE_PYTHON'))) {{
      stop('Set RETICULATE_PYTHON to an existing project interpreter; installation disabled', call. = FALSE)
    }}
    for (package in packages) {{
      module <- sub('[-].*', '', sub('==.*', '', package))
      if (!reticulate::py_module_available(module)) {{
        stop('Missing Python dependency: ', package, '; automatic installation is disabled', call. = FALSE)
      }}
    }}
    invisible(NULL)
  }}
  impl$PrepareEnv <- function(...) stop('Automatic environment creation disabled', call. = FALSE)
  impl$conda_install <- function(...) stop('Automatic environment installation disabled', call. = FALSE)

  check_packages <- function(packages) {
    for (package in unique(packages)) {
      if (!requireNamespace(package, quietly = TRUE)) {
        stop('Missing R dependency: ', package, '; automatic installation is disabled', call. = FALSE)
      }
    }
  }
  restore_search <- function(before) {
    if (identical(search(), before)) return(TRUE)
    for (round in seq_len(5)) {
      added <- setdiff(search(), before)
      if (!length(added)) break
      for (package in rev(added)) {
        try(detach(package, character.only = TRUE, unload = FALSE), silent = TRUE)
      }
    }
    identical(search(), before)
  }
  load_plot_data <- function() {
    file <- file.path(.scp_dir, 'data', 'palette_list.rda')
    if (file.exists(file)) load(file, envir = impl)
    invisible(NULL)
  }
  run_scp <- function(name, arguments, required, optional = list(), features = character()) {
    use <- required
    for (feature in features) {
      add <- optional[[feature]]
      if (!is.null(add)) use <- c(use, add)
    }
    check_packages(use)
    before_search <- search()
    old_options <- options()
    on.exit({
      restore_search(before_search)
      options(old_options)
    }, add = TRUE)
    for (package in unique(use)) {
      suppressPackageStartupMessages(library(package, character.only = TRUE, quietly = TRUE))
    }
    if ('plot' %in% features) load_plot_data()
    warnings <- character()
    result <- withCallingHandlers(
      do.call(impl[[name]], arguments),
      warning = function(w) warnings <<- c(warnings, conditionMessage(w))
    )
    search_restored <- restore_search(before_search)
    options_restored <- identical(options()[names(old_options)], old_options)
    options(old_options)
    if (!search_restored) warning('package search path was not fully restored', call. = FALSE)
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
        search_restored = search_restored,
        options_restored = options_restored,
        loader_side_effects = if (search_restored && options_restored) {
          'none; search path and options restored'
        } else {
          'restoration incomplete; see search_restored/options_restored'
        },
        rng = 'upstream function may set/change global RNG state'
      )
    )
  }

  features_fn <- function(parameters) {
  features <- character()
  if (is.null(parameters$TERM2GENE)) features <- c(features, 'database')
  idtype <- parameters$IDtype
  result_idtype <- parameters$result_IDtype
  if (is.null(idtype)) idtype <- 'symbol'
  if (is.null(result_idtype)) result_idtype <- 'symbol'
  if (!identical(idtype, result_idtype)) features <- c(features, 'idconvert')
  features
}
  function(gene_ids, bundle = NULL, parameters = list()) {
    if (!is.null(bundle)) {
      warning('`bundle` is deprecated and ignored; this module uses only its local call closure', call. = FALSE)
    }
    if (!is.list(parameters) || (length(parameters) &&
        (is.null(names(parameters)) || any(!nzchar(names(parameters))) || anyDuplicated(names(parameters))))) {
      stop('parameters must be a uniquely named list')
    }
    out <- run_scp(
      'RunEnrichment',
      c(list(geneID = gene_ids), parameters),
      required = c('clusterProfiler', 'BiocParallel', 'rlang'),
      optional = list('database' = c('org.Hs.eg.db', 'org.Mm.eg.db', 'GO.db', 'msigdbr', 'gson', 'AnnotationDbi', 'biomaRt', 'R.cache', 'reshape2', 'data.table'), 'idconvert' = c('biomaRt', 'AnnotationDbi', 'R.cache', 'reshape2', 'data.table')),
      features = features_fn(parameters)
    )
  }
})

