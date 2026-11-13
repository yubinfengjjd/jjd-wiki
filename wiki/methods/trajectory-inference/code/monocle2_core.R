# Monocle2 analysis core, extracted from SCP-local v0.5.6 RunMonocle2.
# GPL (>= 3). The ordering helpers are copied verbatim; RunMonocle2's analysis
# steps are kept, while plotting, interactive root selection and Seurat
# object conversion are removed. The caller must supply features and root_state.
#
# Copy this code/ directory only. No SCP-local bundle is required or read.

run_monocle2_core <- local({
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
  sys.source(file.path(.scp_dir, "monocle2_core_helpers.R"), envir = impl)

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
  with_packages <- function(packages, code) {
    check_packages(packages)
    before <- search()
    on.exit(restore_search(before), add = TRUE)
    for (package in unique(packages)) {
      suppressPackageStartupMessages(library(package, character.only = TRUE, quietly = TRUE))
    }
    force(code)
  }

  function(expression_data, cell_metadata, gene_metadata = NULL,
           features = NULL, expressionFamily = "negbinomial.size",
           max_components = 2, reduction_method = "DDRTree", norm_method = "log",
           residualModelFormulaStr = NULL, pseudo_expr = 1,
           feature_type = "HVF", disp_filter = "mean_expression >= 0.1 & dispersion_empirical >= 1 * dispersion_fit",
           root_state = NULL, seed = 11) {
    if (!is.null(root_state) && (!is.character(root_state) && !is.numeric(root_state))) {
      stop("root_state must identify one monocle2 state", call. = FALSE)
    }
    if (is.null(root_state) || !length(root_state)) {
      stop("root_state must be supplied explicitly; the core does not prompt or guess the final root",
           call. = FALSE)
    }
    if (is.null(features) && !identical(feature_type, "Disp")) {
      stop("features must be supplied by the caller (e.g. VariableFeatures) for feature_type='HVF'",
           call. = FALSE)
    }
    with_packages(c("monocle", "DDRTree", "VGAM", "BiocGenerics", "Biobase", "igraph", "Matrix", "rlang"), {
      set.seed(seed)
      if (is.null(gene_metadata)) {
        gene_metadata <- data.frame(gene_short_name = rownames(expression_data),
                                    row.names = rownames(expression_data))
      }
      pd <- methods::new("AnnotatedDataFrame", data = as.data.frame(cell_metadata))
      fd <- methods::new("AnnotatedDataFrame", data = as.data.frame(gene_metadata))
      cds <- monocle::newCellDataSet(
        expression_data,
        phenoData = pd,
        featureData = fd,
        expressionFamily = do.call(get(expressionFamily, envir = getNamespace("VGAM")), args = list())
      )
      if (any(c("negbinomial", "negbinomial.size") %in% expressionFamily)) {
        cds <- BiocGenerics::estimateSizeFactors(cds)
        cds <- BiocGenerics::estimateDispersions(cds)
      }
      if (is.null(features)) {
        features <- subset(monocle::dispersionTable(cds), eval(rlang::parse_expr(disp_filter)))$gene_id
      }
      if (!length(features)) {
        stop("No features selected for monocle2 ordering", call. = FALSE)
      }
      cds <- monocle::setOrderingFilter(cds, features)
      cds <- monocle::reduceDimension(
        cds = cds,
        max_components = max_components,
        reduction_method = reduction_method,
        norm_method = norm_method,
        residualModelFormulaStr = residualModelFormulaStr,
        pseudo_expr = pseudo_expr
      )
      cds <- impl$orderCells(cds)
      cds <- impl$orderCells(cds, root_state = root_state)
      embeddings <- t(cds@reducedDimS)
      colnames(embeddings) <- paste0(cds@dim_reduce_type, "_", seq_len(ncol(embeddings)))
      list(
        cds = cds,
        embeddings = embeddings,
        reduced_dim_type = cds@dim_reduce_type,
        pseudotime = cds[["Pseudotime"]],
        state = cds[["State"]],
        features = features,
        root_state = root_state
      )
    })
  }
})
