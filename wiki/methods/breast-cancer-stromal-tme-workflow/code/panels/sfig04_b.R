# Panel ID: sfig04/B (Supp. Fig. 4 S4B)
# Title: EC 32-marker expression DotPlot across 12 subclusters.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/dotplot_ec.csv
# Default dimensions: width = 7.8 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/sfig04_b.R --paper-root <PAPER_ROOT> --out sfig04_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig04_b.png', default_width = 7.8, default_height = 4.2)
pal <- ec_cols
markers <- read_step("step01_harmony_de", "dotplot_ec")
markers$cluster <- wave_cluster(markers$cluster, pal)
preferred <- c("GJA4","SEMA3G","GJA5","NOTCH4","NOTCH1","DLL4","CD36","RGCC","FABP4",
  "ESM1","VWA1","PGF","SELE","MCTP1","CNKSR3","HIF1A","ACKR1","CD74","CCL14",
  "RASAL2","DOCK4","MAGI1","CD24","KRT19","AZGP1","ACTA2","APOE","COL1A1",
  "IL6","CXCL8","CSF3","HMOX1","MT1A","CYP1A1","PROX1","LYVE1","CCL21")
genes <- head(intersect(preferred, markers$gene), 32)
p <- panel_tag(supp_dotplot(markers, names(pal), genes, c(-1, 2), c(.81, 3.9), 23, 8, size_name = "Pct", colour_name = "Exp") +
  theme(plot.margin = margin(22, 8, 7, 8)), "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
