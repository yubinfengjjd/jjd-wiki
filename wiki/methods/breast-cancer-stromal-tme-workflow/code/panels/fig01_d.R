# Panel ID: fig01/D (Fig. 1 1D)
# Title: 36 stromal subclusters across Fib, EC, and Mural compartments with dashed lineage hulls and 4-column legend.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_fib.csv, runs/step01_harmony_de/umap_ec.csv, runs/step01_harmony_de/umap_mural.csv, extracted/pages/main_p03.png
# Default dimensions: width = 9.6 in, height = 6.2 in
# Usage: Rscript --vanilla code/panels/fig01_d.R --paper-root <PAPER_ROOT> --out fig01_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig01_d.png', default_width = 9.6, default_height = 6.2)
manifolds <- make_manifolds(c("fib", "ec", "mural"))
enclose_groups <- function(d, groups, positions) {
  curves <- lapply(seq_along(groups), function(i) {
    points <- d[match(d$cluster, unique(positions$cluster)) %in% groups[[i]], c("x", "y")]
    stopifnot(nrow(points) > 3)
    mid <- colMeans(points)
    dist <- sqrt(rowSums(sweep(as.matrix(points), 2, mid)^2))
    points <- points[dist <= quantile(dist, .96), ]
    h <- chull(points)
    scaled <- 1.075 * sweep(as.matrix(points[h, ]), 2, mid)
    scaled <- sweep(scaled, 2, mid, "+")
    closed <- rbind(scaled, scaled[1, ])
    bx <- stats::spline(seq_len(nrow(closed)), closed[, 1], n = 120, method = "periodic")$y
    by <- stats::spline(seq_len(nrow(closed)), closed[, 2], n = 120, method = "periodic")$y
    data.frame(x = bx, y = by, group = i)
  })
  geom_polygon(
    data = do.call(rbind, curves), aes(x, y, group = group),
    inherit.aes = FALSE, colour = "#D63A2F", fill = NA, linetype = "dashed", linewidth = .32
  )
}
sub_panel <- function(d, pal, title, groups, x, y) {
  lookup <- data.frame(cluster = names(pal))
  text <- data.frame(x = x, y = -y, label = names(groups))
  ggplot(d, aes(x, y, colour = cluster)) +
    geom_raster(data = attr(d, "reference_density"), aes(x, y, fill = cluster),
                inherit.aes = FALSE, alpha = .76, interpolate = TRUE) +
    scale_fill_manual(values = pal, guide = "none", na.value = "transparent") +
    manifold_points(size = .81) +
    scale_colour_manual(values = pal, guide = "none") +
    coord_equal(clip = "off") +
    labs(title = title) +
    theme_umap_blank() +
    enclose_groups(d, groups, lookup) +
    centroid_labels(d, pal, 3.05, offset = .95) +
    halo_text(text, 2.55, "#D63A2F", offset = 1.05) +
    theme(legend.position = "none", plot.title = element_text(size = 9.5, face = "bold"))
}
D_body <- panel_tag(wrap_plots(
  sub_panel(manifolds$umap_fib, fib_cols, "Fib",
    list(mFib = c(1, 9), tFib = c(11, 14), apFib = 12, iFib = c(4, 5, 6), ifnFib = 2, lpFib = c(3, 7, 10, 13)),
    c(195, 298, 335, 431, 454, 393), c(1076, 956, 1028, 986, 1038, 1140)),
  sub_panel(manifolds$umap_ec, ec_cols, "EC",
    list(infEC = 10:11, VenEC = 5:6, CapEC = 3, TipEC = 4, emtEC = c(8, 9), tEC = 7, ArtEC = 1:2, LEC = 12),
    c(633, 550, 594, 608, 672, 688, 649, 777), c(950, 1040, 1018, 1068, 1024, 1093, 1144, 1055)),
  sub_panel(manifolds$umap_mural, mural_cols, "Mural cell",
    list(tPC = 4:8, SMC = 1:3, nPC = 9:10), c(935, 870, 1027), c(916, 993, 1126)),
  nrow = 1
), "D")
items <- c("Fib", names(fib_cols), "EC", names(ec_cols), "Mural cell", names(mural_cols))
labels <- data.frame(label = items, x = rep(0:3, c(10, 10, 10, 9)), y = rep(10:1, 4)[-40])
pal <- c(fib_cols, ec_cols, mural_cols)
labels$ink <- unname(pal[labels$label])
legend <- ggplot(labels, aes(x, y)) +
  geom_point(data = labels[!is.na(labels$ink), ], aes(colour = ink), size = 3.2) +
  geom_text(aes(x = x + .075, label = label, fontface = ifelse(is.na(ink), "bold", "plain")), hjust = 0, size = 3.1) +
  scale_colour_identity() +
  coord_cartesian(xlim = c(-.12, 3.83), ylim = c(.6, 10.65), expand = FALSE) +
  theme_void() +
  theme(plot.margin = margin(0, 4, 1, 7))
p <- wrap_plots(D_body, legend, ncol = 1, heights = c(.65, .35))

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
