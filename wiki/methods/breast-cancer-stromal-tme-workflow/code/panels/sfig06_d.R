# Panel ID: sfig06/D (Supp. Fig. 6 S6D)
# Title: MOESM8 C4_TipEC_PGF to 21 TME cell types 14-pair CellChat L-R probability bubble matrix.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/sfig6d_pgf_tme_lr.csv, data_small/moesm/cellchat_edges.csv
# Default dimensions: width = 6.2 in, height = 6.8 in
# Usage: Rscript --vanilla code/panels/sfig06_d.R --paper-root <PAPER_ROOT> --out sfig06_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig06_d.png', default_width = 6.2, default_height = 6.8)
targets <- c("Regulatory T","Transitory_T","Plasma B","pDC","NK","Neutrophil","Naive B",
  "Memory B","Mast","M2","M1","GC B","Epi","DC_LAMP3","DC_CLEC9A","DC_CD1C",
  "CD8_Cytotoxic_T","CD4_Tfh","CD4_Naive_T","CD4_Exhausted_T","CD4_Effector_T")
interactions <- c("TGFB1_TGFBR1_TGFBR2","CCL14_CCR1","CXCL12_CXCR4","MIF_CD74_CXCR4",
  "MIF_CD74_CD44","LGALS9_CD45","LGALS9_HAVCR2","LGALS9_CD44","LGALS9_P4HB",
  "LAMA4_CD44","LAMA5_CD44","LAMB1_CD44","LAMB2_CD44","LAMC1_CD44")
pick_lr <- function(x) {
  x$target <- sub("^(GC|Memory|Naive|Plasma|Regulatory)_([BT])$", "\\1 \\2", x$target)
  x[grepl("^C4_tips_PGF", x$source) & x$target %in% targets & x$interaction_name %in% interactions & is.finite(x$prob), ]
}
panel <- pick_lr(read_step("step05_crosstalk", "sfig6d_pgf_tme_lr"))
official <- pick_lr(read_input("data_small", "moesm", "cellchat_edges.csv"))
key_fn <- function(d) paste(d$target, d$interaction_name, sep = "|")
missing <- !key_fn(official) %in% key_fn(panel)
lr <- rbind(panel[c("target", "interaction_name", "prob")], official[missing, c("target", "interaction_name", "prob")])
lr$x <- lr$interaction_name
lr$x[lr$x == "TGFB1_TGFBR1_TGFBR2"] <- "TGFB1_TGFBR1/2"
lr$y <- paste0("C4_TipEC_PGF -> ", lr$target)
shown_cols <- interactions; shown_cols[1] <- "TGFB1_TGFBR1/2"
shown_rows <- paste0("C4_TipEC_PGF -> ", targets)
bubble <- ggplot(aggregate(prob ~ x + y, lr, max), aes(x, y, fill = prob, size = prob)) +
  geom_point(shape = 21, colour = "#151515", stroke = .42) +
  scale_x_discrete(limits = shown_cols, expand = expansion(add = .57), drop = FALSE) +
  scale_y_discrete(limits = rev(shown_rows), expand = expansion(add = .57), drop = FALSE) +
  scale_fill_gradientn(colours = lr_cols, breaks = c(.04, .08, .12), name = "Communication\nProbability") +
  scale_size_continuous(range = c(1.03, 4.35), breaks = c(.04, .08, .12), name = "prob") +
  guides(size = guide_legend(order = 1, ncol = 1, override.aes = list(fill = "#0E0E0E")),
         fill = guide_colourbar(order = 2, direction = "vertical", barwidth = grid::unit(2.3, "mm"), barheight = grid::unit(16, "mm"))) +
  theme_bw(base_size = 7) +
  theme(axis.title = element_blank(), axis.ticks = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, colour = "#262326", size = 6.55, margin = margin(t = 2)),
    axis.text.y = element_text(colour = "#262326", size = 6.15),
    panel.border = element_rect(colour = "#111111", linewidth = .52),
    panel.grid = element_line(colour = "#E3E3E5", linewidth = .37),
    legend.position = "bottom", legend.box = "horizontal", legend.box.just = "left",
    legend.title = element_text(size = 7), legend.text = element_text(size = 6.3),
    legend.key.size = grid::unit(3.5, "mm"), legend.box.spacing = grid::unit(1.25, "mm"),
    plot.margin = margin(30, 8, 4, 8))
grDevices::pdf(NULL)
g <- tryCatch(ggplotGrob(bubble), finally = invisible(grDevices::dev.off()))
i <- match("guide-box-bottom", g$layout$name)
legend <- g$grobs[[i]]
bubble <- bubble + theme(legend.position = "none", plot.margin = margin(30, 8, 60, 8))
p <- panel_tag(wrap_elements(full = bubble) + inset_element(legend, .005, .010, .279, .158, align_to = "full"), "D")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
