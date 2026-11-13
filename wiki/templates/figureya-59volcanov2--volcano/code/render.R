# Portable renderer shared by the FigureYa-derived L2 templates.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus <interface>.csv; writes figure.png/pdf/svg and sizing.json.
# panel.R must define plot_panel(tables, style), figure_size(tables, style, p) and draw_figure(p).
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
spec <- jsonlite::fromJSON(file.path(root, "spec.json"), simplifyVector = FALSE)
style <- spec$style
style_file <- get_arg("--style")
if (!is.null(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  # Named objects (sizing) merge key by key; arrays (levels, palette, ...) are replaced whole.
  merge_style <- function(base, extra) {
    for (key in names(extra)) {
      both_named <- is.list(base[[key]]) && is.list(extra[[key]]) &&
        !is.null(names(base[[key]])) && !is.null(names(extra[[key]]))
      base[key] <- list(if (both_named) merge_style(base[[key]], extra[[key]]) else extra[[key]])
    }
    base
  }
  style <- merge_style(style, override)
}
tables <- list()
for (name in names(spec$tables)) {
  cfg <- spec$tables[[name]]
  path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
  if (!file.exists(path)) {
    if (isFALSE(cfg$required)) next
    stop("Missing table: ", path)
  }
  tables[[name]] <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE,
                                    na.strings = c("", "NA"), strip.white = FALSE,
                                    fileEncoding = "UTF-8-BOM")
}
source(file.path(root, "code", "panel.R"))
p <- plot_panel(tables, style)
plan <- figure_size(tables, style, p)
sizing <- style$sizing
if (!is.null(sizing$max_width_in) && plan$width_in > sizing$max_width_in) {
  stop("Required width ", plan$width_in, " in exceeds max_width_in ", sizing$max_width_in,
       " in; enlarge the limit, not shrink fonts.")
}
if (!is.null(sizing$max_height_in) && plan$height_in > sizing$max_height_in) {
  stop("Required height ", plan$height_in, " in exceeds max_height_in ", sizing$max_height_in,
       " in; enlarge the limit, not shrink fonts.")
}
dpi <- if (is.null(style$dpi)) 200 else style$dpi
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
w <- plan$width_in
h <- plan$height_in
grDevices::png(file.path(out_dir, "figure.png"), width = w, height = h, units = "in", res = dpi, bg = "white")
draw_figure(p)
grDevices::dev.off()
grDevices::cairo_pdf(file.path(out_dir, "figure.pdf"), width = w, height = h, bg = "white")
draw_figure(p)
grDevices::dev.off()
if (requireNamespace("svglite", quietly = TRUE)) {
  svglite::svglite(file.path(out_dir, "figure.svg"), width = w, height = h, bg = "white")
  plan$svg_device <- "svglite"
} else {
  grDevices::svg(file.path(out_dir, "figure.svg"), width = w, height = h, bg = "white")
  plan$svg_device <- "grDevices::svg"
}
draw_figure(p)
grDevices::dev.off()
plan$dpi <- dpi
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"), auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
