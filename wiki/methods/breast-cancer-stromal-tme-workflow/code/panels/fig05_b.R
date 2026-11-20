# Panel ID: fig05/B (Fig. 5 5B)
# Title: Mural Angiogenic/Quiescent signatures and ACTA2/RGS5 marker feature UMAPs.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_mural.csv, runs/step04_trajectory/traj_mural.csv, data_small/scrna_stromal_small.qs, extracted/pages/main_p03.png
# Default dimensions: width = 5.0 in, height = 4.4 in
# Usage: Rscript --vanilla code/panels/fig05_b.R --paper-root <PAPER_ROOT> --out fig05_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_b.png', default_width = 5.0, default_height = 4.4)
u <- make_manifolds("mural")$umap_mural
traj <- read_step("step04_trajectory", "traj_mural")
srt <- qs::qread(file.path(paper_dir, "data_small/scrna_stromal_small.qs"), nthreads = 1)
counts <- as.matrix(SeuratObject::GetAssayData(srt, layer = "counts"))
ids <- match(u$cell, colnames(counts))
traj_ids <- match(u$cell, traj$cell_id)
markers <- list(Angiogenic_signature = traj$score_Angiogenic[traj_ids],
                Quiescent_signature = traj$score_Quiescent[traj_ids])
for (gene in c("ACTA2", "RGS5")) {
  markers[[gene]] <- if (gene %in% rownames(counts)) log1p(1e4 * counts[gene, ids] / colSums(counts)[ids]) else NA_real_
}
rm(srt, counts)
p <- wave_features(u, markers, c("#4DAC26", "#F7F7F7", "#D73027"))

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
