# Panel ID: sfig05/B (Supp. Fig. 5 S5B)
# Title: Mural 32-marker expression DotPlot across 10 subclusters.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/dotplot_mural.csv
# Default dimensions: width = 7.6 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/sfig05_b.R --paper-root <PAPER_ROOT> --out sfig05_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig05_b.png', default_width = 7.6, default_height = 4.2)
pal <- mural_cols
legacy_labels <- setNames(c("C1_SMC_MYL9","C2_SMC_FN1","C3_SMC_MYH11","C1_tPC_COL3A1",
  "C2_tPC_CCL19","C3_tPC_CD74","C4_tPC_SEPT7","C5_tPC_PRKG1","C6_nPC_CXCL8","C7_nPC_GJA5"), names(pal))
markers <- read_step("step01_harmony_de", "dotplot_mural")
markers$cluster <- wave_cluster(markers$cluster, pal)
preferred <- c("MYL9","RERGL","MUSTN1","FN1","EGFL6","IFI27","MYH11","GADD45B","SORBS2",
  "COL3A1","LUM","POSTN","CCL19","CCL21","C1S","CD74","APOD","AZGP1","SEPT7","H3F3A","SEPT4",
  "PRKG1","DLC1","CCDC102B","CXCL8","CXCL3","CXCL2","KLF2","NRXN3","TIMP1","TAGLN","GJA5")
genes <- intersect(preferred, markers$gene)
p <- panel_tag(supp_dotplot(markers, names(pal), genes, c(-1, 2), c(.77, 3.65), 22, 7.05,
  cluster_labels = legacy_labels) + theme(plot.margin = margin(25, 6, 7, 8)), "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
