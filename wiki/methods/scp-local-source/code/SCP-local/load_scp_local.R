# load_scp_local.R
# Source-only SCP: defines SCP functions without installing the SCP package.
#
# Usage:
#   source("path/to/SCP-local/load_scp_local.R")
#   SCP_local$RunCellQC(srt, ...)
#   scp_local_attach(); RunCellQC(srt, ...)
#   scp_local_export(c("RunCellQC", "CellDimPlot"))
#
# This is a patched copy of SCP v0.5.6 (GPL-3). See PATCHES.md for the
# complete list of changes and README.md for dependencies and limitations.

.scp_local_root <- local({
  # An explicit root always wins. This makes the loader safe to source from a
  # wrapper (e.g. replica.R -> render.R), where sys.frame(1)$ofile would
  # otherwise resolve to the wrapper's directory instead of SCP-local.
  root <- getOption("SCP.local.root", Sys.getenv("SCP_LOCAL_ROOT", ""))
  if (nzchar(root)) {
    return(normalizePath(root, mustWork = TRUE))
  }
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (is.null(ofile) || !nzchar(ofile)) {
    stop(
      "Cannot determine the SCP-local root. Source this file directly or ",
      "set options(SCP.local.root = '/path/to/SCP-local').",
      call. = FALSE
    )
  }
  dirname(normalizePath(ofile, mustWork = TRUE))
})

SCP_local <- new.env(parent = globalenv())
SCP_local$.root <- .scp_local_root

# Best-effort attachment of the upstream Depends/Imports. Missing packages are
# reported but do not prevent the source files from loading; errors occur only
# when a function actually needs a missing package.
scp_local_attach_deps <- function(quiet = FALSE) {
  desc_path <- file.path(SCP_local$.root, "DESCRIPTION")
  if (!file.exists(desc_path)) {
    warning("DESCRIPTION not found; cannot determine package dependencies.", call. = FALSE)
    return(invisible(list(attached = character(), missing = character())))
  }
  desc <- read.dcf(desc_path)
  fields <- intersect(c("Depends", "Imports"), colnames(desc))
  raw <- paste(desc[1, fields], collapse = ",")
  pkgs <- trimws(strsplit(raw, ",")[[1]])
  pkgs <- sub("\\s*\\(.*\\)$", "", pkgs)
  pkgs <- pkgs[nzchar(pkgs) & pkgs != "R"]
  pkgs <- unique(pkgs)
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  installed <- setdiff(pkgs, missing)
  # R.utils exports an S3 `draw()` that masks ComplexHeatmap's S4 `draw()`
  # when attached after ComplexHeatmap. SCP only calls R.utils::gunzip()
  # explicitly, so keep the namespace available but off the search path.
  installed <- setdiff(installed, "R.utils")
  for (pkg in installed) {
    suppressPackageStartupMessages(
      suppressWarnings(library(pkg, character.only = TRUE, warn.conflicts = FALSE))
    )
  }
  if (!quiet && length(missing)) {
    warning(
      "Missing packages (functions using them will fail): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(list(attached = installed, missing = missing))
}

# Data objects referenced by the plotting functions.
.scp_load_data <- function() {
  e <- new.env(parent = emptyenv())
  for (f in c("palette_list.rda", "words_excluded.rda")) {
    path <- file.path(SCP_local$.root, "data", f)
    if (file.exists(path)) load(path, envir = e)
  }
  for (nm in ls(e)) assign(nm, get(nm, envir = e), envir = SCP_local)
  invisible(ls(e))
}

SCP_local$scp_local_python_path <- function() {
  file.path(SCP_local$.root, "python")
}

# Faithful pure-R replacement for src/asMatrix.cpp. The C++ function uses
# 0-based row indices and 1-based column indices as supplied by as_matrix();
# this translation preserves that behaviour. Upstream as_matrix() does not
# exercise this branch because its condition tests `matrix`, not `x`.
SCP_local$asMatrix <- function(rp, cp, z, nrows, ncols) {
  mat <- matrix(0, nrow = as.integer(nrows), ncol = as.integer(ncols))
  idx <- cbind(as.integer(rp) + 1L, as.integer(cp))
  mat[idx] <- as.numeric(z)
  mat
}

# SeuratObject >= 5 renamed the `slot` argument of GetAssayData/SetAssayData
# to `layer` and made `slot` defunct. SCP 0.5.6 still passes `slot`; translate
# it here so the localized source runs with Seurat 5 without editing every call.
SCP_local$GetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, ...) {
  if (is.null(layer) && !is.null(slot)) layer <- slot
  if (is.null(layer) && is.null(slot)) layer <- "data"
  SeuratObject::GetAssayData(object = object, assay = assay, layer = layer, ...)
}
SCP_local$SetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, new.data, ...) {
  if (is.null(layer) && !is.null(slot)) layer <- slot
  SeuratObject::SetAssayData(object = object, assay = assay, layer = layer, new.data = new.data, ...)
}

# Seurat 4's Assays(object, assay) returned the assay object; SeuratObject 5
# removed the second argument. Keep the old call sites working.
SCP_local$Assays <- function(object, assay = NULL, ...) {
  if (is.null(assay)) {
    SeuratObject::Assays(object)
  } else {
    # GetAssay is exported by Seurat, not SeuratObject (checked with Seurat 5.6.0).
    Seurat::GetAssay(object, assay = assay)
  }
}

# dplyr::select masks AnnotationDbi::select when all Imports are attached.
# SCP calls select() on both data frames and OrgDb objects; dispatch by class.
SCP_local$select <- function(.data, ...) {
  if (inherits(.data, c("AnnotationDb", "OrgDb"))) {
    AnnotationDbi::select(.data, ...)
  } else {
    dplyr::select(.data, ...)
  }
}

scp_local_attach_deps(quiet = TRUE)
# Mirrors the upstream .onAttach() default; remove or lower it if your project
# intentionally limits future globals.
options(future.globals.maxSize = Inf)
.scp_load_data()

.scp_local_files <- c(
  "utils.R", "Seurat-function.R", "ggsankey.R",
  "SCP-cellqc.R", "SCP-workflow.R", "SCP-cell_annotation.R",
  "SCP-projection.R", "SCP-analysis.R", "SCP-plot.R",
  "SCP-feature_annotation.R", "data.R", "SCP-imputation.R"
)
for (f in .scp_local_files) {
  path <- file.path(SCP_local$.root, "R", f)
  if (!file.exists(path)) stop("Missing localized source file: ", path, call. = FALSE)
  if (file.info(path)$size == 0) next
  sys.source(path, envir = SCP_local, keep.source = FALSE)
}

scp_local_attach <- function(pos = 2L, name = "SCP_local") {
  if (!name %in% search()) {
    attach(SCP_local, pos = pos, name = name, warn.conflicts = FALSE)
  }
  invisible(SCP_local)
}

scp_local_export <- function(names, envir = .GlobalEnv) {
  for (nm in names) {
    if (!exists(nm, envir = SCP_local, inherits = FALSE)) {
      stop("Not found in SCP_local: ", nm, call. = FALSE)
    }
    assign(nm, get(nm, envir = SCP_local, inherits = FALSE), envir = envir)
  }
  invisible(names)
}

scp_local_list <- function(pattern = NULL) {
  out <- ls(SCP_local, all.names = TRUE)
  if (!is.null(pattern)) out <- grep(pattern, out, value = TRUE)
  out
}

message(
  "SCP local source loaded: ", length(ls(SCP_local)), " objects. ",
  "Call SCP_local$<function>() or scp_local_attach()."
)
