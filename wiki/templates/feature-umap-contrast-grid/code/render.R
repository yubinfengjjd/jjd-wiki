# High-Contrast Continuous Feature / Module Score UMAP Grid Renderer (Cai 2026 style)
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(jsonlite)
  library(scales)
  library(grid)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1L]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
tpl_root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[1L]))))

data_dir <- get_arg("--data")
out_dir <- get_arg("--out")
style_file <- get_arg("--style", NULL)
if (is.null(data_dir) || is.null(out_dir)) {
  stop("Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]")
}
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

spec <- jsonlite::fromJSON(file.path(tpl_root, "spec.json"), simplifyVector = FALSE)
style <- if (is.null(spec$style)) list() else spec$style
if (!is.null(style_file) && file.exists(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  for (k in names(override)) if (!is.null(override[[k]])) style[[k]] <- override[[k]]
}

fname <- if (!is.null(spec$tables$cells$filename)) spec$tables$cells$filename else "feature_umap_scores.csv"
df <- utils::read.csv(file.path(data_dir, fname), check.names = FALSE, stringsAsFactors = FALSE)
df$x <- as.numeric(df$umap_1)
df$y <- as.numeric(df$umap_2)
df <- df[is.finite(df$x) & is.finite(df$y), , drop = FALSE]

meta_cols <- c("cell_id", "cell", "umap_1", "umap_2", "UMAP_1", "UMAP_2", "x", "y", "subcluster", "condition", "compartment")
feat_cols <- setdiff(names(df), meta_cols)
if (length(feat_cols) == 0L) stop("No continuous feature columns found in input table.")

pal_mode <- if (!is.null(style$palette_mode)) as.character(style$palette_mode) else "module_spectral"
pal_cols <- if (pal_mode == "marker_crimson") {
  c("#E8E8E8", "#D6D4D2", "#E6DDDE", "#F1CED2", "#D53E4F")
} else {
  c("#3288BD", "#9ECAE1", "#FFFFBF", "#FDAE61", "#D53E4F")
}

ncol_val <- if (!is.null(style$ncol)) as.integer(style$ncol) else 2L
dot_sz <- if (!is.null(style$dot_size)) as.numeric(style$dot_size) else 0.62
gamma_val <- if (!is.null(style$gamma)) as.numeric(style$gamma) else 1.6

scale01 <- function(v) {
  ok <- is.finite(v)
  if (!any(ok)) return(rep(0, length(v)))
  rng <- range(v[ok])
  if (diff(rng) == 0) return(rep(0, length(v)))
  (v - rng[1L]) / diff(rng)
}

plots <- lapply(feat_cols, function(fc) {
  raw_v <- as.numeric(df[[fc]])
  s_v <- scale01(raw_v)^gamma_val
  sub <- data.frame(x = df$x, y = df$y, val = s_v)
  sub <- sub[order(sub$val, na.last = FALSE), , drop = FALSE]
  ggplot(sub, aes(x = x, y = y, colour = val)) +
    geom_point(size = dot_sz * 1.55, stroke = 0, alpha = 0.95) +
    scale_colour_gradientn(
      colours = pal_cols,
      limits = c(0, 1),
      breaks = c(0, 1),
      labels = c("Min", "Max"),
      oob = scales::squish,
      name = NULL
    ) +
    guides(colour = guide_colourbar(
      direction = "vertical",
      barwidth = grid::unit(2.2, "mm"),
      barheight = grid::unit(14, "mm"),
      ticks = FALSE
    )) +
    coord_equal() +
    labs(title = fc) +
    theme_void(base_size = 8.5) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "plain", size = 9.5, margin = margin(b = 2)),
      legend.position = "right",
      legend.text = element_text(size = 6.8),
      plot.margin = margin(4, 6, 4, 6)
    )
})

combined <- patchwork::wrap_plots(plots, ncol = ncol_val)

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 5.6
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 4.8
dpi_val <- if (!is.null(style$dpi)) as.integer(style$dpi) else 300L

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
