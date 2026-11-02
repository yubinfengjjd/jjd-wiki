# Replica of the SCP v0.5.6 VolcanoPlot single panel (Endocrine vs rest).
# Data: SCP pancreas_sub example, DE table computed with Seurat FindMarkers.
# Plotting core is shared with the future Wiki template.

file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(file_arg) != 1) stop("Run with Rscript --vanilla replica.R")
script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/", mustWork = TRUE))
here <- dirname(script_dir)
source(file.path(script_dir, "core.R"), encoding = "UTF-8")

df <- utils::read.csv(file.path(here, "data/estimated_data.csv"), stringsAsFactors = FALSE)
spec <- jsonlite::fromJSON(file.path(here, "data/figure_spec.json"), simplifyVector = FALSE)

p <- plot_volcano(
  df,
  group = spec$group,
  x_metric = spec$x_metric,
  log2fc_cutoff = spec$log2fc_cutoff,
  padj_cutoff = spec$padj_cutoff,
  direction = spec$direction,
  nlabel = spec$nlabel,
  cap_quantiles = unlist(spec$cap_quantiles),
  color_limits = unlist(spec$color_limits),
  palette = unlist(spec$palette),
  pt_size = spec$pt_size,
  pt_alpha = spec$pt_alpha,
  highlight_size = spec$highlight_size,
  label_size = spec$label_size,
  aspect_ratio = spec$aspect_ratio
)

outdir <- file.path(here, "output")
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
width <- spec$width_in
height <- spec$height_in
dpi <- spec$dpi
ggplot2::ggsave(file.path(outdir, "replica.png"), p, width = width, height = height, dpi = dpi, bg = "white")
ggplot2::ggsave(file.path(outdir, "replica.pdf"), p, width = width, height = height, device = cairo_pdf, bg = "white")
if (requireNamespace("svglite", quietly = TRUE)) {
  ggplot2::ggsave(file.path(outdir, "replica.svg"), p, width = width, height = height, device = svglite::svglite, bg = "white")
} else {
  grDevices::svg(file.path(outdir, "replica.svg"), width = width, height = height)
  print(p)
  grDevices::dev.off()
}
writeLines(
  c(
    paste("PNG: ggplot2::ggsave", paste0(width, "x", height, " in @", dpi, " dpi")),
    "PDF: cairo_pdf",
    paste("SVG:", if (requireNamespace("svglite", quietly = TRUE)) "svglite" else "grDevices::svg fallback")
  ),
  file.path(outdir, "replica-devices.txt"), useBytes = TRUE
)
writeLines(capture.output(utils::sessionInfo()), file.path(here, "sessionInfo.txt"), useBytes = TRUE)
cat("Volcano replica written:", file.path(outdir, "replica.png"), "\n")
cat("Rows:", nrow(df), " group:", spec$group, "\n")
