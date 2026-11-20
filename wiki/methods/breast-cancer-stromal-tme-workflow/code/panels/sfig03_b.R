# Panel ID: sfig03/B (Supp. Fig. 3 S3B)
# Title: 4-quadrant low-res H&E paired with C10_lpFib_ABCA8 / CD8_Cytotoxic_T spatial deconvolution weights.
# Evidence tier: proxy
# Input tables: runs/step03_spatial/st_spots_sfig3.csv, data_small/CAA_ST-umap.qs
# Default dimensions: width = 10.6 in, height = 4.6 in
# Usage: Rscript --vanilla code/panels/sfig03_b.R --paper-root <PAPER_ROOT> --out sfig03_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig03_b.png', default_width = 10.6, default_height = 4.6)
st <- read_step("step03_spatial", "st_spots_sfig3")
weights <- c("C10_lpFib_ABCA8" = "weight_C10_lpFib_ABCA8", "CD8_Cytotoxic_T" = "weight_CD8_Cytotoxic_T")
density_ink <- c("#46468A", "#5CB874", "#F7DC6F", "#C0392B")
st$x_half <- 1L + (st$imagecol > median(st$imagecol))
st$quadrant <- 1L + 2L * (st$x_half - 1L) + (st$imagerow > median(st$imagerow))
object <- qs::qread(file.path(paper_dir, "data_small/CAA_ST-umap.qs"), nthreads = 1)
image <- object[[SeuratObject::Images(object)[1]]]
he <- methods::slot(image, "image")
rm(object, image); invisible(gc())
for (field in weights) st[[paste0(field, "_display")]] <- panel_quantile01(st[[field]], p = c(0, .995))^1.65
crop_bounds <- function(d) {
  list(x = seq(max(1, floor(min(d$imagecol) - 7)), min(dim(he)[2], ceiling(max(d$imagecol) + 7))),
       y = seq(max(1, floor(min(d$imagerow) - 7)), min(dim(he)[1], ceiling(max(d$imagerow) + 7))))
}
tissue_crop <- function(bounds) grid::rasterGrob(as.raster(he[bounds$y, bounds$x, , drop = FALSE]), interpolate = TRUE)
density_tile <- function(d, field, bounds) {
  d$score <- d[[paste0(field, "_display")]]
  d <- d[order(d$score), ]
  xy <- cbind(d$imagecol, -d$imagerow)
  grid <- expand.grid(x = seq(min(bounds$x), max(bounds$x), length.out = 95),
                      y = seq(-max(bounds$y), -min(bounds$y), length.out = 95))
  near <- RANN::nn2(xy, as.matrix(grid), k = 1)
  spacing <- median(RANN::nn2(xy, k = 2)$nn.dists[, 2])
  grid$score <- d$score[near$nn.idx[, 1]]
  grid$score[near$nn.dists[, 1] > .85 * spacing] <- NA_real_
  ggplot(d, aes(imagecol, -imagerow, colour = score)) +
    geom_raster(data = grid, aes(x, y, fill = score), inherit.aes = FALSE, interpolate = TRUE) +
    geom_point(size = .99, stroke = 0) +
    scale_fill_gradientn(colours = density_ink, limits = c(0, 1), na.value = "white", guide = "none") +
    scale_colour_gradientn(colours = density_ink, limits = c(0, 1), guide = "none") +
    coord_fixed(xlim = range(bounds$x), ylim = range(-bounds$y), expand = FALSE) +
    theme_void() + theme(plot.margin = margin(0, 0, 0, 0))
}
score_header <- function(label) {
  colours <- grDevices::colorRampPalette(density_ink)(96)
  grid::grobTree(grid::textGrob(label, x = .01, y = .55, just = "left", gp = grid::gpar(fontsize = 5.3)),
                 grid::rasterGrob(as.raster(matrix(colours, nrow = 1)), x = .79, y = .58, width = .34, height = .31),
                 grid::textGrob(c("Min", "Max"), x = c(.62, .96), y = .19, gp = grid::gpar(fontsize = 4.45)))
}
B_plot <- ggplot() + theme_void() + theme(plot.margin = margin(0, 0, 0, 0))
order <- c(1L, 3L, 2L, 4L)
for (i in seq_along(order)) {
  q <- order[i]; d <- st[st$quadrant == q, ]; bounds <- crop_bounds(d)
  origin_x <- if (i %% 2L == 0) .506 else .013
  origin_y <- if (i > 2L) .01 else .512
  he_header <- grid::textGrob(paste("H&E  |  Section quadrant", q), gp = grid::gpar(fontsize = 5.8, col = "#454045"))
  tops <- list(he_header, score_header(names(weights)[1]), score_header(names(weights)[2]))
  maps <- list(tissue_crop(bounds), density_tile(d, weights[1], bounds), density_tile(d, weights[2], bounds))
  for (j in seq_along(maps)) {
    a <- origin_x + (j - 1L) * .159; b <- a + .151
    B_plot <- B_plot + inset_element(tops[[j]], a, origin_y + .398, b, origin_y + .471, align_to = "full") +
      inset_element(maps[[j]], a, origin_y + .006, b, origin_y + .390, align_to = "full")
  }
}
p <- panel_tag(B_plot, "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
