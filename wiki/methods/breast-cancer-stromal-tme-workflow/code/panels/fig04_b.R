# Panel ID: fig04/B (Fig. 4 4B)
# Title: 4 canonical endothelial markers (SEMA3G, ACKR1, RGCC, LYVE1) projected on EC UMAP.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_ec.csv, data_small/scrna_stromal_small.qs, extracted/pages/main_p03.png
# Default dimensions: width = 5.0 in, height = 4.4 in
# Usage: Rscript --vanilla code/panels/fig04_b.R --paper-root <PAPER_ROOT> --out fig04_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_b.png', default_width = 5.0, default_height = 4.4)
u <- make_manifolds("ec")$umap_ec
srt <- qs::qread(file.path(paper_dir, "data_small/scrna_stromal_small.qs"), nthreads = 1)
counts <- as.matrix(SeuratObject::GetAssayData(srt, layer = "counts"))
ids <- match(u$cell, colnames(counts))
genes <- c("SEMA3G", "ACKR1", "RGCC", "LYVE1")
markers <- setNames(lapply(genes, function(gene) {
  if (gene %in% rownames(counts)) log1p(1e4 * counts[gene, ids] / colSums(counts)[ids]) else NA_real_
}), genes)
rm(srt, counts)
p <- wave_features(u, markers, c("#1B7837", "#A6DBA0", "#F7F7F7", "#F4A582", "#B2182B"))

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
