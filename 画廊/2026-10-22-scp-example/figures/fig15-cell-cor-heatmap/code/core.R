# Compatibility loader for the native SCP CellCorHeatmap core.
# All files are template-local; no Wiki path or installed SCP package is used.
suppressPackageStartupMessages({
  library(ggplot2)
  library(ComplexHeatmap)
  library(circlize)
  library(patchwork)
  library(grid)
  library(gtable)
  library(dplyr)
  library(rlang)
  library(scales)
})
.core_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
.core_dir <- if (!is.null(.core_file) && nzchar(.core_file)) {
  dirname(normalizePath(.core_file, mustWork = TRUE))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}
source(file.path(.core_dir, "scp_helpers.R"))
source(file.path(.core_dir, "scp_cell-cor-heatmap_native.R"))
