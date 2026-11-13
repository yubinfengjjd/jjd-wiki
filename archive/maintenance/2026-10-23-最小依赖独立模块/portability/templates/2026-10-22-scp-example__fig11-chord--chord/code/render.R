# Portable renderer for the single-panel native SCP CellStatPlot chord template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
#
# Reads spec.json plus the render-cell-linkage interface CSV; writes
# figure.png/pdf/svg and sizing.json. No raw-metadata counting, Seurat object,
# installed SCP package, file discovery or Wiki path is used. plot_type
# "chord" returns a recordedplot, so output devices are opened explicitly.
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
source(file.path(root, "code", "panel.R"))

spec <- jsonlite::fromJSON(file.path(root, "spec.json"), simplifyVector = TRUE)
style <- spec$style
style_file <- get_arg("--style")
if (!is.null(style_file)) {
  if (!file.exists(style_file)) stop("Style file not found: ", style_file)
  override <- jsonlite::fromJSON(style_file, simplifyVector = TRUE)
  style <- utils::modifyList(style, override)
}

table_key <- "linkage"
cfg <- spec$tables[[table_key]]
if (is.null(cfg)) stop("spec.tables has no entry for ", table_key, call. = FALSE)
path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
if (!file.exists(path)) stop("Missing table: ", path)
linkage <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

cell_col <- style$cell_col %||% "cell"
dimension_col <- style$dimension_col %||% "dimension"
category_col <- style$category_col %||% "category"
dimension_order_col <- style$dimension_order_col %||% "dimension_order"
required <- c(cell_col, dimension_col, category_col, dimension_order_col)
if (!all(required %in% names(linkage))) {
  stop("Missing linkage column(s): ", paste(setdiff(required, names(linkage)), collapse = ", "), call. = FALSE)
}

dimension_order <- if (is.null(style$dimension_order)) NULL else unlist(style$dimension_order)
category_levels <- if (is.null(style$category_levels)) NULL else lapply(style$category_levels, as.character)

info <- scp_chord_linkage_summary(linkage,
  cell_col = cell_col, dimension_col = dimension_col, category_col = category_col,
  dimension_order_col = dimension_order_col, dimension_order = dimension_order,
  category_levels = category_levels
)

tables <- list()
tables[[table_key]] <- linkage
p <- plot_panel(tables, style)

sizing <- style$sizing
if (is.null(sizing)) sizing <- list()
mode <- sizing$mode %||% "adaptive"
if (identical(mode, "fixed")) {
  width_in <- style$width_in %||% 8
  height_in <- style$height_in %||% 6
  plan <- list(
    mode = "fixed", profile = "chord",
    n_dimensions = info$n_dimensions, n_sectors = info$n_sectors,
    n_cells = info$n_cells, n_rows = info$n_rows,
    width_in = width_in, height_in = height_in
  )
} else if (identical(mode, "adaptive")) {
  base <- sizing$base_in %||% 5.0
  per_sector <- sizing$per_sector_in %||% 0.35
  base_chars <- sizing$base_label_chars %||% 12
  per_char <- sizing$per_label_char_in %||% 0.12
  min_width <- sizing$min_width_in %||% 6.0
  min_height <- sizing$min_height_in %||% 5.0
  aspect <- sizing$aspect %||% 0.75
  width_in <- max(min_width, base + per_sector * info$n_sectors +
    per_char * max(0, info$max_label_chars - base_chars))
  height_in <- max(min_height, width_in * aspect)
  plan <- list(
    mode = "adaptive", profile = "chord",
    n_dimensions = info$n_dimensions, n_sectors = info$n_sectors,
    n_cells = info$n_cells, n_rows = info$n_rows,
    base_in = base, per_sector_in = per_sector, base_label_chars = base_chars,
    per_label_char_in = per_char, max_label_chars = info$max_label_chars,
    min_width_in = min_width, min_height_in = min_height, aspect = aspect,
    width_in = width_in, height_in = height_in
  )
} else {
  stop("sizing.mode must be 'fixed' or 'adaptive'")
}
if (!is.null(sizing$max_width_in) && width_in > sizing$max_width_in) {
  stop("Required width ", width_in, " in exceeds max_width_in ",
       sizing$max_width_in, " in; enlarge the limit or merge categories, not shrink fonts.",
       call. = FALSE)
}
if (!is.null(sizing$max_height_in) && height_in > sizing$max_height_in) {
  stop("Required height ", height_in, " in exceeds max_height_in ",
       sizing$max_height_in, " in; enlarge the limit or merge categories, not shrink fonts.",
       call. = FALSE)
}
dpi <- style$dpi %||% 150
width_px <- round(width_in * dpi)
height_px <- round(height_in * dpi)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
grDevices::png(file.path(out_dir, "figure.png"),
  width = width_px, height = height_px, res = dpi, bg = "white"
)
grDevices::replayPlot(p)
invisible(grDevices::dev.off())

grDevices::cairo_pdf(file.path(out_dir, "figure.pdf"),
  width = width_in, height = height_in, bg = "white"
)
grDevices::replayPlot(p)
invisible(grDevices::dev.off())

svg_device <- "svglite"
if (requireNamespace("svglite", quietly = TRUE)) {
  svglite::svglite(file.path(out_dir, "figure.svg"),
    width = width_in, height = height_in, bg = "white"
  )
  grDevices::replayPlot(p)
  invisible(grDevices::dev.off())
} else {
  svg_device <- "grDevices::svg (text may be outlined)"
  grDevices::svg(file.path(out_dir, "figure.svg"), width = width_in, height = height_in)
  grDevices::replayPlot(p)
  invisible(grDevices::dev.off())
}

plan$dpi <- dpi
plan$width_px <- width_px
plan$height_px <- height_px
plan$svg_device <- svg_device
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"), auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
