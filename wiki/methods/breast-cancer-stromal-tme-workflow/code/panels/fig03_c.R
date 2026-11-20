# Panel ID: fig03/C (Fig. 3 3C)
# Title: 8 immune checkpoint genes across ABCA8 high vs low quartiles in CAA_ST (sqrt y-axis, P97 cap).
# Evidence tier: local_recompute
# Input tables: runs/step05_crosstalk/fig3c_checkpoint_box.csv
# Default dimensions: width = 5.8 in, height = 3.6 in
# Usage: Rscript --vanilla code/panels/fig03_c.R --paper-root <PAPER_ROOT> --out fig03_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig03_c.png', default_width = 5.8, default_height = 3.6)
checkpoints <- c("PDCD1", "CTLA4", "HAVCR2", "CD274", "ICOS", "TNFRSF4", "TIGIT", "CD276")
ck <- read_step("step05_crosstalk", "fig3c_checkpoint_box")
ck <- ck[ck$abca8_quartile_group %in% c("ABCA8_low", "ABCA8_high") & ck$gene %in% checkpoints, ]
ck$group <- factor(sub("ABCA8_", "", ck$abca8_quartile_group), levels = c("low", "high"))
ck$gene <- factor(ck$gene, levels = checkpoints)
pvalue <- unique(ck[c("gene", "wilcox_p_quartile")])
display_limits <- aggregate(expression ~ gene, ck, function(x) unname(quantile(x, .97)))
names(display_limits)[2] <- "cap"
pvalue <- merge(pvalue, display_limits, by = "gene")
pvalue$stars <- cut(pvalue$wilcox_p_quartile, breaks = c(-Inf, .0001, .001, .01, .05, Inf),
                    labels = c("****", "***", "**", "*", "ns"), right = FALSE)
by_group <- split(ck, interaction(ck$gene, ck$group, drop = TRUE))
box_groups <- lapply(by_group, function(d) {
  x <- d$expression
  hinges <- quantile(x, c(.25, .5, .75), names = FALSE)
  inlier <- x >= hinges[1] - 1.5 * diff(hinges[c(1, 3)]) & x <= hinges[3] + 1.5 * diff(hinges[c(1, 3)])
  cap <- max(display_limits$cap[match(d$gene[1], display_limits$gene)], hinges[3])
  list(
    box = data.frame(gene = d$gene[1], group = d$group[1], ymin = min(x[inlier]),
                     lower = hinges[1], middle = hinges[2], upper = hinges[3], ymax = min(max(x[inlier]), cap)),
    outliers = d[!inlier & x <= cap, ]
  )
})
boxes <- do.call(rbind, lapply(box_groups, "[[", "box"))
outliers <- do.call(rbind, lapply(box_groups, "[[", "outliers"))
pvalue$expression <- 1.12 * pmax(pvalue$cap, tapply(boxes$ymax, boxes$gene, max)[as.character(pvalue$gene)])
C_plot <- ggplot(boxes, aes(group, fill = group)) +
  geom_boxplot(aes(ymin = ymin, lower = lower, middle = middle, upper = upper, ymax = ymax),
               stat = "identity", width = .62, colour = "black", linewidth = .34) +
  geom_point(data = outliers, aes(group, expression), inherit.aes = FALSE, size = .52, alpha = .65) +
  geom_text(data = pvalue, aes(x = 1.5, y = expression, label = stars), inherit.aes = FALSE, size = 2.3) +
  facet_wrap(~gene, ncol = 4, scales = "free_y") +
  scale_fill_manual(values = box_cols, guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(.02, .055)), n.breaks = 4) +
  coord_transform(y = "sqrt") +
  labs(x = NULL, y = "Expression", subtitle = "CAA_ST | ABCA8 quartiles | square-root axis, display capped at P97") +
  theme_classic(base_size = 7) +
  theme(strip.background = element_blank(), strip.text = element_text(size = 7, face = "plain"),
        panel.border = element_rect(fill = NA, linewidth = .26, colour = "#757575"),
        axis.text = element_text(size = 6), axis.ticks.length = grid::unit(.7, "mm"),
        panel.spacing = grid::unit(1.75, "mm"), plot.subtitle = element_text(size = 6),
        plot.margin = margin(9, 4, 4, 8))
p <- panel_tag(C_plot, "C")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
