analyze_module <- function(module) {
	column <- match(module, modNames)
	moduleGenes <- moduleColors == module
	module_genes <- dimnames(data.frame(datExpr))[[2]][moduleGenes]
	
	# 创建数据框
	c <- data.frame(
		MM = abs(geneModuleMembership[moduleGenes, column]),
		GS = abs(geneTraitSignificance[moduleGenes, 1]),
		row.names = module_genes
	)
	c$group <- ifelse(c$MM > 0.6 & c$GS > 0.2, TRUE, FALSE)
	
	# Spearman 相关性
	cor_result <- cor.test(c$MM, c$GS, method = "spearman", exact = FALSE)
	cor_label <- sprintf(
		"Spearman's rho = %.2f\np = %s",
		cor_result$estimate,
		ifelse(cor_result$p.value < 0.001, "< 0.001", format(cor_result$p.value, digits = 2))
	)
	
	p <- ggplot(c, aes(x = MM, y = GS, color = group)) +
		geom_point(size = 3.5, alpha = 1) +
		geom_smooth(
			method = "lm",
			color = "#5b82a0",        # 拟合线颜色
			linetype = "solid",     # 实线
			size = 3,             # 加粗线
			se = TRUE,              # 显示置信区间
			fill = "#5a5676",       # 置信区间颜色（可换）
			alpha = 0.3             # 置信区间透明度
		) +
		scale_color_manual(values = c("#0c695e", "#b81b23")) +
		geom_vline(xintercept = 0.6, linetype = "dotted", color = "grey60",size = 1.2) +
		geom_hline(yintercept = 0.2, linetype = "dotted", color = "grey60",size = 1.2) +
		annotate("text",
						 x = min(c$MM) + 0.05 * diff(range(c$MM)),
						 y = max(c$GS) - 0.05 * diff(range(c$GS)),
						 label = cor_label, hjust = 0, color = "black", size = 5) +
		labs(
			title = paste("Module Membership vs. Gene Significance -", module),
			x = paste("Module Membership (", module, ")", sep = ""),
			y = "Gene Significance for RA"
		) +
		theme_bw(base_size = 14) +
		theme(
			legend.position = "none",
			panel.grid.major = element_blank(),    # 去除主网格线
			panel.grid.minor = element_blank(),    # 去除次网格线
			panel.border = element_rect(color = "black", size = 1.2),  # 加粗边框
			plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
			axis.title = element_text(size = 14),
			axis.text = element_text(size = 12)
		)
	
	# 保存图像
	ggsave(paste0("MM_vs_GS_", module, ".pdf"), p, width = 7, height = 7, dpi = 300)
	
	# 返回符合条件的基因名
	rownames(c)[c$group]
}
