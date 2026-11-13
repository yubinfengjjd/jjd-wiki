# Replica of the SCP CellStatPlot ring panel (CellType x Phase).
# Data: SCP pancreas_sub example metadata, within-CellType Phase proportions.
# Plotting core is shared with the future Wiki template.

file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(file_arg) != 1) stop("Run with Rscript --vanilla replica.R")
script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/", mustWork = TRUE))
here <- dirname(script_dir)
source(file.path(script_dir, "core.R"), encoding = "UTF-8")

df <- utils::read.csv(file.path(here, "data/estimated_data.csv"), stringsAsFactors = FALSE)
spec <- jsonlite::fromJSON(file.path(here, "data/figure_spec.json"), simplifyVector = FALSE)

p <- plot_ring(
  df,
  group_col = spec$group_col,
  celltype_col = spec$celltype_col,
  proportion_col = spec$proportion_col,
  group_levels = if (is.null(spec$group_levels)) NULL else unlist(spec$group_levels),
  celltype_levels = if (is.null(spec$celltype_levels)) NULL else unlist(spec$celltype_levels),
  palette = unlist(spec$palette),
  ring_gap = spec$ring_gap,
  min_label_prop = spec$min_label_prop,
  label_size = spec$label_size,
  group_label_size = spec$group_label_size,
  show_reference = spec$show_reference,
  show_axis_titles = spec$show_axis_titles,
  legend_title = spec$legend_title,
  group_title = spec$group_title,
  base_size = spec$base_size
)

outdir <- file.path(here, "output")
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
width <- spec$width_in
height <- spec$height_in
dpi <- spec$dpi
ggplot2::ggsave(file.path(outdir, "replica.png"), p, width = width, height = height, dpi = dpi, bg = "white")
ggplot2::ggsave(file.path(outdir, "replica.pdf"), p, width = width, height = height, device = cairo_pdf, bg = "white")
# Base R SVG export; glyphs may be outlined. The prior shutdown failure
# was traced to missing PROCESSOR_ARCHITECTURE, not to the SVG device.
grDevices::svg(file.path(outdir, "replica.svg"), width = width, height = height)
print(p)
grDevices::dev.off()
writeLines(
  c(
    paste("PNG: ggplot2::ggsave", paste0(width, "x", height, " in @", dpi, " dpi")),
    "PDF: cairo_pdf",
    "SVG: grDevices::svg fallback (text may be outlined)"
  ),
  file.path(outdir, "replica-devices.txt"), useBytes = TRUE
)
writeLines(capture.output(utils::sessionInfo()), file.path(here, "sessionInfo.txt"), useBytes = TRUE)
cat("Ring replica written:", file.path(outdir, "replica.png"), "\n")
cat("Rows:", nrow(df), " groups:", length(unique(df$group)), " celltypes:", length(unique(df$celltype)), "\n")
