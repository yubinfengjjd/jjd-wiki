# Panel ID: fig01/B (Fig. 1 1B)
# Title: Major stromal lineage UMAP (Fib, EC, Mural cell) with numbered centroids on downsampled scRNA object.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_all.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.4 in, height = 4.8 in
# Usage: Rscript --vanilla code/panels/fig01_b.R --paper-root <PAPER_ROOT> --out fig01_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig01_b.png', default_width = 5.4, default_height = 4.8)
atlas <- make_manifolds("all")$umap_all
p <- embedding(atlas, major_cols, dots = .91, labels = paste0(1:3, ": ", names(major_cols))) +
  centroid_labels(atlas, major_cols, 2.85, offset = .8) +
  add_l_arrows(data = atlas, x = -.01, y = -.035, length = .155) +
  guides(colour = guide_legend(override.aes = list(size = 2.4, alpha = 1))) +
  theme(
    legend.position = "inside",
    legend.position.inside = c(.82, .135),
    legend.key.size = grid::unit(2.9, "mm"),
    legend.background = element_rect(fill = "white", colour = NA)
  )
p <- panel_tag(p, "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
