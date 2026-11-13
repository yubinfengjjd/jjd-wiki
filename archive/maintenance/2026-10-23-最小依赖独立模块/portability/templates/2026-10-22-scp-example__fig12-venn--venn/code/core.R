# Compatibility loader for the native SCP venn core.
# All files are template-local; no Wiki path or installed SCP package is used.
suppressPackageStartupMessages({
  library(ggplot2)
  library(ggrepel)
  library(rlang)
  library(dplyr)
})
for (.pkg in c("ggVennDiagram", "sf")) {
  if (!requireNamespace(.pkg, quietly = TRUE)) {
    stop("Package '", .pkg, "' is required for the venn template but is not installed.", call. = FALSE)
  }
}
.core_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
.core_dir <- if (!is.null(.core_file) && nzchar(.core_file)) {
  dirname(normalizePath(.core_file, mustWork = TRUE))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}
source(file.path(.core_dir, "scp_helpers.R"))
source(file.path(.core_dir, "scp_venn_native.R"))
