# Panel ID: fig04/I (Fig. 4 4I)
# Title: MOESM8 EC-stromal 12x36 CellPhoneDB interaction count heatmap with marginal bars.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/fig4i_ec_stromal_counts.csv
# Default dimensions: width = 6.4 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig04_i.R --paper-root <PAPER_ROOT> --out fig04_i.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_i.png', default_width = 6.4, default_height = 4.2)
pal <- ec_cols
interactions <- read_step("step05_crosstalk", "fig4i_ec_stromal_counts")
interactions <- interactions[interactions$source_compartment == "EC", ]
palettes <- list(Fib = fib_cols, EC = ec_cols, Mural = mural_cols)
interactions$x <- NA_character_
for (group in names(palettes)) {
  rows <- interactions$target_compartment == group
  interactions$x[rows] <- wave_cluster(interactions$TARGET[rows], palettes[[group]])
}
interactions$y <- wave_cluster(interactions$SOURCE, pal)
ec_order <- names(pal)[c(8, 3, 7, 10, 2, 11, 6, 12, 4, 5, 1, 9)]
targets <- c(names(fib_cols), names(mural_cols), names(ec_cols))
p <- panel_tag(wave_counts(interactions, targets, ec_order, small = TRUE), "I")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
