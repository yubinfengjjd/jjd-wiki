# Panel ID: fig02/A (Fig. 2 2A)
# Title: Fibroblast 14-subcluster UMAP split by Adjacent normal tissue vs Tumor.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_fib.csv, extracted/pages/main_p03.png
# Default dimensions: width = 5.2 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig02_a.R --paper-root <PAPER_ROOT> --out fig02_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_a.png', default_width = 5.2, default_height = 4.2)
fib <- read_step("step01_harmony_de", "umap_fib")
umap <- make_manifolds("fib")$umap_fib
tab <- match(umap$cell, fib$cell)
tissue <- function(value, title) {
  active <- umap[fib$tissue[tab] == value, ]
  ggplot(umap, aes(x, y)) +
    manifold_points(size = .67, colour = "#DCDCDC") +
    manifold_points(data = active, aes(colour = cluster), size = .58) +
    scale_colour_manual(values = fib_cols) +
    coord_equal() +
    labs(title = title) +
    theme_umap_blank(7) +
    theme(legend.position = "none", plot.title = element_text(face = "plain", size = 7.4))
}
flegend <- data.frame(x = rep(c(1, 2), each = 7), y = rep(7:1, 2), cluster = names(fib_cols))
flegend_p <- ggplot(flegend, aes(x, y)) +
  geom_point(aes(colour = cluster), size = 1.55) +
  geom_text(aes(x = x + .07, label = cluster), hjust = 0, size = 1.7) +
  scale_colour_manual(values = fib_cols, guide = "none") +
  coord_cartesian(xlim = c(.88, 3.0), ylim = c(.55, 7.45), expand = FALSE) +
  theme_void()
axis_a <- grid::grobTree(
  grid::segmentsGrob(x0 = c(.25, .25), x1 = c(.92, .25), y0 = c(.22, .22), y1 = c(.22, .92),
    arrow = grid::arrow(length = grid::unit(.95, "mm")), gp = grid::gpar(lwd = .8)),
  grid::textGrob("UMAP2D_1", x = .58, y = .05, gp = grid::gpar(fontsize = 5.4)),
  grid::textGrob("UMAP2D_2", x = .12, y = .58, rot = 90, gp = grid::gpar(fontsize = 5.4))
)
p <- panel_tag(wrap_plots(
  wrap_plots(
    tissue("Normal", "Adjacent normal tissue") + inset_element(axis_a, .003, .013, .40, .275, align_to = "full"),
    tissue("Tumor", "Tumor"),
    nrow = 1
  ),
  flegend_p, ncol = 1, heights = c(.69, .31)
), "A")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
