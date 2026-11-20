# Panel ID: fig04/H (Fig. 4 4H)
# Title: EC Diffusion Map overlaid with Stalk-like vs Tip-like signature scores.
# Evidence tier: local_recompute
# Input tables: runs/step04_trajectory/traj_ec.csv, extracted/pages/main_p07.png
# Default dimensions: width = 4.4 in, height = 3.6 in
# Usage: Rscript --vanilla code/panels/fig04_h.R --paper-root <PAPER_ROOT> --out fig04_h.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_h.png', default_width = 4.4, default_height = 3.6)
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
fields <- c("score_Stalk_cell", "score_Tip_cell")
labels <- c("Stalk-like score", "Tip-like score")
ramps <- list(c("#F5E5E1", "#D73027"), c("#E6E8EF", "#4575B4"))
v <- vapply(fields, function(field) scale01(traj[[field]][match(dm$cell, traj$cell_id)]), numeric(nrow(dm)))
dominant <- max.col(v, ties.method = "first")
dm$ink <- NA_character_
for (i in 1:2) dm$ink[dominant == i] <- wave_colour(v[dominant == i, i], ramps[[i]], c(0, 1))
h <- ggplot(dm, aes(x, y, colour = ink)) + manifold_points(size = .76) + scale_colour_identity() + coord_equal() + theme_umap_blank()
keys <- wrap_plots(lapply(1:2, function(i) wrap_elements(full = wave_key(ramps[[i]], labels[i], "0", "1", TRUE))), ncol = 1)
p <- panel_tag(wrap_plots(h, keys, nrow = 1, widths = c(.73, .27)), "H")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
