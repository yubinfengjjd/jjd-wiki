library(tidyverse)
library(IOBR)
library(reshape2)
library(ggplot2)
library(ggpubr)
library(ggsci)
library(pheatmap)
library(cowplot)
library(ComplexHeatmap)
rm(list = ls())
setwd("D:\\UC-20种修饰\\12.免疫浸润")
rt=read.table("./bindgeo_PTMDs.txt", header=T, sep="\t", check.names=F, row.names=1)
cibersort <- deconvo_tme(eset = rt, 
												 method = "cibersort", 
												 arrays = FALSE, 
												 perm = 1000)
colnames(cibersort)=str_replace_all(colnames(cibersort),"_CIBERSORT","")
outTab=cibersort[cibersort[,"P-value"]<0.05,]
outTab=as.matrix(outTab[,1:(ncol(outTab)-3)])
write.table(outTab, file="CIBERSORT-Results.txt", sep="\t", quote=F, col.names=T,row.names = F)

#####小提琴图#####
rm(list = ls())
library(tidyverse)
library(ggthemes)
library(ggpubr)
library(ggunchained)
# 读取数据
data <- read.table("CIBERSORT-Results.txt", sep="\t", header=T, row.names=1, check.names=F)

# 数据处理部分
conNum <- sum(gsub("(.*)_(.*)_(.*)", "\\3", rownames(data)) == "low")
treatNum <- sum(gsub("(.*)_(.*)_(.*)", "\\3", rownames(data)) == "high")

data2 <- data %>%
	add_column(class = rep(c("PTMD_high", "PTMD_low"), c(treatNum, conNum)), .before = 1) %>%
	gather("cell_types", "percentages", -class) %>%
	mutate(cell_types = factor(cell_types, levels = colnames(data)),
				 class = factor(class, levels = c("PTMD_high", "PTMD_low")))

# 计算p值并生成标签
p_values <- sapply(colnames(data), function(cell) {
	wilcox.test(percentages ~ class, data = filter(data2, cell_types == cell))$p.value
})

sig_labels <- ifelse(p_values < 0.001, "***",
										 ifelse(p_values < 0.01, "**",
										 			 ifelse(p_values < 0.05, "*", "")))

# 计算每个细胞类型的最大值用于标签位置
label_pos <- data2 %>%
	group_by(cell_types) %>%
	summarise(max_pct = max(percentages)) %>%
	mutate(y_pos = max_pct * 1.1)

# 加载必要的库
library(ggplot2)
library(ggpubr)
library(dplyr)
library(Rmisc)
# 自定义主题
mytheme <- theme(
	plot.title = element_text(size = 12, color = "black", hjust = 0.5),
	axis.title = element_text(size = 12, color = "black"),
	axis.text = element_text(size = 12, color = "black"),
	panel.grid.minor.y = element_blank(),
	panel.grid.minor.x = element_blank(),
	axis.text.x = element_text(angle = 45, hjust = 1),
	panel.grid = element_blank(),
	legend.position = "top",
	legend.text = element_text(size = 12),
	legend.title = element_text(size = 12)
)

Data_summary <- summarySE(data2, measurevar = "percentages", groupvars = c("class", "cell_types"))

# 绘图代码
ESTI_split_violin <- ggplot(data2, aes(x = cell_types, y = percentages, fill = class)) +
	geom_split_violin(
		trim = T, 
		color = "white", 
		scale = "width",
		width = 0.9
	) +
	geom_point(
		data = Data_summary, 
		aes(x = cell_types, y = percentages), 
		pch = 19,
		position = position_dodge(width = 0.7),
		size = 2,
		color = "black"  # 添加点图描边
	) +
	geom_errorbar(
		data = Data_summary, 
		aes(ymin = percentages - ci, ymax = percentages + ci),
		width = 0.1,                    # 加宽误差条
		position = position_dodge(0.7), # 与点图对齐
		color = "black",
		size = 0.8
	) +
	scale_fill_manual(values = c("#56B4E9", "#E69F00")) +
	labs(y = "Cibersort score", x = NULL, title = "Split violin") +
	theme_bw() + 
	mytheme +
	stat_compare_means(
		aes(class = class),
		label = "p.signif",
		method = "wilcox",
		label.y = max(data2$percentages) * 1.05,  # 提升显著性标记位置
		hide.ns = TRUE
	)

# 保存优化版本
ggsave(
	filename = "ESTIMATE_plot_optimized.pdf",
	plot = ESTI_split_violin,
	height = 16, 
	width = 48, 
	units = "cm"
)

#####免疫相关性分析####
library(limma)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(linkET)
rm(list = ls())
expFile="./bindgeo_PTMDs.txt"       #?????????ļ?
geneFile="./intersectGenes.txt"       #?????б??ļ?
immFile="CIBERSORT-Results.txt"     #????ϸ???????Ľ????ļ?

rt=read.table(expFile, header=T, sep="\t", check.names=F)
rt=as.matrix(rt)
rownames(rt)=rt[,1]
exp=rt[,2:ncol(rt)]
dimnames=list(rownames(exp),colnames(exp))
data=matrix(as.numeric(as.matrix(exp)),nrow=nrow(exp),dimnames=dimnames)
data=avereps(data)
geneRT=read.table(geneFile, header=T, sep="\t", check.names=F)
data = data[as.vector(geneRT[,1]), , drop = FALSE]

data=t(data)
immune=read.table(immFile, header=T, sep="\t", check.names=F, row.names=1)
#immune=t(immune)
sameSample=intersect(row.names(data), row.names(immune))
data=data[sameSample,,drop=F]
immune=immune[sameSample,,drop=F]
immune=immune[,apply(immune,2,sd)>0]
geneLists=list()
for(i in 1:ncol(data)){geneLists[[colnames(data)[i]]]=i}

geneCor=data.frame()
for(cell in colnames(immune)){
	if(sd(immune[,cell])==0){next}
	for(gene in colnames(data)){
		x=as.numeric(immune[,cell])
		y=as.numeric(data[,gene])
		corT=cor.test(x, y, method="spearman")
		cor=corT$estimate
		pvalue=corT$p.value
		geneCor=rbind(geneCor, cbind(spec=gene, env=cell, r=cor, p=pvalue))
	}
}
geneCor$r=as.numeric(geneCor$r)
geneCor$p=as.numeric(geneCor$p)
geneCor$pd=ifelse(geneCor$p<0.05, ifelse(geneCor$r>0, "Postive", "Negative"), "Not")
geneCor$r=abs(geneCor$r)
geneCor=geneCor %>% mutate(rd = cut(r, breaks = c(-Inf, 0.2, 0.4, 0.6, Inf),
																		labels = c("< 0.2", "0.2 - 0.4", "0.4 - 0.6",">= 0.6")))

# 加载必要的库
library(ggplot2)
library(ggpubr)
library(ggExtra)

# 初始化输出表格
outTab <- data.frame()

# 获取基因名
gene <- geneRT[,1] # 请替换为实际的基因名

# 遍历 rt 的列（除了最后一列）
for (i in colnames(rt)[1:(ncol(rt) - 1)]) {
	x <- as.numeric(rt[, gene])
	y <- as.numeric(rt[, i])
	
	# 如果 y 的标准差为 0，将其第一个元素设为 0.00001
	if (sd(y) == 0) {
		y[1] <- 0.00001
	}
	
	# 计算 Spearman 相关性
	cor_result <- cor.test(x, y, method = "spearman")
	
	# 构建输出向量
	outVector <- data.frame(
		Gene = gene,
		Cell = i,
		cor = cor_result$estimate,
		pvalue = cor_result$p.value
	)
	
	# 将结果添加到输出表格中
	outTab <- rbind(outTab, outVector)
	
	# 如果 p 值小于 0.05，绘制相关性图
	if (cor_result$p.value < 0.05) {
		outFile <- paste0("cor.", i, ".pdf")
		df1 <- data.frame(x = x, y = y)
		
		p1 <- ggplot(df1, aes(x, y)) + 
			xlab(paste0(gene, " expression")) + 
			ylab(i) +
			geom_point() + 
			geom_smooth(method = "lm", formula = y ~ x) + 
			theme_bw() +
			stat_cor(method = 'spearman', aes(x = x, y = y))
		
		p2 <- ggMarginal(p1, type = "density", xparams = list(fill = "#FD7446FF"), yparams = list(fill = "#3B4992FF"))
		
		# 保存图形
		pdf(file = outFile, width = 5, height = 4.3)
		print(p2)
		dev.off()
	}
}

# 保存相关性结果
write.table(outTab, file = "cor.result.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# 读取相关性结果
data <- read.table("cor.result.txt", header = TRUE, sep = "\t", check.names = FALSE)

# 定义颜色和大小函数
p.col <- c('gold', 'pink', 'orange', 'LimeGreen', 'darkgreen')
fcolor <- function(x, p.col) {
	color <- ifelse(x > 0.8, p.col[1], 
									ifelse(x > 0.6, p.col[2], 
												 ifelse(x > 0.4, p.col[3], 
												 			 ifelse(x > 0.2, p.col[4], p.col[5]))))
	return(color)
}

p.cex <- seq(2.5, 5.5, length = 5)
fcex <- function(x) {
	x <- abs(x)
	cex <- ifelse(x < 0.1, p.cex[1], 
								ifelse(x < 0.2, p.cex[2], 
											 ifelse(x < 0.3, p.cex[3], 
											 			 ifelse(x < 0.4, p.cex[4], p.cex[5]))))
	return(cex)
}

# 计算颜色和大小
data$points.color <- fcolor(x = data$pvalue, p.col = p.col)
data$points.cex <- fcex(x = data$cor)
data <- data[order(data$cor), ]

# 绘制棒棒图
pdf(file = "Lollipop.pdf", width = 10,height = 8)
xlim <- ceiling(max(abs(data$cor)) * 10) / 10

layout(mat = matrix(c(1, 1, 1, 1, 1, 0, 2, 0, 3, 0), nc = 2), width = c(8, 2.2), heights = c(1, 2, 1, 2, 1))

par(bg = "white", las = 1, mar = c(5, 18, 2, 4), cex.axis = 1.5, cex.lab = 2)
plot(1, type = "n", xlim = c(-xlim, xlim), ylim = c(0.5, nrow(data) + 0.5), xlab = "Correlation Coefficient", ylab = "", yaxt = "n", yaxs = "i", axes = FALSE)
rect(par('usr')[1], par('usr')[3], par('usr')[2], par('usr')[4], col = "#F5F5F5", border = "#F5F5F5")
grid(ny = nrow(data), col = "white", lty = 1, lwd = 2)

# 绘制棒棒图的线段
segments(x0 = data$cor, y0 = 1:nrow(data), x1 = 0, y1 = 1:nrow(data), lwd = 4)

# 绘制棒棒图的点
points(x = data$cor, y = 1:nrow(data), col = data$points.color, pch = 16, cex = data$points.cex)

# 添加细胞名称
text(par('usr')[1], 1:nrow(data), data$Cell, adj = 1, xpd = TRUE, cex = 1)

# 添加 p 值
pvalue.text <- ifelse(data$pvalue < 0.001, '<0.001', sprintf("%.03f", data$pvalue))
redcutoff_cor <- 0
redcutoff_pvalue <- 0.05
text(par('usr')[2], 1:nrow(data), pvalue.text, adj = 0, xpd = TRUE, col = ifelse(abs(data$cor) > redcutoff_cor & data$pvalue < redcutoff_pvalue, "red", "black"), cex = 1)

axis(1, tick = FALSE)

# 绘制点的大小图例
par(mar = c(0, 4, 3, 4))
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
legend("left", legend = c(0.1, 0.2, 0.3, 0.4, 0.5), col = "black", pt.cex = p.cex, pch = 16, bty = "n", cex = 2, title = "abs(cor)")

# 绘制点的颜色图例
par(mar = c(0, 6, 4, 6), cex.axis = 1.5, cex.main = 2)
barplot(rep(1, 5), horiz = TRUE, space = 0, border = NA, col = p.col, xaxt = "n", yaxt = "n", xlab = "", ylab = "", main = "pvalue")
axis(4, at = 0:5, c(1, 0.8, 0.6, 0.4, 0.2, 0), tick = FALSE)

dev.off()

#####免疫功能分析####
library(GSVA)
rt=read.table("./bindgeo_PTMDs.txt", header=T, sep="\t", check.names=F, row.names=1)
geneSet <- getGmt("immune.gmt", geneIdType=SymbolIdentifier())
ssgseaScore=ssgseaParam(as.matrix(rt), geneSet,normalize = T)
ssgseaScore <- gsva(ssgseaScore)
#ssgseaScore <- t(scale(t(ssgseaScore)))
result_scaled = ssgseaScore
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)
group=gsub("(.*)\\_(.*?)", "\\2", colnames(rt))
### 数据准备 -----------------------------------------------------------
# 计算各通路亚型间差异（MBC2 - MBC1）
pathway_diff <- apply(result_scaled, 1, function(x) {
	mean(x[group == "high"]) - mean(x[group == "low"])
})

# 筛选MBC2上调的前10个通路（差异值最大的正数）
mbc2_up <- pathway_diff[pathway_diff>0] %>%
	sort(decreasing = TRUE) %>%
	head(20) %>%
	names()

### 自定义绘图函数 -----------------------------------------------------
plot_subtype_pathways <- function(pathway_list, title){
	# 数据转换
	plot_data <- as.data.frame(t(result_scaled[pathway_list, ])) %>%
		mutate(Subtype = group) %>%
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
		# 添加组间分隔线（竖虚线） - 核心添加部分
		geom_vline(
			xintercept = seq(1.5, length(pathway_list) - 0.5,  # 计算分隔线位置
											 color = "gray60", 
											 linetype = "dashed", 
											 linewidth = 0.4
			)) +
				geom_violin(aes(fill = Subtype), position = position_dodge(0.9), alpha = 0.4, color = NA, width = 0.8) +
				geom_boxplot(aes(fill = Subtype), 
										 width = 0.4, 
										 position = position_dodge(0.9),
										 outlier.shape = NA,
										 color = "black") +
				geom_text(
					data = data.frame(Pathway = pathway_list, label = sig_labels),
					aes(x = Pathway, y = max(plot_data$Score)*1.1, label = label),
					size = 5, vjust = -0.5
				) +
				scale_fill_manual(values = c("high"="#FF6F61", "low"="#92A8D1")) +
				labs(title = title, x = "", y = "GSVA Enrichment Score") +
				theme_classic() +
				theme(
					axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 9),
					plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
					legend.position = "top",
					panel.border = element_rect(color = "black", fill = NA),
					panel.grid.major.y = element_line(color = "grey90")
				) +
				coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score)*1.15))
}

### 生成图形 -----------------------------------------------------------
# MBC2上调通路图
p_mbc2 <- plot_subtype_pathways(
	pathway_list = mbc2_up,
	title = "Top 20 Pathways Upregulated in PTMD_high subtype"
)

### 保存输出 -----------------------------------------------------------
ggsave("MBC2_Top10_Upregulated_immuse.pdf", p_mbc2, width = 20, height = 6)

#######!!!!!!!!!#####
library(tidyverse)
library(linkET)
library(cowplot)
library(RColorBrewer)
library(patchwork)
library(GSEABase)
library(limma)

# 函数：创建优化后的相关性网络图
create_optimized_corr_plot <- function(immune_matrix) {
	# 计算基因与免疫特征的相关性
	geneCor <- data.frame()
	for(cell in colnames(immune_matrix)) {
		for(gene in colnames(data)) {
			x <- as.numeric(immune_matrix[, cell])
			y <- as.numeric(data[, gene])
			corT <- cor.test(x, y, method = "spearman")
			geneCor <- rbind(geneCor, cbind(spec = gene, env = cell, 
																			r = corT$estimate, p = corT$p.value))
		}
	}
	
	# 处理相关性数据
	geneCor$r <- as.numeric(geneCor$r)
	geneCor$p <- as.numeric(geneCor$p)
	geneCor$pd <- ifelse(geneCor$p < 0.05, 
											 ifelse(geneCor$r > 0, "Positive", "Negative"), 
											 "Not")
	geneCor$r_abs <- abs(geneCor$r)
	geneCor <- geneCor %>% 
		mutate(rd = cut(r_abs, breaks = c(-Inf, 0.2, 0.4, 0.6, Inf),
										labels = c("< 0.2", "0.2 - 0.4", "0.4 - 0.6", ">= 0.6")))
	return(geneCor)
}

# 主程序
# 1. 准备基因表达数据
rt <- read.table("./bindgeo_PTMDs.txt", header = TRUE, sep = "\t", 
								 check.names = FALSE, row.names = 1)
exp_data <- rt
data <- matrix(as.numeric(as.matrix(exp_data)), nrow = nrow(exp_data),
							 dimnames = list(rownames(exp_data), colnames(exp_data)))
data <- avereps(data)
geneRT <- read.table("./intersectGenes.txt", header = TRUE, sep = "\t", 
										 check.names = FALSE)
gene <- geneRT[, 1]
data <- t(data[as.vector(gene), , drop = FALSE])

# 2. 准备免疫浸润数据 (Cibersort)
cibersort <- read.table("CIBERSORT-Results.txt", header = TRUE, sep = "\t",
												check.names = FALSE, row.names = 1)
sameSample <- intersect(rownames(data), rownames(cibersort))
cibersort <- cibersort[sameSample, , drop = FALSE]
data <- data[sameSample, , drop = FALSE]

# 3. 准备免疫功能数据 (ssGSEA)
immune_function <- t(result_scaled)  # 转置为样本×通路
sameSample_func <- intersect(rownames(data), rownames(immune_function))
immune_function <- immune_function[sameSample_func, , drop = FALSE]

# 4. 创建两个优化后的相关性网络图
cor_ciber <- create_optimized_corr_plot(cibersort)
cor_func <- create_optimized_corr_plot(immune_function)

p1 = qcorqcor=qcorrplot(correlate(cibersort, method="spearman"), type = "lower", diag = FALSE) +
	geom_square() +
	geom_mark(sep = '\n', size = 1, sig_level = c(0.05, 0.01, 0.001), sig_thres = 0.05, color="black") +
	geom_couple(aes(colour = pd, size = rd), 
							data = cor_ciber, 
							curvature = nice_curvature()) +
	scale_fill_gradientn(colours = rev(RColorBrewer::brewer.pal(11, "PuOr"))) +
	scale_size_manual(values = c(0.5, 1.5, 2, 3)) +
	scale_colour_manual(values = c("#1B9E77","grey60","#D95F02")) +
	guides(size = guide_legend(title = "abs(Cor)",
														 override.aes = list(colour = "grey35"), 
														 order = 2),
				 colour = guide_legend(title = "pvalue", 
				 											override.aes = list(size = 3), 
				 											order = 1),
				 fill = guide_colorbar(title = "Cell-cell cor", order = 3))

p2 = qcorqcor=qcorrplot(correlate(immune_function, method="spearman"), type = "upper", diag = FALSE) +
	geom_square() +
	geom_mark(sep = '\n', size = 1, sig_level = c(0.05, 0.01, 0.001), sig_thres = 0.05, color="black") +
	geom_couple(aes(colour = pd, size = rd), 
							data = cor_func, 
							curvature = nice_curvature()) +
	scale_fill_gradientn(colours = rev(RColorBrewer::brewer.pal(11, "RdBu"))) +
	scale_size_manual(values = c(0.5, 1.5, 2, 3)) +
	scale_colour_manual(values = c("#D95F02")) +
	guides(size = guide_legend(title = "abs(Cor)",
														 override.aes = list(colour = "grey35"), 
														 order = 2),
				 colour = guide_legend(title = "pvalue", 
				 											override.aes = list(size = 3), 
				 											order = 1),
				 fill = guide_colorbar(title = "Cell-cell cor", order = 3))
library(cowplot)
# 左右拼接
combined_plot = plot_grid(p1, p2, ncol = 2)
# 保存图形
ggsave("final_plot.pdf", combined_plot, width = 20, height = 10)

######棒棒糖图#####
library(ggnewscale)
library(tidyverse)
library(ggforce)

# 中心点位置
center <- data.frame(x = 0, y = 0, label = "UBE2L6")
colorMap <- structure(
	c('#c5523f', '#7DA88E', '#0096d6'),
	names = c('Positive', 'Not',"Negative")
)

theme_no_axis <- theme(
	panel.background = element_blank(),
	panel.grid = element_blank(),
	axis.title = element_blank(),
	axis.line = element_blank(),
	axis.ticks = element_blank(),
	axis.text = element_blank()
)

added_data <- cor_ciber %>%
	mutate(x = ifelse(r < 0, -1, 1)) %>%
	group_by(pd) %>%
	arrange(env) %>%  # 删除 by_group = TRUE
	ungroup() %>%
	dplyr::mutate(y = n():1, y = y - mean(y))

adjust <- 0.5
bezier.data <- dplyr::select(added_data, x, y) %>%
	tibble::rowid_to_column('group') %>%
	mutate(type = ifelse(x < 0, 'neg', 'pos')) %>%
	group_by(group) %>%
	group_modify(function(data, group) {
		if (data$x[1] < 0) {
			data.frame(
				x = c(0, -adjust, data$x + adjust, data$x),
				y = c(0, 0, data$y, data$y),
				type = data$type
			)
		} else {
			data.frame(
				x = c(0, adjust, data$x - adjust, data$x),
				y = c(0, 0, data$y, data$y),
				type = data$type
			)
		}
	})

# 绘图
p <- ggplot(added_data, aes(x = x, y = y)) +
	# 曲线连接
	geom_bezier(aes(group = group, 
									colour = type),
							data = bezier.data, 
							linewidth = 0.4,
							show.legend = FALSE) +
	scale_colour_manual(values = c('#2B393B', '#7F2749')) +
	new_scale_colour() +
	# 中心点
	geom_point(data = center, size = 8, color = "#2B393B") +
	# 外部点
	geom_point(aes(size = abs(r), fill = pd),
						 shape = 21) +
	# 添加点标签
	geom_text(aes(label = env, colour = pd), 
						hjust = ifelse(added_data$x > 0, -0, 1), vjust = 0.5,
						nudge_x = ifelse(added_data$x > 0, 0.2, -0.2),
						size = 4, alpha = 0.8,
						show.legend = FALSE) +
	# 添加中心点标签
	geom_text(aes(label = label), 
						data = center, 
						fontface = "italic", size = 6, hjust = 0.8, vjust = 0.8,
						nudge_x = 1.5, colour = "#2B393B") +
	# 调整点的大小和颜色
	scale_colour_manual(values = colorMap) +
	scale_fill_manual(values = colorMap) +
	lims(x = c(-3, 3)) +
	# 美化图形
	theme_no_axis
p
low_pos <- min(added_data$y)

p1 = p + annotate(geom = 'segment', 
					 x = -.5, y = low_pos - 1, 
					 xend = -2.5, yend = low_pos - 1,
					 arrow = arrow(angle = 20, length = unit(0.03, 'npc'), 
					 							type = 'closed')) +
	annotate(geom = 'text', x = -2.3, y = low_pos - 2, 
					 label = 'Negative correlation',
					 hjust = 0) +
	
	# Annotate positive correlation
	annotate(geom = 'segment', 
					 x = .5, y = low_pos - 1, 
					 xend = 2.5, yend = low_pos - 1,
					 arrow = arrow(angle = 20, length = unit(0.03, 'npc'), 
					 							type = 'closed')) +
	annotate(geom = 'text', x = 2.3, y = low_pos - 2, 
					 label = 'Positive correlation',
					 hjust = 1)

ggsave("final_plot1.pdf", p1, width = 8, height =8)

#####免疫调控分子####
library(ComplexHeatmap)
library(circlize)
library(dplyr)
library(stringr)

### === Step 1: 读取基因分类 ===
gene_line = data.table::fread("./immune_regulators_classified.txt",header = F)
genes <- gene_line$V1
gene_category <- gene_line$V2
names(gene_category) <- genes

### === Step 2: 提取表达矩阵中匹配的基因 ===
common_genes <- intersect(genes, rownames(exp_data))
exp_subset <- exp_data[common_genes, ]
gene_category <- gene_category[common_genes]
category <- factor(gene_category, levels = unique(gene_category))

### === Step 3: 差异检验并生成显著性标记 ===
group_factor <- as.factor(group)
pvals <- apply(exp_subset, 1, function(x) {
	if (length(unique(group_factor)) == 2) {
		wilcox.test(
			x[group_factor == levels(group_factor)[1]],
			x[group_factor == levels(group_factor)[2]]
		)$p.value
	} else {
		1
	}
})
signif <- cut(pvals,
							breaks = c(-Inf, 0.001, 0.01, 0.05, Inf),
							labels = c("***", "**", "*", "ns"))

### === Step 4: 计算组间平均值 ===
# 对原始数据进行归一化处理
exp_scaled <- t(scale(t(exp_subset)))

# 计算归一化后的组间平均值
group_means <- t(apply(exp_scaled, 1, function(x) {
	tapply(x, group_factor, mean)
}))
exp_means <- group_means  # 使用归一化后的组平均值作为绘图输入

### === Step 5: 构建颜色和注释 ===
col_fun <- colorRamp2(c(min(exp_means), 0, max(exp_means)),
											c("#0c447f", "#d4cac9", "#8f1d25"))

# 右侧注释（显著性 + 小提琴图）
right_anno <- rowAnnotation(
	Significance = anno_text(
		signif,
		which = "row",
		rot = 0,
		just = "left",
		location = unit(0, "npc"),
		gp = gpar(fontsize = 10)
	),
	Density = anno_density(
		as.matrix(exp_subset),
		which = "row",
		type = "line",
		joyplot_scale = 8,  # 提高密度图高度
		width = unit(3, "cm"),
		border = FALSE,       # 去除边框
		gp = gpar(
			fill = "#edc3bb",   # 改为黄色填充
			col = "black",     # 黑色描边
			lwd = 1            # 描边宽度
		),
		axis_param = list(gp = gpar(fontsize = 8))
	),
	annotation_name_rot = 0,
	annotation_name_gp = gpar(fontsize = 10)
)

row_order <- order(category)
exp_means_ordered <- exp_means[row_order, ]
category_ordered <- category[row_order]

# 确保因子水平与行顺序一致
category_ordered <- factor(category_ordered, levels = unique(category_ordered))

# 更新左侧注释
left_anno <- rowAnnotation(
	Category = anno_block(
		labels = levels(category_ordered),
		gp = gpar(fill = scales::hue_pal()(length(levels(category_ordered)))),
		labels_gp = gpar(col = "white", fontsize = 10, fontface = "bold")
	),
	annotation_name_side = "top"
)

# 顶部注释（分组信息）
top_anno <- HeatmapAnnotation(
	Group = factor(colnames(exp_means)),
	col = list(Group = structure(
		c("#FF6F61", "#92A8D1"),
		names = colnames(exp_means)
	)),
	simple_anno_size = unit(0.4, "cm"),
	annotation_name_gp = gpar(fontsize = 10)
)

### === Step 6: 绘图 ===
ht <- Heatmap(
	exp_means_ordered,
	rect_gp = gpar(col = "black", lwd = 3),
	name = "Expression\nZ-score",
	col = col_fun,
	row_split = category_ordered,  # 使用排序后的类别
	cluster_rows = FALSE,  # 禁用行聚类
	column_split = colnames(exp_means),
	top_annotation = top_anno,
	left_annotation = left_anno,
	right_annotation = right_anno,
	show_row_names = TRUE,
	show_column_names = FALSE,
	row_title = NULL,
	column_title = NULL,
	row_names_gp = gpar(fontsize = 9),
	column_names_gp = gpar(fontsize = 10),
	heatmap_legend_param = list(
		title_position = "topleft",
		legend_height = unit(4, "cm")
	),
	# 设置单元格为正方形
	width = ncol(exp_means) * unit(8, "mm"),
	height = nrow(exp_means) * unit(8, "mm"),
	# 增加分类之间的距离
	row_gap = unit(7, "mm"),
	# 将基因名移到左边
	row_names_side = "left"
)

# 绘制图形
pdf("PTMDs_expression_heatmap.pdf", width = 6, height = 18)
draw(ht, padding = unit(c(5, 5, 5, 5), "mm"))
dev.off()