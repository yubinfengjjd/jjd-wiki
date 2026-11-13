# Render the gallery replica from the saved cell-level metadata table.
# Run from this entry directory: Rscript code/render.R
# The native ggplot construction is in code/scp_stat_native.R; no SCP package
# or Wiki path is required at run time.
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
entry_dir <- if (length(file_arg)) dirname(dirname(normalizePath(sub("^--file=", "", file_arg[1])))) else normalizePath(getwd(), mustWork = TRUE)

source(file.path(entry_dir, "code", "core.R"))
spec <- jsonlite::fromJSON(file.path(entry_dir, "data", "figure_spec.json"), simplifyVector = TRUE)
params <- spec$params
meta <- read.csv(file.path(entry_dir, "data", "render-cell-metadata.csv"),
                 stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(all(c("cell", "CellType", "Phase") %in% names(meta)))
stopifnot(!anyDuplicated(meta$cell))

p <- scp_stat_meta(
  meta.data = meta,
  stat.by = "Phase", group.by = "CellType",
  type = params$plot_type, stat_type = params$stat_type,
  group_levels = params$group_levels,
  stat_levels = params$stat_levels,
  palette = params$palette %||% "Paired",
  palcolor = params$palcolor,
  flip = isTRUE(params$flip),
  label = isTRUE(params$label),
  label.size = params$label.size %||% 3.5,
  position = params$position %||% "stack",
  xlab = params$xlab,
  ylab = params$ylab,
  legend_title = params$legend_title,
  merge_polar_endpoints = isTRUE(params$merge_polar_endpoints),
  seed = params$seed %||% 11,
  scp = SCP_helpers
)

width_in <- params$width_in %||% 8
height_in <- params$height_in %||% 6
dpi <- params$dpi %||% 150
dir.create(file.path(entry_dir, "output"), showWarnings = FALSE)
ggsave(file.path(entry_dir, "output", "replica.png"), p,
       width = width_in, height = height_in, dpi = dpi, bg = "white")
ggsave(file.path(entry_dir, "output", "replica.pdf"), p,
       width = width_in, height = height_in, device = grDevices::cairo_pdf, bg = "white")
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(entry_dir, "output", "replica.svg"), p,
         width = width_in, height = height_in, device = svglite::svglite, bg = "white")
} else {
  grDevices::svg(file.path(entry_dir, "output", "replica.svg"), width = width_in, height = height_in)
  print(p)
  dev.off()
}
writeLines(capture.output(sessionInfo()), file.path(entry_dir, "output", "sessionInfo.txt"))
writeLines(c(
  paste("plot_type:", params$plot_type),
  paste("stat_type:", params$stat_type),
  paste("position:", params$position %||% "stack"),
  paste("label:", isTRUE(params$label)),
  paste("size_in:", paste(width_in, height_in, sep = "x")),
  paste("dpi:", dpi),
  paste("png_md5:", unname(tools::md5sum(file.path(entry_dir, "output", "replica.png"))))
), file.path(entry_dir, "output", "run-summary.txt"))
cat("Wrote", file.path(entry_dir, "output", "replica.png"), "\n")
