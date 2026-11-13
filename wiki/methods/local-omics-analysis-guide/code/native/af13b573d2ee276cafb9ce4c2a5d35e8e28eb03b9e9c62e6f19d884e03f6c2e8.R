plot_subtype_pathways <- function(pathway_list, title){
	# 数据转换
	plot_data <- as.data.frame(t(result_scaled[pathway_list, ])) %>%
		mutate(Subtype = group) %>%
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
		# 添加组间分隔线（竖虚线） - 核心添加部分
		geom_vline(
			xintercept = seq(1.5, length(pathway_list) - 0.5,  # 计算分隔线位置
											 color = "gray60", 
											 linetype = "dashed", 
											 linewidth = 0.4
			)) +
				geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.4, color = NA, width = 0.8) +
				geom_boxplot(aes(fill = Subtype), 
										 width = 0.4, 
										 position = position_dodge(0.9),
										 outlier.shape = NA,
										 color = "black") +
				geom_text(
					data = data.frame(Pathway = pathway_list, label = sig_labels),
					aes(x = Pathway, y = max(plot_data$Score)*1.1, label = label),
					size = 5, vjust = -0.5
				) +
				scale_fill_manual(values = c("high"="#FF6F61", "low"="#92A8D1")) +
				labs(title = title, x = "", y = "GSVA Enrichment Score") +
				theme_classic() +
				theme(
					axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 9),
					plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
					legend.position = "top",
					panel.border = element_rect(color = "black", fill = NA),
					panel.grid.major.y = element_line(color = "grey90")
				) +
				coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score)*1.15))
}
