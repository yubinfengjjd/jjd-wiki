# Panel ID: fig04/F (Fig. 4 4F)
# Title: EC V-shaped Diffusion Map colored by 12 subclusters (with branch arrows) and DPT pseudotime.
# Evidence tier: local_recompute
# Input tables: runs/step04_trajectory/traj_ec.csv, extracted/pages/main_p07.png
# Default dimensions: width = 6.4 in, height = 3.6 in
# Usage: Rscript --vanilla code/panels/fig04_f.R --paper-root <PAPER_ROOT> --out fig04_f.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_f.png', default_width = 6.4, default_height = 3.6)
pal <- ec_cols
traj <- read_step("step04_trajectory", "traj_ec")
page <- png::readPNG(file.path(paper_dir, "extracted/pages/main_p07.png"))
anchors <- rbind(c(203,710),c(322,733),c(228,812),c(263,761),c(204,788),c(241,748),
  c(315,777),c(253,789),c(283,794),c(224,766),c(235,800),c(326,695))
ink <- c("#466A85","#356E99","#C68DAD","#DDB7B7","#4C727E","#9F8997",
         "#849690","#787E80","#BCA9A6","#BAB3B2","#CAAAA1","#616D86")
set.seed(42)
dm <- sample_reference(page, c(187, 666, 345, 824), anchors, names(pal), 6000, ink,
                       spatial_weight = 1.2, min_saturation = .043, keep_density = TRUE)
traj$cluster <- wave_cluster(traj$subcluster, pal)
dm <- bind_display_cells(dm, traj, "cluster", "cell_id")
anchor_centers <- data.frame(x = anchors[, 1] + c(-3,6,-5,0,-4,-4,5,-6,3,-7,4,5),
                             y = -anchors[, 2] + c(1,4,-2,1,-3,1,1,0,1,2,-2,5), cluster = names(pal))
branches <- data.frame(x = c(207, 230), y = c(-710, -759), xe = c(226, 324), ye = c(-764, -729))
left <- embedding(dm, pal, dots = .69) +
  add_l_arrows("DC1", "DC2", dm, x = -.02, y = -.075) +
  theme(legend.position = "none") +
  geom_curve(data = branches, aes(x, y, xend = xe, yend = ye), inherit.aes = FALSE,
             curvature = .28, colour = "#BD3F47", linetype = "dashed", linewidth = .40,
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
