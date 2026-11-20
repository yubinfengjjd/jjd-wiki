# Panel ID: fig05/D (Fig. 5 5D)
# Title: Mural chemokine, MHC-I, and MHC-II Z-score heatmap overlaid with published DEG markers.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_mural.csv, runs/step02_progeny_roe_cox/chemokine_zscore_mural.csv, data_small/moesm/deg_mural.csv, data_small/scrna_stromal_small.qs
# Default dimensions: width = 7.2 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig05_d.R --paper-root <PAPER_ROOT> --out fig05_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_d.png', default_width = 7.2, default_height = 3.8)
pal <- mural_cols
obs <- read_step("step01_harmony_de", "umap_mural")
obs$cluster <- wave_cluster(obs$canonical_subcluster, pal)
srt <- qs::qread(file.path(paper_dir, "data_small/scrna_stromal_small.qs"), nthreads = 1)
counts <- as.matrix(SeuratObject::GetAssayData(srt, layer = "counts"))
p <- wave_functional("mural", pal, obs, counts)
rm(srt, counts)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
