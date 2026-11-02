process_single_file <- function(input_file) {
	# 数据读取 -----------------------------------------------------------
	exp <- data.table::fread(input_file, data.table = FALSE) %>%
		column_to_rownames("ID")
	
	# GSVA分析 ----------------------------------------------------------
	gsva_results <- ssgseaParam(
		as.matrix(exp), 
		gsc, normalize = FALSE
	)
	result <- gsva(gsva_results)
	result <- t(scale(t(result)))
	# 提取评分结果
	scores <- t(result)  # 转置为样本×基因集
	# 计算PTMDs评分 = PTMD_up - PTMD_down
	scores_df <- as.data.frame(scores) %>%
		mutate(PTMDs = PTMD_down - PTMD_up)
	# 数据准备 -----------------------------------------------------------
	Type <- gsub("(.*)_(.*)", "\\2", colnames(exp))
	plot_data <- data.frame(scores_df$PTMDs, Type)
	colnames(plot_data) <- c("Scoreing", "Subtype")
	plot_data$Subtype <- as.factor(plot_data$Subtype)
	
	# 计算显著性 --------------------------------------------------------
	p_value <- wilcox.test(Scoreing ~ Subtype, data = plot_data)$p.value
	sig_label <- ifelse(p_value < 0.001, "***",
											ifelse(p_value < 0.01, "**",
														 ifelse(p_value < 0.05, "*", "")))
	
	# 可视化 ------------------------------------------------------------
	p <- ggplot(plot_data, aes(x = Subtype, y = Scoreing)) +
		geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.4, color = NA) +
		geom_boxplot(aes(fill = Subtype), 
								 width = 0.3, 
								 position = position_dodge(0.9),
								 outlier.shape = NA,
								 color = "black",size = 1) +
		geom_text(
			aes(x = 1.5, y = max(plot_data$Scoreing)*1.1, label = sig_label),
			size = 5, vjust = -0.5
		) +
		scale_fill_manual(values = c("control"="#7aa3f2", "treat"="#ff9a24")) +
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
	
	# 生成输出文件名 -----------------------------------------------------
	output_name <- tools::file_path_sans_ext(basename(input_file)) %>%
		paste0(".pdf")
	
	# 保存图形 ----------------------------------------------------------
	ggsave(output_name, plot = p, width = 6, height = 6)
}
