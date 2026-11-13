plot_subtype_pathways <- function(pathway_list, title) {
	# 数据转换
	plot_data <- as.data.frame(t(result_scaled[pathway_list, ])) %>%
		mutate(Subtype = subtypes) %>%
		pivot_longer(cols = -Subtype, 
								 names_to = "Pathway",
								 values_to = "Score") %>%
		mutate(Pathway = factor(Pathway, levels = pathway_list))
	
	# 计算显著性标记
	p_values <- sapply(pathway_list, function(p) {
		wilcox.test(Score ~ Subtype, data = filter(plot_data, Pathway == p))$p.value
	})
	sig_labels <- ifelse(p_values < 0.001, "***",
											 ifelse(p_values < 0.01, "**",
											 			 ifelse(p_values < 0.05, "*", "")))
	
	# 可视化
	ggplot(plot_data, aes(x = Pathway, y = Score)) +
		geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.4, color = NA) +
		geom_boxplot(aes(fill = Subtype), 
								 width = 0.15, 
								 position = position_dodge(0.9),
								 outlier.shape = NA,
								 color = "black") +  # 添加箱式图描边
		geom_text(
			data = data.frame(Pathway = pathway_list, label = sig_labels),
			aes(x = Pathway, y = max(plot_data$Score)*1.1, label = label),
			size = 5, vjust = -0.5
		) +
		scale_fill_manual(values = c("MBC1"="#FF6F61", "MBC2"="#92A8D1")) +
		labs(title = title, x = "", y = "GSVA Enrichment Score") +
		theme_classic() +
		theme(
			axis.text.x = element_text(angle = 45, hjust = 1, face = "bold",size = 6),
			plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
			legend.position = "top",
			panel.border = element_rect(color = "black", fill = NA),  # 添加边框
			panel.grid.major.y = element_line(color = "grey90")
		) +
		coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score)*1.15))
}
