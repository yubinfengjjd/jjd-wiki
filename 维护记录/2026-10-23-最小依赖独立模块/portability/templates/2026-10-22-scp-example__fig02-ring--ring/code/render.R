# Portable renderer for the single-panel native SCP ring template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus <interface>.csv; writes figure.png/pdf/svg and sizing.json.
# No cell counting, file discovery, Seurat object, or installed SCP package.
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

tables <- lapply(spec$tables, function(cfg) {
  path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
  if (!file.exists(path)) stop("Missing table: ", path)
  utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
})

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))
p <- plot_panel(tables, style)

proportions <- tables$proportions
group_col <- if (is.null(style$group_col)) "group" else style$group_col
celltype_col <- if (is.null(style$celltype_col)) "celltype" else style$celltype_col
n_groups <- length(unique(as.character(proportions[[group_col]])))
n_celltypes <- length(unique(as.character(proportions[[celltype_col]])))

sizing <- style$sizing
mode <- if (is.null(sizing$mode)) "adaptive" else sizing$mode
if (identical(mode, "fixed")) {
  width_in <- if (is.null(style$width_in)) 8 else style$width_in
  height_in <- if (is.null(style$height_in)) 6 else style$height_in
  plan <- list(mode = "fixed", profile = "ring_composition",
               n_groups = n_groups, n_celltypes = n_celltypes,
               width_in = width_in, height_in = height_in)
} else if (identical(mode, "adaptive")) {
  base <- if (is.null(sizing$base_in)) 5.0 else sizing$base_in
  per_group <- if (is.null(sizing$per_group_in)) 0.6 else sizing$per_group_in
  per_celltype <- if (is.null(sizing$per_celltype_in)) 0.12 else sizing$per_celltype_in
  minimum <- if (is.null(sizing$min_size_in)) 6.0 else sizing$min_size_in
  min_height <- if (is.null(sizing$min_height_in)) 6.0 else sizing$min_height_in
  base_chars <- if (is.null(sizing$base_label_chars)) 14 else sizing$base_label_chars
  per_char <- if (is.null(sizing$per_label_char_in)) 0.10 else sizing$per_label_char_in
  max_chars <- max(c(0L, nchar(as.character(unique(proportions[[group_col]]))),
                     nchar(as.character(unique(proportions[[celltype_col]])))))
  width_in <- max(minimum, base + per_group * n_groups +
    per_celltype * max(0, n_celltypes - 3) +
    per_char * max(0, max_chars - base_chars))
  aspect <- if (is.null(sizing$aspect)) 0.75 else sizing$aspect
  height_in <- max(min_height, width_in * aspect)
  plan <- list(mode = "adaptive", profile = "ring_composition",
               n_groups = n_groups, n_celltypes = n_celltypes,
               base_in = base, per_group_in = per_group,
               per_celltype_in = per_celltype, min_size_in = minimum,
               min_height_in = min_height,
               base_label_chars = base_chars, per_label_char_in = per_char,
               max_label_chars = max_chars,
               aspect = aspect, width_in = width_in, height_in = height_in)
} else {
  stop("sizing.mode must be 'fixed' or 'adaptive'")
}
if (!is.null(sizing$max_width_in) && width_in > sizing$max_width_in) {
  stop("Required ring width ", width_in, " in exceeds max_width_in ",
       sizing$max_width_in, " in; enlarge the limit or merge categories, not shrink fonts.")
}
if (!is.null(sizing$max_height_in) && height_in > sizing$max_height_in) {
  stop("Required ring height ", height_in, " in exceeds max_height_in ",
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
