# Portable renderer for the single-panel native SCP CellStatPlot upset template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus the render-cell-membership interface table; writes
# figure.png/pdf/svg and sizing.json. No cell counting, file discovery, Seurat
# object, installed SCP package, or Wiki path is used. The input CSV is only
# read, never written.
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
style_value <- function(name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

table_key <- "membership"
cfg <- spec$tables[[table_key]]
if (is.null(cfg)) stop("spec.tables has no entry for ", table_key, call. = FALSE)
path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
if (!file.exists(path)) stop("Missing table: ", path)
membership <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
required <- c(style_value("cell_col", "cell"), style_value("set_col", "set"),
              style_value("member_col", "member"))
if (!all(required %in% names(membership))) {
  stop("Missing membership column(s): ",
       paste(setdiff(required, names(membership)), collapse = ", "), call. = FALSE)
}
tables <- list()
tables[[table_key]] <- membership

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))
p <- plot_panel(tables, style)
info <- attr(p, "scp_upset")
sets <- info$sets
n_sets <- length(sets)
n_intersections_total <- info$n_intersections_total
n_shown <- min(n_intersections_total, 20L)
max_chars <- max(c(0L, nchar(sets)))

sizing <- style$sizing
if (is.null(sizing)) sizing <- list()
mode <- if (is.null(sizing$mode)) "adaptive" else sizing$mode
num <- function(name, default) {
  value <- sizing[[name]]
  if (is.null(value)) default else value
}
if (identical(mode, "fixed")) {
  width_in <- style_value("width_in", 8)
  height_in <- style_value("height_in", 6)
  plan <- list(
    mode = "fixed", profile = "upset",
    n_sets = n_sets, n_intersections = n_intersections_total,
    n_shown = n_shown, n_cells = info$n_cells,
    width_in = width_in, height_in = height_in
  )
} else if (identical(mode, "adaptive")) {
  base <- num("base_in", 5.2)
  per_intersection <- num("per_intersection_in", 0.75)
  per_set_w <- num("per_set_in", 0.05)
  base_chars <- num("base_label_chars", 6)
  per_char <- num("per_label_char_in", 0.12)
  base_h <- num("base_height_in", 3.6)
  per_set_h <- num("per_set_height_in", 0.6)
  minimum <- num("min_width_in", 5.0)
  min_height <- num("min_height_in", 4.0)
  width_in <- max(
    minimum,
    base + per_intersection * n_shown + per_set_w * n_sets +
      per_char * max(0, max_chars - base_chars)
  )
  height_in <- max(min_height, base_h + per_set_h * n_sets)
  plan <- list(
    mode = "adaptive", profile = "upset",
    n_sets = n_sets, n_intersections = n_intersections_total,
    n_shown = n_shown, n_cells = info$n_cells,
    base_in = base, per_intersection_in = per_intersection,
    per_set_in = per_set_w, base_label_chars = base_chars,
    per_label_char_in = per_char, max_label_chars = max_chars,
    base_height_in = base_h, per_set_height_in = per_set_h,
    min_width_in = minimum, min_height_in = min_height,
    width_in = width_in, height_in = height_in
  )
} else {
  stop("sizing.mode must be 'fixed' or 'adaptive'")
}
if (!is.null(sizing$max_width_in) && width_in > sizing$max_width_in) {
  stop("Required width ", width_in, " in exceeds max_width_in ",
       sizing$max_width_in,
       " in; enlarge the limit or merge categories, not shrink fonts.")
}
if (!is.null(sizing$max_height_in) && height_in > sizing$max_height_in) {
  stop("Required height ", height_in, " in exceeds max_height_in ",
       sizing$max_height_in,
       " in; enlarge the limit or merge categories, not shrink fonts.")
}
dpi <- style_value("dpi", 150)

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
plan$set_levels <- sets
plan$membership_rows <- nrow(membership)
jsonlite::write_json(plan, file.path(out_dir, "sizing.json"),
                     auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
