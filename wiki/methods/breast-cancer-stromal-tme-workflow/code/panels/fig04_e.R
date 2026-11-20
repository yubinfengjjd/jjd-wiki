# Panel ID: fig04/E (Fig. 4 4E)
# Title: PROGENy 14-pathway activity Z-score heatmap across 12 EC subclusters.
# Evidence tier: local_recompute
# Input tables: runs/step02_progeny_roe_cox/progeny_ec.csv
# Default dimensions: width = 4.4 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig04_e.R --paper-root <PAPER_ROOT> --out fig04_e.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_e.png', default_width = 4.4, default_height = 3.8)
p <- wave_progeny("ec", ec_cols, c("PI3K", "Estrogen", "VEGF", "Androgen", "NFkB", "TNFa",
  "EGFR", "MAPK", "Trail", "p53", "WNT", "TGFb", "Hypoxia", "JAK-STAT"))

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
