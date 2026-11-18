# Standalone renderer for KS-style multi-track CellChat Circos template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- sub("^--file=", "", script_arg[1])
root <- dirname(dirname(normalizePath(script_path)))

data_dir <- get_arg("--data")
out_dir <- get_arg("--out")
if (is.null(data_dir) || is.null(out_dir)) {
  stop("Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]")
}
if (!dir.exists(data_dir)) stop("Data directory not found: ", data_dir)

source(file.path(root, "code", "core.R"))

spec <- jsonlite::fromJSON(file.path(root, "spec.json"), simplifyVector = TRUE)
style <- spec$style
style_file <- get_arg("--style")
if (!is.null(style_file)) {
  if (!file.exists(style_file)) stop("Style file not found: ", style_file)
  override <- jsonlite::fromJSON(style_file, simplifyVector = TRUE)
  style <- utils::modifyList(style, override)
}

lr_path <- file.path(data_dir, paste0(spec$tables$interactions$interface, ".csv"))
if (!file.exists(lr_path)) stop("Missing required interactions table: ", lr_path)
interactions <- utils::read.csv(lr_path, stringsAsFactors = FALSE, check.names = FALSE)

expression <- NULL
if (!is.null(spec$tables$expression)) {
  ex_path <- file.path(data_dir, paste0(spec$tables$expression$interface, ".csv"))
  if (file.exists(ex_path)) {
    expression <- utils::read.csv(ex_path, stringsAsFactors = FALSE, check.names = FALSE)
  }
}

prep <- prepare_circos_data(interactions, expression, style)

width_in <- as.numeric(style$width_in %||% 9.8)
height_in <- as.numeric(style$height_in %||% 7.6)
dpi <- as.numeric(style$dpi %||% 200)
width_px <- round(width_in * dpi)
height_px <- round(height_in * dpi)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

grDevices::png(file.path(out_dir, "figure.png"), width = width_px, height = height_px, res = dpi, bg = "white")
draw_ks_circos(prep, style)
invisible(grDevices::dev.off())

grDevices::cairo_pdf(file.path(out_dir, "figure.pdf"), width = width_in, height = height_in, bg = "white")
draw_ks_circos(prep, style)
invisible(grDevices::dev.off())

svg_device <- "svglite"
if (requireNamespace("svglite", quietly = TRUE)) {
  svglite::svglite(file.path(out_dir, "figure.svg"), width = width_in, height = height_in, bg = "white")
  draw_ks_circos(prep, style)
  invisible(grDevices::dev.off())
} else {
  svg_device <- "grDevices::svg"
  grDevices::svg(file.path(out_dir, "figure.svg"), width = width_in, height = height_in)
  draw_ks_circos(prep, style)
  invisible(grDevices::dev.off())
}

plan <- list(
  mode = "fixed",
  profile = "circos-multi",
  n_sectors = length(prep$sectors),
  n_nodes = nrow(prep$nodes),
  n_links = nrow(prep$links),
  width_in = width_in,
  height_in = height_in,
  dpi = dpi,
  width_px = width_px,
  height_px = height_px,
  svg_device = svg_device
)
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"), auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
