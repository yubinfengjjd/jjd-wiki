# Panel ID: fig05/J (Fig. 5 5J)
# Title: MOESM8 Mural-to-EC L-R probability bubble matrix.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/fig5j_mural_ec_lr.csv
# Default dimensions: width = 3.8 in, height = 5.2 in
# Usage: Rscript --vanilla code/panels/fig05_j.R --paper-root <PAPER_ROOT> --out fig05_j.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_j.png', default_width = 3.8, default_height = 5.2)
pal <- mural_cols
lr <- read_step("step05_crosstalk", "fig5j_mural_ec_lr")
lr$x <- wave_cluster(lr$source, pal)
lr$y <- lr$interaction_name
lr_rows <- c("JAG1_NOTCH4", "JAG1_NOTCH1", "COL4A2_ITGA9_ITGB1", "COL4A1_ITGA9_ITGB1",
  "COL1A2_ITGA9_ITGB1", "COL1A1_ITGA9_ITGB1", "LAMA4_ITGA6_ITGB1", "COL6A1_ITGA1_ITGB1",
  "COL4A2_ITGA1_ITGB1", "COL4A1_ITGA1_ITGB1", "COL1A2_ITGA1_ITGB1", "COL1A1_ITGA1_ITGB1", "PGF_VEGFR1")
p <- panel_tag(wave_bubbles(lr, names(pal)[c(4, 2)], lr_rows, font = 5.35, size = c(.95, 3.35)) +
  guides(size = guide_legend(order = 1, ncol = 1, override.aes = list(fill = "black"))) +
  theme(legend.title = element_text(size = 4.85), legend.box.margin = margin(0, 3, 0, 0)), "J")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
