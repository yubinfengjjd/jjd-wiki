# Panel ID: sfig05/A (Supp. Fig. 5 S5A)
# Title: Mural cohort UMAP combined with ANT/T/LM tissue proportion and batch x tissue boxplot.
# Evidence tier: proxy
# Input tables: runs/step01_harmony_de/umap_mural.csv, runs/step02_progeny_roe_cox/tissue_prop_mural.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.8 in, height = 4.6 in
# Usage: Rscript --vanilla code/panels/sfig05_a.R --paper-root <PAPER_ROOT> --out sfig05_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig05_a.png', default_width = 5.8, default_height = 4.6)
obs <- read_step("step01_harmony_de", "umap_mural")
u <- make_manifolds("mural")$umap_mural
key <- supp_cohort_palette[names(supp_cohort_palette) != "GSE139495"]
p <- supp_batch_and_ratio("mural", u, obs, mural_cols, TRUE, "% Mural cells", cohort_key = key)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
