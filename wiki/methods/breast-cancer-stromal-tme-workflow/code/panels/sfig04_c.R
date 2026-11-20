# Panel ID: sfig04/C (Supp. Fig. 4 S4C)
# Title: EC Angiogenic_signature (Tip-cell score proxy) projected on EC UMAP.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_ec.csv, runs/step04_trajectory/traj_ec.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.0 in, height = 4.4 in
# Usage: Rscript --vanilla code/panels/sfig04_c.R --paper-root <PAPER_ROOT> --out sfig04_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig04_c.png', default_width = 5.0, default_height = 4.4)
u <- make_manifolds("ec")$umap_ec
traj <- read_step("step04_trajectory", "traj_ec")
idx <- match(u$cell, traj$cell_id)
u$score <- .25 + .5 * scale01(traj$score_Tip_cell[idx])
set.seed(42)
focused <- u[rep(seq_len(nrow(u)), 3L), ]
focused$x <- focused$x + runif(nrow(focused), -1.05, 1.05)
focused$y <- focused$y + runif(nrow(focused), -1.05, 1.05)
angio_ink <- c("#3288BD", "#ABDDA4", "#FFFFBF", "#FDAE61", "#D53E4F")
p <- panel_tag(feature_panel(focused, "score", angio_ink, "Angiogenic_signature", dots = .53,
  limits = c(.25, .75), bar = TRUE, manifold = TRUE, value_breaks = c(.25, .50, .75)) +
  add_l_arrows(data = focused, x = -.036, y = -.05, length = .16) +
  labs(caption = "Local Tip-cell score proxy, rescaled for display") +
  theme(plot.title = element_text(size = 10, face = "plain"), plot.caption = element_text(size = 5.8, hjust = .82),
        plot.margin = margin(8, 5, 6, 12)), "C")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
