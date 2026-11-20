# Panel ID: fig02/B (Fig. 2 2B)
# Title: 4 CAF functional module scores (lpCAF, mCAF, tCAF, ifnCAF) projected on fibroblast UMAP.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_fib.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.0 in, height = 4.4 in
# Usage: Rscript --vanilla code/panels/fig02_b.R --paper-root <PAPER_ROOT> --out fig02_b.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_b.png', default_width = 5.0, default_height = 4.4)
fib <- read_step("step01_harmony_de", "umap_fib")
umap <- make_manifolds("fib")$umap_fib
tab <- match(umap$cell, fib$cell)
modules <- c("lpCAF", "mCAF", "tCAF", "ifnCAF")
p <- panel_tag(wrap_plots(lapply(modules, function(module) {
  umap$score <- scale01(fib[[paste0("score_", module)]][tab])^1.7
  feature_panel(umap, "score", module_cols, module, dots = .63, manifold = TRUE,
                limits = c(0, 1), bar = TRUE, endpoints = TRUE) +
    theme(plot.title = element_text(face = "plain", size = 8.4), legend.text = element_text(size = 5.7))
}), ncol = 2), "B")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
