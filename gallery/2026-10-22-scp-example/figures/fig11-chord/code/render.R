# Render the gallery replica of the native CellStatPlot chord panel from the
# lossless cell-level linkage table.
# Run from this entry directory: Rscript code/render.R
# The native table+plot core is in code/scp_chord_native.R; no SCP package or
# Wiki path is required at run time. The upstream function returns a
# recordedplot, so output devices are opened explicitly (ggsave is not used).
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
entry_dir <- if (length(file_arg)) {
  dirname(dirname(normalizePath(sub("^--file=", "", file_arg[1]))))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}

source(file.path(entry_dir, "code", "core.R"))
spec <- jsonlite::fromJSON(file.path(entry_dir, "data", "figure_spec.json"), simplifyVector = TRUE)
params <- spec$params
linkage <- utils::read.csv(file.path(entry_dir, "data", "render-cell-linkage.csv"),
                           stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(all(c("cell", "dimension", "category", "dimension_order") %in% names(linkage)))

p <- scp_chord_long_meta(
  linkage = linkage,
  cell_col = "cell",
  dimension_col = "dimension",
  category_col = "category",
  dimension_order_col = "dimension_order",
  dimension_order = params$stat_by,
  category_levels = lapply(params$category_levels, as.character),
  palette = params$palette %||% "Paired",
  palcolor = params$palcolor,
  NA_color = params$NA_color %||% "grey",
  transparency = params$transparency %||% 0.2,
  link_lwd = params$link_lwd %||% 1,
  link_lty = params$link_lty %||% 1,
  link_border = params$link_border %||% 1,
  seed = params$seed %||% 11,
  scp = SCP_helpers
)

width_in <- params$width_in %||% 8
height_in <- params$height_in %||% 6
dpi <- params$dpi %||% 150
out_dir <- file.path(entry_dir, "output")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

grDevices::png(file.path(out_dir, "replica.png"),
  width = width_in * dpi, height = height_in * dpi, res = dpi, bg = "white"
)
grDevices::replayPlot(p)
invisible(grDevices::dev.off())

grDevices::cairo_pdf(file.path(out_dir, "replica.pdf"),
  width = width_in, height = height_in, bg = "white"
)
grDevices::replayPlot(p)
invisible(grDevices::dev.off())

svglite::svglite(file.path(out_dir, "replica.svg"),
  width = width_in, height = height_in, bg = "white"
)
grDevices::replayPlot(p)
invisible(grDevices::dev.off())

writeLines(capture.output(sessionInfo()), file.path(out_dir, "sessionInfo.txt"))
writeLines(c(
  paste("plot_type:", params$plot_type %||% "chord"),
  paste("stat_by:", paste(params$stat_by, collapse = " + ")),
  paste("stat_type: count (forced by upstream for chord)"),
  paste("size_in:", paste(width_in, height_in, sep = "x")),
  paste("dpi:", dpi),
  paste("device_png: grDevices::png(width=1200, height=900, res=150, bg=white)"),
  paste("device_pdf: grDevices::cairo_pdf(width=8, height=6, bg=white)"),
  paste("device_svg: svglite::svglite(width=8, height=6, bg=white)"),
  paste("replica_png_sha256:", digest::digest(file = file.path(out_dir, "replica.png"), algo = "sha256", serialize = FALSE))
), file.path(out_dir, "run-summary.txt"))
cat("Wrote", file.path(out_dir, "replica.png"), "\n")
