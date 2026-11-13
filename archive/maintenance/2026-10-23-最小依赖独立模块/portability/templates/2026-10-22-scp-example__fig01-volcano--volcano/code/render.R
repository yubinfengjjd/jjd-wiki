# Portable renderer for the single-panel native SCP volcano template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus <interface>.csv; writes figure.png/pdf/svg and sizing.json.
# No DE test, no Seurat object, no installed SCP package.
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

de <- tables$de
group_col <- if (is.null(style$group_col)) "group1" else style$group_col
if (!is.null(style$group)) {
  de <- de[as.character(de[[group_col]]) == style$group, , drop = FALSE]
}
labels <- attr(p, "label_table")
if (is.null(labels)) labels <- data.frame(gene = character(), label = logical())
n_labels <- nrow(labels)
max_label_chars <- if (n_labels) max(nchar(as.character(labels$gene))) else 0L

sizing <- style$sizing
mode <- if (is.null(sizing$mode)) "adaptive" else sizing$mode
if (identical(mode, "fixed")) {
  width_in <- if (is.null(style$width_in)) 7 else style$width_in
  height_in <- if (is.null(style$height_in)) 6 else style$height_in
  plan <- list(mode = "fixed", profile = "volcano", width_in = width_in,
               height_in = height_in)
} else if (identical(mode, "adaptive")) {
  base_w <- if (is.null(sizing$base_width_in)) 7 else sizing$base_width_in
  base_h <- if (is.null(sizing$base_height_in)) 6 else sizing$base_height_in
  base_chars <- if (is.null(sizing$base_label_chars)) 8 else sizing$base_label_chars
  per_char <- if (is.null(sizing$per_label_char_in)) 0.12 else sizing$per_label_char_in
  base_labels <- if (is.null(sizing$base_labels)) 16 else sizing$base_labels
  per_label <- if (is.null(sizing$per_label_in)) 0.1 else sizing$per_label_in
  width_in <- max(base_w, base_w + per_char * max(0, max_label_chars - base_chars))
  height_in <- max(base_h, base_h + per_label * max(0, n_labels - base_labels))
  plan <- list(mode = "adaptive", profile = "volcano",
               base_width_in = base_w, base_height_in = base_h,
               base_label_chars = base_chars, per_label_char_in = per_char,
               base_labels = base_labels, per_label_in = per_label,
               width_in = width_in, height_in = height_in)
} else {
  stop("sizing.mode must be 'fixed' or 'adaptive'")
}
if (!is.null(sizing$max_width_in) && width_in > sizing$max_width_in) {
  stop("Required volcano width ", width_in, " in exceeds max_width_in ",
       sizing$max_width_in, " in; enlarge the limit, not shrink fonts.")
}
if (!is.null(sizing$max_height_in) && height_in > sizing$max_height_in) {
  stop("Required volcano height ", height_in, " in exceeds max_height_in ",
       sizing$max_height_in, " in; enlarge the limit, not shrink fonts.")
}
dpi <- if (is.null(style$dpi)) 200 else style$dpi

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
plan$n_genes <- nrow(de)
plan$n_groups <- 1L
plan$n_labels <- n_labels
plan$max_label_chars <- max_label_chars
plan$svg_device <- svg_device
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"),
                     auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
