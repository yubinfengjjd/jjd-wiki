# Panel ID: sfig03/A (Supp. Fig. 3 S3A)
# Title: CAA_ST 8-region COL1A1, COL1A2, and DCN spatial expression grid.
# Evidence tier: local_recompute
# Input tables: runs/step03_spatial/st_spots_sfig3.csv
# Default dimensions: width = 9.6 in, height = 7.4 in
# Usage: Rscript --vanilla code/panels/sfig03_a.R --paper-root <PAPER_ROOT> --out sfig03_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig03_a.png', default_width = 9.6, default_height = 7.4)
st <- read_step("step03_spatial", "st_spots_sfig3")
genes <- c("COL1A1", "COL1A2", "DCN")
expr_ink <- c("#3288BD", "#E6F598", "#FEE08B", "#F46D43", "#9E0142")
st$x_half <- 1L + (st$imagecol > median(st$imagecol))
st$y_band <- ave(st$imagerow, st$x_half, FUN = function(y) cut(y, quantile(y, 0:4 / 4), labels = FALSE, include.lowest = TRUE))
st$region <- (st$x_half - 1L) * 4L + st$y_band
for (gene in genes) st[[paste0(gene, "_display")]] <- panel_quantile01(st[[gene]])
expr_block <- function(region_order) {
  s <- st[st$region %in% region_order, ]
  s$region_label <- factor(paste("Region", s$region), levels = paste("Region", region_order))
  long <- do.call(rbind, lapply(genes, function(gene) transform(s, gene = factor(gene, levels = genes), signal = s[[paste0(gene, "_display")]])))
  long <- do.call(rbind, lapply(split(long, long$region), function(d) transform(d, x = scale01(imagecol), y = scale01(-imagerow))))
  ground <- do.call(rbind, lapply(split(s, s$region), function(d) {
    xy <- cbind(d$imagecol, -d$imagerow)
    grid <- expand.grid(x = seq(min(xy[, 1]), max(xy[, 1]), length.out = 92), y = seq(min(xy[, 2]), max(xy[, 2]), length.out = 92))
    near <- RANN::nn2(xy, as.matrix(grid), k = 1)
    spacing <- median(RANN::nn2(xy, k = 2)$nn.dists[, 2])
    do.call(rbind, lapply(genes, function(gene) {
      score <- d[[paste0(gene, "_display")]][near$nn.idx[, 1]]
      ink <- wave_colour(score, expr_ink, c(0, 1))
      rgb <- col2rgb(ink)
      ink <- grDevices::rgb((.72 * 255 + .28 * rgb[1, ]) / 255, (.72 * 255 + .28 * rgb[2, ]) / 255, (.72 * 255 + .28 * rgb[3, ]) / 255)
      ink[near$nn.dists[, 1] > .93 * spacing] <- "white"
      transform(grid, x = round(scale01(x), 8), y = round(scale01(y), 8), ink = ink,
                region_label = d$region_label[1], gene = factor(gene, levels = genes))
    }))
  }))
  ggplot(long[order(long$signal), ], aes(x, y, colour = signal)) +
    geom_raster(data = ground, aes(x, y, fill = ink), inherit.aes = FALSE, interpolate = TRUE) +
    scale_fill_identity() + geom_point(size = 1.02, stroke = 0, alpha = .91) +
    facet_grid(region_label ~ gene, switch = "y") +
    scale_colour_gradientn(colours = expr_ink, limits = c(0, 1), guide = "none") +
    coord_cartesian(xlim = c(-.038, 1.038), ylim = c(-.038, 1.038), expand = FALSE) +
    theme_void() + theme(aspect.ratio = 1, panel.border = element_rect(fill = NA, colour = "#141414", linewidth = .54),
      strip.text.x = element_text(size = 10.1, margin = margin(b = 4)),
      strip.text.y.left = element_text(size = 8.7, angle = 90, margin = margin(r = 4)),
      strip.placement = "outside", panel.spacing = grid::unit(1.9, "mm"), plot.margin = margin(4, 3, 2, 5))
}
expression <- wrap_plots(wrap_elements(full = expr_block(1:4)), wrap_elements(full = expr_block(5:8)), nrow = 1)
title <- wrap_elements(full = grid::textGrob("CAA_ST  |  Eight regions of one Visium section", x = .055, just = "left", gp = grid::gpar(fontsize = 7.2, col = "#444444")))
A_plot <- wrap_elements(full = wrap_plots(title, expression, ncol = 1, heights = c(.045, .955))) +
  inset_element(wave_key(expr_ink, min = "Min", max = "Max"), .448, .953, .551, .998, align_to = "full")
p <- panel_tag(A_plot, "A")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
