# Panel ID: fig04/A (Fig. 4 4A)
# Title: EC 12 subclusters UMAP split by Adjacent normal tissue vs Tumor.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_ec.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.2 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig04_a.R --paper-root <PAPER_ROOT> --out fig04_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig04_a.png', default_width = 5.2, default_height = 4.2)
pal <- ec_cols
obs <- read_step("step01_harmony_de", "umap_ec")
obs$cluster <- wave_cluster(obs$canonical_subcluster, pal)
u <- make_manifolds("ec")$umap_ec
p <- wave_split(u, obs, pal)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
