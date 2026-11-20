# Panel ID: fig06/C (Fig. 6 6C)
# Title: MOESM8 C8_iFib_CCL19 to 20 TME cell types TLS L-R probability bubble matrix.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/fig6c_ccl19_lr.csv
# Default dimensions: width = 4.8 in, height = 6.4 in
# Usage: Rscript --vanilla code/panels/fig06_c.R --paper-root <PAPER_ROOT> --out fig06_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig06_c.png', default_width = 4.8, default_height = 6.4)
tls <- read_step("step05_crosstalk", "fig6c_ccl19_lr")
tls$x <- tls$interaction_name
tls$y <- paste0("C8_iFib_CCL19 -> ", gsub(" ", "_", tls$target, fixed = TRUE))
tls_columns <- c("CCL19_CCR7", "CXCL9_CXCR3", "CXCL10_CXCR3", "CXCL11_CXCR3",
  "CXCL12_CXCR4", "MIF_CD74_CXCR4", "MIF_CD74_CD44", "CSF1_CSF1R")
tls_rows <- paste0("C8_iFib_CCL19 -> ", c("Transitory_T", "Regulatory_T", "pDC", "NK", "Neutrophil",
  "Naive_B", "Memory_B", "Mast", "M2", "M1", "GC_B", "Epi", "DC_LAMP3", "DC_CLEC9A", "DC_CD1C",
  "CD8_Cytotoxic_T", "CD4_Tfh", "CD4_Naive_T", "CD4_Exhausted_T", "CD4_Effector_T"))
p <- panel_tag(wave_bubbles(tls, tls_columns, tls_rows, font = 5.6, size = c(.70, 3.55)), "C")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
