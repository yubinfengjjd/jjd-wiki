# Panel ID: sfig01/A (Supp. Fig. 1 S1A)
# Title: Stromal major atlas UMAP colored by Harmony-integrated GSE cohorts.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_all.csv, extracted/pages/main_p03.png
# Default dimensions: width = 6.4 in, height = 4.8 in
# Usage: Rscript --vanilla code/panels/sfig01_a.R --paper-root <PAPER_ROOT> --out sfig01_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig01_a.png', default_width = 6.4, default_height = 4.8)
u <- make_manifolds("all")$umap_all
obs <- read_step("step01_harmony_de", "umap_all")
by_batch <- supp_batch_plot(u, obs, supp_cohort_palette, width = .42, repeats = 4)
key <- wave_dot_legend(supp_cohort_palette, cols = 1, header = "GSE_number:", size = 3.5) +
  annotate("text", x = -.04, y = .50, label = "4 cohorts in local subset", hjust = 0, size = 2.15, colour = "#565656") +
  theme(plot.title = element_text(size = 11, hjust = 0, margin = margin(b = 4)))
batch_key <- wrap_plots(wrap_elements(), key, wrap_elements(), ncol = 1, heights = c(.23, .52, .25))
p <- panel_tag(wrap_plots(by_batch, batch_key, nrow = 1, widths = c(.765, .235)), "A")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
