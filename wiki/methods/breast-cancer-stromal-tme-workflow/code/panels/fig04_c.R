# Panel ID: fig04/C (Fig. 4 4C)
# Title: EC 12 subclusters tissue/subtype Ro/e combined with MOESM5 TCGA/in-house Cox HR.
# Evidence tier: original_table
# Input tables: runs/step02_progeny_roe_cox/roe_cox_ec.csv
# Default dimensions: width = 6.2 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig04_c.R --paper-root <PAPER_ROOT> --out fig04_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_c.png', default_width = 6.2, default_height = 4.2)
p <- wave_cox("ec", ec_cols)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
