# Portable renderer for the native SCP CellStatPlot(plot_type = "bar") template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus the declared table interface; writes figure.png/pdf/svg
# and sizing.json. No cell counting, file discovery, Seurat object, installed
# SCP package, or Wiki path is used.
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

spec <- jsonlite::fromJSON(file.path(root, "spec.json"), simplifyVector = TRUE)
style <- spec$style
style_file <- get_arg("--style")
if (!is.null(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = TRUE)
  style <- utils::modifyList(style, override)
}

table_key <- "metadata"
cfg <- spec$tables[[table_key]]
if (is.null(cfg)) stop("spec.tables has no entry for ", table_key, call. = FALSE)
path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
if (!file.exists(path)) stop("Missing table: ", path)
tables <- list()
tables[[table_key]] <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
group_col <- if (is.null(style$group_col)) "group" else style$group_col
stat_col <- if (is.null(style$stat_col)) "stat" else style$stat_col
if (!all(c(group_col, stat_col) %in% names(tables[[table_key]]))) {
  stop("Missing group/stat column: ", group_col, ", ", stat_col, call. = FALSE)
}
if ("cell" %in% names(tables[[table_key]]) && anyDuplicated(tables[[table_key]]$cell)) {
  stop("cell ids must be unique", call. = FALSE)
}

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))
p <- plot_panel(tables, style)

tab <- tables[[table_key]]
group_col <- if (is.null(style$group_col)) "group" else style$group_col
stat_col <- if (is.null(style$stat_col)) "stat" else style$stat_col
group_values <- if (is.null(style$group_levels)) unique(as.character(tab[[group_col]])) else unlist(style$group_levels)
stat_values <- if (is.null(style$stat_levels)) unique(as.character(tab[[stat_col]])) else unlist(style$stat_levels)
n_groups <- length(group_values)
n_stats <- length(stat_values)
max_chars <- max(c(0L, nchar(as.character(group_values)), nchar(as.character(stat_values))))

sizing <- style$sizing
if (is.null(sizing)) sizing <- list()
mode <- if (is.null(sizing$mode)) "adaptive" else sizing$mode
plot_type <- if (is.null(style$plot_type)) "bar" else style$plot_type
flip <- isTRUE(style$flip)
if (identical(mode, "fixed")) {
  width_in <- if (is.null(style$width_in)) 8 else style$width_in
  height_in <- if (is.null(style$height_in)) 6 else style$height_in
  plan <- list(mode = "fixed", profile = plot_type,
               n_groups = n_groups, n_stats = n_stats,
               width_in = width_in, height_in = height_in)
} else if (identical(mode, "adaptive")) {
  base <- if (is.null(sizing$base_in)) 5.0 else sizing$base_in
  per_group <- if (is.null(sizing$per_group_in)) 0.7 else sizing$per_group_in
  per_stat <- if (is.null(sizing$per_stat_in)) 0.25 else sizing$per_stat_in
  base_chars <- if (is.null(sizing$base_label_chars)) 14 else sizing$base_label_chars
  per_char <- if (is.null(sizing$per_label_char_in)) 0.10 else sizing$per_label_char_in
  minimum <- if (is.null(sizing$min_width_in)) 6.0 else sizing$min_width_in
  min_height <- if (is.null(sizing$min_height_in)) 3.5 else sizing$min_height_in
  base_h <- if (is.null(sizing$base_height_in)) 4.6 else sizing$base_height_in
  aspect <- if (is.null(sizing$aspect)) 0.75 else sizing$aspect
  label_extra <- per_char * max(0, max_chars - base_chars)
  if (flip) {
    # Horizontal bars: categories run down the y axis, series across x.
    height_in <- max(min_height + per_group * n_groups + label_extra, base_h + per_group * n_groups + label_extra)
    width_in <- max(minimum, base + per_stat * n_stats)
  } else {
    width_in <- max(minimum, base + per_group * n_groups + label_extra)
    height_in <- max(min_height, base_h + per_stat * n_stats)
  }
  plan <- list(mode = "adaptive", profile = plot_type,
               n_groups = n_groups, n_stats = n_stats,
               base_in = base, per_group_in = per_group, per_stat_in = per_stat,
               base_height_in = base_h, min_width_in = minimum,
               min_height_in = min_height, base_label_chars = base_chars,
               per_label_char_in = per_char, max_label_chars = max_chars,
               aspect = aspect, width_in = width_in, height_in = height_in)
} else {
  stop("sizing.mode must be 'fixed' or 'adaptive'")
}
if (!is.null(sizing$max_width_in) && width_in > sizing$max_width_in) {
  stop("Required width ", width_in, " in exceeds max_width_in ",
       sizing$max_width_in, " in; enlarge the limit or merge categories, not shrink fonts.")
}
if (!is.null(sizing$max_height_in) && height_in > sizing$max_height_in) {
  stop("Required height ", height_in, " in exceeds max_height_in ",
       sizing$max_height_in, " in; enlarge the limit or merge categories, not shrink fonts.")
}
dpi <- if (is.null(style$dpi)) 150 else style$dpi

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
ggplot2::ggsave(file.path(out_dir, "figure.png"), p,
                width = width_in, height = height_in, dpi = dpi, bg = "white")
ggplot2::ggsave(file.path(out_dir, "figure.pdf"), p,
                width = width_in, height = height_in, device = grDevices::cairo_pdf, bg = "white")
svg_device <- "svglite"
if (requireNamespace("svglite", quietly = TRUE)) {
  ggplot2::ggsave(file.path(out_dir, "figure.svg"), p,
                  width = width_in, height = height_in, device = svglite::svglite, bg = "white")
} else {
  svg_device <- "grDevices::svg (text may be outlined)"
  grDevices::svg(file.path(out_dir, "figure.svg"), width = width_in, height = height_in)
  print(p)
  grDevices::dev.off()
}

plan$dpi <- dpi
plan$svg_device <- svg_device
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"),
                     auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
