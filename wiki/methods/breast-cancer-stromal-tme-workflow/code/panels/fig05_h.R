# Panel ID: fig05/H (Fig. 5 5H)
# Title: Mural Diffusion Map overlaid with Angiogenic vs Quiescent signature scores.
# Evidence tier: local_recompute
# Input tables: runs/step04_trajectory/traj_mural.csv, extracted/pages/main_p09.png
# Default dimensions: width = 4.4 in, height = 3.6 in
# Usage: Rscript --vanilla code/panels/fig05_h.R --paper-root <PAPER_ROOT> --out fig05_h.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_h.png', default_width = 4.4, default_height = 3.6)
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
fields <- c("score_Angiogenic", "score_Quiescent")
labels <- c("Angiogenic", "Quiescent")
ramps <- list(c("#FCDED6", "#E34A33"), c("#D8EAD9", "#41AB5D"))
v <- vapply(fields, function(field) scale01(traj[[field]][match(dm$cell, traj$cell_id)]), numeric(nrow(dm)))
dominant <- max.col(v, ties.method = "first")
dm$ink <- NA_character_
for (i in 1:2) dm$ink[dominant == i] <- wave_colour(v[dominant == i, i], ramps[[i]], c(0, 1))
h <- ggplot(dm, aes(x, y, colour = ink)) + manifold_points(size = .76) + scale_colour_identity() + coord_equal() + theme_umap_blank()
keys <- wrap_plots(lapply(1:2, function(i) wrap_elements(full = wave_key(ramps[[i]], labels[i], "0", "1", TRUE))), ncol = 1)
p <- panel_tag(wrap_plots(h, keys, nrow = 1, widths = c(.73, .27)), "H")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
