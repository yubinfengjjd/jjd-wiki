library(clusterProfiler)
library(GSVA)
library(GSEABase)
library(org.Hs.eg.db)
rm(list = ls())
setwd("D:\\哮喘乳酸化单细胞开篇\\10.MBDs评分")
load(file.path("D:\\哮喘乳酸化单细胞开篇\\6.一致性聚类","Cluster.Rdata"))
gene_sets = data.table::fread("./intersectGenes.txt",data.table = F)[,1]
gene_sets = list(gene_sets)
names(gene_sets) = "MBDs"
# 创建GeneSetCollection对象
gsc <- GeneSetCollection(lapply(names(gene_sets), function(name) {
	# 创建GeneSet
	GeneSet(
		geneIds = gene_sets[[name]],
		collectionType = KEGGCollection(),
		setName = name,
		organism = "Homo sapiens"
	)
}))

exp = oc_subset@assays$RNA$data
gsva_results <- ssgseaParam(
	exp, 
	gsc,minSize = 5,normalize = F
)
result <- gsva(gsva_results)
result_scaled <- t(scale(t(result)))

library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)

### 数据提取与准备 -----------------------------------------------------------
# 提取Seurat对象中的Scoreing列和Subtype列
plot_data <- data.frame(t(result_scaled),oc_subset$subtypes)
colnames(plot_data)=c("Scoreing","Subtype")
# 确保Subtype是因子类型
plot_data$Subtype <- as.factor(plot_data$Subtype)

### 计算显著性标记 ----------------------------------------------------
# 使用Wilcoxon检验计算p值
p_value <- wilcox.test(Scoreing ~ Subtype, data = plot_data)$p.value

# 创建显著性标签
sig_label <- ifelse(p_value < 0.001, "***",
										ifelse(p_value < 0.01, "**",
													 ifelse(p_value < 0.05, "*", "")))

### 可视化 ------------------------------------------------------------

# 可视化
ggplot(plot_data, aes(x = Subtype, y = Scoreing)) +
	geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.7) +
	geom_boxplot(aes(fill = Subtype), 
							 width = 0.15, 
							 position = position_dodge(0.9),
							 outlier.shape = NA,
							 color = "black") +  # 添加箱式图描边
	geom_text(
		aes(x = 1.5, y = max(plot_data$Scoreing)*1.1, label = sig_label),
		size = 5, vjust = -0.5
	) +
	scale_fill_manual(values = c("MBC1"="#acd5ab", "MBC2"="#feadac")) +
	labs(x = "Subtype", y = "MBDs") +
	theme_classic() +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 8),
		plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
		legend.position = "top",
		panel.border = element_rect(color = "black", fill = NA),  # 添加边框
		panel.grid.major.y = element_line(color = "grey90")
	) +
	coord_cartesian(ylim = c(min(plot_data$Scoreing), max(plot_data$Scoreing)*1.15))

### 保存输出 -----------------------------------------------------------
ggsave("Subtype_MBDs.pdf", width = 6, height = 6)

#####ddd####
# 提取Seurat对象中的Scoreing列和Subtype列
plot_data <- data.frame(t(result_scaled),oc_subset$phenotype)
colnames(plot_data)=c("Scoreing","Subtype")
# 确保Subtype是因子类型
plot_data$Subtype <- as.factor(plot_data$Subtype)

### 计算显著性标记 ----------------------------------------------------
# 使用Wilcoxon检验计算p值
p_value <- wilcox.test(Scoreing ~ Subtype, data = plot_data)$p.value

# 创建显著性标签
sig_label <- ifelse(p_value < 0.001, "***",
										ifelse(p_value < 0.01, "**",
													 ifelse(p_value < 0.05, "*", "")))

### 可视化 ------------------------------------------------------------

# 可视化
ggplot(plot_data, aes(x = Subtype, y = Scoreing)) +
	geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.7) +
	geom_boxplot(aes(fill = Subtype), 
							 width = 0.15, 
							 position = position_dodge(0.9),
							 outlier.shape = NA,
							 color = "black") +  # 添加箱式图描边
	geom_text(
		aes(x = 1.5, y = max(plot_data$Scoreing)*1.1, label = sig_label),
		size = 5, vjust = -0.5
	) +
	scale_fill_manual(values = c("ANA"="#acd5ab", "AA"="#feadac")) +
	labs(x = "phenotype", y = "MBDs") +
	theme_classic() +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 8),
		plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
		legend.position = "top",
		panel.border = element_rect(color = "black", fill = NA),  # 添加边框
		panel.grid.major.y = element_line(color = "grey90")
	) +
	coord_cartesian(ylim = c(min(plot_data$Scoreing), max(plot_data$Scoreing)*1.15))

### 保存输出 -----------------------------------------------------------
ggsave("phenotype_MBDs.pdf", width = 6, height = 6)

#####相关性#####
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
		geom_pointdensity(size = 2) +
		# 设置颜色渐变
		scale_color_gradientn(colors = color_palette) +
		# 设置主题样式
		theme_classic(base_size = text_size) +
		# 添加轴标签
		labs(x = x_col, y = y_col) +
		# 自定义主题元素
		theme(
			legend.position = "none",  # 隐藏图例
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
				method = "pearson",  # 使用Pearson相关性
				aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")),  # 格式化标签
				label.x = -1,  # 设置标签位置
				size = text_size / 2.8,  # 设置标签大小
				fontface = "bold"  # 设置标签字体样式
			)
	}
	
	# 返回最终的绘图对象
	return(p)
}

data <- data.frame(
	t(result_scaled),
	oc_subset$Scoreing
)
colnames(data) = c("MBDs","Lactylation")
# 调用函数
plot_with_statistics(data, 
										 x_col = "MBDs", 
										 y_col = "Lactylation", 
										 show_fit_line = TRUE)
ggsave("cor_MBDs.pdf", width = 6, height = 6)

#####转录组评分####
library(tidyverse)
library(GSVA)
library(purrr)

# 定义处理单个文件的函数
process_single_file <- function(input_file) {
	# 数据读取 -----------------------------------------------------------
	exp <- data.table::fread(input_file, data.table = FALSE) %>%
		column_to_rownames("ID")
	
	# GSVA分析 ----------------------------------------------------------
	gsva_results <- ssgseaParam(
		as.matrix(exp), 
		gsc, minSize = 5, normalize = FALSE
	)
	result <- gsva(gsva_results)
	result_scaled <- t(scale(t(result)))
	
	# 数据准备 -----------------------------------------------------------
	Type <- gsub("(.*)_(.*)", "\\2", colnames(exp))
	plot_data <- data.frame(t(result_scaled), Type)
	colnames(plot_data) <- c("Scoreing", "Subtype")
	plot_data$Subtype <- as.factor(plot_data$Subtype)
	
	# 计算显著性 --------------------------------------------------------
	p_value <- wilcox.test(Scoreing ~ Subtype, data = plot_data)$p.value
	sig_label <- ifelse(p_value < 0.001, "***",
											ifelse(p_value < 0.01, "**",
														 ifelse(p_value < 0.05, "*", "")))
	
	# 可视化 ------------------------------------------------------------
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
	
	# 生成输出文件名 -----------------------------------------------------
	output_name <- tools::file_path_sans_ext(basename(input_file)) %>%
		paste0(".pdf")
	
	# 保存图形 ----------------------------------------------------------
	ggsave(output_name, plot = p, width = 6, height = 6)
}

# 批量处理nor目录下所有txt文件 -----------------------------------------
list.files(path = "./nor", 
					 pattern = "\\.txt$", 
					 full.names = TRUE) %>%
	walk(process_single_file)