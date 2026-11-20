# Panel ID: sfig06/A (Supp. Fig. 6 S6A)
# Title: CAA_ST 3-region 9-cell-type spatial signature grid.
# Evidence tier: proxy
# Input tables: runs/step03_spatial/st_spots_sfig6abc.csv
# Default dimensions: width = 10.6 in, height = 4.8 in
# Usage: Rscript --vanilla code/panels/sfig06_a.R --paper-root <PAPER_ROOT> --out sfig06_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig06_a.png', default_width = 10.6, default_height = 4.8)
st <- read_step("step03_spatial", "st_spots_sfig6abc")
features <- c("C8_iFib_CCL19", "C4_TipEC_PGF", "M1", "M2", "CD4_Effector_T", "CD4_Exhausted_T",
              "CD8_Cytotoxic_T", "Treg", "Transitory_T")
fields <- paste0("score_", features)
density_pal <- c("#46468A", "#5CB874", "#F7DC6F", "#C0392B")
scale_ranges <- lapply(st[fields], function(x) quantile(x, c(.025, .985), na.rm = TRUE, names = FALSE))
st$density_region <- cut(st$imagerow, quantile(st$imagerow, 0:3 / 3), include.lowest = TRUE, labels = FALSE)
density <- do.call(rbind, lapply(split(st, st$density_region), function(d) {
  xy <- cbind(d$imagecol, -d$imagerow)
  grid <- expand.grid(x = seq(min(xy[, 1]), max(xy[, 1]), length.out = 87),
                      y = seq(min(xy[, 2]), max(xy[, 2]), length.out = 87))
  nn <- RANN::nn2(xy, as.matrix(grid), k = 4)
  spacing <- median(RANN::nn2(xy, k = 2)$nn.dists[, 2])
  mask <- nn$nn.dists[, 1] <= 1.01 * spacing
  w <- exp(-.5 * (nn$nn.dists / (.42 * spacing))^2)
  do.call(rbind, lapply(seq_along(fields), function(i) {
    value <- rowSums(matrix(d[[fields[i]]][nn$nn.idx], nrow = nrow(nn$nn.idx)) * w) / rowSums(w)
    value[!mask] <- NA_real_
    transform(grid, x = round(scale01(x), 8), y = round(scale01(y), 8),
              intensity = scales::squish(scales::rescale(value, from = scale_ranges[[i]])),
              region = factor(d$density_region[1], levels = 1:3, labels = paste("Region", 1:3)),
              feature = factor(features[i], levels = features))
  }))
}))
grids <- ggplot(density, aes(x, y, fill = intensity)) +
  geom_raster(interpolate = TRUE) + facet_grid(region ~ feature, switch = "y") +
  scale_fill_gradientn(colours = density_pal, limits = c(0, 1), na.value = "white", guide = "none") +
  coord_cartesian(xlim = c(-.024, 1.024), ylim = c(-.024, 1.024), expand = FALSE) +
  theme_void() + theme(aspect.ratio = 1, strip.placement = "outside",
    strip.text.x = element_text(size = 7.65, hjust = .5, margin = margin(b = 4)),
    strip.text.y.left = element_text(size = 6.3, angle = 90, margin = margin(r = 3)),
    panel.border = element_rect(fill = NA, colour = "#171717", linewidth = .56),
    panel.spacing = grid::unit(2.4, "mm"), plot.margin = margin(1, 2, 1, 4))
subhead <- wrap_elements(full = grid::textGrob("CAA_ST  |  Three regions of one Visium section", x = .043, just = "left", gp = grid::gpar(fontsize = 6.9, col = "#4D484B")))
a_body <- wrap_plots(subhead, wrap_elements(full = grids), wrap_elements(), ncol = 1, heights = c(.065, .888, .047))
density_key <- grid::grobTree(
  grid::textGrob("Cell density", x = .282, y = .43, just = "right", gp = grid::gpar(fontsize = 6.45)),
  grid::rasterGrob(as.raster(matrix(colorRampPalette(density_pal)(128), nrow = 1)), x = .651, y = .42, width = .648, height = .30),
  grid::textGrob(c("Min", "Max"), x = c(.328, .975), y = .86, gp = grid::gpar(fontsize = 5.4))
)
p <- panel_tag(wrap_elements(full = a_body) + inset_element(density_key, .826, .001, .996, .054, align_to = "full"), "A")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
