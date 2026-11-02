# Compatibility loader for the native SCP CellStatPlot chord core.
# All files are template-local; no Wiki path or installed SCP package is used.
`%||%` <- function(x, y) if (is.null(x)) y else x
.core_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
.core_dir <- if (!is.null(.core_file) && nzchar(.core_file)) {
  dirname(normalizePath(.core_file, mustWork = TRUE))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}
source(file.path(.core_dir, "scp_helpers.R"))
source(file.path(.core_dir, "scp_chord_native.R"))
