# Portable renderer for the single-panel native SCP CellStatPlot venn template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus the selected interface table; writes figure.png/pdf/svg
# and sizing.json. No file discovery, Seurat object, installed SCP package, or
# Wiki path is used. Base R devices are opened explicitly for non-PNG outputs.
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

table_key <- "membership"
cfg <- spec$tables[[table_key]]
if (is.null(cfg)) stop("spec.tables has no entry for ", table_key, call. = FALSE)
path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
if (!file.exists(path)) stop("Missing table: ", path)
tables <- list()
tables[[table_key]] <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
tab <- tables[[table_key]]
cell_col <- if (is.null(style$cell_col)) "cell" else style$cell_col
if (!cell_col %in% names(tab)) stop("membership table needs a '", cell_col, "' column", call. = FALSE)

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))
# The interface is long (cell, set, member); the upstream plot core needs one
# logical column per set. Pivot only when the long-form columns are present.
if (all(c("set", "member") %in% names(tab))) {
  tab <- venn_long_to_wide(tab, cell_col = cell_col, set_levels = style$set_levels)
  tables[[table_key]] <- tab
}
if (anyDuplicated(tab[[cell_col]])) stop("cell ids must be unique", call. = FALSE)
set_cols <- venn_set_columns(tab, style)
p <- plot_panel(tables, style)

n_sets <- length(set_cols)
max_chars <- max(c(0L, nchar(set_cols)))

sizing <- style$sizing
if (is.null(sizing)) sizing <- list()
mode <- if (is.null(sizing$mode)) "adaptive" else sizing$mode
if (identical(mode, "fixed")) {
  width_in <- if (is.null(style$width_in)) 8 else style$width_in
  height_in <- if (is.null(style$height_in)) 6 else style$height_in
  plan <- list(mode = "fixed", profile = "venn", n_sets = n_sets,
               width_in = width_in, height_in = height_in)
} else if (identical(mode, "adaptive")) {
  base <- if (is.null(sizing$base_in)) 6.0 else sizing$base_in
  per_set <- if (is.null(sizing$per_set_in)) 0.35 else sizing$per_set_in
  base_chars <- if (is.null(sizing$base_label_chars)) 8 else sizing$base_label_chars
  per_char <- if (is.null(sizing$per_label_char_in)) 0.08 else sizing$per_label_char_in
  minimum <- if (is.null(sizing$min_width_in)) 5.0 else sizing$min_width_in
  min_height <- if (is.null(sizing$min_height_in)) 4.5 else sizing$min_height_in
  aspect <- if (is.null(sizing$aspect)) 0.75 else sizing$aspect
  width_in <- max(minimum, base + per_set * n_sets +
    per_char * max(0, max_chars - base_chars))
  height_in <- max(min_height, width_in * aspect)
  plan <- list(mode = "adaptive", profile = "venn", n_sets = n_sets,
               base_in = base, per_set_in = per_set,
               base_label_chars = base_chars, per_label_char_in = per_char,
               min_width_in = minimum, min_height_in = min_height,
               max_label_chars = max_chars, aspect = aspect,
               width_in = width_in, height_in = height_in)
} else {
  stop("sizing.mode must be 'fixed' or 'adaptive'")
}
if (!is.null(sizing$max_width_in) && width_in > sizing$max_width_in) {
  stop("Required width ", width_in, " in exceeds max_width_in ",
       sizing$max_width_in, " in; enlarge the limit or reduce set name length, not shrink fonts.")
}
if (!is.null(sizing$max_height_in) && height_in > sizing$max_height_in) {
  stop("Required height ", height_in, " in exceeds max_height_in ",
       sizing$max_height_in, " in; enlarge the limit or reduce set name length, not shrink fonts.")
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
  svg_device <- "grDevices::svg"
  grDevices::svg(file.path(out_dir, "figure.svg"), width = width_in, height = height_in)
  print(p)
  grDevices::dev.off()
}

plan$dpi <- dpi
plan$svg_device <- svg_device
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"),
                     auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
