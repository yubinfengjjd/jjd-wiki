# Spatial Transcriptomics Feature Grid Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(jsonlite)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
tpl_root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[1]))))

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

fname <- if (!is.null(spec$tables$spots$filename)) spec$tables$spots$filename else "spatial_spots_long.csv"
df <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    x = as.numeric(x),
    y = as.numeric(y),
    feature = factor(as.character(feature), levels = unique(as.character(feature))),
    value = as.numeric(value)
  ) %>%
  dplyr::filter(!is.na(x), !is.na(y), !is.na(feature), !is.na(value))

invert_y <- if (is.null(style$invert_y)) TRUE else isTRUE(style$invert_y)
if (invert_y) df$y_plot <- -df$y else df$y_plot <- df$y

ncol_val <- if (is.null(style$ncol)) min(4L, length(levels(df$feature))) else as.integer(style$ncol)
pt_sz <- if (is.null(style$point_size)) 0.9 else as.numeric(style$point_size)
pt_alpha <- if (is.null(style$point_alpha)) 0.95 else as.numeric(style$point_alpha)
pal_name <- if (is.null(style$palette)) "spectral" else as.character(style$palette)

pal_cols <- switch(pal_name,
  "viridis" = c("#440154", "#3b528b", "#21918c", "#5ec962", "#fde725"),
  "bwr"     = c("#3B4CC0", "#7092F3", "#F7F7F7", "#F0705B", "#B40426"),
  c("#3288BD", "#66C2A5", "#E6F598", "#FEE08B", "#F46D43", "#9E0142")
)

feat_levels <- levels(df$feature)
panels <- lapply(feat_levels, function(ft) {
  sub_df <- df %>% dplyr::filter(feature == ft)
  rng <- range(sub_df$value, na.rm = TRUE)
  if (diff(rng) == 0) rng <- c(rng[1], rng[1] + 1e-4)
  ggplot(sub_df, aes(x = x, y = y_plot, color = value)) +
    geom_point(size = pt_sz, alpha = pt_alpha, shape = 16) +
    scale_color_gradientn(
      colours = pal_cols,
      limits = rng,
      breaks = rng,
      labels = c("Min", "Max"),
      name = NULL
    ) +
    coord_fixed() +
    labs(title = ft) +
    theme_void(base_size = 9.5) +
    theme(
      plot.title = element_text(hjust = 0.02, face = "bold", size = 9.5, margin = margin(b = 2)),
      legend.position = "top",
      legend.key.width = unit(0.45, "in"),
      legend.key.height = unit(0.08, "in"),
      legend.text = element_text(size = 7.5),
      legend.margin = margin(b = -4),
      panel.border = element_rect(color = "#222222", fill = NA, linewidth = 0.5),
      plot.margin = margin(4, 4, 4, 4)
    )
})

n_feats <- length(panels)
nrow_val <- ceiling(n_feats / ncol_val)
w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(4.2, min(14, ncol_val * 2.35))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(2.8, min(14, nrow_val * 2.55))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

combined <- patchwork::wrap_plots(panels, ncol = ncol_val)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
