process_single_file <- function(input_file) {
	exp <- data.table::fread(input_file, data.table = FALSE) %>%
		column_to_rownames("ID")

	gsva_results <- ssgseaParam(
		as.matrix(exp),
		gsc, minSize = 5, normalize = FALSE
	)
	result <- gsva(gsva_results)
	result_scaled <- t(scale(t(result)))

	Type <- gsub("(.*)_(.*)", "\\2", colnames(exp))
	plot_data <- data.frame(t(result_scaled), Type)
	colnames(plot_data) <- c("Scoreing", "Subtype")
	plot_data$Subtype <- as.factor(plot_data$Subtype)

	p_value <- wilcox.test(Scoreing ~ Subtype, data = plot_data)$p.value
	sig_label <- ifelse(p_value < 0.001, "***",
											ifelse(p_value < 0.01, "**",
														 ifelse(p_value < 0.05, "*", "")))

	p <- ggplot(plot_data, aes(x = Subtype, y = Scoreing)) +
		geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.7) +
		geom_boxplot(aes(fill = Subtype),
								 width = 0.15,
								 position = position_dodge(0.9),
								 outlier.shape = NA,
								 color = "black") +
		geom_text(
			aes(x = 1.5, y = max(plot_data$Scoreing)*1.1, label = sig_label),
			size = 5, vjust = -0.5
		) +
		scale_fill_manual(values = c("control"="#7cafc4", "treat"="#540d15")) +
		labs(x = "Subtype", y = "LMBDs") +
		theme_classic() +
		theme(
			axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 8),
			plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
			legend.position = "top",
			panel.border = element_rect(color = "black", fill = NA),
			panel.grid.major.y = element_line(color = "grey90")
		) +
		coord_cartesian(ylim = c(min(plot_data$Scoreing), max(plot_data$Scoreing)*1.15))

	output_name <- tools::file_path_sans_ext(basename(input_file)) %>%
		paste0(".pdf")

	ggsave(output_name, plot = p, width = 6, height = 6)
}
