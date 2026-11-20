# Panel ID: sfig02/B (Supp. Fig. 2 S2B)
# Title: Fibroblast 36-marker expression DotPlot across 14 subclusters.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/dotplot_fib.csv
# Default dimensions: width = 7.6 in, height = 4.4 in
# Usage: Rscript --vanilla code/panels/sfig02_b.R --paper-root <PAPER_ROOT> --out sfig02_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig02_b.png', default_width = 7.6, default_height = 4.4)
marker_order <- c("ACTA2","TAGLN","MYL9","BAG3","HSPA6","CLEC3B","PLA2G2A","PI16","RORA",
  "BNC2","KCND2","PRKG1","CXCL8","CXCL3","CXCL1","NFKB1","ZSWIM6","APOD","APOE","CCL19",
  "CXCL10","CXCL9","COL12A1","COL10A1","SULF1","ABCA8","SVEP1","ENO1","TGFBI","CD74",
  "HLA-DRA","LUM","SFRP2","NOTCH3","F2R","A2M")
markers <- read_step("step01_harmony_de", "dotplot_fib")
genes <- intersect(marker_order, markers$gene)
p <- panel_tag(supp_dotplot(markers, names(fib_cols), genes, c(-1, 2), c(.55, 3.0), 18, 7.5) +
  theme(plot.margin = margin(23, 5, 4, 8)), "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
