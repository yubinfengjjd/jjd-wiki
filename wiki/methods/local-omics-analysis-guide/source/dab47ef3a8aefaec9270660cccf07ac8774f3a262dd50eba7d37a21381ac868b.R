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
setwd("D:\\哮喘乳酸化单细胞开篇\\17.RCC2基因功能探究")
mm <- subset(oc,subset = celltype == "AEC") %>% NormalizeData() %>%
	FindVariableFeatures(selection.method = "vst" ,nfeatures = 1500 ,verbose = T)
mm$group <- ifelse(
	mm@assays$RNA$counts["RCC2", ] > median(mm@assays$RNA$counts["RCC2", ]),
	"RCC2high AEC",
	"RCC2low AEC")
table(mm$group)
#####RCC2_UMAP图绘制####
library(SCP)
oc[["RNA"]] <- as(object = oc[["RNA"]], Class = "Assay")
pdf(file="RCC2_DIM.pdf", width=6, height=6)
FeatureDimPlot(oc,
							 features = "RCC2", reduction = "umap", label = TRUE,
							 cells.highlight = colnames(oc)[oc$celltype == "AEC"]
)
dev.off()
pdf(file="RCC2_vio.pdf", width=12, height=6)
FeatureStatPlot(
	srt = oc, 
	group.by = "celltype",
	stat.by = c("RCC2"), 
	add_box = TRUE)
dev.off()

#####基因差异表达小提琴图####
output_dir <- "MetaAnalysis_Results"
type_groups <- c("AA", "ANA")
color_scheme <- c("#b71b23", "#0c695e")
plot_data <- oc@meta.data %>% 
	rownames_to_column("CellID") %>% 
	filter(phenotype %in% type_groups) %>%
	mutate(Group = factor(phenotype, levels = type_groups)) %>% 
	dplyr::select(CellID, Group, celltype) %>% 
	mutate(Expression = oc@assays$RNA$data["RCC2",])

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

#####基因表达量与乳酸化相关性点图#####
library(IOBR)
data(signature_metabolism)
cor_results <- data.frame(
	PTM = character(),
	Correlation = numeric(),
	P_value = numeric(),
	stringsAsFactors = FALSE
)

# 循环处理每个PTM基因集
for (ptm in names(signature_metabolism)) {
	# 检查当前PTM是否在mm中存在
	if (!ptm %in% colnames(mm@meta.data)) {
		warning(paste("Column", ptm, "not found in mm. Skipping."))
		next
	}
	
	# 创建数据框
	data <- data.frame(
		Expression = mm@assays$RNA$data["RCC2",],
		Score = mm@meta.data[[ptm]],
		Phenotype = mm$phenotype
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
}
library(dplyr)
library(ggplot2)

# 1) 选出 |Correlation| 前三的通路
top3_ptms <- cor_results %>%
	filter(!is.na(Correlation)) %>%
	arrange(desc(abs(Correlation))) %>%
	slice_head(n = 3) %>%
	pull(PTM)

# 如需改用其它基因，换这里
gene_symbol <- "RCC2"

# 2) 循环绘图并保存
for (ptm in top3_ptms) {
	# 构建数据（与原先一致）
	data <- data.frame(
		Expression = as.numeric(mm@assays$RNA$data[gene_symbol, ]),
		Score      = mm@meta.data[[ptm]],
		Phenotype  = mm$phenotype
	)
	colnames(data) <- c("Expression", "Score", "Phenotype")
	data$Phenotype <- as.factor(data$Phenotype)
	data <- data[complete.cases(data), ]
	if (nrow(data) < 3) next
	
	# 从 cor_results 取对应的相关系数和 p 值（不再重复计算）
	rrow      <- cor_results[cor_results$PTM == ptm, , drop = FALSE]
	cor_value <- round(rrow$Correlation[1], 3)
	p_value   <- rrow$P_value[1]
	
	# 安全文件名 & 标注文本
	safe_filename <- gsub("[^[:alnum:]_]", "_", ptm)
	pdf_file      <- paste0("cor_Expression_", safe_filename, ".pdf")
	cor_label     <- paste0("cor = ", cor_value, "\n", "p = ", format.pval(p_value, digits = 3))
	
	# 注释位置（更稳健地处理 NA）
	ann_x <- min(data$Expression, na.rm = TRUE) + 0.05 * diff(range(data$Expression, na.rm = TRUE))
	ann_y <- max(data$Score,      na.rm = TRUE) - 0.05 * diff(range(data$Score,      na.rm = TRUE))
	
	# 画图
	p <- ggplot(data, aes(x = Expression, y = Score, color = Phenotype)) +
		geom_point(size = 3.5, alpha = 1) +
		geom_smooth(
			method = "lm",
			color  = "#5b82a0",
			linetype = "solid",
			size   = 3,            # 线更粗
			se     = TRUE,
			fill   = "#5a5676",
			alpha  = 0.3
		) +
		annotate("text", x = ann_x, y = ann_y,
						 label = cor_label, hjust = 0, color = "black", size = 5) +
		labs(
			title = paste("Expression vs.", ptm),
			x     = paste("Expression of", gene_symbol),
			y     = ptm
		) +
		theme_bw(base_size = 14) +
		theme(
			legend.position  = "none",
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			panel.border     = element_rect(color = "black", size = 1.2),
			plot.title       = element_text(hjust = 0.5, size = 16, face = "bold"),
			axis.title       = element_text(size = 14),
			axis.text        = element_text(size = 12)
		)
	
	# 只有两组时使用你自定义的两色；组数不为2就让 ggplot 自己配色，避免报错
	if (length(levels(data$Phenotype)) == 2) {
		p <- p + scale_color_manual(values = c("#0c695e", "#b81b23"))
	}
	
	# 保存
	ggsave(pdf_file, p, width = 7, height = 7, dpi = 300)
}

# 3) 仍然保存完整结果表
write.table(cor_results, file = "cor_results.xls",
						sep = "\t", quote = FALSE, col.names = TRUE, row.names = FALSE)

#####差异修饰通路可视化####
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)
library(ggforce)  # 用于绘制半边箱式/小提琴图
library(gghalves)
plot_data <- data.frame(mm$group, mm$GLYCOLYSIS_GLUCONEOGENESIS,
												mm$HIF_1_SIGNALING_PATHWAY,mm$LACTATE_DEHYDROGENASE_ACTIVITY,
												mm$LACTATE_METABOLIC_PROCESS)
colnames(plot_data) <- c("subtypes","GLYCOLYSIS_GLUCONEOGENESIS","HIF_1_SIGNALING_PATHWAY",
												 "LACTATE_DEHYDROGENASE_ACTIVITY","LACTATE_METABOLIC_PROCESS")

# 调整通路显示名称
plot_data <- plot_data %>%
	pivot_longer(
		cols = -subtypes,
		names_to = "Pathway",
		values_to = "Score"
	) %>%
	mutate(
		Subtype = as.factor(subtypes),
		Pathway = factor(Pathway, 
										 levels = c("GLYCOLYSIS_GLUCONEOGENESIS", "HIF_1_SIGNALING_PATHWAY",
										 					 "LACTATE_DEHYDROGENASE_ACTIVITY", "LACTATE_METABOLIC_PROCESS"),
										 labels = c("Glycolysis/Gluconeogenesis", "HIF-1 Signaling",
										 					 "LDH Activity (GO)", "Lactate Metabolism (GO)"))
	)

### 计算显著性标记（每个通路单独检验）-------------------------------
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

### 可视化 ------------------------------------------------------------

# 可视化
ggplot(plot_data, aes(x = Subtype, y = Score, fill = Subtype)) +
	# 左侧散点（抖动点）
	geom_jitter(
		aes(color = Subtype), 
		position = position_jitter(width = 0.1, height = 0.1),
		alpha = 0.6, 
		size = 1.5, 
		show.legend = FALSE
	) +
	# 右侧半小提琴图
	geom_half_violin(
		side = "r",        # 右侧显示
		alpha = 0.7, 
		color = NA, 
		trim = FALSE
	) +
	# 右侧半箱式图
	geom_half_boxplot(
		side = "r",        # 右侧显示
		width = 0.15, 
		outlier.shape = NA,
		color = "black", 
		alpha = 0.7
	) +
	# 显著性标记
	geom_text(
		data = p_values,
		aes(x = 1.5, y = max(plot_data$Score) * 1.1, label = sig_label),
		size = 5, vjust = -0.5, inherit.aes = FALSE
	) +
	# 分面显示三个通路
	facet_wrap(~ Pathway, nrow = 1, scales = "free_y") +
	# 颜色与主题调整
	scale_fill_manual(values = c("RCC2low AEC" = "#2c5ca0", "RCC2high AEC" = "#88b36e")) +
	scale_color_manual(values = c("RCC2low AEC" = "#2c5cb0", "RCC2high AEC" = "#88b34e")) +
	labs(x = "Subtype", y = "Score") +
	theme_classic() +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 10),
		axis.title = element_text(face = "bold", size = 12),
		strip.text = element_text(face = "bold", size = 12),
		strip.background = element_blank(),
		legend.position = "top",
		panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),  # 添加分面边框
		panel.spacing = unit(1, "lines")
	) +
	coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score) * 1.15))

ggsave("Combined_lactytation.pdf", width = 16, height = 8)
#####irGSEA####
library(RcppML)
library(irGSEA)
Idents(mm)=mm$group
# 基因集打分oc
pbmc3k.final3=mm
DefaultAssay(mm) <- "RNA"  
pbmc3k.final3 <- SeuratObject::UpdateSeuratObject(object = mm)
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


library(clusterProfiler)
library(GSVA)
library(GSEABase)
library(org.Hs.eg.db)
library(KEGGREST)
kegg_pathways <- list(
	"Th1_Th2_diff" = "hsa04658",     # Th1 and Th2 cell differentiation
	"NF_KappaB" = "hsa04064",             # NF-kappa B signaling pathway
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
exp = mm@assays$RNA$data
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
library(ggforce)  # 用于绘制半边箱式/小提琴图
library(gghalves)

### 数据准备 -----------------------------------------------------------
# 假设GSVA评分矩阵的列名已正确对应
plot_data <- data.frame(mm$group, t(result_scaled))
colnames(plot_data)[1] <- "subtypes"
plot_data <- plot_data %>%
	dplyr::select(subtypes,NF_KappaB, JAK_STAT,Th1_Th2_diff) %>%
	pivot_longer(
		cols = -subtypes,
		names_to = "Pathway",
		values_to = "Score"
	) %>%
	mutate(
		Subtype = as.factor(subtypes),
		Pathway = factor(Pathway, 
										 levels = c("Th1_Th2_diff", "NF_KappaB", "JAK_STAT"),
										 labels = c("Th1_Th2_diff", "NF_KappaB", "JAK-STAT"))
	)

### 计算显著性标记（每个通路单独检验）-------------------------------
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

### 可视化 ------------------------------------------------------------

# 可视化
ggplot(plot_data, aes(x = Subtype, y = Score, fill = Subtype)) +
	# 左侧散点（抖动点）
	geom_jitter(
		aes(color = Subtype), 
		position = position_jitter(width = 0.1, height = 0.1),
		alpha = 0.6, 
		size = 1.5, 
		show.legend = FALSE
	) +
	# 右侧半小提琴图
	geom_half_violin(
		side = "r",        # 右侧显示
		alpha = 0.7, 
		color = NA, 
		trim = FALSE
	) +
	# 右侧半箱式图
	geom_half_boxplot(
		side = "r",        # 右侧显示
		width = 0.15, 
		outlier.shape = NA,
		color = "black", 
		alpha = 0.7
	) +
	# 显著性标记
	geom_text(
		data = p_values,
		aes(x = 1.5, y = max(plot_data$Score) * 1.1, label = sig_label),
		size = 5, vjust = -0.5, inherit.aes = FALSE
	) +
	# 分面显示三个通路
	facet_wrap(~ Pathway, nrow = 1, scales = "free_y") +
	# 颜色与主题调整
	scale_fill_manual(values = c("RCC2low AEC" = "#acd5ab", "RCC2high AEC" = "#feadac")) +
	scale_color_manual(values = c("RCC2low AEC" = "#6a9662", "RCC2high AEC" = "#e67c73")) +
	labs(x = "Subtype", y = "GSVA Score") +
	theme_classic() +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 10),
		axis.title = element_text(face = "bold", size = 12),
		strip.text = element_text(face = "bold", size = 12),
		strip.background = element_blank(),
		legend.position = "top",
		panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),  # 添加分面边框
		panel.spacing = unit(1, "lines")
	) +
	coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score) * 1.15))

### 保存图片 ----------------------------------------------------------
ggsave("Subtype_GSVA_Scores_Modified.pdf", width = 10, height = 6)