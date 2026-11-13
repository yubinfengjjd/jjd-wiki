plot_subtype_pathways <- function(pathway_list, title) {
	# 数据转换
	plot_data <- as.data.frame(state_subset@meta.data[,pathway_list]) %>%
		mutate(Subtype = state_subset$Monocle2_State) %>%
		pivot_longer(
			cols = -Subtype,
			names_to = "Pathway",
			values_to = "Score"
		) %>%
		mutate(
			Pathway = factor(Pathway, levels = pathway_list),
			Subtype = as.factor(Subtype)
		)
	
	# 计算显著性标记
	p_values <- sapply(pathway_list, function(p) {
		wilcox.test(Score ~ Subtype, data = filter(plot_data, Pathway == p))$p.value
	})
	
	sig_labels <- ifelse(p_values < 0.001, "***",
											 ifelse(p_values < 0.01, "**",
											 			 ifelse(p_values < 0.05, "*", "")))
	
	# 创建精美绘图
	p <- ggplot(plot_data, aes(x = Pathway, y = Score, fill = Subtype)) +
		# 添加组间分隔线（竖虚线）
		geom_vline(
			xintercept = seq(1.5, length(pathway_list) - 0.5),
			color = "gray70",
			linetype = "dashed",
			linewidth = 0.5
		) +
		# 小提琴图 - 使用半边效果
		gghalves::geom_half_violin(
			aes(fill = Subtype),
			position = position_dodge(0.8),
			side = "l", 
			scale = "width",
			width = 0.7,
			alpha = 0.5,
			color = NA
		) +
		# 箱线图 - 带缺口
		geom_boxplot(
			aes(color = Subtype),
			width = 0.3,
			position = position_dodge(0.8),
			outlier.shape = NA,
			notch = TRUE,
			notchwidth = 0.5,
			alpha = 0.8,
			linewidth = 0.6
		) +
		# 抖动点 - 半透明
		geom_point(
			aes(color = Subtype),
			position = position_jitterdodge(jitter.width = 0.15, dodge.width = 0.8),
			size = 0.4,
			alpha = 0.4
		) +
		# 显著性标记
		geom_text(
			data = data.frame(Pathway = pathway_list, label = sig_labels),
			aes(x = Pathway, y = max(plot_data$Score) * 1.15, label = label),
			size = 5, 
			vjust = 0.5,
			fontface = "bold",
			inherit.aes = FALSE
		) +
		# 颜色方案
		scale_fill_manual(
			values = c("3" = "#E64B35", "1" = "#4DBBD5"),
			name = "Group"
		) +
		scale_color_manual(
			values = c("3" = "#B71C1C", "1" = "#006064"),
			name = "Group",
			guide = "none"
		) +
		# 标签和标题
		labs(
			title = title,
			x = "",
			y = "Pathway Activity Score"
		) +
		# 主题设置
		theme_minimal(base_size = 13) +
		theme(
			axis.text.x = element_text(
				angle = 45, 
				hjust = 1, 
				face = "bold", 
				size = 11,
				color = "#333333"
			),
			axis.text.y = element_text(
				face = "bold",
				size = 11,
				color = "#333333"
			),
			axis.title.y = element_text(
				face = "bold",
				size = 12,
				margin = margin(r = 10)
			),
			plot.title = element_text(
				hjust = 0.5, 
				size = 16, 
				face = "bold",
				margin = margin(b = 8)
			),
			plot.subtitle = element_text(
				hjust = 0.5, 
				size = 12, 
				color = "#666666",
				margin = margin(b = 15)
			),
			legend.position = "top",
			legend.title = element_text(face = "bold", size = 12),
			legend.text = element_text(size = 11),
			panel.grid.major.y = element_line(color = "grey92", linewidth = 0.6),
			panel.grid.minor.y = element_blank(),
			panel.grid.major.x = element_blank(),
			panel.grid.minor.x = element_blank(),
			panel.background = element_rect(fill = "white", color = NA),
			plot.background = element_rect(fill = "white", color = NA),
			panel.border = element_rect(color = "grey80", fill = NA, linewidth = 0.8),
			plot.margin = margin(15, 15, 15, 15)
		) +
		# 坐标轴范围
		coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score) * 1.2))
	
	return(p)
}
