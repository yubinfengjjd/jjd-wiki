# Panel ID: fig02/F (Fig. 2 2F)
# Title: Fibroblast Diffusion Map (DC_1 vs DC_2) colored by 14 subclusters with numbered centroids and trajectory guide.
# Evidence tier: local_recompute
# Input tables: runs/step04_trajectory/traj_fib.csv, extracted/pages/main_p04.png
# Default dimensions: width = 4.2 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig02_f.R --paper-root <PAPER_ROOT> --out fig02_f.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_f.png', default_width = 4.2, default_height = 3.8)
dm <- make_manifolds("dm")$dm_fib
sequence_dm <- c(1, 2, 10, 6, 3, 12, 8, 11, 9, 13, 4, 14, 7, 5)
centers <- function(d, order) {
  cells <- aggregate(cbind(x, y) ~ cluster, d, median)
  cells[match(names(fib_cols)[order], cells$cluster), ]
}
dm_line <- centers(dm, sequence_dm)
dm_centroids <- centers(dm, seq_along(fib_cols))
dm_label_pos <- transform(dm_centroids,
  x = x + c(-8, -10, -11, 26, 17, 0, 4, 1, 10, -14, 7, 9, -6, 6),
  y = y + c(-7, 7, 5, 1, -3, 2, -7, 13, 1, -6, 5, -5, -7, 8)
)
F_plot <- embedding(dm, fib_cols, "Diffusion Map", dots = .65) +
  geom_path(data = dm_line, aes(x, y), inherit.aes = FALSE, colour = "#555555", linewidth = .3, linetype = "dashed") +
  geom_segment(data = transform(dm_centroids, tx = dm_label_pos$x, ty = dm_label_pos$y),
               aes(x = x, y = y, xend = tx, yend = ty), inherit.aes = FALSE, linewidth = .18, colour = "#5E5757") +
  centroid_labels(dm, fib_cols, 2.35, offset = .95, centers = dm_label_pos) +
  add_l_arrows("DC_1", "DC_2", dm, x = -.065, y = -.064) +
  theme(legend.position = "none", plot.title = element_text(face = "plain", size = 8.8))
p <- panel_tag(F_plot, "F")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
