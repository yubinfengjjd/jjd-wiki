# Load the native GroupHeatmap core and local SCP palette helpers.
suppressPackageStartupMessages({
  library(ComplexHeatmap)
  library(circlize)
  library(patchwork)
  library(gtable)
  library(grid)
})
.core_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
.core_dir <- if (!is.null(.core_file) && nzchar(.core_file)) {
  dirname(normalizePath(.core_file, mustWork = TRUE))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}
source(file.path(.core_dir, "scp_helpers.R"))
source(file.path(.core_dir, "scp_group_heatmap_native.R"))
