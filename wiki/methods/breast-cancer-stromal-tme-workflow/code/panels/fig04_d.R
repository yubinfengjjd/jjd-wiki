# Panel ID: fig04/D (Fig. 4 4D)
# Title: EC Angiogenesis/Notch, Chemokines, MHC-I/II, and ROBO/UNC5 Z-score heatmap with DEG circles.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_ec.csv, runs/step02_progeny_roe_cox/chemokine_zscore_ec.csv, data_small/moesm/deg_ec.csv, data_small/scrna_stromal_small.qs
# Default dimensions: width = 7.6 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig04_d.R --paper-root <PAPER_ROOT> --out fig04_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_d.png', default_width = 7.6, default_height = 3.8)
pal <- ec_cols
obs <- read_step("step01_harmony_de", "umap_ec")
obs$cluster <- wave_cluster(obs$canonical_subcluster, pal)
srt <- qs::qread(file.path(paper_dir, "data_small/scrna_stromal_small.qs"), nthreads = 1)
counts <- as.matrix(SeuratObject::GetAssayData(srt, layer = "counts"))
p <- wave_functional("ec", pal, obs, counts)
rm(srt, counts)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
