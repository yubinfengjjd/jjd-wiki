# Panel ID: fig05/K (Fig. 5 5K)
# Title: Mural KEGG metabolic pathway enrichment lollipop dotplot (MOESM6 KEGG + scRNA proxy).
# Evidence tier: proxy
# Input tables: runs/step05_crosstalk/metab_fig5k_mural.csv
# Default dimensions: width = 5.4 in, height = 5.0 in
# Usage: Rscript --vanilla code/panels/fig05_k.R --paper-root <PAPER_ROOT> --out fig05_k.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_k.png', default_width = 5.4, default_height = 5.0)
p <- wave_metabolism("metab_fig5k_mural", mural_cols, "Top_Metabolic_pathway", 14)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
