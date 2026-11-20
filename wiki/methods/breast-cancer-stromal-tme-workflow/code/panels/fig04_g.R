# Panel ID: fig04/G (Fig. 4 4G)
# Title: EC Slingshot differentiation state projected on EC UMAP.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_ec.csv, runs/step04_trajectory/traj_ec.csv, extracted/pages/main_p03.png
# Default dimensions: width = 4.2 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig04_g.R --paper-root <PAPER_ROOT> --out fig04_g.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_g.png', default_width = 4.2, default_height = 3.8)
u <- make_manifolds("ec")$umap_ec
traj <- read_step("step04_trajectory", "traj_ec")
u$time <- traj$slingshot_pseudotime[match(u$cell, traj$cell_id)]
p <- panel_tag(feature_panel(u, "time", wave_sling_cols, "Differentiation state (Slingshot)",
                             dots = .70, limits = range(u$time, finite = TRUE), bar = TRUE,
                             horizontal = TRUE, manifold = TRUE, endpoints = TRUE) +
               theme(plot.title = element_text(size = 7.5, face = "plain")), "G")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
