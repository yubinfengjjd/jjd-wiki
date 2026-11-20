# Panel ID: fig02/K (Fig. 2 2K)
# Title: MOESM8 Fib-to-malignant CellChat L-R probability bubble matrix.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/fig2k_fib_malignant_lr.csv
# Default dimensions: width = 5.2 in, height = 4.6 in
# Usage: Rscript --vanilla code/panels/fig02_k.R --paper-root <PAPER_ROOT> --out fig02_k.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_k.png', default_width = 5.2, default_height = 4.6)
lr <- read_step("step05_crosstalk", "fig2k_fib_malignant_lr")
ligands <- c("COL1A1", "COL1A2", "COL6A1", "COL6A2", "COL6A3")
pairs <- c(paste0(ligands, "_CD44"), paste0(ligands, "_SDC4"))
lr <- lr[lr$interaction_name %in% pairs & lr$target == "Epi", ]
lr$source <- canonical_cluster(lr$source, fib_cols)
rows <- names(fib_cols)[c(9, 8, 7, 6, 4, 3, 2, 13, 10, 12, 11, 14, 1, 5)]
lr <- aggregate(prob ~ source + interaction_name, lr, max)
lr$source <- factor(lr$source, levels = rev(rows))
lr$interaction_name <- factor(lr$interaction_name, levels = pairs)
emphasis <- names(fib_cols)[c(9, 8, 3, 13, 10, 11, 1)]
label_ink <- ifelse(rev(rows) %in% emphasis, "#D6352E", "#242424")
row_labels <- paste0("<span style=", intToUtf8(34), "color:", label_ink, intToUtf8(34), ">", rev(rows), "-&gt;Malignant</span>")
K_plot <- ggplot(lr, aes(interaction_name, source, fill = prob, size = prob)) +
  geom_point(shape = 21, colour = "black", stroke = .45) +
  scale_x_discrete(drop = FALSE, expand = expansion(add = .55)) +
  scale_y_discrete(drop = FALSE, labels = row_labels, expand = expansion(add = .55)) +
  scale_fill_gradientn(colours = lr_cols, name = "Communication\nProbability") +
  scale_size_continuous(name = "prob", range = c(1.2, 3.9)) +
  guides(size = guide_legend(order = 1, override.aes = list(fill = "black")),
         fill = guide_colourbar(order = 2, barwidth = grid::unit(2, "mm"), barheight = grid::unit(12, "mm"))) +
  theme_bw(base_size = 6) +
  theme(
    axis.title = element_blank(), axis.ticks = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5),
    axis.text.y = ggtext::element_markdown(size = 5.7),
    panel.border = element_rect(colour = "black", linewidth = .45),
    panel.grid = element_line(colour = "#E4E4E4", linewidth = .18),
    legend.position = "left", legend.title = element_text(size = 5), legend.text = element_text(size = 5),
    legend.spacing.y = grid::unit(1, "mm"), legend.key.height = grid::unit(3, "mm"),
    plot.margin = margin(10, 4, 5, 1)
  )
p <- panel_tag(K_plot, "K")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
