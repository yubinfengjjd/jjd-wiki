# H&E Histology & Spatial Deconvolution Side-by-Side Panel Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(jsonlite)
  library(scales)
  library(png)
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

fname <- if (!is.null(spec$tables$spots$filename)) spec$tables$spots$filename else "spatial_deconv_spots.csv"
raw <- utils::read.csv(file.path(data_dir, fname), check.names = FALSE, stringsAsFactors = FALSE)
raw$spot_id <- as.character(raw$spot_id)
raw$x <- as.numeric(raw$x)
raw$y <- as.numeric(raw$y)
raw$feature <- as.character(raw$feature)
raw$score <- as.numeric(raw$score)
keep <- !is.na(raw$spot_id) & is.finite(raw$x) & is.finite(raw$y) & !is.na(raw$feature) & is.finite(raw$score)
raw <- raw[keep, , drop = FALSE]

if (!"region" %in% names(raw)) raw$region <- "Section"
raw$region <- as.character(raw$region)
raw$region[is.na(raw$region) | !nzchar(raw$region)] <- "Section"
if (!"he_intensity" %in% names(raw)) raw$he_intensity <- 0.55
raw$he_intensity <- as.numeric(raw$he_intensity)
raw$he_intensity[!is.finite(raw$he_intensity)] <- 0.55

pal <- unlist(style$palette)
if (length(pal) < 2L) pal <- c("#46468A", "#5CB874", "#F7DC6F", "#C0392B")
invert_y <- if (is.null(style$invert_y)) TRUE else isTRUE(style$invert_y)
qcap <- if (is.null(style$quantile_cap)) 0.995 else as.numeric(style$quantile_cap)
gamma_val <- if (is.null(style$gamma)) 1.65 else as.numeric(style$gamma)
pt_sz <- if (is.null(style$point_size)) 1.0 else as.numeric(style$point_size)

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
    return(scales::squish((v - rng[1L]) / diff(rng)))
  }
  scales::squish((v - b[1L]) / diff(b))
}

raw$score_disp <- NA_real_
for (ft in features) {
  idx <- raw$feature == ft
  raw$score_disp[idx] <- quantile01(raw$score[idx])^gamma_val
}

score_header <- function(label) {
  colours <- grDevices::colorRampPalette(pal)(96)
  grid::grobTree(
    grid::textGrob(label, x = 0.01, y = 0.55, just = "left", gp = grid::gpar(fontsize = 6.0)),
    grid::rasterGrob(as.raster(matrix(colours, nrow = 1)), x = 0.79, y = 0.58, width = 0.34, height = 0.30, interpolate = FALSE),
    grid::textGrob(c("Min", "Max"), x = c(0.62, 0.96), y = 0.18, gp = grid::gpar(fontsize = 4.9))
  )
}

crop_bounds <- function(sub_spots) {
  xr <- range(sub_spots$x); yr <- range(sub_spots$y)
  if (!is.null(he_img) && length(dim(he_img)) >= 3L) {
    H <- dim(he_img)[1L]; W <- dim(he_img)[2L]
    list(
      x = seq(max(1L, floor(xr[1L] - 7)), min(W, ceiling(xr[2L] + 7))),
      y = seq(max(1L, floor(yr[1L] - 7)), min(H, ceiling(yr[2L] + 7)))
    )
  } else {
    pad_x <- max(3, diff(xr) * 0.05); pad_y <- max(3, diff(yr) * 0.05)
    list(x = c(xr[1L] - pad_x, xr[2L] + pad_x), y = c(yr[1L] - pad_y, yr[2L] + pad_y))
  }
}

make_he_panel <- function(sub_spots, reg_name, bounds) {
  if (!is.null(he_img) && length(dim(he_img)) >= 3L) {
    crop <- he_img[bounds$y, bounds$x, 1:min(3L, dim(he_img)[3L]), drop = FALSE]
    p_he <- patchwork::wrap_elements(full = grid::rasterGrob(as.raster(crop), interpolate = TRUE))
  } else {
    yp <- if (invert_y) -sub_spots$y else sub_spots$y
    xy <- cbind(sub_spots$x, yp)
    bx <- range(bounds$x); by <- if (invert_y) range(-bounds$y) else range(bounds$y)
    grid_df <- expand.grid(x = seq(bx[1L], bx[2L], length.out = 95L),
                           y = seq(by[1L], by[2L], length.out = 95L))
    if (nrow(sub_spots) >= 4L) {
      d2 <- outer(grid_df$x, xy[, 1L], "-")^2 + outer(grid_df$y, xy[, 2L], "-")^2
      nn_idx <- max.col(-d2, ties.method = "first")
      min_d <- sqrt(apply(d2, 1L, min))
      sd2 <- outer(xy[, 1L], xy[, 1L], "-")^2 + outer(xy[, 2L], xy[, 2L], "-")^2
      diag(sd2) <- Inf
      spacing <- stats::median(sqrt(apply(sd2, 1L, min)))
      grid_df$val <- sub_spots$he_intensity[nn_idx]
      grid_df$val[min_d > 0.85 * spacing] <- NA_real_
    } else {
      grid_df$val <- NA_real_
    }
    p_he <- ggplot(grid_df, aes(x = x, y = y, fill = val)) +
      geom_raster(interpolate = TRUE) +
      scale_fill_gradientn(colours = c("#F4E7EE", "#DCA2BF", "#9A5B95"), limits = c(0, 1),
                           na.value = "white", guide = "none") +
      coord_fixed(xlim = bx, ylim = by, expand = FALSE) +
      theme_void() + theme(plot.margin = margin(0, 0, 0, 0))
  }
  hdr <- patchwork::wrap_elements(full = grid::textGrob(paste("H&E |", reg_name),
                                                        gp = grid::gpar(fontsize = 6.2, col = "#454045")))
  patchwork::wrap_plots(hdr, p_he, ncol = 1, heights = c(0.14, 0.86))
}

make_deconv_panel <- function(sub_df, ft_name, bounds) {
  sub_df$yp <- if (invert_y) -sub_df$y else sub_df$y
  sub_df <- sub_df[order(sub_df$score_disp), , drop = FALSE]
  xy <- cbind(sub_df$x, sub_df$yp)
  bx <- range(bounds$x); by <- if (invert_y) range(-bounds$y) else range(bounds$y)
  grid_df <- expand.grid(x = seq(bx[1L], bx[2L], length.out = 95L),
                         yp = seq(by[1L], by[2L], length.out = 95L))
  if (nrow(sub_df) >= 4L) {
    d2 <- outer(grid_df$x, xy[, 1L], "-")^2 + outer(grid_df$yp, xy[, 2L], "-")^2
    nn_idx <- max.col(-d2, ties.method = "first")
    min_d <- sqrt(apply(d2, 1L, min))
    sd2 <- outer(xy[, 1L], xy[, 1L], "-")^2 + outer(xy[, 2L], xy[, 2L], "-")^2
    diag(sd2) <- Inf
    spacing <- stats::median(sqrt(apply(sd2, 1L, min)))
    grid_df$sc <- sub_df$score_disp[nn_idx]
    grid_df$sc[min_d > 0.85 * spacing] <- NA_real_
  } else {
    grid_df$sc <- NA_real_
  }
  p_tile <- ggplot(sub_df, aes(x = x, y = yp, colour = score_disp)) +
    geom_raster(data = grid_df, aes(x = x, y = yp, fill = sc), inherit.aes = FALSE, interpolate = TRUE) +
    geom_point(size = pt_sz, stroke = 0) +
    scale_fill_gradientn(colours = pal, limits = c(0, 1), na.value = "white", guide = "none") +
    scale_colour_gradientn(colours = pal, limits = c(0, 1), guide = "none") +
    coord_fixed(xlim = bx, ylim = by, expand = FALSE) +
    theme_void() +
    theme(plot.margin = margin(0, 0, 0, 0))
  hdr <- patchwork::wrap_elements(full = score_header(ft_name))
  patchwork::wrap_plots(hdr, p_tile, ncol = 1, heights = c(0.14, 0.86))
}

region_blocks <- lapply(regions, function(reg) {
  sub <- raw[raw$region == reg, , drop = FALSE]
  base <- sub[!duplicated(sub$spot_id), , drop = FALSE]
  bounds <- crop_bounds(base)
  he_p <- make_he_panel(base, reg, bounds)
  ft_ps <- lapply(features, function(ft) make_deconv_panel(sub[sub$feature == ft, , drop = FALSE], ft, bounds))
  patchwork::wrap_plots(c(list(he_p), ft_ps), nrow = 1)
})

ncol_reg <- if (length(regions) >= 2L) 2L else 1L
combined <- patchwork::wrap_plots(region_blocks, ncol = ncol_reg) &
  theme(plot.margin = margin(3, 5, 4, 5))

nrow_reg <- ceiling(length(regions) / ncol_reg)
n_cols_total <- ncol_reg * (1L + length(features))
w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(5.4, min(14, n_cols_total * 1.75))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.0, min(12, nrow_reg * 2.4))
dpi_val <- if (is.null(style$dpi)) 300L else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
