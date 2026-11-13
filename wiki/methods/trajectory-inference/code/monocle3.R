# Seurat adapter for the Monocle3 analysis core. The core in
# monocle3_core.R performs clustering, graph learning and ordering without
# Seurat; this adapter only extracts counts/embeddings and writes Pseudotime
# and cluster labels back. Plotting is the separate optional monocle3_plot.R.
#
# Copy this code/ directory only. No SCP-local bundle is required or read.

run_trajectory_monocle3 <- local({
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
  sys.source(file.path(.scp_dir, "monocle3_core.R"), envir = core_env, chdir = TRUE)
  core <- core_env$run_monocle3_core

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
    reduction <- parameters$reduction
    if (is.null(reduction)) {
      reduction <- SeuratObject::DefaultDimReduc(srt)
    }
    expression_data <- SeuratObject::GetAssayData(srt, assay = assay, layer = layer)
    reduced_dim <- SeuratObject::Embeddings(srt[[reduction]])
    loadings <- tryCatch(Seurat::Loadings(srt[[reduction]]), error = function(e) NULL)
    stdev <- tryCatch(Seurat::Stdev(srt[[reduction]]), error = function(e) NULL)
    size_factor <- NULL
    size_column <- paste0("nCount_", assay)
    if (size_column %in% colnames(srt[[]])) size_factor <- srt[[size_column, drop = TRUE]]
    clusters <- NULL
    if (!is.null(parameters$clusters)) clusters <- srt[[parameters$clusters, drop = TRUE]]
    graph <- NULL
    if (!is.null(parameters$graph)) graph <- srt[[parameters$graph]]
    fields <- c("partition_qval", "k", "cluster_method", "num_iter", "resolution",
                "use_partition", "close_loop", "root_pr_nodes", "root_cells", "seed")
    core_arguments <- c(list(
      expression_data = expression_data,
      cell_metadata = srt[[]],
      size_factor = size_factor,
      reduced_dim = reduced_dim,
      loadings = loadings,
      stdev = stdev,
      clusters = clusters,
      graph = graph
    ), parameters[intersect(names(parameters), fields)])
    result <- do.call(core, core_arguments)
    srt[["Monocle3_Pseudotime"]] <- result$pseudotime
    srt[["Monocle3_clusters"]] <- result$clusters
    srt[["Monocle3_partitions"]] <- result$partitions
    srt@tools$Monocle3 <- list(cds = result$cds, use_partition = result$use_partition,
                               root_pr_nodes = result$root_pr_nodes,
                               root_cells = result$root_cells)
    search_restored <- restore_search(before_search)
    options_restored <- identical(options()[names(old_options)], old_options)
    options(old_options)
    list(
      result = srt,
      diagnostics = list(
        upstream_function = "RunMonocle3 (analysis core + Seurat adapter)",
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
        rng = "upstream function may set/change global R state",
        plotting = "not part of this entry; use plot_monocle3 on the result"
      )
    )
  }
})
