# Panel ID: fig05/G (Fig. 5 5G)
# Title: Mural Slingshot differentiation state projected on Mural UMAP.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_mural.csv, runs/step04_trajectory/traj_mural.csv, extracted/pages/main_p03.png
# Default dimensions: width = 4.2 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig05_g.R --paper-root <PAPER_ROOT> --out fig05_g.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_g.png', default_width = 4.2, default_height = 3.8)
u <- make_manifolds("mural")$umap_mural
traj <- read_step("step04_trajectory", "traj_mural")
u$time <- traj$slingshot_pseudotime[match(u$cell, traj$cell_id)]
p <- panel_tag(feature_panel(u, "time", wave_sling_cols, "Differentiation state (Slingshot)",
                             dots = .70, limits = range(u$time, finite = TRUE), bar = TRUE,
                             horizontal = TRUE, manifold = TRUE, endpoints = TRUE) +
               theme(plot.title = element_text(size = 7.5, face = "plain")), "G")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
