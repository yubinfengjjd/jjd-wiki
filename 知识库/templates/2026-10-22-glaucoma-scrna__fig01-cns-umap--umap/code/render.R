# Portable renderer for the single-panel R template.
# Reads spec.json, example tables and an optional style override; writes
# figure.png/pdf/svg plus sizing.json. No training or statistical analysis.
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

spec <- jsonlite::fromJSON(file.path(root, "spec.json"), simplifyVector = FALSE)
simplify_style <- function(x) {
  if (is.list(x) && is.null(names(x))) return(unlist(x, use.names = FALSE))
  if (is.list(x)) return(lapply(x, simplify_style))
  x
}
style <- simplify_style(spec$style)
style_file <- get_arg("--style")
if (!is.null(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  style <- utils::modifyList(style, simplify_style(override))
}

tables <- lapply(spec$tables, function(cfg) {
  path <- file.path(data_dir, paste0(cfg$interface, ".csv"))
  if (!file.exists(path)) stop("Missing table: ", path)
  utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
})

source(file.path(root, "code", "core.R"))
source(file.path(root, "code", "panel.R"))
source(file.path(root, "code", "sizing.R"))
p <- plot_panel(tables, style)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
tab <- tables[[1]]
group_col <- if (is.null(style$group_col)) "group" else style$group_col
n_groups <- length(unique(as.character(tab[[group_col]])))
max_chars <- max(c(0L, nchar(as.character(unique(tab[[group_col]])))))
plan <- resolve_sizing(style, "umap_groups", n_groups, 1, max_chars)
width_in <- plan$width_in
height_in <- plan$height_in
dpi <- plan$dpi
ggplot2::ggsave(
  file.path(out_dir, "figure.png"), p,
  width = width_in, height = height_in, dpi = dpi, bg = "white"
)
ggplot2::ggsave(
  file.path(out_dir, "figure.pdf"), p,
  width = width_in, height = height_in, device = cairo_pdf, bg = "white"
)
ggplot2::ggsave(
  file.path(out_dir, "figure.svg"), p,
  width = width_in, height = height_in, device = svglite::svglite, bg = "white"
)

jsonlite::write_json(
  plan, file.path(out_dir, "sizing.json"),
  auto_unbox = TRUE, pretty = TRUE
)
cat("Wrote", file.path(out_dir, "figure.png"), "and sizing.json\n")
