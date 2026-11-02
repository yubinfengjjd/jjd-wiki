library(org.Hs.eg.db)
library(GOSemSim)
library(reshape2)
library(ggplot2)
library(igraph)
rm(list = ls())
setwd("D:\\UC-20种修饰\\11.表达差异图与基因ROC")
gene_list=data.table::fread("./output_mRNA_selected.txt",header = T,data.table = F)[,1]
bp <- godata('org.Hs.eg.db', ont="BP", computeIC = FALSE)
cc <- godata('org.Hs.eg.db', ont="CC", computeIC = FALSE)
mf <- godata('org.Hs.eg.db', ont="MF", computeIC = FALSE)
entrez_ids <- mapIds(org.Hs.eg.db,
										 keys = gene_list,
										 column = "ENTREZID",
										 keytype = "SYMBOL",
										 multiVals = "first")
genes=data.frame(ENTREZID=entrez_ids,symbols=gene_list)
simbp <- mgeneSim(genes$ENTREZID,semData = bp,measure = "Wang",drop = NULL,combine = "BMA")
simcc <- mgeneSim(genes$ENTREZID,semData = cc,measure = "Wang",drop = NULL,combine = "BMA")
simmf <- mgeneSim(genes$ENTREZID,semData = mf,measure = "Wang",drop = NULL,combine = "BMA")

fsim <- (simmf * simcc * simbp)^(1/3)
colnames(fsim) = genes$symbols
rownames(fsim) = genes$symbols

for (i in 1:ncol(fsim)){ 
	fsim[i,i] <- NA}
dat <- melt(fsim)
dat <- dat[!is.na(dat$value),]
dat <- dat[,c(1,3)]
head(dat)

dat.mean <- aggregate(value~Var1, dat, mean)
m <- dat.mean$value
names(m) <- dat.mean$Var1 #按平均值给基因名排序
dat$Var1 <- factor(dat$Var1,levels=names(sort(m)))
str(dat)
library(ggplot2)
library(RColorBrewer)
mycolors <- colorRampPalette(brewer.pal(9,"Blues"))(length(unique(dat$Var1)))

pdf("optimized_friends_boxplot.pdf", width=8, height=10)
ggplot(dat, aes(x = reorder(Var1, value, FUN = median), y = value)) +  # 按中位数排序
	geom_boxplot(
		aes(fill = reorder(Var1, value, FUN = median)),  # 按中位数填充颜色
		width = 0.7,
		outlier.size = 1.5,
		outlier.color = "red"
	) +
	scale_fill_manual(values = mycolors) +
	coord_flip() +
	labs(
		title = "Functional Similarity Analysis of PTMD Genes",
		x = "Gene Symbols",
		y = "Integrated Semantic Similarity Score"
	) +
	theme_minimal(base_size = 12) +
	theme(
		legend.position = "none",  # 移除图例
		axis.text.y = element_text(face = "italic", size = 10),  # 基因名斜体
		plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
		panel.grid.major.y = element_blank(),
		panel.grid.minor = element_blank(),
		axis.line.x = element_line(color = "black"),
		plot.caption = element_text(color = "gray40", size = 9)
	) +
	geom_hline(
		yintercept = median(dat$value),
		linetype = "dashed",
		color = "darkred",
		size = 0.8
	) +
	annotate(
		"text",
		x = 1,
		y = median(dat$value)+0.05,
		label = paste("Median =", round(median(dat$value),2)),
		color = "darkred",
		size = 3.5
	)

dev.off()
#####箱式图####
library(ggplot2)
library(tidyr)
library(ggsci)
library(ggpubr)
library(tibble)
library(tidyverse)
gene_list_file <- "intersectGenes.txt"    # 基因列表文件路径
datasets <- c(                            # 定义要分析的数据集
	"GSE38713" = "./GSE38713.normalize.txt",
	"Combined_data" = "./merge.normalize.txt",
	"GSE47908" = "./GSE47908.normalize.txt"
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


#####ROC曲线####
library(pROC)
library(scales)

expFiles <- c("./merge.normalize.txt", "./GSE47908.normalize.txt", "./GSE38713.normalize.txt")
if (!dir.exists("ROC")) dir.create("ROC") 

geneRT <- c("CPT1A","UBE2L6")  # 要分析的基因
bioCol <- c("#d92b50")  # 专业配色

for (expFile in expFiles) {
	# 数据读取
	rt <- read.table(file.path("nor", expFile), header=TRUE, sep="\t",
									 check.names=FALSE, row.names=1)
	y <- ifelse(gsub(".*_", "", colnames(rt)) == "control", 0, 1)
	title <- gsub(".normalize.txt", "", basename(expFile))
	
	# 图形参数设置
	par(mar = c(4.5, 4.5, 2, 2), mgp = c(2.5, 1, 0))
	
	# 绘制每个基因的ROC曲线
	aucText <- c()
	for (i in seq_along(geneRT)) {
		gene <- geneRT[i]
		roc_obj <- roc(y, as.numeric(rt[gene,]))
		# 创建PDF文件
		pdf(file.path("ROC", paste0(title, "_" ,gene, "_ROC.pdf")), width=7, height=6)
		
		# 图形参数设置
		par(mar = c(4.5, 4.5, 2, 2), mgp = c(2.5, 1, 0))
		plot(roc_obj,
				 print.auc = FALSE,  # 禁用默认AUC显示
				 grid = c(0.2, 0.2), # 更精细的网格线
				 grid.col = "lightgray",
				 legacy.axes = TRUE,
				 xlab = "False Positive Rate (1 - Specificity)",
				 ylab = "True Positive Rate (Sensitivity)",
				 main = "ROC Curve with 95% Confidence Intervals",
				 col = "#d92b50",
				 lwd = 2)
		# 计算置信区间
		set.seed(123)
		auc_ci <- ci.auc(roc_obj, method="bootstrap", boot.n=2000)
		sp_ci <- ci.sp(roc_obj, sensitivities=seq(0,1,0.01), boot.n=2000, progress="none")
		
		plot(sp_ci, 
				 type = "shape", 
				 col = alpha("#f3bbc6", 0.3), # 使用透明度
				 border = NA)
		
		# 添加AUC文本注释
		auc_text <- sprintf("AUC = %.3f (95%% CI: %.3f-%.3f)", 
												auc(roc_obj), 
												auc_ci[1], 
												auc_ci[3])
		text(x = 0.6, y = 0.2,  # 调整文本位置
				 labels = auc_text,
				 col = "#d92b50",
				 cex = 1.2)
		
		
		# 添加图例
		legend("bottomright",
					 legend = c("ROC Curve", "95% Confidence Band"),
					 col = c("#d92b50", alpha("#f3bbc6", 0.3)),
					 lwd = c(2, 10),
					 bty = "n",
					 cex = 0.9)
		dev.off()}
}