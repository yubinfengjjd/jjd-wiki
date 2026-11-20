# Panel ID: fig05/A (Fig. 5 5A)
# Title: Mural 10 subclusters UMAP split by Adjacent normal tissue vs Tumor.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_mural.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.2 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig05_a.R --paper-root <PAPER_ROOT> --out fig05_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_a.png', default_width = 5.2, default_height = 4.2)
pal <- mural_cols
obs <- read_step("step01_harmony_de", "umap_mural")
obs$cluster <- wave_cluster(obs$canonical_subcluster, pal)
u <- make_manifolds("mural")$umap_mural
p <- wave_split(u, obs, pal)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
