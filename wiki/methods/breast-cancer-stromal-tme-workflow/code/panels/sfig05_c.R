# Panel ID: sfig05/C (Supp. Fig. 5 S5C)
# Title: Mural 10 subclusters faceted Top-7 KEGG horizontal bars.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/sfig5c_kegg_mural.csv
# Default dimensions: width = 9.2 in, height = 6.8 in
# Usage: Rscript --vanilla code/panels/sfig05_c.R --paper-root <PAPER_ROOT> --out sfig05_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig05_c.png', default_width = 9.2, default_height = 6.8)
pal <- mural_cols
legacy_labels <- setNames(c("C1_SMC_MYL9","C2_SMC_FN1","C3_SMC_MYH11","C1_tPC_COL3A1",
  "C2_tPC_CCL19","C3_tPC_CD74","C4_tPC_SEPT7","C5_tPC_PRKG1","C6_nPC_CXCL8","C7_nPC_GJA5"), names(pal))
charts <- supp_kegg_bars("sfig5c_kegg_mural", pal, 7, unname(legacy_labels), font = 5.6)
kegg_grid <- wrap_plots(lapply(charts, function(g) wrap_elements(full = g)), ncol = 3)
p <- panel_tag(wrap_plots(wrap_elements(), wrap_elements(full = kegg_grid), ncol = 1, heights = c(.045, .955)), "C")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
