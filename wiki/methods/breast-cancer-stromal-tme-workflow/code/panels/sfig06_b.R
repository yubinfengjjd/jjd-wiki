# Panel ID: sfig06/B (Supp. Fig. 6 S6B)
# Title: CAA_ST 8-region CCL19 and CCR7 dual-channel spatial co-expression grid.
# Evidence tier: local_recompute
# Input tables: runs/step03_spatial/st_spots_sfig6abc.csv
# Default dimensions: width = 6.8 in, height = 4.0 in
# Usage: Rscript --vanilla code/panels/sfig06_b.R --paper-root <PAPER_ROOT> --out sfig06_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig06_b.png', default_width = 6.8, default_height = 4.0)
st <- read_step("step03_spatial", "st_spots_sfig6abc")
st$half <- 1L + (st$imagecol > median(st$imagecol))
st$band <- ave(st$imagerow, st$half, FUN = function(y) cut(y, quantile(y, 0:4 / 4), labels = FALSE, include.lowest = TRUE))
st$region <- (st$half - 1L) * 4L + st$band
areas <- split(st, st$region)
view_order <- 1:8
positions <- do.call(rbind, lapply(areas, function(d) { d$x <- scale01(d$imagecol); d$y <- scale01(-d$imagerow); d }))
positions$region <- factor(positions$region, levels = view_order, labels = paste("Area", view_order))
footprint <- do.call(rbind, lapply(areas, function(d) {
  xy <- cbind(d$imagecol, -d$imagerow)
  grid <- expand.grid(x = seq(min(xy[, 1]), max(xy[, 1]), length.out = 70), y = seq(min(xy[, 2]), max(xy[, 2]), length.out = 70))
  spacing <- median(RANN::nn2(xy, k = 2)$nn.dists[, 2])
  gap <- RANN::nn2(xy, as.matrix(grid), k = 1)$nn.dists[, 1]
  transform(grid, x = round(scale01(x), 8), y = round(scale01(y), 8),
            ink = ifelse(gap < .93 * spacing, "#F4F2F4", "white"),
            region = factor(paste("Area", d$region[1]), levels = paste("Area", view_order)))
}))
scale_signals <- function(channels) {
  setNames(vapply(channels, function(gene) {
    pv <- quantile(st[[gene]], .99, na.rm = TRUE, names = FALSE)
    if (pv <= 0) max(st[[gene]], na.rm = TRUE) else pv
  }, numeric(1)), channels)
}
tls_grid <- function(inks, tag, title) {
  high <- scale_signals(names(inks))
  offsets <- if (length(inks) == 2L) rbind(c(-1, 0), c(1, 0)) else rbind(c(-1, 1), c(1, 1), c(-1, -1), c(1, -1))
  dots <- do.call(rbind, lapply(seq_along(inks), function(i) {
    gene <- names(inks)[i]
    v <- scales::squish(positions[[gene]] / high[[gene]])
    value <- transform(positions, x = x + offsets[i, 1] * .009, y = y + offsets[i, 2] * .009, level = v, ink = unname(inks[i]))
    value[is.finite(value$level) & value$level > 0, ]
  }))
  maps <- ggplot(positions, aes(x, y)) +
    geom_raster(data = footprint, aes(x, y, fill = ink), inherit.aes = FALSE, interpolate = TRUE) +
    scale_fill_identity() +
    geom_point(colour = "#E0DFE1", size = .63, stroke = 0) +
    geom_point(data = dots[order(dots$level), ], aes(colour = ink, alpha = level^1.25), size = .48, stroke = 0) +
    scale_colour_identity() + scale_alpha_continuous(range = c(.07, .88), limits = c(0, 1), guide = "none") +
    facet_wrap(~region, ncol = 4) +
    coord_cartesian(xlim = c(-.032, 1.032), ylim = c(-.035, 1.035), expand = FALSE) +
    theme_void() + theme(aspect.ratio = 1, strip.text = element_text(size = 6.3, margin = margin(b = 2)),
      panel.border = element_rect(fill = NA, colour = "#A39EA2", linewidth = .43),
      panel.spacing = grid::unit(2.2, "mm"), plot.margin = margin(0, 1, 0, 4))
  keys <- wrap_plots(lapply(names(inks), function(gene)
    wrap_elements(full = wave_key(c("#F3EFF1", inks[[gene]]), title = gene, min = "0",
      max = format(round(high[[gene]], 2), trim = TRUE, nsmall = 1),
      vertical = TRUE, label_size = 6.0, title_gap = length(inks) > 2L))), ncol = 1)
  tag_body <- wrap_plots(wrap_elements(full = grid::textGrob(title, x = .085, just = "left", gp = grid::gpar(fontsize = 6.75, col = "#4B444A"))),
                         wave_section(wrap_elements(full = maps), wrap_elements(full = keys), widths = c(.881, .119)),
                         ncol = 1, heights = c(.068, .932))
  panel_tag(tag_body, tag)
}

p <- tls_grid(c(CCL19 = "#3B7EB6", CCR7 = "#D73027"), "B", "CAA_ST  |  CCL19 and CCR7")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
