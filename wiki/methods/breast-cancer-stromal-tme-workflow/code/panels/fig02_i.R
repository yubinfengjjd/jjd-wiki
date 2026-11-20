# Panel ID: fig02/I (Fig. 2 2I)
# Title: Fibroblast Diffusion Map overlaid with dominant 4 CAF module scores (mCAF, ifnCAF, iCAF, lpCAF).
# Evidence tier: local_recompute
# Input tables: runs/step04_trajectory/traj_fib.csv, extracted/pages/main_p04.png
# Default dimensions: width = 4.4 in, height = 4.0 in
# Usage: Rscript --vanilla code/panels/fig02_i.R --paper-root <PAPER_ROOT> --out fig02_i.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_i.png', default_width = 4.4, default_height = 4.0)
traj <- read_step("step04_trajectory", "traj_fib")
dm <- make_manifolds("dm")$dm_fib
module_fields <- c(mCAF = "score_mCAF", ifnCAF = "score_ifnCAF", iCAF = "score_iCAF", lpCAF = "score_LipCAF")
module_ramps <- list(c("#F2EFF4", "#BF3347"), c("#F3F6F1", "#328D40"), c("#EDF2FB", "#397BB9"), c("#F3EEF7", "#825097"))
score <- vapply(module_fields, function(field) scale01(traj[[field]][match(dm$cell, traj$cell_id)]), numeric(nrow(dm)))
dominant <- max.col(score, ties.method = "first")
dm$ink <- vapply(seq_len(nrow(dm)), function(i) {
  panel_tile_colours(score[i, dominant[i]], module_ramps[[dominant[i]]], c(0, 1))
}, character(1))
I_plot <- ggplot(dm, aes(x, y, colour = ink)) +
  manifold_points(size = .57) +
  scale_colour_identity() +
  coord_equal(clip = "off") +
  theme_umap_blank() +
  add_l_arrows("DC_1", "DC_2", dm, x = -.065, y = -.064) +
  labs(title = "CAF module scores")
for (i in seq_along(module_ramps)) {
  x <- .30 + .167 * (i - 1)
  I_plot <- I_plot + inset_element(panel_legend_bar(module_ramps[[i]], names(module_fields)[i], c("0", "1"), TRUE),
                                   x, .015, x + .163, .238, align_to = "full")
}
p <- panel_tag(I_plot, "I")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
