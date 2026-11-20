# Panel ID: sfig02/E (Supp. Fig. 2 S2E)
# Title: Fibroblast 16 metabolic pathways enrichment lollipop dotplot (MOESM6 KEGG + scRNA proxy).
# Evidence tier: proxy
# Input tables: runs/step05_crosstalk/metab_sfig2e_fib.csv
# Default dimensions: width = 5.4 in, height = 5.2 in
# Usage: Rscript --vanilla code/panels/sfig02_e.R --paper-root <PAPER_ROOT> --out sfig02_e.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig02_e.png', default_width = 5.4, default_height = 5.2)
p <- wave_metabolism("metab_sfig2e_fib", fib_cols, "Top_Metabolic_pathway", 16, tag = "E", key_cols = 3, clean_names = TRUE)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
