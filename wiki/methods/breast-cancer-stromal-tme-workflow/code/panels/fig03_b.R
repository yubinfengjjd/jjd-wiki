# Panel ID: fig03/B (Fig. 3 3B)
# Title: CAA_ST 4-region Tumor/ABCA8+ lpFib/CD8 T/exhausted T spatial signature proxy.
# Evidence tier: proxy
# Input tables: runs/step03_spatial/st_spots_fig3be.csv
# Default dimensions: width = 5.8 in, height = 6.0 in
# Usage: Rscript --vanilla code/panels/fig03_b.R --paper-root <PAPER_ROOT> --out fig03_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig03_b.png', default_width = 5.8, default_height = 6.0)
st <- read_step("step03_spatial", "st_spots_fig3be")
spot_fields <- c(Tumor_cell = "weight_Tumor_cell", C10_lpFib_ABCA8 = "weight_C10_lpFib_ABCA8",
                 CD8_Cytotoxic_T = "weight_CD8_Cytotoxic_T", Exhausted_T = "weight_Exhausted_T")
st$region <- interaction(st$imagecol > median(st$imagecol), st$imagerow > median(st$imagerow))
region_mean <- tapply(st$weight_C10_lpFib_ABCA8, st$region, mean)
regions <- names(sort(region_mean, decreasing = TRUE))
tile_names <- c("Tumor cell", "C10_lpFib_ABCA8", "CD8_Cytotoxic_T", "Exhausted_T")
limits <- lapply(spot_fields, function(field) c(min(st[[field]], na.rm = TRUE), quantile(st[[field]], .96, na.rm = TRUE, names = FALSE)))
density <- do.call(rbind, lapply(seq_along(regions), function(row) {
  area <- st[st$region == regions[row], ]
  sampled <- panel_spot_grid(area)
  do.call(rbind, lapply(seq_along(spot_fields), function(col) {
    raw <- area[[spot_fields[col]]]
    values <- matrix(raw[sampled$index], nrow = nrow(sampled$index))
    smoothed <- rowSums(sampled$weight * values) / rowSums(sampled$weight)
    smoothed[!sampled$inside] <- NA_real_
    transform(sampled$grid, x = round(scale01(x), 8), y = round(scale01(y), 8),
              density = scales::rescale(smoothed, from = limits[[col]]),
              region = factor(row, levels = seq_along(regions)),
              feature = factor(tile_names[col], levels = tile_names))
  }))
}))
B_tiles <- ggplot(density, aes(x, y, fill = density)) +
  geom_raster(interpolate = TRUE) +
  facet_grid(region ~ feature) +
  scale_fill_gradientn(colours = density_cols, limits = c(0, 1), oob = scales::squish, na.value = "white") +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
  theme_void() +
  theme(aspect.ratio = 1, strip.text.x = element_text(size = 5.8, margin = margin(b = 2)),
        strip.text.y = element_blank(), strip.background = element_blank(), legend.position = "none",
        panel.border = element_rect(fill = NA, colour = "black", linewidth = .6),
        panel.spacing.x = grid::unit(3.3, "pt"), panel.spacing.y = grid::unit(3.5, "pt"),
        plot.margin = margin(0, 4, 0, 2))
region_labels <- wrap_elements(full = grid::textGrob(c("Higher ABCA8+ lpCAF score", "Lower ABCA8+ lpCAF score"),
  x = .85, y = c(.735, .25), rot = 90, gp = grid::gpar(fontsize = 6.2)))
grob_palette <- as.raster(matrix(grDevices::colorRampPalette(density_cols)(128), nrow = 1))
bar_grob <- grid::grobTree(
  grid::textGrob("Cell density proxy", x = .75, y = .63, just = "right", gp = grid::gpar(fontsize = 6.1)),
  grid::rasterGrob(grob_palette, x = .868, y = .65, width = .205, height = .25, interpolate = FALSE),
  grid::textGrob(c("Min", "Max"), x = c(.766, .971), y = .24, gp = grid::gpar(fontsize = 5))
)
p <- panel_tag(wrap_plots(
  wrap_elements(full = grid::textGrob("Four regions of one Visium section (CAA_ST)", gp = grid::gpar(fontsize = 6))),
  wrap_plots(region_labels, B_tiles, nrow = 1, widths = c(.045, .955)),
  wrap_elements(full = bar_grob),
  ncol = 1, heights = c(.042, .923, .035)
), "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
