# Panel ID: fig06/G (Fig. 6 6G)
# Title: CAA_ST 3-signal spatial signature weighting proxy for C4_TipEC_PGF, M1, and M2.
# Evidence tier: proxy
# Input tables: runs/step03_spatial/st_spots_fig6degh.csv
# Default dimensions: width = 5.6 in, height = 3.4 in
# Usage: Rscript --vanilla code/panels/fig06_g.R --paper-root <PAPER_ROOT> --out fig06_g.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig06_g.png', default_width = 5.6, default_height = 3.4)
st <- read_step("step03_spatial", "st_spots_fig6degh")
spectral <- c("#4575B4", "#91BFDB", "#FEE090", "#D73027")
normalize_q <- function(x) {
  q <- unname(quantile(x, c(.05, .98), na.rm = TRUE))
  if (diff(q) < .Machine$double.eps) return(scale01(x))
  scales::squish(scales::rescale(x, from = q))
}
map_group <- function(d, features, ncol, tag, subtitle) {
  xy <- cbind(d$imagecol, -d$imagerow)
  grid <- expand.grid(x = seq(min(xy[, 1]), max(xy[, 1]), length.out = 77),
                      y = seq(min(xy[, 2]), max(xy[, 2]), length.out = 99))
  spacing <- median(RANN::nn2(xy, k = 2)$nn.dists[, 2])
  near <- RANN::nn2(xy, as.matrix(grid), k = 1)
  inside <- near$nn.dists[, 1] <= .98 * spacing
  maps <- do.call(rbind, lapply(names(features), function(label) {
    v <- normalize_q(d[[features[[label]]]])[near$nn.idx[, 1]]
    v[!is.finite(v)] <- 0
    dominant <- col2rgb(wave_colour(v, spectral, c(0, 1)))
    blend <- .06 + .94 * v^1.45
    base <- as.numeric(col2rgb("#B0A6C4"))
    clr <- grDevices::rgb((base[1] * (1 - blend) + dominant[1, ] * blend) / 255,
                          (base[2] * (1 - blend) + dominant[2, ] * blend) / 255,
                          (base[3] * (1 - blend) + dominant[3, ] * blend) / 255)
    clr[!inside] <- "white"
    transform(grid, x = round(scale01(x), 8), y = round(scale01(y), 8),
              ink = clr, label = factor(label, levels = names(features)))
  }))
  markers <- data.frame(label = factor(names(features), levels = names(features)))
  edges <- seq(.616, .976, length.out = 97)
  bars <- merge(markers, data.frame(xleft = head(edges, -1), xright = tail(edges, -1),
    ink = grDevices::colorRampPalette(spectral)(96)), by = NULL)
  endpoints <- merge(markers, data.frame(x = c(.616, .978), endpoint = c("Min", "Max"), align = c(.25, .89)), by = NULL)
  g <- ggplot(maps, aes(x, y, fill = ink)) +
    geom_raster(interpolate = TRUE) +
    geom_rect(data = bars, aes(xmin = xleft, xmax = xright, ymin = 1.061, ymax = 1.117, fill = ink), inherit.aes = FALSE) +
    geom_text(data = markers, aes(label = label), x = .0, y = 1.08, hjust = 0, size = 1.78, inherit.aes = FALSE) +
    geom_text(data = endpoints, aes(x = x, label = endpoint, hjust = align), y = 1.185, size = 1.55, inherit.aes = FALSE) +
    facet_wrap(~label, ncol = ncol) +
    scale_fill_identity() +
    coord_cartesian(xlim = c(-.01, 1.02), ylim = c(-.015, 1.22), expand = FALSE, clip = "off") +
    theme_void() + theme(strip.text = element_blank(), panel.spacing = grid::unit(2.6, "mm"), plot.margin = margin(4, 5, 4, 9))
  panel_tag(wrap_plots(wrap_elements(full = grid::textGrob(subtitle, x = .06, just = "left", gp = grid::gpar(fontsize = 5.7))),
                       g, ncol = 1, heights = c(.092, .908)), tag)
}

p <- map_group(st, c("C4_TipEC_PGF" = "score_C4_TipEC_PGF", "M1" = "score_M1", "M2" = "score_M2"), 3, "G", "CAA_ST")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
