library(dplyr)
library(tidyverse)
library(GSEABase)
library(GSVA)       # 通路富集分析
library(data.table)
library(SummarizedExperiment)
setwd("D:\\哮喘乳酸化单细胞开篇\\10.MBDs评分")
rm(list = ls())
main_gene = data.table::fread("./output_mRNA_selected.txt")
rt = data.table::fread("./MBDS.xls")
rt = rt %>% 
	dplyr::select(avg_log2FC,id) %>% 
	column_to_rownames("id")
data = rt[main_gene$x,,drop = F]

up_ragulate = rownames(data)[which(data$avg_log2FC > 0)]
down_ragulate = rownames(data)[which(data$avg_log2FC < 0)]
gene_sets = list("PTMD_up" = up_ragulate,
								 "PTMD_down" = down_ragulate)
load(file.path("D:\\哮喘乳酸化单细胞开篇\\6.一致性聚类","Cluster.Rdata"))
exp <- oc_subset@assays$RNA$data

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
# 执行GSVA分析
gsva_results <- ssgseaParam(
	exp, 
	gsc,normalize = F
)

result <- gsva(gsva_results)
result <- t(scale(t(result)))
# 提取评分结果
scores <- t(result)  # 转置为样本×基因集
# 计算PTMDs评分 = PTMD_up - PTMD_down
scores_df <- as.data.frame(scores) %>%
	mutate(PTMDs = PTMD_up)
#####可视化#####
# 提取Seurat对象中的Scoreing列和Subtype列
plot_data <- data.frame(scores_df$PTMDs,
												oc_subset$subtypes)
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
	geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.7, color = NA) +
	geom_boxplot(aes(fill = Subtype), 
							 width = 0.3, 
							 position = position_dodge(0.9),
							 outlier.shape = NA,
							 color = "black",
							 size = 1,       # Bold box outline
							 notch = TRUE) +  # 添加箱式图描边
	geom_text(
		aes(x = 1.5, y = max(plot_data$Scoreing)*1.1, label = sig_label),
		size = 5, vjust = -0.5
	) +
	scale_fill_manual(values = c("MBC1"="#acd5ab", "MBC2"="#feadac")) +
	labs(x = "Subtype", y = "LMBCS") +
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
ggsave("Subtype_MBDS.pdf", width = 6, height = 6)

plot_data <- data.frame(scores_df$PTMDs,
												oc_subset$phenotype)
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
	geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.7, color = NA) +
	geom_boxplot(aes(fill = Subtype), 
							 width = 0.3, 
							 position = position_dodge(0.9),
							 outlier.shape = NA,
							 color = "black",
							 size = 1,       # Bold box outline
							 notch = TRUE) +  # 添加箱式图描边
	geom_text(
		aes(x = 1.5, y = max(plot_data$Scoreing)*1.1, label = sig_label),
		size = 5, vjust = -0.5
	) +
	scale_fill_manual(values = c("ANA"="#acd5ab", "AA"="#feadac")) +
	labs(x = "Phenotype", y = "LMBCS") +
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
ggsave("Phenotype_MBDS.pdf", width = 6, height = 6)

#####测试集评分####
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
		gsc, normalize = FALSE
	)
	result <- gsva(gsva_results)
	result <- t(scale(t(result)))
	# 提取评分结果
	scores <- t(result)  # 转置为样本×基因集
	# 计算PTMDs评分 = PTMD_up - PTMD_down
	scores_df <- as.data.frame(scores) %>%
		mutate(PTMDs = PTMD_up)
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

# 批量处理nor目录下所有txt文件 -----------------------------------------
list.files(path = "./nor", 
					 pattern = "\\.txt$", 
					 full.names = TRUE) %>%
	walk(process_single_file)

#####相关性####
library(clusterProfiler)
library(GSVA)
library(GSEABase)
library(org.Hs.eg.db)
library(KEGGREST)
kegg_pathways <- list(
	"Th1_Th2_diff" = "hsa04658",     # Th1 and Th2 cell differentiation
	"NFKB" = "hsa04064",             # NF-kappa B signaling pathway
	"JAK_STAT" = "hsa04630"          # JAK-STAT signaling pathway
)


gene_sets <- list()

for (name in names(kegg_pathways)) {
	pathway_id <- kegg_pathways[[name]]
	pathway <- keggGet(pathway_id)[[1]]
	genes <- pathway$GENE
	
	# 提取Symbol（偶数位置，格式为 "EntrezID; Symbol"）
	symbols <- genes[seq(2, length(genes), by = 2)]  # 改为偶数位置
	symbols <- gsub(";.*", "", symbols)              # 移除可能的分隔符和附加信息
	symbols <- as.character(na.omit(symbols))        # 去除非符号内容
	
	gene_sets[[name]] <- symbols
}


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

gsva_results <- ssgseaParam(
	as.matrix(exp), 
	gsc,minSize = 5,normalize = F
)

result <- gsva(gsva_results)
result_scaled <- t(scale(t(result)))

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

# 创建保存图像的文件夹
if (!dir.exists("cor")) {
	dir.create("cor")
}

# 循环遍历每个通路与PTMDs进行相关性分析
for (pathway_name in names(kegg_pathways)) {
	
	# 提取通路的GSVA结果
	pathway_scores <- result_scaled[pathway_name, ]
	
	# 创建数据框
	data <- data.frame(
		LMBDs = scores_df$PTMDs,
		Pathway_Score = pathway_scores
	)
	
	# 为了避免列名冲突，将y_col设为当前的通路名
	colnames(data) <- c("LMBDs", pathway_name)
	
	# 调用函数进行绘图
	plot <- plot_with_statistics(data, 
															 x_col = "LMBDs", 
															 y_col = pathway_name, 
															 show_fit_line = TRUE)
	
	# 保存每个通路的图像到cor文件夹
	ggsave(paste0("cor/cor_", pathway_name, ".pdf"), plot = plot, width = 6, height = 6)
}