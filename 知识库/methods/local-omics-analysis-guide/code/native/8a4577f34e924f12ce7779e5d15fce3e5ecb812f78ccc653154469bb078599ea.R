generate_plot <- function(exp_matrix, gene, dataset_name, color_pal){
	# 创建结果目录
	dir.create(file.path(output_dir, dataset_name), showWarnings = FALSE, recursive = TRUE)
	
	# 构造比较组列表（可根据dataset_name自定义）
	my_comparisons <- list(
		c("control","treat")
	)
	
	# 统计学检验并获取p.value（留作 label）
	# stat_compare_means 会在图中自动执行 t.test
	# p_val <- wilcox.test(count ~ type, data = exp_matrix)$p.value
	
	# 开始绘图
	p <- ggplot(exp_matrix, aes(x = type, y = count, fill = type)) +
		scale_fill_manual(values = color_pal) +
		# 小提琴图
		geom_violin(
			alpha = 0.4,
			position = position_dodge(width = .75),
			size = 0.8,
			color = "black"
		) +
		# 带缺口的箱线图
		geom_boxplot(
			notch = TRUE,
			outlier.size = -1,
			lwd = 0.8,
			alpha = 0.7,
			color = "black",
			position = position_dodge(width = .75)
		) +
		# 散点（点状抖动）
		geom_point(
			aes(color = NULL),
			shape = 21,
			size = 2,
			color = "black",
			position = position_jitterdodge(dodge.width = .75)
		) +
		# 添加显著性标记
		stat_compare_means(
			method = "wilcox.test",      # 或 "t.test" 根据需要
			hide.ns = FALSE,
			comparisons = my_comparisons,
			label = "p.signif"
		) +
		# 坐标轴与主题
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
	
	# 保存图片
	ggsave(
		filename = file.path(output_dir, dataset_name, paste0(gene, "_", dataset_name, ".pdf")),
		plot     = p,
		width    = 8,
		height   = 6
	)
}
