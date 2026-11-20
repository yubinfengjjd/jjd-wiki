# Panel ID: fig06/F (Fig. 6 6F)
# Title: MOESM8 C4_TipEC_PGF to M1/M2 CellChat L-R probability bubble matrix.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/fig6f_pgf_tam_lr.csv
# Default dimensions: width = 5.0 in, height = 3.4 in
# Usage: Rscript --vanilla code/panels/fig06_f.R --paper-root <PAPER_ROOT> --out fig06_f.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig06_f.png', default_width = 5.0, default_height = 3.4)
tam <- read_step("step05_crosstalk", "fig6f_pgf_tam_lr")
tam$x <- tam$interaction_name
tam$y <- paste0("C4_TipEC_PGF -> ", tam$target)
tam_columns <- c("TGFB1_TGFBR1_TGFBR2", "CCL14_CCR1", "CXCL12_CXCR4", "MIF_CD74_CXCR4", "MIF_CD74_CD44")
p <- panel_tag(wave_bubbles(tam, tam_columns, paste0("C4_TipEC_PGF -> ", c("M2", "M1")),
                            font = 5.35, legend = "left", size = c(1.15, 4.05)) +
               theme(plot.margin = margin(16, 4, 4, 6)), "F")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
