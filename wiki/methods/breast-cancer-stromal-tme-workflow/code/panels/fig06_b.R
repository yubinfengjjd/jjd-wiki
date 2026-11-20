# Panel ID: fig06/B (Fig. 6 6B)
# Title: MOESM8 16x36 immune/epithelial vs stromal CellPhoneDB count heatmap with compartment groups.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/fig6b_tme_stromal_counts.csv
# Default dimensions: width = 7.6 in, height = 4.8 in
# Usage: Rscript --vanilla code/panels/fig06_b.R --paper-root <PAPER_ROOT> --out fig06_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig06_b.png', default_width = 7.6, default_height = 4.8)
cell_order <- c("M2","M1","DC_CD1C","DC_LAMP3","Regulatory_T","DC_CLEC9A",
  "Neutrophil","pDC","CD4_Exhausted_T","NK","Epi","CD8_Cytotoxic_T",
  "CD4_Effector_T","CD4_Tfh","GC_B","Memory_B")
palettes <- list(Fib = fib_cols, EC = ec_cols, Mural = mural_cols)
stromal <- do.call(c, unname(palettes))
counts <- read_step("step05_crosstalk", "fig6b_tme_stromal_counts")
counts <- counts[counts$SOURCE %in% cell_order & counts$target_compartment %in% names(palettes), ]
counts$x <- NA_character_
for (group in names(palettes)) {
  pick <- counts$target_compartment == group
  counts$x[pick] <- wave_cluster(counts$TARGET[pick], palettes[[group]])
}
counts$y <- counts$SOURCE
p <- panel_tag(wave_counts(counts, names(stromal), cell_order,
  groups = setNames(lapply(palettes, names), c("Fib", "EC", "Mural cell"))), "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
