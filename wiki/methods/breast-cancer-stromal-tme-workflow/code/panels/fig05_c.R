# Panel ID: fig05/C (Fig. 5 5C)
# Title: Mural 10 subclusters tissue/subtype Ro/e combined with MOESM5 TCGA/in-house Cox HR.
# Evidence tier: original_table
# Input tables: runs/step02_progeny_roe_cox/roe_cox_mural.csv
# Default dimensions: width = 6.0 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig05_c.R --paper-root <PAPER_ROOT> --out fig05_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_c.png', default_width = 6.0, default_height = 4.2)
p <- wave_cox("mural", mural_cols[c(4:10, 1:3)])

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
