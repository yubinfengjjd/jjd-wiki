#####箱式图####
library(ggplot2)
library(tidyr)
library(ggsci)
library(ggpubr)
library(tibble)
library(tidyverse)
setwd("D:\\哮喘乳酸化单细胞开篇\\12.箱式图")
gene_list_file <- "./maingene.txt"    # 基因列表文件路径
datasets <- c(                            # 定义要分析的数据集
	"GSE43696" = "./GSE43696.normalize.txt",
	"GSE63142" = "./GSE63142.normalize.txt"
)
output_dir <- "Results"                   # 结果输出目录
control_suffix <- "control"               # 对照组样本后缀
treat_suffix <- "treat"                   # 处理组样本后缀
color_palette <- c("#2874C5", "#EABF00")  # 颜色设置（对照，处理）

#------------------[函数定义区域]------------------
#' 数据预处理函数
preprocess_data <- function(expFile){
	rt <- read.table(file.path("nor", expFile), sep = "\t", header = T, check.names = F)
	exp <- as.matrix(rt[, -1])
	rownames(exp) <- rt[, 1]
	return(exp)
}

#------------------[可视化函数（新版样式）]------------------
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


#------------------[主程序执行区域]------------------
# 加载必要包
suppressPackageStartupMessages({
	library(tidyr)
	library(ggplot2)
	library(dplyr)
})

# 读取基因列表
gene_list <- read.table(gene_list_file)$V1 %>% as.character()

# 主循环处理每个数据集
for(dataset_name in names(datasets)){
	# 数据预处理
	exp_data <- preprocess_data(datasets[dataset_name])
	
	# 筛选目标基因
	target_genes <- intersect(gene_list, rownames(exp_data))
	
	# 转换数据格式
	plot_data <- exp_data[target_genes, , drop = F] %>% 
		as.data.frame() %>% 
		tibble::rownames_to_column("gene") %>% 
		pivot_longer(-gene, names_to = "sample", values_to = "count") %>% 
		mutate(
			type = case_when(
				grepl(paste0("_", control_suffix, "$"), sample) ~ "control",
				grepl(paste0("_", treat_suffix, "$"), sample) ~ "treat",
				TRUE ~ NA_character_
			)
		) %>% 
		filter(!is.na(type))  # 移除未分类样本
	
	# 生成每个基因的图表
	for(gene in unique(plot_data$gene)){
		gene_data <- filter(plot_data, gene == !!gene)
		generate_plot(gene_data, gene, dataset_name, color_palette)
	}
}

# 提示信息
message("\n[运行状态] 分析已完成！结果保存至：", 
				normalizePath(output_dir), "\n")