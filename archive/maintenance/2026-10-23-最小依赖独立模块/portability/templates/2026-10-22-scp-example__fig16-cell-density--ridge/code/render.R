# Portable renderer for the native SCP CellDensityPlot template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus the declared table interface; writes figure.png/pdf/svg
# and sizing.json. No feature extraction, Seurat object, installed SCP package,
# or Wiki path is used.
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

table_key <- "density"
cfg <- spec$tables[[table_key]]
if (is.null(cfg)) stop("spec.tables has no entry for ", table_key, call. = FALSE)
path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
if (!file.exists(path)) stop("Missing table: ", path)
tables <- list()
tables[[table_key]] <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

tab <- tables[[table_key]]
get_style <- function(name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}
cell_col <- get_style("cell_col", "cell")
feature_col <- get_style("feature_col", "feature")
value_col <- get_style("value_col", "value")
group_col <- get_style("group_col", "group")
feature_order_col <- get_style("feature_order_col", "feature_order")
group_order_col <- get_style("group_order_col", "group_order")

required <- c(cell_col, feature_col, value_col, group_col)
if (!all(required %in% names(tab))) {
  stop("Missing required column: ",
       paste(setdiff(required, names(tab)), collapse = ", "), call. = FALSE)
}
if (anyNA(tab[[cell_col]]) || anyNA(tab[[feature_col]]) || anyNA(tab[[group_col]])) {
  stop("cell, feature and group must not contain NA", call. = FALSE)
}
if (anyDuplicated(paste(tab[[cell_col]], tab[[feature_col]], sep = "\r"))) {
  stop("cell x feature rows must be unique", call. = FALSE)
}
tab[[value_col]] <- suppressWarnings(as.numeric(tab[[value_col]]))
if (all(is.na(tab[[value_col]])) && nrow(tab) > 0) {
  stop("value column has no numeric entries", call. = FALSE)
}

feature_values <- unique(as.character(tab[[feature_col]]))
group_values <- unique(as.character(tab[[group_col]]))
if (!is.null(style$feature_levels)) feature_values <- as.character(style$feature_levels)
if (!is.null(style$group_levels)) group_values <- as.character(style$group_levels)
n_features <- length(feature_values)
n_groups <- length(group_values)
if (n_features < 1 || n_groups < 1) stop("no feature or group values", call. = FALSE)
max_chars <- max(c(0L, nchar(feature_values), nchar(group_values)))

sizing <- style$sizing
if (is.null(sizing)) sizing <- list()
mode <- if (is.null(sizing$mode)) "adaptive" else sizing$mode
if (identical(mode, "fixed")) {
  width_in <- if (is.null(style$width_in)) 8 else style$width_in
  height_in <- if (is.null(style$height_in)) 6 else style$height_in
  plan <- list(mode = "fixed", profile = "ridge",
               n_features = n_features, n_groups = n_groups,
               width_in = width_in, height_in = height_in)
} else if (identical(mode, "adaptive")) {
  base <- if (is.null(sizing$base_in)) 5.5 else sizing$base_in
  per_feature <- if (is.null(sizing$per_feature_in)) 3.5 else sizing$per_feature_in
  per_char <- if (is.null(sizing$per_char_in)) 0.09 else sizing$per_char_in
  base_chars <- if (is.null(sizing$base_label_chars)) 10 else sizing$base_label_chars
  minimum <- if (is.null(sizing$min_width_in)) 5.0 else sizing$min_width_in
  base_h <- if (is.null(sizing$base_height_in)) 3.2 else sizing$base_height_in
  per_group <- if (is.null(sizing$per_group_in)) 0.35 else sizing$per_group_in
  min_height <- if (is.null(sizing$min_height_in)) 3.0 else sizing$min_height_in
  label_extra <- per_char * max(0, max_chars - base_chars)
  width_in <- max(minimum, base + per_feature * (n_features - 1) + label_extra)
  height_in <- max(min_height, base_h + per_group * n_groups)
  plan <- list(mode = "adaptive", profile = "ridge",
               n_features = n_features, n_groups = n_groups,
               base_in = base, per_feature_in = per_feature,
               per_char_in = per_char, base_label_chars = base_chars,
               base_height_in = base_h, per_group_in = per_group,
               min_width_in = minimum, min_height_in = min_height,
               max_label_chars = max_chars,
               width_in = width_in, height_in = height_in)
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
seed <- if (is.null(style$seed)) 11 else style$seed

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))
set.seed(seed)
p <- plot_panel(tables, style)

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
plan$seed <- seed
plan$svg_device <- svg_device
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"),
                     auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
