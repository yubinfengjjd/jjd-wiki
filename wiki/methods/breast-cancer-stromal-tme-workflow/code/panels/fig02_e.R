# Panel ID: fig02/E (Fig. 2 2E)
# Title: PROGENy 14-pathway activity Z-score heatmap across 14 fibroblast subclusters.
# Evidence tier: local_recompute
# Input tables: runs/step02_progeny_roe_cox/progeny_fib.csv
# Default dimensions: width = 4.4 in, height = 4.0 in
# Usage: Rscript --vanilla code/panels/fig02_e.R --paper-root <PAPER_ROOT> --out fig02_e.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_e.png', default_width = 4.4, default_height = 4.0)
prog <- read_step("step02_progeny_roe_cox", "progeny_fib")
mat <- as.matrix(prog[match(names(fib_cols), prog$canonical_subcluster), -1])
rownames(mat) <- names(fib_cols)
path_order <- c("PI3K", "VEGF", "NFkB", "TNFa", "EGFR", "MAPK", "Hypoxia", "Androgen",
                "Estrogen", "p53", "Trail", "JAK-STAT", "WNT", "TGFb")
progplot <- expand.grid(cluster = names(fib_cols), path = rev(path_order))
progplot$z <- mat[cbind(match(progplot$cluster, rownames(mat)), match(progplot$path, colnames(mat)))]
E_plot <- ggplot(progplot, aes(factor(cluster, levels = names(fib_cols)), factor(path, levels = rev(path_order)), fill = z)) +
  geom_tile(colour = "#BCBAC0", linewidth = .14) +
  scale_y_discrete(position = "right", expand = c(0, 0)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_fill_gradientn(colours = progeny_cols, limits = c(-1, 2), values = c(0, 1 / 3, 1), oob = scales::squish, name = "Z-scale") +
  guides(fill = guide_colourbar(barwidth = grid::unit(1.55, "mm"), barheight = grid::unit(12, "mm"))) +
  theme_void(base_size = 7) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 5.45),
    axis.text.y = element_text(size = 5.65), legend.position = "right",
    legend.text = element_text(size = 5), legend.title = element_text(size = 5),
    plot.margin = margin(12, 1, 3, 3), legend.margin = margin(0, 0, 0, 1)
  )
p <- panel_tag(E_plot, "E")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
