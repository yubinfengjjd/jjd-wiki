generate_plot <- function(exp_matrix, gene, dataset_name, color_pal){
	dir.create(file.path(output_dir, dataset_name), showWarnings = FALSE, recursive = TRUE)

	my_comparisons <- list(
		c("control","treat")
	)

	# p_val <- wilcox.test(count ~ type, data = exp_matrix)$p.value

	p <- ggplot(exp_matrix, aes(x = type, y = count, fill = type)) +
		scale_fill_manual(values = color_pal) +
		geom_violin(
			alpha = 0.4,
			position = position_dodge(width = .75),
			size = 0.8,
			color = "black"
		) +
		geom_boxplot(
			notch = TRUE,
			outlier.size = -1,
			lwd = 0.8,
			alpha = 0.7,
			color = "black",
			position = position_dodge(width = .75)
		) +
		geom_point(
			aes(color = NULL),
			shape = 21,
			size = 2,
			color = "black",
			position = position_jitterdodge(dodge.width = .75)
		) +
		stat_compare_means(
			method = "wilcox.test",
			hide.ns = FALSE,
			comparisons = my_comparisons,
			label = "p.signif"
		) +
		theme_bw() +
		labs(
			title = paste0(dataset_name, ": ", gene),
			x = "",
			y = "Normalized Expression"
		) +
		theme(
			panel.background     = element_blank(),
			panel.grid           = element_blank(),
			axis.text.x          = element_text(size = 12, color = "black"),
			axis.text.y          = element_text(size = 12, color = "black"),
			axis.title           = element_text(size = 12),
			axis.ticks           = element_line(size = 0.2, color = "black"),
			axis.ticks.length    = unit(0.2, "cm"),
			legend.position      = "none",
			plot.title           = element_text(face = "bold", hjust = 0.5)
		)

	ggsave(
		filename = file.path(output_dir, dataset_name, paste0(gene, "_", dataset_name, ".pdf")),
		plot     = p,
		width    = 8,
		height   = 6
	)
}
