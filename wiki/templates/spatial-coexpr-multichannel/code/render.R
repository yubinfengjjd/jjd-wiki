# Multi-Channel Spatial Co-Expression & Highlighted Zone Map Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(jsonlite)
  library(scales)
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

fname <- if (!is.null(spec$tables$spots$filename)) spec$tables$spots$filename else "spatial_coexpr_spots.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    spot_id = as.character(spot_id),
    x = as.numeric(x),
    y = as.numeric(y),
    channel = as.character(channel),
    value = as.numeric(value)
  ) %>%
  dplyr::filter(!is.na(spot_id), is.finite(x), is.finite(y), !is.na(channel), is.finite(value))

if (!"region" %in% names(raw)) raw$region <- "Section"
if (!"highlight_zone" %in% names(raw)) raw$highlight_zone <- 0L
raw$region <- as.character(raw$region)
raw$region[is.na(raw$region) | !nzchar(raw$region)] <- "Section"
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
pt_sz <- if (is.null(style$point_size)) 0.95 else as.numeric(style$point_size)
ncol_val <- if (is.null(style$ncol)) min(4L, max(1L, length(regions))) else as.integer(style$ncol)
ch_mode <- if (is.null(style$channel_mode)) "auto" else as.character(style$channel_mode)
if (ch_mode == "auto") ch_mode <- if (n_ch == 2L) "concentric" else "offset"

# Normalize each region to [0, 1] x [0, 1] and compute soft tissue footprint without external C libs
base_spots <- raw %>%
  dplyr::distinct(region_fac, spot_id, .keep_all = TRUE) %>%
  dplyr::group_by(region_fac) %>%
  dplyr::mutate(
    xn = if (diff(range(x)) > 0) (x - min(x)) / diff(range(x)) else 0.5,
    yn = if (diff(range(y_plot)) > 0) (y_plot - min(y_plot)) / diff(range(y_plot)) else 0.5
  ) %>%
  dplyr::ungroup()

raw <- raw %>%
  dplyr::left_join(base_spots %>% dplyr::select(region_fac, spot_id, xn, yn), by = c("region_fac", "spot_id"))

footprint_list <- lapply(regions, function(reg) {
  sub <- base_spots[base_spots$region == reg, ]
  gx <- seq(-0.02, 1.02, length.out = 64)
  gy <- seq(-0.02, 1.02, length.out = 64)
  grid <- expand.grid(xn = gx, yn = gy)
  if (nrow(sub) >= 4L) {
    d2 <- outer(grid$xn, sub$xn, "-")^2 + outer(grid$yn, sub$yn, "-")^2
    min_d <- sqrt(apply(d2, 1, min))
    # Median nearest-neighbor spacing among spots
    sd2 <- outer(sub$xn, sub$xn, "-")^2 + outer(sub$yn, sub$yn, "-")^2
    diag(sd2) <- Inf
    spacing <- stats::median(sqrt(apply(sd2, 1, min)))
    inside <- min_d <= 0.95 * spacing
  } else {
    inside <- rep(TRUE, nrow(grid))
  }
  grid$ink <- ifelse(inside, "#F4F2F4", "white")
  grid$region_fac <- factor(reg, levels = regions)
  grid
})
footprint <- do.call(rbind, footprint_list)

high <- setNames(vapply(channels, function(ch) {
  vals <- raw$value[raw$channel == ch]
  p <- as.numeric(stats::quantile(vals, qcap, na.rm = TRUE, names = FALSE))
  if (!is.finite(p) || p <= 0) max(vals, na.rm = TRUE) else p
}, numeric(1)), channels)

wave_colour <- function(v, ramp) {
  clamped <- scales::squish(v)
  grDevices::colorRampPalette(ramp)(256)[1L + round(clamped * 255)]
}

p <- ggplot(base_spots, aes(x = xn, y = yn)) +
  geom_raster(data = footprint, aes(x = xn, y = yn, fill = ink), inherit.aes = FALSE, interpolate = TRUE) +
  scale_fill_identity() +
  geom_point(colour = "#DFDCE0", size = pt_sz * 1.15, stroke = 0)

hl_spots <- base_spots[as.numeric(base_spots$highlight_zone) > 0, ]
if (nrow(hl_spots) > 0L) {
  p <- p + geom_point(data = hl_spots, colour = "#D7191C", size = pt_sz * 1.65, stroke = 0, alpha = 0.25)
}

if (ch_mode == "concentric" && n_ch == 2L) {
  c1 <- raw[raw$channel == channels[1L], ]
  c2 <- raw[raw$channel == channels[2L], ]
  merged <- dplyr::inner_join(
    c1 %>% dplyr::select(region_fac, spot_id, xn, yn, v1 = value),
    c2 %>% dplyr::select(region_fac, spot_id, v2 = value),
    by = c("region_fac", "spot_id")
  )
  merged$m1 <- scales::squish(merged$v1 / high[[channels[1L]]])
  merged$m2 <- scales::squish(merged$v2 / high[[channels[2L]]])
  merged$fill_ink <- wave_colour(merged$m1, c("#F0EBEF", inks[[channels[1L]]]))
  merged$ring_ink <- wave_colour(merged$m2, c("#EFE9EE", inks[[channels[2L]]]))
  merged <- merged[order(merged$m1 + merged$m2), ]

  p <- p +
    geom_point(data = merged, aes(x = xn, y = yn, fill = fill_ink, colour = ring_ink),
               shape = 21, size = pt_sz * 1.15, stroke = 0.35, alpha = 0.90) +
    scale_colour_identity()
} else {
  angles <- seq(0, 2 * pi, length.out = n_ch + 1L)[seq_len(n_ch)] + pi / 4
  offsets <- cbind(cos(angles), sin(angles)) * 0.011
  dots_list <- lapply(seq_len(n_ch), function(i) {
    ch <- channels[i]
    sub <- raw[raw$channel == ch, ]
    sub$lvl <- scales::squish(sub$value / high[[ch]])
    sub <- sub[is.finite(sub$lvl) & sub$lvl > 0, ]
    sub$dx <- sub$xn + offsets[i, 1L]
    sub$dy <- sub$yn + offsets[i, 2L]
    sub$ink <- inks[[ch]]
    sub
  })
  dots <- do.call(rbind, dots_list)
  dots <- dots[order(dots$lvl), ]
  p <- p +
    geom_point(data = dots, aes(x = dx, y = dy, colour = ink, alpha = lvl^1.2),
               size = pt_sz * 0.88, stroke = 0) +
    scale_colour_identity() +
    scale_alpha_continuous(range = c(0.08, 0.92), limits = c(0, 1), guide = "none")
}

if (nrow(hl_spots) > 0L) {
  p <- p + geom_point(data = hl_spots, shape = 21, fill = NA, colour = "#D7191C",
                      size = pt_sz * 1.75, stroke = 0.35)
}

if (length(regions) > 1L) {
  p <- p + facet_wrap(~region_fac, ncol = ncol_val)
}

p <- p +
  coord_fixed(xlim = c(-0.04, 1.04), ylim = c(-0.04, 1.04), expand = FALSE) +
  theme_void(base_size = 8.5) +
  theme(
    strip.text = element_text(size = 8.5, face = "bold", margin = margin(b = 3)),
    panel.border = element_rect(fill = NA, colour = "#9E999E", linewidth = 0.5),
    panel.spacing = grid::unit(3.0, "mm"),
    plot.margin = margin(6, 4, 6, 6)
  )

# Right-side stacked vertical channel colorbars
key_panels <- lapply(channels, function(ch) {
  ink_vec <- grDevices::colorRampPalette(c("#F3EFF1", inks[[ch]]))(128)
  max_lbl <- format(round(high[[ch]], 2), trim = TRUE, nsmall = 1)
  g <- grid::grobTree(
    grid::textGrob(ch, x = 0.08, y = 0.90, just = "left", gp = grid::gpar(fontsize = 7.2, fontface = "bold")),
    grid::rasterGrob(as.raster(matrix(rev(ink_vec), ncol = 1)), x = 0.22, y = 0.44, width = 0.22, height = 0.62, interpolate = FALSE),
    grid::textGrob(c(max_lbl, "0"), x = 0.42, y = c(0.73, 0.15), just = "left", gp = grid::gpar(fontsize = 6.2))
  )
  patchwork::wrap_elements(full = g)
})
keys <- patchwork::wrap_plots(key_panels, ncol = 1)
combined <- patchwork::wrap_plots(p, keys, nrow = 1, widths = c(0.84, 0.16))

nrow_val <- ceiling(length(regions) / ncol_val)
w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(5.2, min(14, ncol_val * 2.8 + 1.5))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.6, min(12, nrow_val * 2.8 + 0.6))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
