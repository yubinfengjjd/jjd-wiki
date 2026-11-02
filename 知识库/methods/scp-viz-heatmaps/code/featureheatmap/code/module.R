# ============================================================================
# SCP 0.5.6 module: FeatureHeatmap  (source commit b9b0eb7a, read-only provenance)
# Self-contained private-closure module. Only FeatureHeatmap is exposed.
# - imported package symbols are lazy bindings in a private `imports` env:
#   a namespace loads only when code actually evaluates one of its exports.
# - installer functions (check_R/check_Python/PrepareEnv/conda_install/download)
#   are replaced by NO-INSTALL guards, bound after all source files and locked.
# ============================================================================
FeatureHeatmap <- local({
  # Isolate the module machinery from the CALLER's workspace: after this line
  # every free symbol below resolves only inside this env or base — a user
  # object named e.g. `matrix`/`search`/`options` can never shadow base here.
  # (the bare `local` name itself is the single residual lookup, required by
  # the official entry-function pattern `<name> <- local({`)
  base::`parent.env<-`(base::environment(), base::baseenv())
  .find_ofile <- function() {
    for (i in rev(seq_len(sys.nframe()))) {
      of <- tryCatch(get("ofile", envir = sys.frame(i), inherits = FALSE),
                     error = function(e) NULL)
      if (!is.null(of)) return(normalizePath(of, winslash = "/", mustWork = FALSE))
    }
    arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(arg)) return(normalizePath(sub("^--file=", "", arg[1]),
                                        winslash = "/", mustWork = FALSE))
    NULL
  }
  .this <- .find_ofile()
  .code_dir <- if (is.null(.this)) file.path(getwd(), "code") else dirname(.this)
  .mroot <- dirname(.code_dir)
  env <- new.env(parent = emptyenv())
  # Package-namespace semantics: module functions resolve free symbols via
  # env -> imports (NAMESPACE-imported + explicitly bound std-pkg symbols) ->
  # baseenv. The caller's global env is NOT an ancestor, so ordinary user
  # objects cannot shadow package/base symbols inside module code.
  imports <- new.env(parent = baseenv())
  parent.env(env) <- imports
  # lazy per-symbol bindings: package namespace loads only on first real use
  .lazy_sym <- function(pkg, sym) {
    eval(substitute(
      delayedAssign(NM, getExportedValue(PKG, NM), assign.env = imports),
      list(NM = sym, PKG = pkg)))
  }
  .lazy_sym('ComplexHeatmap', '%v%')
  .lazy_sym('rlang', '%||%')
  .lazy_sym('dplyr', '.data')
  .lazy_sym('stats', 'C')
  .lazy_sym('stats', 'D')
  .lazy_sym('SeuratObject', 'DefaultAssay')
  .lazy_sym('nlme', 'Dim')
  .lazy_sym('ComplexHeatmap', 'Heatmap')
  .lazy_sym('ComplexHeatmap', 'HeatmapAnnotation')
  .lazy_sym('ComplexHeatmap', 'Legend')
  .lazy_sym('tools', 'R')
  .lazy_sym('BiocParallel', 'SerialParam')
  .lazy_sym('igraph', 'V')
  .lazy_sym('Seurat', 'VariableFeatures')
  .lazy_sym('grid', 'addGrob')
  .lazy_sym('ggplot2', 'aes')
  .lazy_sym('stats', 'aggregate')
  .lazy_sym('ComplexHeatmap', 'anno_block')
  .lazy_sym('ComplexHeatmap', 'anno_empty')
  .lazy_sym('ComplexHeatmap', 'anno_mark')
  .lazy_sym('ComplexHeatmap', 'anno_simple')
  .lazy_sym('ComplexHeatmap', 'anno_textbox')
  .lazy_sym('methods', 'as')
  .lazy_sym('stats', 'as.dendrogram')
  .lazy_sym('stats', 'as.dist')
  .lazy_sym('Matrix', 'as.matrix')
  .lazy_sym('BiocParallel', 'bpRNGseed<-')
  .lazy_sym('BiocParallel', 'bplapply')
  .lazy_sym('BiocParallel', 'bpprogressbar<-')
  .lazy_sym('BiocParallel', 'bpworkers')
  .lazy_sym('graphics', 'clip')
  .lazy_sym('survival', 'cluster')
  .lazy_sym('ComplexHeatmap', 'cluster_within_group')
  .lazy_sym('grDevices', 'cm')
  .lazy_sym('grDevices', 'col2rgb')
  .lazy_sym('Matrix', 'colMeans')
  .lazy_sym('Matrix', 'colSums')
  .lazy_sym('nlme', 'collapse')
  .lazy_sym('circlize', 'colorRamp2')
  .lazy_sym('grDevices', 'colorRampPalette')
  .lazy_sym('grDevices', 'colors')
  .lazy_sym('AnnotationDbi', 'columns')
  .lazy_sym('boot', 'control')
  .lazy_sym('grid', 'convertHeight')
  .lazy_sym('grid', 'convertUnit')
  .lazy_sym('grid', 'convertWidth')
  .lazy_sym('stats', 'cutree')
  .lazy_sym('utils', 'data')
  .lazy_sym('reshape2', 'dcast')
  .lazy_sym('utils', 'de')
  .lazy_sym('ComplexHeatmap', 'decorate_annotation')
  .lazy_sym('stats', 'dendrapply')
  .lazy_sym('grDevices', 'dev.off')
  .lazy_sym('stats', 'df')
  .lazy_sym('Matrix', 'diff')
  .lazy_sym('proxyC', 'dist')
  .lazy_sym('dplyr', 'distinct')
  .lazy_sym('ComplexHeatmap', 'draw')
  .lazy_sym('Matrix', 'drop')
  .lazy_sym('ggplot2', 'element_blank')
  .lazy_sym('ggplot2', 'element_rect')
  .lazy_sym('ggplot2', 'element_text')
  .lazy_sym('clusterProfiler', 'enricher')
  .lazy_sym('Matrix', 'expand')
  .lazy_sym('dplyr', 'filter')
  .lazy_sym('utils', 'find')
  .lazy_sym('utils', 'fix')
  .lazy_sym('methods', 'formalArgs')
  .lazy_sym('Matrix', 'format')
  .lazy_sym('stats', 'formula')
  .lazy_sym('grid', 'gList')
  .lazy_sym('grid', 'gTree')
  .lazy_sym('ggplot2', 'geom_col')
  .lazy_sym('biomaRt', 'getBM')
  .lazy_sym('R.cache', 'getCacheRootPath')
  .lazy_sym('methods', 'getFunction')
  .lazy_sym('ggplot2', 'ggplot')
  .lazy_sym('ggplot2', 'ggplotGrob')
  .lazy_sym('ggplot2', 'ggsave')
  .lazy_sym('grid', 'gpar')
  .lazy_sym('grid', 'grid.draw')
  .lazy_sym('grid', 'grid.grabExpr')
  .lazy_sym('grid', 'grid.rect')
  .lazy_sym('grid', 'grid.text')
  .lazy_sym('grid', 'grob')
  .lazy_sym('grid', 'grobTree')
  .lazy_sym('dplyr', 'group_by')
  .lazy_sym('gtable', 'gtable')
  .lazy_sym('gtable', 'gtable_add_padding')
  .lazy_sym('gtable', 'gtable_col')
  .lazy_sym('ggplot2', 'guides')
  .lazy_sym('stats', 'hclust')
  .lazy_sym('utils', 'head')
  .lazy_sym('stats', 'heatmap')
  .lazy_sym('ComplexHeatmap', 'height.HeatmapAnnotation')
  .lazy_sym('BiocParallel', 'ipcid')
  .lazy_sym('BiocParallel', 'ipclock')
  .lazy_sym('BiocParallel', 'ipcunlock')
  .lazy_sym('methods', 'is')
  .lazy_sym('AnnotationDbi', 'keys')
  .lazy_sym('stats', 'kmeans')
  .lazy_sym('plotly', 'layout')
  .lazy_sym('graphics', 'legend')
  .lazy_sym('graphics', 'lines')
  .lazy_sym('biomaRt', 'listAttributes')
  .lazy_sym('biomaRt', 'listDatasets')
  .lazy_sym('biomaRt', 'listEnsemblArchives')
  .lazy_sym('R.cache', 'loadCache')
  .lazy_sym('AnnotationDbi', 'mappedkeys')
  .lazy_sym('ggplot2', 'margin')
  .lazy_sym('Matrix', 'mean')
  .lazy_sym('stats', 'median')
  .lazy_sym('reshape2', 'melt')
  .lazy_sym('ComplexHeatmap', 'merge_dendrogram')
  .lazy_sym('utils', 'modifyList')
  .lazy_sym('dplyr', 'mutate')
  .lazy_sym('dplyr', 'n')
  .lazy_sym('stats', 'na.omit')
  .lazy_sym('stats', 'order.dendrogram')
  .lazy_sym('stats', 'p.adjust')
  .lazy_sym('utils', 'packageVersion')
  .lazy_sym('grDevices', 'palette')
  .lazy_sym('grid', 'pattern')
  .lazy_sym('graphics', 'plot')
  .lazy_sym('grDevices', 'png')
  .lazy_sym('graphics', 'points')
  .lazy_sym('Matrix', 'print')
  .lazy_sym('stats', 'pt')
  .lazy_sym('stats', 'quantile')
  .lazy_sym('grid', 'rasterGrob')
  .lazy_sym('utils', 'read.csv')
  .lazy_sym('clusterProfiler', 'read.gmt')
  .lazy_sym('utils', 'read.table')
  .lazy_sym('R.cache', 'readCacheHeader')
  .lazy_sym('dplyr', 'reframe')
  .lazy_sym('stats', 'reorder')
  .lazy_sym('grDevices', 'rgb')
  .lazy_sym('Matrix', 'rowMeans')
  .lazy_sym('ComplexHeatmap', 'row_order')
  .lazy_sym('mgcv', 's')
  .lazy_sym('R.cache', 'saveCache')
  .lazy_sym('ggplot2', 'scale_fill_manual')
  .lazy_sym('ggplot2', 'scale_x_continuous')
  .lazy_sym('graphics', 'screen')
  .lazy_sym('graphics', 'segments')
  .lazy_sym('stats', 'setNames')
  .lazy_sym('clusterProfiler', 'simplify')
  .lazy_sym('methods', 'slot')
  .lazy_sym('stats', 'start')
  .lazy_sym('Matrix', 't')
  .lazy_sym('stats', 'terms')
  .lazy_sym('graphics', 'text')
  .lazy_sym('ggplot2', 'theme')
  .lazy_sym('stats', 'time')
  .lazy_sym('utils', 'timestamp')
  .lazy_sym('graphics', 'title')
  .lazy_sym('grid', 'unit')
  .lazy_sym('grid', 'unitType')
  .lazy_sym('biomaRt', 'useDataset')
  .lazy_sym('biomaRt', 'useEnsembl')
  .lazy_sym('biomaRt', 'useMart')
  .lazy_sym('grid', 'viewport')
  .lazy_sym('Matrix', 'which')
  .lazy_sym('ComplexHeatmap', 'width.HeatmapAnnotation')
  .lazy_sym('ComplexHeatmap', 'width.Legends')
  .lazy_sym('grDevices', 'windows')
  .lazy_sym('ggplot2', 'wrap_dims')
  .lazy_sym('patchwork', 'wrap_plots')
  .lazy_sym('ggplot2', 'zeroGrob')
  # baseenv() is the LAST environment of the search path (its parent is
  # emptyenv), so `imports` parented to baseenv() does not see the default
  # attached packages. Code evaluated through formulas / model.frame (e.g.
  # xtabs -> na.action = na.pass) needs them. Bind every export of the
  # default-attached standard packages lazily (namespaces already loaded in
  # any R session) unless a NAMESPACE import already owns the name. The
  # caller's global environment stays excluded.
  for (.p in c("stats", "graphics", "grDevices", "utils", "methods")) {
    for (.s in getNamespaceExports(.p)) {
      if (!exists(.s, envir = imports, inherits = FALSE))
        eval(substitute(delayedAssign(NM, getExportedValue(PKG, NM), assign.env = imports),
                        list(NM = .s, PKG = .p)))
    }
  }
  rm(.p, .s)
  .import_pkg <- function(pkg) {
    ns <- tryCatch(asNamespace(pkg), error = function(e) NULL)
    if (is.null(ns)) return(invisible(FALSE))
    for (nm in getNamespaceExports(pkg)) {
      if (!exists(nm, envir = imports, inherits = FALSE))
        assign(nm, getExportedValue(pkg, nm), envir = imports)
    }
    invisible(TRUE)
  }
  .scp_ensure <- function(pkgs) {
    # namespace must be LOADED (S3/S4 method dispatch on passed objects), but
    # only when the calling branch actually runs — never installs, never attaches
    miss <- pkgs[!vapply(pkgs, function(p) requireNamespace(p, quietly = TRUE), logical(1))]
    if (length(miss))
      stop(sprintf("missing required R package(s): %s [no-install module: never installs]",
                   paste(miss, collapse = ", ")), call. = FALSE)
    invisible(TRUE)
  }
  env$.scp_import <- .import_pkg
  env$.scp_ensure <- .scp_ensure
  .check_R_guard <- function(packages, ...) {
    pkgs <- vapply(packages, function(p) {
      p <- sub("@.*|==.*|>=.*", "", p); if (grepl("/", p)) p <- basename(p); p
    }, character(1))
    ok <- vapply(pkgs, function(p) requireNamespace(p, quietly = TRUE), logical(1))
    if (any(!ok))
      stop(sprintf("missing required R package(s): %s [no-install module: never installs]",
                   paste(pkgs[!ok], collapse = ", ")), call. = FALSE)
    for (p in pkgs) .import_pkg(p)
    invisible(TRUE)
  }
  .check_Python_guard <- function(packages, envname = NULL, ...) {
    if (!requireNamespace("reticulate", quietly = TRUE))
      stop("missing required R package: reticulate [no-install module]", call. = FALSE)
    py <- Sys.getenv("RETICULATE_PYTHON", unset = "")
    if (!nzchar(py) || !file.exists(py))
      stop("RETICULATE_PYTHON is not set to an existing interpreter; this module never creates or downloads Python environments", call. = FALSE)
    tryCatch(reticulate::use_python(py, required = TRUE), error = function(e)
      stop(sprintf("cannot bind RETICULATE_PYTHON (%s): %s", py, conditionMessage(e)), call. = FALSE))
    .dist2mod <- c("scvi-tools" = "scvi", "magic-impute" = "magic")
    mods <- ifelse(packages %in% names(.dist2mod), unname(.dist2mod[packages]), packages)
    miss <- which(!vapply(mods, function(m)
      isTRUE(tryCatch(reticulate::py_module_available(m), error = function(e) FALSE)), TRUE))
    if (length(miss))
      stop(sprintf("missing required Python module(s): %s [no-install module]",
                   paste(packages[miss], "(imports", paste0("'", mods[miss], "'", collapse = ", "), ")", collapse = ", ")), call. = FALSE)
    invisible(TRUE)
  }
  .noenv <- function(what) function(...)
    stop(sprintf("%s disabled: no-install module never installs, downloads or creates environments", what), call. = FALSE)
  env$check_R <- .check_R_guard
  env$check_Python <- .check_Python_guard
  env$PrepareEnv <- .noenv("PrepareEnv")
  env$conda_install <- .noenv("conda_install")
  env$download <- .noenv("download")
  sys.source(file.path(.code_dir, 'fns', 'asMatrix.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'GeneConvert.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'ListDB.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'PrepareDB.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'RunEnrichment.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'searchDatasets.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'Blend2Color.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'BlendRGBList.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'FeatureHeatmap.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'RGBA2RGB.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'as_grob.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'as_gtable.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'blendcolors.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'build_patchwork.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'cluster_within_group2.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'fc_matrix.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'heatmap_enrichment.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'heatmap_fixsize.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'heatmap_rendersize.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'log1p_matrix.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'log2fc_matrix.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'matrix_process.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'mestimate.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'palette_scp.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'panel_fix_overall.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'patchworkGrob.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'show_palettes.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'standardise.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'theme_scp.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'zscore_matrix.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'as_matrix.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'capitalize.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'kegg_get.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'rescale.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'try_get.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'unnest.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'zero_range.R'), envir = env, keep.source = FALSE)
  env$palette_list <- local({ e <- new.env(); load(file.path(.mroot, 'resources', 'palette_list.rda'), envir = e); e$palette_list })
  env$words_excluded <- local({ e <- new.env(); load(file.path(.mroot, 'resources', 'words_excluded.rda'), envir = e); e$words_excluded })
  # --- infrastructure shims (recorded modifications) ---
  env$.module_root <- .mroot
  env$.scp_detach_residual <- character(0)  # packages a call failed to detach
  env$.scp_detached <- character(0)         # packages a call did detach
  env$.scp_search_restored <- NA
  # option names literally assigned by the copied SCP source; options with
  # these names that a call ADDS are algorithm-temporary and removed on exit
  .scp_algo_options <- character(0)
  env$.scp_algo_options <- .scp_algo_options
  env$.scp_options_existing_restored <- character(0)
  env$.scp_options_ns_init_kept <- character(0)
  env$.scp_options_algorithm_removed <- character(0)
  env$.scp_options_unrestored <- character(0)
  env$.scp_options_restored <- NA
  env$asMatrix <- function(rp, cp, z, nrows, ncols) {
    mat <- matrix(0, nrow = as.integer(nrows), ncol = as.integer(ncols))
    idx <- cbind(as.integer(rp) + 1L, as.integer(cp) + 1L)
    mat[idx] <- as.numeric(z)
    mat
  }
  env$GetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, ...) {
    if (is.null(layer) && !is.null(slot)) layer <- slot
    if (is.null(layer) && is.null(slot)) layer <- "data"
    SeuratObject::GetAssayData(object = object, assay = assay, layer = layer, ...)
  }
  env$SetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, new.data, ...) {
    if (is.null(layer) && !is.null(slot)) layer <- slot
    SeuratObject::SetAssayData(object = object, assay = assay, layer = layer, new.data = new.data, ...)
  }
  env$Assays <- function(object, assay = NULL, ...) {
    if (is.null(assay)) SeuratObject::Assays(object) else Seurat::GetAssay(object, assay = assay)
  }
  env$select <- function(.data, ...) {
    if (inherits(.data, c("AnnotationDb", "OrgDb"))) AnnotationDbi::select(.data, ...) else dplyr::select(.data, ...)
  }
  env$check_R <- .check_R_guard
  env$check_Python <- .check_Python_guard
  env$PrepareEnv <- .noenv("PrepareEnv")
  env$conda_install <- .noenv("conda_install")
  env$download <- .noenv("download")
  for (.b in c("check_R", "check_Python", "PrepareEnv", "conda_install", "download", ".scp_import", ".scp_ensure"))
    lockBinding(.b, env)
  # no S3 methods in this closure
  # no S3 generics to wrap
  # per-method object-namespace ensure (loaded only when that method runs)
  env$FeatureHeatmap <- local({ .m <- env$FeatureHeatmap; function(...) { .scp_ensure(c('Seurat', 'SeuratObject')); .m(...) } })
  .entry_fn <- env$FeatureHeatmap
  entry <- local({
    .fn <- .entry_fn
    .mod_env <- env
    function(...) {
      # public entry must leave the caller's search()/options() untouched on
      # both success and error paths (restore inside the entry, not by harness)
      .s0 <- search()
      .o0 <- options()
      on.exit({
        # detach ONLY packages attached by this call, newest-first; retry until
        # the search list is back to .s0 or a full pass removes nothing. The
        # residual (still-attached new packages) and the detached set are
        # recorded in the module env for the runner's diagnostics — author's
        # pre-attached packages are never touched.
        .det <- character(0); .res <- character(0)
        repeat {
          .extra <- setdiff(search(), .s0)
          if (!length(.extra)) break
          .ndet <- 0L
          for (.p in rev(.extra)) {
            .ok <- tryCatch({ detach(.p, character.only = TRUE); TRUE },
                            error = function(e) FALSE)
            if (.ok) { .ndet <- .ndet + 1L; .det <- c(.det, .p) }
          }
          if (.ndet == 0L) { .res <- .extra; break }
        }
        .mod_env$.scp_detached <- .det
        .mod_env$.scp_detach_residual <- .res
        .mod_env$.scp_search_restored <- identical(search(), .s0)
        # options, classified (kiro S1 / requirement 5.5-5.9):
        # - pre-existing options whose value changed -> restored to caller value
        # - options ADDED by this call whose name is literally assigned by the
        #   copied SCP source (`options(NAME = ...)`, e.g. RcppML.verbose) are
        #   algorithm-temporary -> removed
        # - any other added option comes from first namespace initialisation
        #   (package .onLoad defaults, e.g. data.table's datatable.*) and is
        #   kept: the namespace stays loaded and returned objects (plotly) need it
        .o1 <- options()
        .common <- intersect(names(.o0), names(.o1))
        .changed <- .common[!vapply(.common, function(.n)
          identical(.o0[[.n]], .o1[[.n]]), logical(1))]
        .removed_by_call <- setdiff(names(.o0), names(.o1))
        .added <- setdiff(names(.o1), names(.o0))
        .algo_added <- intersect(.added, .scp_algo_options)
        .ns_kept <- setdiff(.added, .algo_added)
        .fix <- c(.o0[c(.changed, .removed_by_call)],
                  stats::setNames(vector("list", length(.algo_added)), .algo_added))
        if (length(.fix)) options(.fix)
        .o2 <- options()
        .unres <- c(names(.o0)[!vapply(names(.o0), function(.n)
                      identical(.o0[[.n]], .o2[[.n]]), logical(1))],
                    intersect(.algo_added, names(.o2)))
        .mod_env$.scp_options_existing_restored <- c(.changed, .removed_by_call)
        .mod_env$.scp_options_ns_init_kept <- .ns_kept
        .mod_env$.scp_options_algorithm_removed <- setdiff(.algo_added, .unres)
        .mod_env$.scp_options_unrestored <- .unres
        .mod_env$.scp_options_restored <- !length(.unres)
      }, add = TRUE)
      do.call(.fn, list(...), envir = .mod_env)
    }
  })
  attr(entry, "scp_module_env") <- env
  entry
})
