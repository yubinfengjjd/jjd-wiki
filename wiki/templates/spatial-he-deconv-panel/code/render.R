# H&E Histology & Spatial Deconvolution Side-by-Side Panel Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(jsonlite)
  library(scales)
  library(png)
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

fname <- if (!is.null(spec$tables$spots$filename)) spec$tables$spots$filename else "spatial_deconv_spots.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    spot_id = as.character(spot_id),
    x = as.numeric(x),
    y = as.numeric(y),
    feature = as.character(feature),
    score = as.numeric(score)
  ) %>%
  dplyr::filter(!is.na(spot_id), is.finite(x), is.finite(y), !is.na(feature), is.finite(score))

if (!"region" %in% names(raw)) raw$region <- "Section"
raw$region <- as.character(raw$region)
raw$region[is.na(raw$region) | !nzchar(raw$region)] <- "Section"
if (!"he_intensity" %in% names(raw)) raw$he_intensity <- 0.65

pal <- unlist(style$palette)
if (length(pal) < 2L) pal <- c("#46468A", "#5CB874", "#F7DC6F", "#C0392B")
invert_y <- if (is.null(style$invert_y)) TRUE else isTRUE(style$invert_y)
qcap <- if (is.null(style$quantile_cap)) 0.995 else as.numeric(style$quantile_cap)
gamma_val <- if (is.null(style$gamma)) 1.4 else as.numeric(style$gamma)
pt_sz <- if (is.null(style$point_size)) 1.15 else as.numeric(style$point_size)

he_fname <- if (!is.null(style$he_image)) as.character(style$he_image) else "he_image.png"
he_path <- file.path(data_dir, he_fname)
he_img <- if (file.exists(he_path)) png::readPNG(he_path) else NULL

features <- unique(raw$feature)
regions <- unique(raw$region)

quantile01 <- function(v, p = c(0, qcap)) {
  b <- as.numeric(stats::quantile(v, p, na.rm = TRUE, names = FALSE))
  if (!all(is.finite(b)) || diff(b) < .Machine$double.eps) {
    rng <- range(v, na.rm = TRUE)
    if (diff(rng) < .Machine$double.eps) return(rep(0, length(v)))
    return(scales::squish((v - rng[1]) / diff(rng)))
  }
  scales::squish((v - b[1]) / diff(b))
}

for (ft in features) {
  idx <- raw$feature == ft
  raw$score_disp[idx] <- quantile01(raw$score[idx])^gamma_val
}

score_header <- function(label) {
  colours <- grDevices::colorRampPalette(pal)(96)
  grid::grobTree(
    grid::textGrob(label, x = 0.02, y = 0.55, just = "left", gp = grid::gpar(fontsize = 6.2, fontface = "bold")),
    grid::rasterGrob(as.raster(matrix(colours, nrow = 1)), x = 0.78, y = 0.58, width = 0.36, height = 0.30, interpolate = FALSE),
    grid::textGrob(c("Min", "Max"), x = c(0.60, 0.96), y = 0.18, gp = grid::gpar(fontsize = 5.2))
  )
}

make_he_panel <- function(sub_spots, reg_name) {
  xr <- range(sub_spots$x); yr <- range(sub_spots$y)
  pad_x <- max(3, diff(xr) * 0.06); pad_y <- max(3, diff(yr) * 0.06)
  if (!is.null(he_img) && length(dim(he_img)) >= 3L) {
    H <- dim(he_img)[1]; W <- dim(he_img)[2]
    x0 <- max(1L, floor(xr[1] - pad_x)); x1 <- min(W, ceiling(xr[2] + pad_x))
    y0 <- max(1L, floor(yr[1] - pad_y)); y1 <- min(H, ceiling(yr[2] + pad_y))
    crop <- he_img[y0:y1, x0:x1, 1:min(3L, dim(he_img)[3]), drop = FALSE]
    p_he <- ggplot() +
      annotation_custom(grid::rasterGrob(as.raster(crop), width = grid::unit(1, "npc"), height = grid::unit(1, "npc"), interpolate = TRUE)) +
      coord_fixed(ratio = (y1 - y0 + 1) / max(1, (x1 - x0 + 1))) +
      theme_void() +
      theme(panel.border = element_rect(fill = NA, colour = "#D5D0D5", linewidth = 0.4))
  } else {
    y_vals <- if (invert_y) -sub_spots$y else sub_spots$y
    p_he <- ggplot(sub_spots, aes(x = x, y = y_vals, colour = he_intensity)) +
      geom_point(size = pt_sz * 1.4, stroke = 0, alpha = 0.85) +
      scale_colour_gradientn(colours = c("#F7EDF2", "#E2ABC3", "#845691"), guide = "none") +
      coord_equal() +
      theme_void() +
      theme(panel.background = element_rect(fill = "#FAF7F9", colour = "#D5D0D5", linewidth = 0.4))
  }
  hdr <- patchwork::wrap_elements(full = grid::textGrob(paste("H&E |", reg_name),
                                                        gp = grid::gpar(fontsize = 6.8, fontface = "bold", col = "#383438")))
  patchwork::wrap_plots(hdr, p_he, ncol = 1, heights = c(0.14, 0.86))
}

make_deconv_panel <- function(sub_df, ft_name) {
  y_vals <- if (invert_y) -sub_df$y else sub_df$y
  sub_df$yp <- y_vals
  sub_df <- sub_df[order(sub_df$score_disp), ]
  xy <- cbind(sub_df$x, sub_df$yp)
  gx <- seq(min(xy[, 1]), max(xy[, 1]), length.out = 68)
  gy <- seq(min(xy[, 2]), max(xy[, 2]), length.out = 68)
  grid <- expand.grid(x = gx, yp = gy)
  if (nrow(sub_df) >= 4L) {
    d2 <- outer(grid$x, xy[, 1], "-")^2 + outer(grid$yp, xy[, 2], "-")^2
    nn_idx <- max.col(-d2, ties.method = "first")
    min_d <- sqrt(apply(d2, 1, min))
    sd2 <- outer(xy[, 1], xy[, 1], "-")^2 + outer(xy[, 2], xy[, 2], "-")^2
    diag(sd2) <- Inf
    spacing <- stats::median(sqrt(apply(sd2, 1, min)))
    grid$sc <- sub_df$score_disp[nn_idx]
    grid$sc[min_d > 0.90 * spacing] <- NA_real_
  } else {
    grid$sc <- NA_real_
  }
  p_tile <- ggplot(sub_df, aes(x = x, y = yp, colour = score_disp)) +
    geom_raster(data = grid, aes(x = x, y = yp, fill = sc), inherit.aes = FALSE, interpolate = TRUE) +
    geom_point(size = pt_sz, stroke = 0) +
    scale_fill_gradientn(colours = pal, limits = c(0, 1), na.value = "white", guide = "none") +
    scale_colour_gradientn(colours = pal, limits = c(0, 1), guide = "none") +
    coord_equal() +
    theme_void() +
    theme(panel.border = element_rect(fill = NA, colour = "#D5D0D5", linewidth = 0.4))
  hdr <- patchwork::wrap_elements(full = score_header(ft_name))
  patchwork::wrap_plots(hdr, p_tile, ncol = 1, heights = c(0.14, 0.86))
}

region_blocks <- lapply(regions, function(reg) {
  sub <- raw[raw$region == reg, ]
  base <- sub %>% dplyr::distinct(spot_id, .keep_all = TRUE)
  he_p <- make_he_panel(base, reg)
  ft_ps <- lapply(features, function(ft) make_deconv_panel(sub[sub$feature == ft, ], ft))
  patchwork::wrap_plots(c(list(he_p), ft_ps), nrow = 1)
})

ncol_reg <- if (length(regions) >= 2L) 2L else 1L
combined <- patchwork::wrap_plots(region_blocks, ncol = ncol_reg) &
  theme(plot.margin = margin(3, 4, 4, 4))

nrow_reg <- ceiling(length(regions) / ncol_reg)
n_cols_total <- ncol_reg * (1L + length(features))
w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(5.4, min(14, n_cols_total * 1.65))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.0, min(12, nrow_reg * 2.75))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
