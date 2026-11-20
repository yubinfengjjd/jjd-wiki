# Panel ID: sfig04/D (Supp. Fig. 4 S4D)
# Title: EC 12 subclusters faceted Top-5 KEGG horizontal bars.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/sfig4d_kegg_ec.csv
# Default dimensions: width = 8.6 in, height = 6.4 in
# Usage: Rscript --vanilla code/panels/sfig04_d.R --paper-root <PAPER_ROOT> --out sfig04_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig04_d.png', default_width = 8.6, default_height = 6.4)
plots <- supp_kegg_bars("sfig4d_kegg_ec", ec_cols, 5, font = 6.0)
kegg <- wrap_plots(lapply(plots, function(g) wrap_elements(full = g)), ncol = 3)
p <- panel_tag(wrap_plots(wrap_elements(), wrap_elements(full = kegg), ncol = 1, heights = c(.047, .953)), "D")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
