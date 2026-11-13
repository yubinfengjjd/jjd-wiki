# Portable renderer for the single-panel native SCP CellCorHeatmap template.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
# Reads spec.json plus the correlation interface table; writes figure.png/pdf/svg
# and sizing.json. No similarity is recomputed and no SCP package is required.
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

table_key <- "correlation"
cfg <- spec$tables[[table_key]]
if (is.null(cfg)) stop("spec.tables has no entry for ", table_key, call. = FALSE)
path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
if (!file.exists(path)) stop("Missing table: ", path)
tables <- list()
tables[[table_key]] <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))
source(file.path(root, "code", "sizing.R"))
p <- plot_panel(tables, style)

tab <- tables[[table_key]]
n_rows <- length(unique(tab$row))
n_cols <- length(unique(tab$column))
max_chars <- max(c(0L, nchar(as.character(tab$row)), nchar(as.character(tab$column))))
plan <- resolve_sizing(style, "cellcor", n_x = n_cols, n_y = n_rows,
                       max_label_chars = max_chars)
width_in <- plan$width_in
height_in <- plan$height_in
dpi <- plan$dpi

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
