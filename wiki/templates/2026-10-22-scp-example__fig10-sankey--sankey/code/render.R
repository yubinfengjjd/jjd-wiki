# Portable renderer for the single-panel native SCP CellStatPlot sankey template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads the render-cell-linkage long table, rebuilds the wide cell x dimension
# table, and draws the upstream StatPlot sankey construction. Writes
# figure.png/figure.pdf/figure.svg plus sizing.json.
# No file discovery beyond the declared interface, no Seurat object, no
# installed SCP package, and no Wiki path is used.
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

table_key <- "linkage"
cfg <- spec$tables[[table_key]]
if (is.null(cfg)) stop("spec.tables has no entry for ", table_key, call. = FALSE)
path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
if (!file.exists(path)) stop("Missing table: ", path)
linkage <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))

dimension_levels <- style$dimension_levels
if (!is.null(dimension_levels)) {
  dimension_levels <- lapply(dimension_levels, function(x) as.character(unlist(x)))
}
# Validate the interface and obtain the explicit dimension/category structure.
prep <- scp_sankey_linkage_wide(
  linkage,
  cell_col = if (is.null(style$cell_col)) "cell" else style$cell_col,
  dimension_col = if (is.null(style$dimension_col)) "dimension" else style$dimension_col,
  category_col = if (is.null(style$category_col)) "category" else style$category_col,
  dimension_order_col = if (is.null(style$dimension_order_col)) "dimension_order" else style$dimension_order_col,
  dimension_levels = dimension_levels
)
n_dims <- length(prep$dimensions)
n_nodes <- sum(vapply(prep$levels, length, integer(1)))
max_nodes <- max(vapply(prep$levels, length, integer(1)))
labels <- c(unlist(prep$levels, use.names = FALSE), prep$dimensions)
max_chars <- max(c(0L, nchar(labels)))

sizing <- style$sizing
if (is.null(sizing)) sizing <- list()
mode <- if (is.null(sizing$mode)) "adaptive" else sizing$mode
if (identical(mode, "fixed")) {
  width_in <- if (is.null(style$width_in)) 8 else style$width_in
  height_in <- if (is.null(style$height_in)) 6 else style$height_in
  plan <- list(
    mode = "fixed", profile = "sankey",
    n_dimensions = n_dims, n_nodes = n_nodes,
    max_nodes_per_dimension = max_nodes, max_label_chars = max_chars,
    width_in = width_in, height_in = height_in
  )
} else if (identical(mode, "adaptive")) {
  base <- if (is.null(sizing$base_in)) 5.0 else sizing$base_in
  per_dim <- if (is.null(sizing$per_dimension_in)) 0.6 else sizing$per_dimension_in
  per_node <- if (is.null(sizing$per_node_in)) 0.08 else sizing$per_node_in
  base_h <- if (is.null(sizing$base_height_in)) 4.2 else sizing$base_height_in
  per_node_h <- if (is.null(sizing$per_node_height_in)) 0.25 else sizing$per_node_height_in
  base_chars <- if (is.null(sizing$base_label_chars)) 14 else sizing$base_label_chars
  per_char <- if (is.null(sizing$per_label_char_in)) 0.08 else sizing$per_label_char_in
  min_w <- if (is.null(sizing$min_width_in)) 6.0 else sizing$min_width_in
  min_h <- if (is.null(sizing$min_height_in)) 4.0 else sizing$min_height_in
  width_in <- max(min_w, base + per_dim * n_dims + per_node * n_nodes +
    per_char * max(0, max_chars - base_chars))
  height_in <- max(min_h, base_h + per_node_h * max_nodes)
  plan <- list(
    mode = "adaptive", profile = "sankey",
    n_dimensions = n_dims, n_nodes = n_nodes,
    max_nodes_per_dimension = max_nodes, max_label_chars = max_chars,
    base_in = base, per_dimension_in = per_dim, per_node_in = per_node,
    base_height_in = base_h, per_node_height_in = per_node_h,
    min_width_in = min_w, min_height_in = min_h,
    base_label_chars = base_chars, per_label_char_in = per_char,
    width_in = width_in, height_in = height_in
  )
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

p <- plot_panel(list(linkage = linkage), style)

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
