# Panel ID: fig04/K (Fig. 4 4K)
# Title: EC Top 20 KEGG metabolic pathway enrichment lollipop dotplot (MOESM6 KEGG + scRNA proxy).
# Evidence tier: proxy
# Input tables: runs/step05_crosstalk/metab_fig4k_ec.csv
# Default dimensions: width = 5.4 in, height = 5.2 in
# Usage: Rscript --vanilla code/panels/fig04_k.R --paper-root <PAPER_ROOT> --out fig04_k.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_k.png', default_width = 5.4, default_height = 5.2)
p <- wave_metabolism("metab_fig4k_ec", ec_cols, "Top3_Metabolic_pathway", 20, short_labels = c(
  "Glycosaminoglycan biosynthesis - chondroitin sulfate / dermatan sulfate" = "GAG biosynthesis\n(chondroitin / dermatan sulfate)",
  "Biosynthesis of various nucleotide sugars" = "Nucleotide sugar biosynthesis"
))

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
