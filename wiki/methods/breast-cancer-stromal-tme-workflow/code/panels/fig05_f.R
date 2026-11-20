# Panel ID: fig05/F (Fig. 5 5F)
# Title: Mural triangular Diffusion Map colored by 10 subclusters and DPT pseudotime.
# Evidence tier: local_recompute
# Input tables: runs/step04_trajectory/traj_mural.csv, extracted/pages/main_p09.png
# Default dimensions: width = 6.4 in, height = 3.6 in
# Usage: Rscript --vanilla code/panels/fig05_f.R --paper-root <PAPER_ROOT> --out fig05_f.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_f.png', default_width = 6.4, default_height = 3.6)
pal <- mural_cols
traj <- read_step("step04_trajectory", "traj_mural")
page <- png::readPNG(file.path(paper_dir, "extracted/pages/main_p09.png"))
anchors <- rbind(c(208,629),c(215,726),c(295,673),c(229,767),c(238,739),c(223,680),
                 c(269,673),c(318,705),c(374,677),c(349,677))
ink <- c("#AD4E54","#C0AE69","#C0A188","#D8C4DE","#C98BA9","#CDB373",
         "#BB8076","#DCAA67","#60A274","#C7D4A6")
set.seed(42)
dm <- sample_reference(page, c(190, 601, 387, 793), anchors, names(pal), 5500, ink,
                       spatial_weight = 1.2, min_saturation = .043, keep_density = TRUE)
traj$cluster <- wave_cluster(traj$subcluster, pal)
dm <- bind_display_cells(dm, traj, "cluster", "cell_id")
anchor_centers <- data.frame(x = anchors[, 1] + c(-2,-1,6,-4,0,-3,0,0,4,0),
                             y = -anchors[, 2] + c(2,2,4,-2,0,2,4,-2,4,7), cluster = names(pal))
branches <- data.frame(x = c(376, 376), y = c(-678, -682), xe = c(205, 225), ye = c(-611, -784))
left <- embedding(dm, pal, dots = .69) +
  add_l_arrows("DC1", "DC2", dm, x = -.02, y = -.075) +
  theme(legend.position = "none") +
  geom_curve(data = branches, aes(x, y, xend = xe, yend = ye), inherit.aes = FALSE,
             curvature = -.20, colour = "#BD3F47", linetype = "solid", linewidth = .40,
             arrow = grid::arrow(length = grid::unit(1.1, "mm"))) +
  centroid_labels(dm, pal, 2.18, .95, centers = anchor_centers)
dm$time <- traj$dpt_pseudotime[match(dm$cell, traj$cell_id)]
right <- feature_panel(dm, "time", wave_dpt_cols, dots = .76, limits = range(dm$time, finite = TRUE),
                       bar = TRUE, horizontal = TRUE, manifold = TRUE, endpoints = TRUE)
p <- panel_tag(wrap_plots(left, right, nrow = 1) +
  plot_annotation(title = "Differentiation state (Diffusion Map)",
                  theme = theme(plot.title = element_text(size = 8, hjust = .5, margin = margin(b = 0)))), "F")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
