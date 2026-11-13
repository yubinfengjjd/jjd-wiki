# 加载必要的包
library(sva)        # 用于Combat批量校正
library(IOBR)       # 获取代谢通路基因集
library(GSVA)       # 通路富集分析
library(ConsensusClusterPlus) # 一致性聚类
library(Seurat)
data(signature_metabolism)
setwd("D:\\哮喘乳酸化单细胞开篇\\6.一致性聚类")
#gene=data.table::fread("./hdWGCNAgene.txt",header = F,data.table = F)[,1]
#exp = exp %>% column_to_rownames("ID")
# 转换为GSVA需要的列表格式
metabolic_genesets <- lapply(signature_metabolism, function(x) unlist(strsplit(x, split = ",")))
oc_subset <- subset(oc, subset = celltype == "Mono/Mac") %>% NormalizeData() %>%
	FindVariableFeatures(selection.method = "vst" ,nfeatures = 1500 ,verbose = T)
exp = as.matrix(oc_subset@assays$RNA$data)
Dim(exp)
################################
### 步骤4：GSVA通路富集分析 ###
################################
gsva_results <- ssgseaParam(
	exp, 
  metabolic_genesets,minSize = 5,normalize = F
)

result <- gsva(gsva_results)
result_scaled <- t(scale(t(result))) 
input = as.matrix(result_scaled)
summary(as.vector(input))
####################################
### 步骤5：一致性聚类确定亚型 ###
####################################
# 设置聚类参数
result_cluster <- ConsensusClusterPlus(
	d = input,
	maxK = 3,            # 指定最大聚类数
	reps = 1000,         # 重抽样次数
	pItem = 0.8,         # 每次抽样80%样本
	pFeature = 1,        # 使用全部特征
	clusterAlg = "pam",   # 层次聚类
	distance = "euclidean", # 使用Pearson距离
	seed = 123456,plot = 'pdf'
)
save(result_cluster,file = "result_cluster.Rdata")
# 提取聚类结果
cluster_assignment <- result_cluster[[2]]$consensusClass
oc_subset$subtypes <- ifelse(cluster_assignment == 1, "MBC1", "MBC2")
save(oc_subset,file = "Cluster.Rdata")
# 提取K=2的一致性矩阵（样本 × 样本）
consensus_matrix <- result_cluster[[2]]$consensusMatrix
colnames(consensus_matrix) <- rownames(consensus_matrix) <- colnames(input)

# 按聚类亚型排序样本
order_samples <- order(subtypes)
sorted_consensus <- consensus_matrix[order_samples, order_samples]
sorted_subtypes <- subtypes[order_samples]

library(pheatmap)

# 定义亚型注释颜色
annotation_colors <- list(
	Subtype = c(MBC1 = "#FF6F61", MBC2 = "#92A8D1")  # 自定义颜色
)

# 创建注释数据框
annotation_df <- data.frame(
	Subtype = sorted_subtypes,
	row.names = colnames(sorted_consensus)
)

# 绘制热图
pdf(file = "1.pdf",width = 6,height = 6)
pheatmap(
	mat = sorted_consensus,
	color = colorRampPalette(c("white", "#0072B2"))(100),  # 蓝白渐变
	cluster_rows = FALSE,  # 禁止行聚类（已手动排序）
	cluster_cols = FALSE,  # 禁止列聚类
	annotation_col = annotation_df,
	annotation_colors = annotation_colors,
	show_rownames = FALSE,  # 样本过多时隐藏名称
	show_colnames = FALSE,
	main = "Consensus Matrix for K=2 Clustering",
	gaps_col = cumsum(table(sorted_subtypes)),  # 添加分组间隔线
	gaps_row = cumsum(table(sorted_subtypes))
)
dev.off()


###############################
### PCoA分析与高级可视化 ###
###############################

# 加载所需包 ---------------------------------------------------------------
library(vegan)       # 生态学分析
library(ggplot2)     # 绘图
library(patchwork)   # 拼图
library(RColorBrewer)# 颜色调色板
library(multcompView)# 多重比较字母标记

# 数据准备 ----------------------------------------------------------------
# 确保输入矩阵为样本×通路格式
normalize=function(x){
	return((x-min(x))/(max(x)-min(x)))}
input_PCOA=normalize(result)
input_PCOA=input_PCOA[apply(input_PCOA,1,sd)>0.01,]
pcoa_input <- t(input_PCOA)  # input应为通路×样本的GSVA矩阵
rownames(pcoa_input) <- colnames(input_PCOA)  # 样本名称

# 亚型信息处理
subtypes <- factor(subtypes)  # 确保为因子
meta_data <- data.frame(
	sample = colnames(input),
	Subtype = subtypes
)

dist_matrix <- vegdist(pcoa_input, method = "bray")

# PCoA分析 ----------------------------------------------------------------
pcoa_result <- cmdscale(dist_matrix, k = 2, eig = TRUE)
points<-data.frame(scores(pcoa_result))
point<-data.frame(sample=row.names(points),points)
# 计算方差解释度
pc1<-round((pcoa_result$eig/sum(pcoa_result$eig))*100,2)[1]
pc2<-round((pcoa_result$eig/sum(pcoa_result$eig))*100,2)[2]

# 构建绘图数据 ------------------------------------------------------------
colnames(points)[1:2]<-c('dim1','dim2')
plotdata=data.frame(rownames(points),points$dim1,points$dim2,meta_data$Subtype)
colnames(plotdata)=c("sample","dim1","dim2","group")


adonis_result_dis <- adonis2(dist_matrix ~ Subtype, data = meta_data, permutations = 999)
R2 = adonis_result_dis$R2[1]
pvalue = adonis_result_dis$`Pr(>F)`[1]
adonis <- paste("PERMANOVA:\nR2 = ", round(R2, 4), "\nP-value = ", pvalue)
# 计算样本数量和分组数量
length_samples <- length(unique(as.character(meta_data$sample)))
length_groups <- length(unique(as.character(meta_data$Subtype)))

# 计算颜色和形状的重复次数和余数
times1 <- length_samples %/% 8  # 颜色重复次数
res1 <- length_samples %% 8      # 颜色余数
times2 <- length_samples %/% 5   # 形状重复次数
res2 <- length_samples %% 5      # 形状余数

# 定义颜色
mycol <- c("#B2182B", "#E69F00", "#56B4E9", "#009E73",
					 "#F0E442", "#0072B2", "#D55E00", "#CC79A7",
					 "#CC6666", "#9999CC", "#66CC99", "#999999", "#ADD1E5")

# 重复颜色并添加余数部分
col1 <- rep(mycol, times1)
col <- c(col1, mycol[1:res1])

# 定义形状
pich1 <- rep(c(15:18, 20, 7:14, 0:6), times2)
pich <- c(pich1, 15:(15 + res2))

# 设置图例列数
if (length_groups > 30) {
	n <- 2
} else {
	n <- 1
}
# 创建PCoA散点图
plot <- ggplot(plotdata, aes(dim1, dim2)) +
	geom_point(aes(colour = group, shape = group), size = 2) +
	# geom_text(aes(label = sample), size = 4, family = "Arial", hjust = 0.5, vjust = -1) +  # 显示样本名称
	scale_colour_manual(values = col) +  # 自定义颜色
	xlab(paste("PCoA axis1 (", pc1, "%)", sep = "")) +  # 自定义X轴标签
	ylab(paste("PCoA axis2 (", pc2, "%)", sep = "")) +  # 自定义Y轴标签
	theme(
		plot.title = element_text(hjust = 0.5, size = 18, colour = "black", face = "bold"),  # 图标题居中
		panel.background = element_rect(fill = 'white', colour = 'black'),  # 背景白色，边框黑色
		panel.grid = element_blank(),  # 移除网格线
		axis.title = element_text(color = 'black', size = 20),  # 轴标题样式
		axis.text = element_text(colour = 'black', size = 16, margin = unit(0.6, "lines")),  # 轴刻度标签样式
		axis.ticks = element_line(color = 'black'),  # 轴刻度线样式
		axis.ticks.length = unit(0.4, "lines"),  # 轴刻度线长度
		legend.title = element_blank(),  # 移除图例标题
		legend.key = element_blank(),  # 移除图例背景
		legend.position = c(0.9, 0.1),  # 图例位置
		legend.background = element_rect(colour = "black")  # 图例边框
	) +
	geom_vline(xintercept = 0, linetype = "dotted") +  # 添加虚线
	geom_hline(yintercept = 0, linetype = "dotted") +  # 添加虚线
	guides(
		col = guide_legend(ncol = n),  # 图例列数
		shape = guide_legend(ncol = n)
	) +
	stat_ellipse(aes(x = dim1, y = dim2, color = group), data = plotdata)  # 添加置信椭圆

# 显示图形
print(plot)
# PC1方向箱线图 -----------------------------------------------------------
# 创建箱线图1（dim1）
box1 <- ggplot(plotdata, aes(x = meta_data$Subtype, y = dim1, fill = meta_data$Subtype)) +
	geom_boxplot(show.legend = FALSE) +  # 箱线图
	stat_boxplot(geom = "errorbar", width = 0.1, size = 0.5) +  # 添加误差条
	scale_fill_manual(values = col) +  # 自定义填充颜色
	coord_flip() +  # 交换X轴和Y轴
	theme_bw() +  # 使用白色背景主题
	theme(
		panel.grid = element_blank(),  # 移除网格线
		axis.title = element_blank(),  # 移除轴标题
		axis.line = element_line(colour = "black"),  # 轴线颜色
		axis.ticks = element_line(color = 'black'),  # 轴刻度线颜色
		axis.text.x = element_blank(),  # 移除X轴刻度标签
		axis.text.y = element_text(colour = 'black', size = 16)  # Y轴刻度标签样式
	)
box1
# 创建箱线图2（dim2）
box2 <- ggplot(plotdata, aes(x = meta_data$Subtype, y = dim2, fill = meta_data$Subtype)) +
	geom_boxplot(show.legend = FALSE) +  # 箱线图
	stat_boxplot(geom = "errorbar", width = 0.1, size = 0.5) +  # 添加误差条
	scale_fill_manual(values = col) +  # 自定义填充颜色
	theme_bw() +  # 使用白色背景主题
	theme(
		panel.grid = element_blank(),  # 移除网格线
		axis.title = element_blank(),  # 移除轴标题
		axis.line = element_line(colour = "black"),  # 轴线颜色
		axis.ticks = element_line(color = 'black'),  # 轴刻度线颜色
		axis.text.x = element_text(colour = 'black', size = 16, angle = 45, vjust = 1, hjust = 1),  # X轴刻度标签样式
		axis.text.y = element_blank()  # 移除Y轴刻度标签
	)
# 创建文本框（用于显示PERMANOVA结果）
box3 <- ggplot(plotdata, aes(dim1, dim2)) +
	geom_text(
		aes(x = -0.5, y = 0.6, label = adonis),
		size = 2
	) +
	theme_bw() +  # 使用白色背景主题
	xlab("") +  # 移除X轴标签
	ylab("") +  # 移除Y轴标签
	theme(
		panel.grid = element_blank(),  # 移除网格线
		axis.title = element_blank(),  # 移除轴标题
		axis.line = element_blank(),  # 移除轴线
		axis.ticks = element_blank(),  # 移除轴刻度线
		axis.text = element_blank()  # 移除轴刻度标签
	)

p <- box1 + box3 + plot + box2 +
	plot_layout(heights = c(1, 4), widths = c(4, 1), ncol = 2, nrow = 2)
p
pdf(file = "PCoA.pdf",width = 6,height = 6)
print(p)
dev.off()

#####小提琴图####
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)

### 数据准备 -----------------------------------------------------------
# 计算各通路亚型间差异（MBC2 - MBC1）
pathway_diff <- apply(result_scaled, 1, function(x) {
	mean(x[subtypes == "MBC2"]) - mean(x[subtypes == "MBC1"])
})

# 筛选MBC2上调的前10个通路（差异值最大的正数）
mbc2_up <- pathway_diff %>%
	sort(decreasing = TRUE) %>%
	head(10) %>%
	names()

# 筛选MBC1上调的前10个通路（差异值最小的负数）
mbc1_up <- pathway_diff %>%
	sort() %>%
	head(10) %>%
	names()

### 自定义绘图函数 -----------------------------------------------------
plot_subtype_pathways <- function(pathway_list, title) {
	# 数据转换
	plot_data <- as.data.frame(t(result_scaled[pathway_list, ])) %>%
		mutate(Subtype = subtypes) %>%
		pivot_longer(cols = -Subtype, 
								 names_to = "Pathway",
								 values_to = "Score") %>%
		mutate(Pathway = factor(Pathway, levels = pathway_list))
	
	# 计算显著性标记
	p_values <- sapply(pathway_list, function(p) {
		wilcox.test(Score ~ Subtype, data = filter(plot_data, Pathway == p))$p.value
	})
	sig_labels <- ifelse(p_values < 0.001, "***",
											 ifelse(p_values < 0.01, "**",
											 			 ifelse(p_values < 0.05, "*", "")))
	
	# 可视化
	ggplot(plot_data, aes(x = Pathway, y = Score)) +
		geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.4, color = NA) +
		geom_boxplot(aes(fill = Subtype), 
								 width = 0.15, 
								 position = position_dodge(0.9),
								 outlier.shape = NA,
								 color = "black") +  # 添加箱式图描边
		geom_text(
			data = data.frame(Pathway = pathway_list, label = sig_labels),
			aes(x = Pathway, y = max(plot_data$Score)*1.1, label = label),
			size = 5, vjust = -0.5
		) +
		scale_fill_manual(values = c("MBC1"="#FF6F61", "MBC2"="#92A8D1")) +
		labs(title = title, x = "", y = "GSVA Enrichment Score") +
		theme_classic() +
		theme(
			axis.text.x = element_text(angle = 45, hjust = 1, face = "bold",size = 6),
			plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
			legend.position = "top",
			panel.border = element_rect(color = "black", fill = NA),  # 添加边框
			panel.grid.major.y = element_line(color = "grey90")
		) +
		coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score)*1.15))
}

### 生成图形 -----------------------------------------------------------
# MBC2上调通路图
p_mbc2 <- plot_subtype_pathways(
	pathway_list = mbc2_up,
	title = "Top 10 Pathways Upregulated in MBC2"
)

# MBC1上调通路图 
p_mbc1 <- plot_subtype_pathways(
	pathway_list = mbc1_up,
	title = "Top 10 Pathways Upregulated in MBC1"
)

### 保存输出 -----------------------------------------------------------
ggsave("MBC2_Top10_Upregulated.pdf", p_mbc2, width = 12, height = 6)
ggsave("MBC1_Top10_Upregulated.pdf", p_mbc1, width = 12, height = 6)

#####乳酸化差异小提琴图#####
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)

### 数据提取与准备 -----------------------------------------------------------
# 提取Seurat对象中的Scoreing列和Subtype列
plot_data <- oc_subset@meta.data %>%
	select(Scoreing, subtypes)
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
	labs(x = "Subtype", y = "Lactylation") +
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
ggsave("Subtype_Scoreing.pdf", width = 4, height = 6)

#####通路评分####
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
plot_data <- data.frame(oc_subset$subtypes, t(result_scaled))
colnames(plot_data)[1] <- "subtypes"
plot_data <- plot_data %>%
	select(subtypes, Th1_Th2_diff, NFKB, JAK_STAT) %>%
	pivot_longer(
		cols = -subtypes,
		names_to = "Pathway",
		values_to = "Score"
	) %>%
	mutate(
		Subtype = as.factor(subtypes),
		Pathway = factor(Pathway, 
										 levels = c("Th1_Th2_diff", "NFKB", "JAK_STAT"),
										 labels = c("Th1/Th2", "NF-kappaB", "JAK-STAT"))
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
	scale_fill_manual(values = c("MBC1" = "#acd5ab", "MBC2" = "#feadac")) +
	scale_color_manual(values = c("MBC1" = "#6a9662", "MBC2" = "#e67c73")) +
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

