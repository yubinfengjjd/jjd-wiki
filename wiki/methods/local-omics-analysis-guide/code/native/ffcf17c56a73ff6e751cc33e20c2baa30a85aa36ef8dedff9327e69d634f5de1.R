plot_ptm_bubble <- function(seurat_obj, sample_name) {
	# 获取metadata数据
	meta_df <- seurat_obj@meta.data
	
	# 提取Structure列和所有PTM评分列
	ptm_cols <- names(gene_sets)[names(gene_sets)%in%colnames(meta_df)]
	plot_df <- meta_df %>%
		dplyr::select(Structure, all_of(ptm_cols)) %>%
		pivot_longer(
			cols = -Structure,
			names_to = "Pathway",
			values_to = "Score"
		)
	
	# 计算每个通路-结构的平均评分
	agg_df <- plot_df %>%
		group_by(Structure, Pathway) %>%
		summarise(Avg_Score = mean(Score, na.rm = TRUE), .groups = "drop")
	
	# 计算每个通路的全局平均分（用于排序）
	pathway_global_avg <- agg_df %>%
		group_by(Pathway) %>%
		summarise(Global_Avg = mean(Avg_Score, na.rm = TRUE), .groups = "drop")
	
	# 将全局平均分合并到agg_df中
	agg_df <- agg_df %>%
		left_join(pathway_global_avg, by = "Pathway")
	
	# 选择评分最高的前20个通路（按全局平均分排序）
	top_pathways <- pathway_global_avg %>%
		arrange(desc(Global_Avg)) %>%
		head(20) %>%
		pull(Pathway)
	
	# 过滤数据
	filtered_df <- agg_df %>%
		filter(Pathway %in% top_pathways)
	
	# 创建美观的气泡图
	p <- ggplot(filtered_df, aes(x = Structure, y = reorder(Pathway, Global_Avg))) +
		# 添加气泡点
		geom_point(
			aes(size = Avg_Score, fill = Avg_Score),
			shape = 21,           # 使用带轮廓的圆点
			color = "black",      # 轮廓颜色
			stroke = 0.3,         # 轮廓粗细
			alpha = 0.9           # 透明度
		) +
		# 设置尺寸比例
		scale_size_continuous(
			name = "Average Score",
			range = c(3, 10),
			breaks = seq(0, max(filtered_df$Avg_Score), length.out = 5),
			limits = c(0, max(filtered_df$Avg_Score))
		) +
		# 设置填充颜色渐变
		scale_fill_gradientn(
			name = "Average Score",
			colors = c("#4575B4", "#74ADD1", "#FFFFBF", "#F46D43", "#D73027"),  # 蓝-青-黄-橙-红
			breaks = seq(0, max(filtered_df$Avg_Score), length.out = 5),
			limits = c(0, max(filtered_df$Avg_Score))
		) +
		# 坐标轴和标题
		labs(
			x = "Spatial Structure",
			y = "PTM Pathway",
			title = paste("PTM Pathway Activity in", sample_name),
			subtitle = "Bubble size and color indicate pathway activity score"
		) +
		# 使用经典主题作为基础
		theme_classic(base_size = 12) +
		# 自定义主题元素
		theme(
			# 坐标轴文本
			axis.text.x = element_text(
				angle = 45,
				hjust = 1,
				vjust = 1,
				size = 10,
				face = "bold"
			),
			axis.text.y = element_text(
				size = 10,
				face = "bold"
			),
			# 坐标轴标题
			axis.title.x = element_text(
				size = 12,
				face = "bold",
				margin = margin(t = 10)
			),
			axis.title.y = element_text(
				size = 12,
				face = "bold",
				margin = margin(r = 10)
			),
			# 图例
			legend.position = "right",
			legend.title = element_text(face = "bold"),
			legend.text = element_text(size = 9),
			# 标题居中
			plot.title = element_text(
				hjust = 0.5,
				face = "bold",
				size = 14,
				margin = margin(b = 10)
			),
			plot.subtitle = element_text(
				hjust = 0.5,
				size = 11,
				margin = margin(b = 15)
			),
			# 绘图区域
			panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
			# 移除背景网格（确保没有网格线）
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			# 绘图边距
			plot.margin = margin(20, 20, 20, 20)
		) +
		# 添加坐标轴线（确保坐标轴可见）
		coord_cartesian(clip = "off") +
		# 添加参考线（可选）
		geom_hline(
			yintercept = seq(0.5, length(top_pathways) + 0.5),
			color = "grey90",
			linewidth = 0.2
		)
	
	return(list(plot = p, agg_df = agg_df))
}
