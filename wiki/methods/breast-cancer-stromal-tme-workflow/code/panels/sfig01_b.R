# Panel ID: sfig01/B (Supp. Fig. 1 S1B)
# Title: 9 canonical stromal lineage marker DotPlot across Fib, EC, and Mural cell.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/dotplot_major.csv
# Default dimensions: width = 6.4 in, height = 4.6 in
# Usage: Rscript --vanilla code/panels/sfig01_b.R --paper-root <PAPER_ROOT> --out sfig01_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig01_b.png', default_width = 6.4, default_height = 4.6)
genes <- c("COL1A1", "COL1A2", "DCN", "PECAM1", "VWF", "CD34", "ACTA2", "PDGFRB", "MCAM")
markers <- read_step("step01_harmony_de", "dotplot_major")
p <- panel_tag(supp_dotplot(markers, c("Fib", "EC", "Mural cell"), genes, c(-.5, 1), c(.9, 7.6), 29, 12), "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
