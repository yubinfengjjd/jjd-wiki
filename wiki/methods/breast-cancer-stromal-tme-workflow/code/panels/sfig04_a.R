# Panel ID: sfig04/A (Supp. Fig. 4 S4A)
# Title: EC cohort UMAP combined with ANT/T/LM tissue proportion and batch x tissue boxplot.
# Evidence tier: proxy
# Input tables: runs/step01_harmony_de/umap_ec.csv, runs/step02_progeny_roe_cox/tissue_prop_ec.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.8 in, height = 4.6 in
# Usage: Rscript --vanilla code/panels/sfig04_a.R --paper-root <PAPER_ROOT> --out sfig04_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig04_a.png', default_width = 5.8, default_height = 4.6)
obs <- read_step("step01_harmony_de", "umap_ec")
u <- make_manifolds("ec")$umap_ec
p <- supp_batch_and_ratio("ec", u, obs, ec_cols, TRUE, "% EC cells")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
