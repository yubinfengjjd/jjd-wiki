# Multi-Channel Spatial Co-Expression & Highlighted Zone Map Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(jsonlite)
  library(scales)
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

fname <- if (!is.null(spec$tables$spots$filename)) spec$tables$spots$filename else "spatial_coexpr_spots.csv"
raw <- utils::read.csv(file.path(data_dir, fname), check.names = FALSE, stringsAsFactors = FALSE)
raw$spot_id <- as.character(raw$spot_id)
raw$x <- as.numeric(raw$x)
raw$y <- as.numeric(raw$y)
raw$channel <- as.character(raw$channel)
raw$value <- as.numeric(raw$value)
keep <- !is.na(raw$spot_id) & is.finite(raw$x) & is.finite(raw$y) & !is.na(raw$channel) & is.finite(raw$value)
raw <- raw[keep, , drop = FALSE]

if (!"region" %in% names(raw)) raw$region <- "Section"
if (!"highlight_zone" %in% names(raw)) raw$highlight_zone <- 0L
raw$region <- as.character(raw$region)
raw$region[is.na(raw$region) | !nzchar(raw$region)] <- "Section"
raw$highlight_zone <- as.integer(raw$highlight_zone)
raw$highlight_zone[is.na(raw$highlight_zone)] <- 0L

invert_y <- if (is.null(style$invert_y)) TRUE else isTRUE(style$invert_y)
raw$y_plot <- if (invert_y) -raw$y else raw$y

regions <- unique(raw$region)
raw$region_fac <- factor(raw$region, levels = regions)
channels <- unique(raw$channel)
n_ch <- length(channels)

ch_pal <- unlist(style$channel_colors)
if (length(ch_pal) < n_ch) {
  ch_pal <- grDevices::colorRampPalette(c("#D73027", "#31A354", "#3B7EB6", "#8856A7", "#E68A00"))(n_ch)
}
inks <- setNames(ch_pal[seq_len(n_ch)], channels)

qcap <- if (is.null(style$quantile_cap)) 0.99 else as.numeric(style$quantile_cap)
pt_sz <- if (is.null(style$point_size)) 0.65 else as.numeric(style$point_size)
ncol_val <- if (is.null(style$ncol)) min(4L, max(1L, length(regions))) else as.integer(style$ncol)
ch_mode <- if (is.null(style$channel_mode)) "auto" else as.character(style$channel_mode)
if (ch_mode == "auto") ch_mode <- if (n_ch == 2L) "concentric" else "offset"

# Normalize each region to [0, 1] x [0, 1]
base_spots <- raw[!duplicated(paste(raw$region_fac, raw$spot_id, sep = "\r")), , drop = FALSE]
base_spots$xn <- 0.5
base_spots$yn <- 0.5
for (reg in regions) {
  idx <- which(base_spots$region == reg)
  rx <- range(base_spots$x[idx]); ry <- range(base_spots$y_plot[idx])
  base_spots$xn[idx] <- if (diff(rx) > 0) (base_spots$x[idx] - rx[1L]) / diff(rx) else 0.5
  base_spots$yn[idx] <- if (diff(ry) > 0) (base_spots$y_plot[idx] - ry[1L]) / diff(ry) else 0.5
}

key_bs <- paste(base_spots$region, base_spots$spot_id, sep = "\r")
key_rw <- paste(raw$region, raw$spot_id, sep = "\r")
m_idx <- match(key_rw, key_bs)
raw$xn <- base_spots$xn[m_idx]
raw$yn <- base_spots$yn[m_idx]

footprint_list <- lapply(regions, function(reg) {
  sub <- base_spots[base_spots$region == reg, , drop = FALSE]
  gx <- seq(-0.02, 1.02, length.out = 72L)
  gy <- seq(-0.02, 1.02, length.out = 72L)
  grid_df <- expand.grid(xn = gx, yn = gy)
  if (nrow(sub) >= 4L) {
    d2 <- outer(grid_df$xn, sub$xn, "-")^2 + outer(grid_df$yn, sub$yn, "-")^2
    min_d <- sqrt(apply(d2, 1L, min))
    sd2 <- outer(sub$xn, sub$xn, "-")^2 + outer(sub$yn, sub$yn, "-")^2
    diag(sd2) <- Inf
    spacing <- stats::median(sqrt(apply(sd2, 1L, min)))
    inside <- min_d <= 0.94 * spacing
  } else {
    inside <- rep(TRUE, nrow(grid_df))
  }
  grid_df$ink <- ifelse(inside, "#F4F2F4", "white")
  grid_df$region_fac <- factor(reg, levels = regions)
  grid_df
})
footprint <- do.call(rbind, footprint_list)

high <- setNames(vapply(channels, function(ch) {
  vals <- raw$value[raw$channel == ch]
  p_val <- as.numeric(stats::quantile(vals, qcap, na.rm = TRUE, names = FALSE))
  if (!is.finite(p_val) || p_val <= 0) max(vals, na.rm = TRUE) else p_val
}, numeric(1L)), channels)

wave_colour <- function(v, ramp) {
  clamped <- scales::squish(v)
  grDevices::colorRampPalette(ramp)(256L)[1L + round(clamped * 255)]
}

p <- ggplot(base_spots, aes(x = xn, y = yn)) +
  geom_raster(data = footprint, aes(x = xn, y = yn, fill = ink), inherit.aes = FALSE, interpolate = TRUE) +
  scale_fill_identity() +
  geom_point(colour = "#E0DFE1", size = pt_sz * 1.02, stroke = 0)

if (ch_mode == "concentric" && n_ch == 2L) {
  c1 <- raw[raw$channel == channels[1L], , drop = FALSE]
  c2 <- raw[raw$channel == channels[2L], , drop = FALSE]
  k1 <- paste(c1$region, c1$spot_id, sep = "\r")
  k2 <- paste(c2$region, c2$spot_id, sep = "\r")
  mm <- match(k1, k2)
  keep_m <- !is.na(mm)
  merged <- data.frame(
    region_fac = c1$region_fac[keep_m],
    xn = c1$xn[keep_m],
    yn = c1$yn[keep_m],
    v1 = c1$value[keep_m],
    v2 = c2$value[mm[keep_m]],
    stringsAsFactors = FALSE
  )
  merged$m1 <- scales::squish(merged$v1 / high[[channels[1L]]])
  merged$m2 <- scales::squish(merged$v2 / high[[channels[2L]]])
  merged$fill_ink <- wave_colour(merged$m1, c("#F0EBEF", inks[[channels[1L]]]))
  merged$ring_ink <- wave_colour(merged$m2, c("#EFE9EE", inks[[channels[2L]]]))
  merged <- merged[order(merged$m1 + merged$m2), , drop = FALSE]

  p <- p +
    geom_point(data = merged, aes(x = xn, y = yn, fill = fill_ink, colour = ring_ink),
               shape = 21, size = pt_sz * 1.05, stroke = 0.24, alpha = 0.90) +
    scale_colour_identity()
} else {
  offsets <- if (n_ch == 2L) {
    rbind(c(-1, 0), c(1, 0)) * 0.009
  } else if (n_ch == 4L) {
    rbind(c(-1, 1), c(1, 1), c(-1, -1), c(1, -1)) * 0.009
  } else {
    angles <- seq(0, 2 * pi, length.out = n_ch + 1L)[seq_len(n_ch)] + pi / 4
    cbind(cos(angles), sin(angles)) * 0.010
  }
  dots_list <- lapply(seq_len(n_ch), function(i) {
    ch <- channels[i]
    sub <- raw[raw$channel == ch, , drop = FALSE]
    sub$lvl <- scales::squish(sub$value / high[[ch]])
    sub <- sub[is.finite(sub$lvl) & sub$lvl > 0, , drop = FALSE]
    sub$dx <- sub$xn + offsets[i, 1L]
    sub$dy <- sub$yn + offsets[i, 2L]
    sub$ink <- inks[[ch]]
    sub
  })
  dots <- do.call(rbind, dots_list)
  dots <- dots[order(dots$lvl), , drop = FALSE]
  p <- p +
    geom_point(data = dots, aes(x = dx, y = dy, colour = ink, alpha = lvl^1.25),
               size = pt_sz * 0.78, stroke = 0) +
    scale_colour_identity() +
    scale_alpha_continuous(range = c(0.08, 0.90), limits = c(0, 1), guide = "none")
}

hl_spots <- base_spots[base_spots$highlight_zone > 0L, , drop = FALSE]
if (nrow(hl_spots) > 0L) {
  p <- p + geom_point(data = hl_spots, shape = 21, fill = NA, colour = "#D7191C",
                      size = pt_sz * 1.45, stroke = 0.22, alpha = 0.50)
}

if (length(regions) > 1L) {
  p <- p + facet_wrap(~region_fac, ncol = ncol_val)
}

p <- p +
  coord_fixed(xlim = c(-0.032, 1.032), ylim = c(-0.035, 1.035), expand = FALSE) +
  theme_void(base_size = 8.0) +
  theme(
    strip.text = element_text(size = 7.2, margin = margin(b = 2)),
    panel.border = element_rect(fill = NA, colour = "#A39EA2", linewidth = 0.43),
    panel.spacing = grid::unit(2.2, "mm"),
    plot.margin = margin(4, 2, 4, 4)
  )

key_panels <- lapply(channels, function(ch) {
  ink_vec <- grDevices::colorRampPalette(c("#F3EFF1", inks[[ch]]))(128L)
  max_lbl <- format(round(high[[ch]], 2), trim = TRUE, nsmall = 1)
  g <- grid::grobTree(
    grid::textGrob(ch, x = 0.06, y = 0.94, just = "left", gp = grid::gpar(fontsize = 6.8, fontface = "bold")),
    grid::rasterGrob(as.raster(matrix(rev(ink_vec), ncol = 1L)), x = 0.20, y = 0.44, width = 0.22, height = 0.62, interpolate = FALSE),
    grid::textGrob(c(max_lbl, "0"), x = 0.39, y = c(0.73, 0.14), just = "left", gp = grid::gpar(fontsize = 6.0))
  )
  patchwork::wrap_elements(full = g)
})
keys <- patchwork::wrap_plots(key_panels, ncol = 1L)
combined <- patchwork::wrap_plots(p, keys, nrow = 1L, widths = c(0.87, 0.13))

nrow_val <- ceiling(length(regions) / ncol_val)
w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(5.2, min(14, ncol_val * 2.0 + 1.2))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.6, min(12, nrow_val * 2.1 + 0.5))
dpi_val <- if (is.null(style$dpi)) 300L else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
