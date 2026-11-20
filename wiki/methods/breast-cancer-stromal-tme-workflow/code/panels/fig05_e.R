# Panel ID: fig05/E (Fig. 5 5E)
# Title: PROGENy 14-pathway activity Z-score heatmap across 10 mural subclusters.
# Evidence tier: local_recompute
# Input tables: runs/step02_progeny_roe_cox/progeny_mural.csv
# Default dimensions: width = 4.4 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig05_e.R --paper-root <PAPER_ROOT> --out fig05_e.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_e.png', default_width = 4.4, default_height = 3.8)
p <- wave_progeny("mural", mural_cols, c("p53", "Trail", "JAK-STAT", "Hypoxia", "TGFb", "Androgen",
  "NFkB", "TNFa", "EGFR", "MAPK", "PI3K", "Estrogen", "VEGF", "WNT"))

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
