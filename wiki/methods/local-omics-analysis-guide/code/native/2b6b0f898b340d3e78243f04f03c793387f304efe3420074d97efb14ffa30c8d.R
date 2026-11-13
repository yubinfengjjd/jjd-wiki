plot_with_statistics <- function(data, 
																 x_col = "Variable1", 
																 y_col = "Variable2", 
																 color_palette = c("#440154FF", "#3B528BFF", "#21908CFF", "#5DC863FF", "#FDE725FF"), 
																 show_fit_line = FALSE, 
																 text_size = 14, 
																 line_size = 0.5) {
	
	# 加载必要的包
	library(ggplot2)
	library(ggpubr)
	library(ggpointdensity)
	
	# 创建基础绘图对象
	p <- ggplot(data = data, 
							mapping = aes_string(x = x_col, y = y_col)) +
		# 添加点密度图层
		geom_pointdensity(size = 4) +
		# 设置颜色渐变
		scale_color_gradientn(colors = color_palette) +
		# 设置主题样式
		theme_classic(base_size = text_size) +
		# 添加轴标签
		labs(x = x_col, y = y_col) +
		# 自定义主题元素
		theme(
			axis.title = element_text(size = text_size, face = "bold"),  # 轴标题样式
			axis.text = element_text(size = text_size - 2, face = "bold")  # 轴刻度样式
		)
	
	# 如果需要显示拟合线和相关性统计信息
	if (show_fit_line) {
		p <- p +
			# 添加线性回归拟合线
			geom_smooth(method = "lm", formula = y ~ x, color = "black", size = line_size) +
			# 添加相关性统计信息
			stat_cor(
				method = "spearman",  # 使用Pearson相关性
				aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")),  # 格式化标签
				label.x = -1,  # 设置标签位置
				size = text_size / 2.8,  # 设置标签大小
				fontface = "bold"  # 设置标签字体样式
			)
	}
	
	# 返回最终的绘图对象
	return(p)
}
