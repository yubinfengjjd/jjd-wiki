# ============================================================================
# SCP 0.5.6 module: RunMDS  (source commit b9b0eb7a, read-only provenance)
# Self-contained private-closure module. Only RunMDS is exposed.
# - installer functions (check_R/check_Python/PrepareEnv/conda_install/download)
#   are replaced by NO-INSTALL guards, bound after all source files and locked.
# - bare-called package exports resolve in a private `imports` env; nothing is
#   attached to the user search path and no user namespace is ever unloaded.
# ============================================================================
RunMDS <- local({
  .find_ofile <- function() {
    for (i in seq_len(sys.nframe())) {
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
  imports <- new.env(parent = globalenv())
  parent.env(env) <- imports
  .import_pkg <- function(pkg) {
    ns <- tryCatch(asNamespace(pkg), error = function(e) NULL)
    if (is.null(ns)) return(invisible(FALSE))
    for (nm in getNamespaceExports(pkg)) {
      if (!exists(nm, envir = imports, inherits = FALSE))
        assign(nm, getExportedValue(pkg, nm), envir = imports)
    }
    invisible(TRUE)
  }
  env$.scp_import <- .import_pkg
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
    miss <- packages[!vapply(packages, function(p)
      isTRUE(tryCatch(reticulate::py_module_available(p), error = function(e) FALSE)), TRUE)]
    if (length(miss))
      stop(sprintf("missing required Python module(s): %s [no-install module]", paste(miss, collapse = ", ")), call. = FALSE)
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
  sys.source(file.path(.code_dir, 'fns', 'RunMDS.Assay.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'RunMDS.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'RunMDS.Seurat.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'RunMDS.default.R'), envir = env, keep.source = FALSE)
  sys.source(file.path(.code_dir, 'fns', 'as_matrix.R'), envir = env, keep.source = FALSE)
  # re-bind + lock guards AFTER all source files so nothing can overwrite them
  env$check_R <- .check_R_guard
  env$check_Python <- .check_Python_guard
  env$PrepareEnv <- .noenv("PrepareEnv")
  env$conda_install <- .noenv("conda_install")
  env$download <- .noenv("download")
  for (.b in c("check_R", "check_Python", "PrepareEnv", "conda_install", "download", ".scp_import"))
    lockBinding(.b, env)
  .import_pkg('Matrix')  # bare-called, unguarded in source (Imports parity)
  .import_pkg('Seurat')  # bare-called, unguarded in source (Imports parity)
  .import_pkg('SeuratObject')  # bare-called, unguarded in source (Imports parity)
  .import_pkg('rlang')  # bare-called, unguarded in source (Imports parity)
  .import_pkg('stats')  # bare-called, unguarded in source (Imports parity)
  .entry_fn <- env$RunMDS
  entry <- function(...) do.call(.entry_fn, list(...))
  attr(entry, "scp_module_env") <- env
  entry
})
