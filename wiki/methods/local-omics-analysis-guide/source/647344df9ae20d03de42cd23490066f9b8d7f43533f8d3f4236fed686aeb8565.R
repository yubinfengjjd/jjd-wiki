library(cowplot)
library(dplyr)
library(data.table)
library(tidyverse)
library(paletteer)
library(vcd)
library(limma)
library(gplots)
library(Seurat)
library(clustree)
library(ggplot2)
library(reshape2)
library(dplyr)
library(monocle)
library(RColorBrewer)
library(ggpubr)
library(ggsignif)
library(patchwork)
library(tidydr)
library(ggforce)
library(ggrastr)
library(viridis)
library(gridExtra)
library(ggnewscale)
library(org.Mm.eg.db)
library(ComplexHeatmap)
library(ClusterGVis)
library(monocle)
library(Seurat)
rm(list = ls())
setwd("D:\\UC-20种修饰\\17.基因功能探究")
UC_subset <- subset(UC,subset = celltype == "Epithelial") %>% NormalizeData() %>%
	FindVariableFeatures(selection.method = "vst" ,nfeatures = 1500 ,verbose = T)
UC_subset$group <- ifelse(
	UC_subset@assays$RNA$counts["UBE2L6", ] > median(UC_subset@assays$RNA$counts["UBE2L6", ]),
	"UBE2L6high Epithelial",
	"UBE2L6low Epithelial")
table(UC_subset$group)
#####UBE2L6_UMAP图绘制####
library(SCP)
table(UC$celltype)
UC[["RNA"]] <- as(object = UC[["RNA"]], Class = "Assay")
pdf(file="UBE2L6_DIM.pdf", width=6, height=6)
FeatureDimPlot(UC,
							 features = "UBE2L6", reduction = "umap", label = TRUE,
							 cells.highlight = colnames(UC)[UC$celltype == "Epithelial"]
)
dev.off()
pdf(file="UBE2L6_vio.pdf", width=12, height=6)
FeatureStatPlot(
	srt = UC, 
	group.by = "celltype",
	stat.by = c("UBE2L6"), 
	add_box = TRUE)
dev.off()

#####基因差异表达小提琴图####
output_dir <- "MetaAnalysis_Results"
type_groups <- c("UC", "HC")
color_scheme <- c("#b71b23", "#0c695e")
plot_data <- UC@meta.data %>% 
	rownames_to_column("CellID") %>% 
	filter(phenotype %in% type_groups) %>%
	mutate(Group = factor(phenotype, levels = type_groups)) %>% 
	dplyr::select(CellID, Group, celltype) %>% 
	mutate(Expression = UC@assays$RNA$data["UBE2L6",])

#统计学检验
# 按celltype分组计算统计量
stat_data <- plot_data %>%
	group_by(celltype) %>%  # 按细胞类型分组
	summarise(
		p_value = wilcox.test(Expression ~ Group)$p.value,  # 组间比较
		y_max = max(Expression) * 1.1,  # 自动计算标注高度
		.groups = "drop"
	) %>%
	mutate(
		p_label = ifelse(p_value < 0.001, 
										 "***P < 0.001", 
										 paste0("*P = ", signif(p_value, 3)))
	)

# 计算均值和标准差
mean_sd <- plot_data %>%
	group_by(celltype, Group) %>%  # 按细胞类型和组别分组
	summarise(
		mean = mean(Expression, na.rm = TRUE),
		sd = sd(Expression, na.rm = TRUE),
		y_pos = quantile(Expression, 0.95),  # 自动定位到小提琴图上部
		.groups = "drop"
	) %>%
	mutate(label = sprintf("Mean: %.2f\nSD: %.2f", mean, sd))

ggplot(plot_data, aes(x = celltype, y = Expression)) +  # x轴改为celltype
	# 小提琴图
	geom_violin(aes(fill = Group), 
							position = position_dodge(0.8),
							width = 0.7, 
							alpha = 0.5, 
							trim = FALSE) +
	# 箱线图
	geom_boxplot(aes(group = interaction(celltype, Group)),  # 按细胞类型和组别分组
							 position = position_dodge(0.8),
							 width = 0.2,
							 outlier.shape = NA,
							 alpha = 0.8) +
	# 数据点
	geom_jitter(aes(color = Group),
							position = position_jitterdodge(jitter.width = 0.2, 
																							dodge.width = 0.8),
							size = 0.8, 
							alpha = 0.3) +
	# 显著性标注
	geom_text(data = stat_data,
						aes(x = celltype, y = y_max, label = p_label),  # x轴对应celltype
						size = 4.5, 
						vjust = -0.5,
						inherit.aes = FALSE) +
	# 均值和标准差标注
	geom_text(data = mean_sd,
						aes(x = celltype, y = y_pos, 
								label = label, group = Group),
						position = position_dodge(0.8),
						size = 3,
						color = "black",
						vjust = 0) +
	# 颜色设置
	scale_fill_manual(values = color_scheme) +
	scale_color_manual(values = color_scheme) +
	# 坐标轴标签
	labs(title = "Expression Comparison Across Cell Types",
			 y = "Pathway Combined Score",
			 x = "Cell Types") +  # 修改x轴标签
	# 主题设置
	theme_classic(base_size = 14) +
	theme(
		plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
		axis.text.x = element_text(angle = 30, hjust = 1, size = 14),
		axis.text.y = element_text(size = 11),
		legend.position = "top",
		legend.title = element_blank(),
		panel.grid.major.y = element_line(color = "grey90", linewidth = 0.3),
		plot.margin = margin(1, 1, 1, 1, "cm")
	) +
	# 调整坐标轴范围
	scale_y_continuous(expand = expansion(mult = c(0.05, 0.2)))

ggsave(filename = file.path(output_dir, "CellType_Scoreing_Comparison.pdf"),
			 width = 16, 
			 height = 7,
			 dpi = 300)

#####扰动分析####
library(stringr)
library(Seurat)
library(Augur)
library(dplyr)
library(patchwork)
library(viridis)
library(qs)
library(BiocParallel)

#根据基因表达分为高低表达组
table(UC$group)

augur<-calculate_auc(UC,
										 cell_type_col="celltype",
										 label_col="group")
# 加载必要的包
library(ggplot2)
library(dplyr)
library(viridis)

# 提取Augur结果数据
augur_results <- augur$AUC

# 数据预处理：按AUC降序排序，添加显著性标签
augur_data <- augur_results %>%
	arrange(desc(auc)) %>%
	mutate(
		cell_type = factor(cell_type, levels = cell_type)
	)

# 自定义颜色梯度
color_palette <- viridis::viridis(n = nrow(augur_data))

# 绘制美化版条形图
# 绘制美化版条形图
p <- ggplot(augur_data, aes(x = cell_type, y = auc, fill = cell_type)) +
	geom_bar(stat = "identity", width = 0.7, alpha = 0.85) +
	geom_hline(yintercept = 0.5, linetype = "dashed", color = "darkred", size = 0.8) +
	scale_fill_manual(values = color_palette) +
	labs(
		title = "Cell type disturbances",
		x = "celltype",
		y = "AUC",
	) +
	theme_minimal(base_size = 14) +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
		axis.text.y = element_text(face = "bold"),
		axis.title = element_text(face = "bold", size = 14),
		plot.title = element_text(face = "bold", hjust = 0.5, size = 18),
		plot.subtitle = element_text(hjust = 0.5, color = "gray30"),
		plot.caption = element_text(hjust = 0, color = "gray40"),
		panel.grid.major.x = element_blank(),
		legend.position = "none",
		# 添加坐标轴线 (仅修改部分)
		axis.line = element_line(color = "black", size = 0.5)  # 新增坐标轴线
	) +
	ylim(0, max(augur_data$auc) * 1.15) +
	# 添加坐标轴刻度线 (仅修改部分)
	scale_y_continuous(expand = c(0, 0))  # 确保坐标轴从原点开始

# 显示图形
print(p)

# 保存高质量图片
ggsave("augur_barplot.pdf", plot = p, width = 12, height = 8, dpi = 300)
#####基因表达量与乳酸化相关性点图#####
library(readxl)
library(ggplot2)

# 从Excel文件读取PTM基因集
ptm_data <- read_excel("inline-supplementary-material-2.xlsx", sheet = "Sheet1", skip = 1)

# 构建基因集列表
gene_sets <- list()
for (ptm in colnames(ptm_data)) {
	genes <- ptm_data[[ptm]]
	genes <- na.omit(genes)
	genes <- as.character(genes)
	genes <- genes[genes != "" & !grepl("^\\d{4}-\\d{2}-\\d{2}", genes)]
	genes <- toupper(genes)
	if (length(genes) > 0) {
		gene_sets[[ptm]] <- genes
	}
}

cor_results <- data.frame(
	PTM = character(),
	Correlation = numeric(),
	P_value = numeric(),
	stringsAsFactors = FALSE
)

# 循环处理每个PTM基因集
for (ptm in names(gene_sets)) {
	# 检查当前PTM是否在UC_subset中存在
	if (!ptm %in% colnames(UC_subset@meta.data)) {
		warning(paste("Column", ptm, "not found in UC_subset. Skipping."))
		next
	}
	
	# 创建数据框
	data <- data.frame(
		Expression = UC_subset@assays$RNA$data["UBE2L6",],
		Score = UC_subset@meta.data[[ptm]],
		Phenotype = UC_subset$phenotype
	)
	colnames(data) <- c("Expression", "Score", "Phenotype")
	
	# 确保State是因子
	data$Phenotype <- as.factor(data$Phenotype)
	
	# 计算Spearman相关性
	cor_test <- cor.test(data$Expression, data$Score, method = "spearman")
	cor_value <- round(cor_test$estimate, 3)
	p_value <- round(cor_test$p.value, 5)
	
	# 添加到结果数据框
	cor_results <- rbind(cor_results, data.frame(
		PTM = ptm,
		Correlation = cor_value,
		P_value = p_value
	))
	
	# 创建安全文件名
	safe_filename <- gsub("[^[:alnum:]_]", "_", ptm)
	pdf_file <- paste0("cor_Expression_", safe_filename, ".pdf")
	
	# 生成标注文本
	cor_label <- paste0("cor = ", cor_value, "\n", "p = ", format.pval(p_value, digits = 3))
	
	p <- ggplot(data, aes(x = Expression, y = Score, color = Phenotype)) +
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
		annotate("text",
						 x = min(data$Expression) + 0.05 * diff(range(data$Expression)),
						 y = max(data$Score) - 0.05 * diff(range(data$Score)),
						 label = cor_label, hjust = 0, color = "black", size = 5) +
		labs(
			title = paste("Expression vs.ptm"),
			x = "Expression of UBE2L6",
			y = ptm
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
	ggsave(pdf_file, p, width = 7, height = 7, dpi = 300)
}
write.table(cor_results, file = "cor_results.xls", sep = "\t", quote = F, col.names = T,row.names = F)
#####差异修饰通路可视化####
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)
library(ggforce)
library(gghalves)

# 整理数据
plot_data <- UC_subset@meta.data[colnames(UC_subset@meta.data) %in% names(gene_sets)] %>%
	mutate(subtypes = UC_subset$group)

plot_data <- plot_data %>%
	pivot_longer(
		cols = -subtypes,
		names_to = "Pathway",
		values_to = "Score"
	) %>%
	mutate(
		Subtype = as.factor(subtypes),
		Pathway = as.factor(Pathway)
	)

# 计算显著性
calc_p_value <- function(data) {
	test <- wilcox.test(Score ~ Subtype, data = data)
	p_value <- test$p.value
	sig_label <- case_when(
		p_value < 0.001 ~ "***",
		p_value < 0.01 ~ "**",
		p_value < 0.05 ~ "*",
		TRUE ~ ""
	)
	return(data.frame(p_value = p_value, sig_label = sig_label))
}

p_values <- plot_data %>%
	group_by(Pathway) %>%
	group_modify(~ calc_p_value(.x)) %>%
	ungroup()

# 合并p值信息
plot_data <- plot_data %>%
	left_join(p_values, by = "Pathway")

# 仅保留显著通路（p < 0.05）
signif_pathways <- p_values %>%
	filter(p_value < 0.05) %>%
	pull(Pathway)

plot_data <- plot_data %>%
	filter(Pathway %in% signif_pathways)

# 判断上调方向
mean_scores <- plot_data %>%
	group_by(Pathway, Subtype) %>%
	summarise(mean_score = mean(Score), .groups = 'drop') %>%
	pivot_wider(names_from = Subtype, values_from = mean_score)

group1 <- levels(plot_data$Subtype)[1]
group2 <- levels(plot_data$Subtype)[2]

up_group1 <- mean_scores %>%
	filter(!!sym(group1) > !!sym(group2)) %>%
	pull(Pathway)

up_group2 <- mean_scores %>%
	filter(!!sym(group2) > !!sym(group1)) %>%
	pull(Pathway)

# 合并上调通路
plot_data <- plot_data %>%
	filter(Pathway %in% c(up_group1, up_group2))

# 保留显著性标签位置数据
sig_label_df <- plot_data %>%
	group_by(Pathway) %>%
	summarise(
		y_pos = max(Score) * 1.05,
		sig_label = unique(sig_label),
		.groups = "drop"
	)

# 保证通路显示顺序
plot_data$Pathway <- factor(plot_data$Pathway, levels = unique(plot_data$Pathway))

# 绘图
ggplot(plot_data, aes(x = Pathway, y = Score, fill = Subtype)) +
	geom_jitter(
		aes(color = Subtype),
		position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.6),
		alpha = 0.6,
		size = 0.5,
		show.legend = FALSE
	) +
	geom_half_violin(
		side = "r",
		position = position_dodge(width = 0.6),
		alpha = 0.7,
		color = NA,
		trim = FALSE
	) +
	geom_half_boxplot(
		side = "r",
		position = position_dodge(width = 0.6),
		width = 0.15,
		outlier.shape = NA,
		color = "black",
		alpha = 0.7
	) +
	geom_text(
		data = sig_label_df,
		aes(x = Pathway, y = y_pos, label = sig_label),
		inherit.aes = FALSE,
		size = 5,
		vjust = 0
	) +
	scale_fill_manual(values = c(
		"UBE2L6low Epithelial" = "#2c5ca0",
		"UBE2L6high Epithelial" = "#88b36e"
	)) +
	scale_color_manual(values = c(
		"UBE2L6low Epithelial" = "#2c5cb0",
		"UBE2L6high Epithelial" = "#88b34e"
	)) +
	labs(x = "Pathway", y = "Score") +
	theme_classic() +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 10),
		axis.title = element_text(face = "bold", size = 12),
		strip.text = element_text(face = "bold", size = 12),
		strip.background = element_blank(),
		legend.position = "top",
		panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
		panel.spacing = unit(1, "lines")
	) +
	coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score) * 1.15))

ggsave("Filtered_Upregulated_with_Significance.pdf", width = 20, height = 6)
#####irGSEA####
library(RcppML)
library(irGSEA)
Idents(UC_subset)=UC_subset$group
# 基因集打分UC
pbmc3k.final3=UC_subset
DefaultAssay(UC_subset) <- "RNA"  
pbmc3k.final3 <- SeuratObject::UpdateSeuratObject(object = UC_subset)
pbmc3k.final3 <- irGSEA.score(object = pbmc3k.final3,assay = "RNA",
															slot = "data", seeds = 123, ncores = 1,
															min.cells = 3, min.feature = 0,
															custom = F, geneset = NULL, msigdb = T, 
															species = "Homo sapiens", category = "H",  
															subcategory = NULL, geneid = "symbol",
															method = c("AUCell","UCell","singscore","ssgsea","viper"),
															aucell.MaxRank = NULL, ucell.MaxRank = NULL, 
															kcdf = 'Gaussian')
result.dge <- irGSEA.integrate(object = pbmc3k.final3,
															 group.by = "group",
															 method = c("AUCell","UCell","singscore","ssgsea","viper"))

pdf(file="heatmap.plot.H.pdf", width=12, height=6)
irGSEA.heatmap(object = result.dge,
							 method = "RRA",
							 show.geneset = NULL)
dev.off()

library(IOBR)
library(GSEABase)
signatures_list <- lapply(signature_metabolism, function(gs) {
	geneIds(gs)  # 提取基因名称
})
names(signatures_list) <- names(signatures_KEGG_metab)  # 保留基因集名称

pbmc3k.final3 <- irGSEA.score(object = pbmc3k.final3,assay = "RNA",
															slot = "data", seeds = 123, ncores = 1,
															min.cells = 3, min.feature = 0,
															custom = T, geneset = signature_metabolism, 
															subcategory = NULL, geneid = "symbol",
															method = c("AUCell","UCell","singscore","ssgsea","viper"),
															kcdf = 'Gaussian')

result.dge <- irGSEA.integrate(object = pbmc3k.final3,
															 group.by = "group",
															 method = c("AUCell","UCell","singscore","ssgsea", "viper"))
pdf(file="heatmap.plot_metabolism.pdf", width=12, height=6)
irGSEA.heatmap(object = result.dge,
							 method = "RRA",
							 show.geneset = NULL)
dev.off()