# Panel ID: fig05/I (Fig. 5 5I)
# Title: Mural Lineage 2 8-gene pseudotime curves (COL6A3 absent in small gene panel and marked missing).
# Evidence tier: local_recompute
# Input tables: runs/step04_trajectory/traj_mural_branch_genes.csv
# Default dimensions: width = 4.2 in, height = 5.4 in
# Usage: Rscript --vanilla code/panels/fig05_i.R --paper-root <PAPER_ROOT> --out fig05_i.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig05_i.png', default_width = 4.2, default_height = 5.4)
dynamics <- read_step("step04_trajectory", "traj_mural_branch_genes")
genes <- c("COL6A3", "MUSTN1", "SORBS2", "CCL21", "NET1", "THY1", "RERGL", "MYH11")
lineage_size <- aggregate(n_cells_lineage ~ lineage, dynamics, max)
selected <- lineage_size$lineage[which.max(lineage_size$n_cells_lineage)]
dynamics <- dynamics[dynamics$lineage == selected, ]
views <- lapply(genes, function(gene) {
  values <- dynamics[dynamics$gene == gene & is.finite(dynamics$smoothed_expr), ]
  g <- ggplot(values, aes(pseudotime_norm, smoothed_expr)) +
    labs(title = gene, x = "Pseudotime", y = NULL) +
    scale_x_continuous(breaks = c(0, .5, 1), labels = c("0", "0.5", "1")) +
    theme_bw(base_size = 6.1) +
    theme(panel.border = element_rect(colour = "black", linewidth = .47), aspect.ratio = .86,
          panel.grid = element_blank(), plot.title = element_text(hjust = .5, size = 7),
          axis.title.x = element_text(size = 5.45, margin = margin(t = 1)),
          axis.text = element_text(size = 5.1), axis.ticks.length = grid::unit(.65, "mm"),
          plot.margin = margin(2, 3, 2, 4))
  if (nrow(values)) return(g + geom_line(colour = "#529E73", linewidth = .70))
  note <- if (gene == "COL6A3") "Unavailable in\nsmall scRNA" else "No fitted curve"
  g + annotate("text", x = .5, y = .5, label = note, size = 2.05, colour = "#555555") +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
    theme(axis.text = element_blank(), axis.ticks = element_blank())
})
p <- panel_tag(wrap_plots(views, ncol = 2), "I")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
