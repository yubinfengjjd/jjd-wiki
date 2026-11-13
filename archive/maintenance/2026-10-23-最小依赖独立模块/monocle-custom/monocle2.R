# Seurat adapter for the Monocle2 analysis core. The core in
# monocle2_core.R performs the algorithm and has no Seurat dependency; this
# adapter only extracts counts/metadata, supplies VariableFeatures, and writes
# State/Pseudotime back to a Seurat object. Plotting is a separate optional
# entry (monocle2_plot.R).
#
# Copy this code/ directory only. No SCP-local bundle is required or read.

run_trajectory_monocle2 <- local({
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
  core_env <- new.env(parent = globalenv())
  sys.source(file.path(.scp_dir, "monocle2_core.R"), envir = core_env, chdir = TRUE)
  core <- core_env$run_monocle2_core

  check_packages <- function(packages) {
    for (package in unique(packages)) {
      if (!requireNamespace(package, quietly = TRUE)) {
        stop("Missing R dependency: ", package, "; automatic installation is disabled", call. = FALSE)
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

  function(srt, bundle = NULL, parameters = list()) {
    if (!is.null(bundle)) {
      warning("`bundle` is deprecated and ignored; this adapter uses only its local call closure", call. = FALSE)
    }
    if (!is.list(parameters) || (length(parameters) &&
        (is.null(names(parameters)) || any(!nzchar(names(parameters))) || anyDuplicated(names(parameters))))) {
      stop("parameters must be a uniquely named list", call. = FALSE)
    }
    packages <- c("Seurat", "SeuratObject", "Matrix", "rlang")
    check_packages(packages)
    before_search <- search()
    old_options <- options()
    on.exit({
      restore_search(before_search)
      options(old_options)
    }, add = TRUE)
    for (package in packages) {
      suppressPackageStartupMessages(library(package, character.only = TRUE, quietly = TRUE))
    }
    assay <- parameters$assay
    if (is.null(assay)) assay <- Seurat::DefaultAssay(srt)
    layer <- parameters$slot
    if (is.null(layer)) layer <- "counts"
    expression_data <- SeuratObject::GetAssayData(srt, assay = assay, layer = layer)
    features <- parameters$features
    if (is.null(features)) {
      features <- Seurat::VariableFeatures(srt, assay = assay)
      if (!length(features)) {
        features <- Seurat::VariableFeatures(
          Seurat::FindVariableFeatures(srt, assay = assay, verbose = FALSE), assay = assay)
      }
    }
    fields <- c("expressionFamily", "max_components", "reduction_method", "norm_method",
                "residualModelFormulaStr", "pseudo_expr", "feature_type", "disp_filter",
                "root_state", "seed")
    core_arguments <- c(list(expression_data = expression_data,
                             cell_metadata = srt[[]],
                             features = features),
                        parameters[intersect(names(parameters), fields)])
    result <- do.call(core, core_arguments)
    type <- result$reduced_dim_type
    srt[[type]] <- SeuratObject::CreateDimReducObject(
      embeddings = result$embeddings, key = paste0(type, "_"), assay = assay)
    srt[["Monocle2_State"]] <- result$state
    srt[["Monocle2_Pseudotime"]] <- result$pseudotime
    srt@tools$Monocle2 <- list(cds = result$cds, features = result$features,
                               root_state = result$root_state)
    search_restored <- restore_search(before_search)
    options_restored <- identical(options()[names(old_options)], old_options)
    options(old_options)
    list(
      result = srt,
      diagnostics = list(
        upstream_function = "RunMonocle2 (analysis core + Seurat adapter)",
        source_version = "SCP-local 0.5.6; minimal call closure",
        parameters = parameters[setdiff(names(parameters), c("srt", "bundle"))],
        warnings = character(),
        automatic_installation = FALSE,
        search_restored = search_restored,
        options_restored = options_restored,
        loader_side_effects = if (search_restored && options_restored) {
          "none; search path and options restored"
        } else {
          "restoration incomplete; see search_restored/options_restored"
        },
        rng = "upstream function may set/change global RNG state",
        plotting = "not part of this entry; use plot_monocle2 on the result"
      )
    )
  }
})
