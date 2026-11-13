setwd("D:\\UC-20种修饰\\18.拟时序分析")
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
rm(list = ls())
#####上皮细胞再聚类#####
UC_subset = subset(UC,subset = celltype == "Epithelial") %>% NormalizeData() %>%
	FindVariableFeatures(selection.method = "vst" ,nfeatures = 1500 ,verbose = T)
#####拟时序分析####
seurat_to_monocle <- function(otherCDS, assay, slot, lowerDetectionLimit = 0, import_all = FALSE) {
	if(class(otherCDS)[1] == 'Seurat') {
		requireNamespace("Seurat")
		data <- GetAssayData(otherCDS, assay = assay, slot = slot)
		data <- data[rowSums(as.matrix(data)) != 0,]
		pd <- new("AnnotatedDataFrame", data = otherCDS@meta.data)
		fData <- data.frame(gene_short_name = row.names(data), row.names = row.names(data))
		fd <- new("AnnotatedDataFrame", data = fData)
		if(all(data == floor(data))) {
			expressionFamily <- negbinomial.size()
		} else if(any(data < 0)){
			expressionFamily <- uninormal()
		} else {
			expressionFamily <- tobit()
		}
		valid_data <- data[, row.names(pd)]
		monocle_cds <- newCellDataSet(data,
																	phenoData = pd, 
																	featureData = fd,
																	lowerDetectionLimit=lowerDetectionLimit,
																	expressionFamily=expressionFamily)
		if(import_all) {
			if("Monocle" %in% names(otherCDS@misc)) {
				otherCDS@misc$Monocle@auxClusteringData$seurat <- NULL
				otherCDS@misc$Monocle@auxClusteringData$scran <- NULL
				monocle_cds <- otherCDS@misc$Monocle
				mist_list <- otherCDS
			} else {
				mist_list <- otherCDS
			}
		} else {
			mist_list <- list()
		} 
	} 
	return(monocle_cds)
}
cds_seurat <- seurat_to_monocle(UC_subset, assay = "RNA", slot = "counts")
cds_seurat <- estimateSizeFactors(cds_seurat)
cds_seurat <- estimateDispersions(cds_seurat)

cds_seurat <- detectGenes(cds_seurat, min_expr = 0.1)#????10%?ı????һ??????֮?󣬻?????num_cells_expressed??һ??
print(head(fData(cds_seurat)))
expressed_genes <- row.names(subset(fData(cds_seurat), num_cells_expressed >= 10))
pData(cds_seurat)$Total_mRNAs <- Matrix::colSums(exprs(cds_seurat))#??UMI????cds
cds_seurat <- cds_seurat[,pData(cds_seurat)$Total_mRNAs < 1e6]

cds_seurat <- cds_seurat
#seurat_variable_genes <- gene[gene%in%rownames(UC_subset@assays$RNA$data)]
seurat_variable_genes <- VariableFeatures(UC_subset)
cds_seurat <- setOrderingFilter(cds_seurat, seurat_variable_genes)
plot_ordering_genes(cds_seurat)

#??ά,????
cds_seurat <- reduceDimension(cds_seurat, max_components = 2,reduction_method = 'DDRTree')
cds_seurat <- orderCells(cds_seurat)

save(cds_seurat,file="cds_seurat.Rdata")
pdf(file = "plot_genes_in_pseudotime.PDF",width = 6,height = 6)
cds_subset=cds_seurat[c("UBE2L6"),]
plot_genes_in_pseudotime(cds_subset,color_by = "State")
dev.off()
pdf(file = "celltype.PDF",width = 6,height = 6)
plot_cell_trajectory(cds_seurat,color_by="State")
dev.off()

#####SCP_拟时序####
library(SCP)
library(DDRTree)
library(monocle)
UC_subset[["RNA"]] <- as(object = UC_subset[["RNA"]], Class = "Assay")
DefaultAssay(UC_subset) <- "RNA"
UC_subset=RunMonocle2(UC_subset,features = VariableFeatures(UC_subset))
UC_subset@tools$Monocle2$cds
save(UC_subset,file = "UC_subset_monocle.Rdata")
trajectory <- UC_subset@tools$Monocle2$trajectory
pdf("State.PDF", width = 6.5, height = 5.5)
CellDimPlot(UC_subset, group.by = "Monocle2_State", reduction = "DDRTree", label = TRUE, theme_use = "theme_blank") + trajectory
dev.off()
pdf("Pseudotime.PDF", width = 6.5, height = 5.5)
FeatureDimPlot(UC_subset, features = "Monocle2_Pseudotime", reduction = "DDRTree", theme_use = "theme_blank")
dev.off()
pdf("UBE2L6.PDF", width = 6.5, height = 5.5)
FeatureDimPlot(UC_subset, features = "UBE2L6", reduction = "DDRTree", theme_use = "theme_blank")
dev.off()
pdf("Glycosylation.PDF", width = 6.5, height = 5.5)
FeatureDimPlot(UC_subset, features = "Glycosylation", reduction = "DDRTree", theme_use = "theme_blank")
dev.off()

cds_seurat = UC_subset@tools$Monocle2$cds

pdf("plot_genes_in_pseudotime.PDF", width = 6.5, height = 5.5)

cds_subset <- cds_seurat[c("UBE2L6"), ]

# 按State分组计算拟时序中位数，并排序
state_order <- pData(cds_subset) %>%
	group_by(State) %>%
	summarise(median_pseudotime = median(Pseudotime)) %>%
	arrange(median_pseudotime) %>%
	pull(State)

# 将State转换为有序因子
pData(cds_subset)$State <- factor(pData(cds_subset)$State, 
																	levels = state_order)

# 创建基础绘图对象
p <- plot_genes_in_pseudotime(
	cds_subset,
	color_by = "State",
	cell_size = 1.8
) 

# 添加美化层
p + 
	scale_color_viridis_d(
		name = "State",
		option = "D",
		end = 0.9,
		guide = guide_legend(
			override.aes = list(size = 3),
			nrow = 2
		)
	) +
	theme_minimal(base_size = 12) +
	theme(
		legend.position = "bottom",
		legend.box = "horizontal",
		legend.spacing.x = unit(0.2, "cm"),
		panel.grid.major = element_line(linewidth = 0.2),
		axis.line = element_line(linewidth = 0.3),
		plot.title = element_text(hjust = 0.5, face = "bold")
	) +
	labs(
		x = "Pseudotime", 
		y = "Expression Level (log)",
		title = "UBE2L6 Expression Dynamics"
	)

dev.off()
#####相关性#####
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
		Pseudotime = UC_subset$Monocle2_Pseudotime,
		Score = UC_subset@meta.data[[ptm]],
		State = UC_subset$Monocle2_State
	)
	colnames(data) <- c("Pseudotime", "Score", "State")
	
	# 确保State是因子
	data$State <- as.factor(data$State)
	
	# 计算Spearman相关性
	cor_test <- cor.test(data$Pseudotime, data$Score, method = "spearman")
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
	pdf_file <- paste0("cor_Pseudotime_", safe_filename, ".pdf")
	
	# 生成标注文本
	cor_label <- paste0("cor = ", cor_value, "\n", "p = ", format.pval(p_value, digits = 3))
	
	# 创建美观的绘图
	p <- ggplot(data, aes(x = Pseudotime, y = Score, color = State)) +
		# 增强点图层：使用半透明填充色和深色边框
		geom_point(
			alpha = 0.7, 
			size = 3.5, 
			shape = 21, 
			aes(fill = State), 
			color = "black", 
			stroke = 0.3
		) +
		# 趋势线
		geom_smooth(
			aes(group = 1),
			method = "loess",
			formula = y ~ x,
			color = "#2c3e50",          # 深蓝色趋势线
			se = TRUE,
			fill = "#3498db",           # 浅蓝色置信区间
			linewidth = 1.8,
			alpha = 0.2
		) +
		# 颜色方案
		scale_fill_brewer(palette = "Set1") +
		scale_color_brewer(palette = "Set1") +
		
		# 主题设置
		theme_classic(base_size = 14) +
		labs(
			x = "Pseudotime", 
			y = paste(ptm, "Activity"),
			color = "State",
			fill = "State"
		) +
		theme(
			# 坐标轴加粗
			axis.line = element_line(linewidth = 0.8),
			axis.ticks = element_line(linewidth = 0.8),
			# 坐标轴标题加粗
			axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 10)),
			axis.title.y = element_text(size = 14, face = "bold", margin = margin(r = 10)),
			# 坐标刻度加粗
			axis.text = element_text(size = 12, face = "bold"),
			# 图例标题加粗
			legend.title = element_text(face = "bold", size = 12),
			legend.text = element_text(size = 11),
			# 背景和边距
			panel.background = element_rect(fill = "white", color = NA),
			plot.background = element_rect(fill = "white", color = NA),
			plot.margin = margin(15, 15, 15, 15)
		) +
		# 相关性标注
		annotate(
			geom = "text",
			x = Inf, y = Inf,
			label = cor_label,
			hjust = 1.1, vjust = 1.1,
			size = 6,
			color = "black",
			fontface = "bold"
		)
	
	# 保存高质量图形
	ggsave(
		pdf_file, 
		plot = p, 
		width = 7, 
		height = 6,
		dpi = 300
	)
}

# 保存相关性结果
write.csv(cor_results, "pseudotime_correlation_results.csv", row.names = FALSE)
#####提取state下游分析####
library(RcppML)
library(irGSEA)
UC_subset$State <- pData(cds_seurat)$State

# 设置默认 assay 为 RNA
DefaultAssay(UC_subset) <- "RNA"
UC_subset <- SeuratObject::UpdateSeuratObject(object = UC_subset)

# 基因集打分分析
cds_scored <- irGSEA.score(
	object = UC_subset,
	assay = "RNA",
	slot = "data", 
	seeds = 123,
	ncores = 1,
	min.cells = 3,
	min.feature = 0,
	custom = F,
	geneset = NULL,
	msigdb = T,
	species = "Homo sapiens",
	category = "H",  # 使用 Hallmark 基因集
	subcategory = NULL,
	geneid = "symbol",
	method = c("AUCell", "UCell", "singscore", "ssgsea", "viper"),
	aucell.MaxRank = NULL,
	ucell.MaxRank = NULL,
	kcdf = 'Gaussian'
)

# 整合分析结果按 State 分组
result.dge <- irGSEA.integrate(
	object = cds_scored,
	group.by = "State",  # 按细胞状态分组
	method = c("AUCell", "UCell", "singscore", "ssgsea", "viper")
)

# 绘制热图
pdf(file = "heatmap_state.pdf", width = 12, height = 6)
irGSEA.heatmap(
	object = result.dge,
	method = "RRA",  # 使用 Robust Rank Aggregation 方法
	top = 50,        # 显示前 50 个显著基因集
	show.geneset = NULL
)
dev.off()

#####阶段小提琴####
library(ggplot2)
library(ggpubr)
library(gghalves)

# 准备数据
plot_data <- data.frame(
	Glycosylation_expression = UC_subset$Phosphorylation,
	Subtype = UC_subset$Monocle2_State
)
colnames(plot_data) <- c("Glycosylation_expression", "Subtype")
plot_data$Subtype <- as.factor(plot_data$Subtype)

# 计算Kruskal-Wallis检验p值
kruskal_p_value <- kruskal.test(Glycosylation_expression ~ Subtype, data = plot_data)$p.value

# 创建显著性标签
sig_label <- ifelse(kruskal_p_value < 0.001, "***",
										ifelse(kruskal_p_value < 0.01, "**",
													 ifelse(kruskal_p_value < 0.05, "*", "")))

# 创建两两比较列表
my_comparisons <- list(c("1", "2"), c("1", "3"), c("2", "3"))

# 计算绘图范围
y_max <- max(plot_data$Glycosylation_expression) * 1.2

# 创建精美绘图
p <- ggplot(plot_data, aes(x = Subtype, y = Glycosylation_expression, fill = Subtype)) +
	# 左侧：带缺口的箱线图
	gghalves::geom_half_boxplot(
		side = "l",         # 左侧
		notch = TRUE,       # 带缺口
		outlier.shape = NA, # 隐藏异常值
		width = 0.35,       # 调整宽度
		alpha = 0.8,
		color = "black",
		lwd = 0.6,
		center = TRUE       # 确保箱线图居中
	) +
	# 左侧：抖动点（位于箱线图中央）
	gghalves::geom_half_point(
		size = 1.8,
		alpha = 0.6,
		color = "black",
		shape = 21,
		transformation = position_jitter(width = 0.07, height = 0)
	) +
	# 右侧：半边小提琴图（与箱线图保持间距）
	gghalves::geom_half_violin(
		side = "r",         # 右侧
		color = "black",     # 边框颜色
		lwd = 0.6,
		alpha = 0.7,
		trim = TRUE,
		scale = "width",
		width = 0.35,       # 调整宽度
		position = position_nudge(x = 0.08)  # 增加间距
	) +
	# 在小提琴图上添加中位线
	stat_summary(
		fun = median, 
		geom = "errorbar", 
		aes(ymax = ..y.., ymin = ..y..),
		width = 0.25, 
		color = "black", 
		linetype = "solid",
		size = 1.2,
		position = position_nudge(x = 0.08)  # 与右侧小提琴图对齐
	) +
	# 添加组间比较显著性（调整位置避免重叠）
	ggpubr::stat_compare_means(
		comparisons = my_comparisons,
		method = "wilcox.test",
		tip.length = 0.01,
		size = 4.5,
		vjust = 0.4,        # 垂直位置调整
		step.increase = 0.1, # 增加层级间距
		label = "p.signif"
	) +
	# 颜色方案
	scale_fill_manual(values = c("1" = "#acd5ab", "2" = "#feadac", "3" = "#adeada")) +
	
	# 坐标轴与标签
	labs(
		x = "State", 
		y = "Phosphorylation Activity",
		title = "Phosphorylation Activity Across Cell States"
	) +
	
	# 主题设置
	theme_minimal(base_size = 14) +
	theme(
		plot.title = element_text(
			size = 16, 
			face = "bold", 
			hjust = 0.5,
			margin = margin(b = 15)
		),
		axis.title.x = element_text(
			size = 14, 
			face = "bold", 
			margin = margin(t = 10)
		),
		axis.title.y = element_text(
			size = 14, 
			face = "bold", 
			margin = margin(r = 10)
		),
		axis.text.x = element_text(
			size = 12, 
			face = "bold",
			color = "black"
		),
		axis.text.y = element_text(
			size = 12, 
			face = "bold",
			color = "black"
		),
		axis.line = element_line(color = "black", size = 0.8),
		axis.ticks = element_line(color = "black", size = 0.8),
		panel.grid.major = element_line(color = "grey90", size = 0.3),
		panel.grid.minor = element_blank(),
		legend.position = "none",
		plot.background = element_rect(fill = "white", color = NA),
		panel.background = element_rect(fill = "white", color = NA)
	) +
	# 设置Y轴范围
	coord_cartesian(ylim = c(min(plot_data$Glycosylation_expression), y_max))

# 保存图形
ggsave("phosphorylation_state.pdf", plot = p, width = 9, height = 8, dpi = 300)
#####PPARG_State####
plot_data <- data.frame(UC_subset@assays$RNA$data["UBE2L6",], UC_subset$State)
colnames(plot_data) = c("PPARG_expression", "Subtype")
plot_data$Subtype <- as.factor(plot_data$Subtype)

# 使用Kruskal-Wallis检验计算p值
kruskal_p_value <- kruskal.test(PPARG_expression ~ Subtype, data = plot_data)$p.value

# 创建显著性标签
sig_label <- ifelse(kruskal_p_value < 0.001, "***",
										ifelse(kruskal_p_value < 0.01, "**",
													 ifelse(kruskal_p_value < 0.05, "*", "")))

library(ggplot2)

ggplot(plot_data, aes(x = Subtype, y = PPARG_expression)) +
	geom_violin(aes(fill = Subtype), alpha = 0.7) +
	geom_boxplot(aes(fill = Subtype), width = 0.15, outlier.shape = NA, color = "black") +
	geom_text(aes(x = 2, y = max(PPARG_expression)*1.1, label = sig_label),
						size = 5, vjust = -0.5) +
	scale_fill_manual(values = c("1"="#acd5ab", "2"="#feadac", "3"="#adeada")) +
	labs(x = "State", y = "UBE2L6_expression") +
	theme_classic() +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 8),
		legend.position = "top",
		panel.border = element_rect(color = "black", fill = NA),
		panel.grid.major.y = element_line(color = "grey90")
	) +
	coord_cartesian(ylim = c(min(plot_data$PPARG_expression), max(plot_data$PPARG_expression)*1.15))

ggsave("UBE2L6_expression_state.pdf", width = 6, height = 6)

#####表达情况聚类####
library(Mfuzz)
library(dplyr)
library(tidyr)
library(tidyverse)

# 提取UC_subset中包含在gene_sets中的列
ptm_cols <- names(gene_sets)  # 获取所有PTM通路名称
available_ptms <- ptm_cols[ptm_cols %in% colnames(UC_subset@meta.data)]  # 确保列存在于UC_subset中

# 创建包含所需列的数据框
ptm_data <- UC_subset@meta.data %>%
	dplyr::select(Monocle2_State, all_of(available_ptms)) %>%
	mutate(Monocle2_State = as.factor(Monocle2_State))  # 确保状态是因子

# 计算每个状态的平均值
state_means <- ptm_data %>%
	group_by(Monocle2_State) %>%
	summarise(across(all_of(available_ptms), mean, na.rm = TRUE))

# 转换数据框格式
result_df <- state_means %>%
	pivot_longer(cols = -Monocle2_State, 
							 names_to = "Pathway", 
							 values_to = "Mean_Value") %>%
	pivot_wider(names_from = Monocle2_State, 
							values_from = Mean_Value)

# 设置行名为通路名称
result_df <- result_df %>% column_to_rownames("Pathway")

#构建对象
mfuzz_class <- new('ExpressionSet',exprs = as.matrix(result_df))

#预处理缺失值或者异常值
mfuzz_class <- filter.NA(mfuzz_class, thres = 0.25)
mfuzz_class <- fill.NA(mfuzz_class, mode = 'mean')
mfuzz_class <- filter.std(mfuzz_class, min.std = 0)

#标准化数据
mfuzz_class <- standardise(mfuzz_class)

#Mfuzz 基于 fuzzy c-means 的算法进行聚类，详情 ?mfuzz
#需手动定义目标聚类群的个数，例如这里我们为了重现原作者的结果，设定为 10，即期望获得 10 组聚类群
#需要设定随机数种子，以避免再次运行时获得不同的结果
set.seed(123)
cluster_num <- 6
mfuzz_cluster <- mfuzz(mfuzz_class, c = cluster_num, m = mestimate(mfuzz_class))

library(RColorBrewer)
library(ggplot2)

# 创建自定义美化版的 Mfuzz 绘图函数
mfuzz_plot <- function(eset, cl, mfrow = c(1,1), colo, min.mem = 0, time.labels, new.window = TRUE) {
	# 创建更美观的颜色方案
	if (missing(colo)) {
		colo <- colorRampPalette(c("#2c7bb6", "#ffffbf", "#d7191c"))(100)
	}
	
	# 设置绘图布局
	opar <- par(no.readonly = TRUE)
	on.exit(par(opar))
	par(mfrow = mfrow, mar = c(5, 5, 4, 2) + 0.1)
	
	# 获取聚类中心
	centers <- cl$centers
	ncluster <- nrow(centers)
	
	# 设置时间点标签
	if (missing(time.labels)) {
		time.labels <- colnames(eset)
	}
	
	# 绘制每个聚类
	for (i in 1:ncluster) {
		# 获取当前聚类中心
		center <- centers[i, ]
		
		# 创建空白绘图区域
		plot(1, type = "n", 
				 xlim = c(1, length(center)), 
				 ylim = range(centers), 
				 xlab = "", ylab = "", 
				 axes = FALSE,
				 main = paste0("Cluster ", i, " (", sum(cl$cluster == i), " pathways)"),
				 cex.main = 1.8, font.main = 2, col.main = "#333333")
		
		# 添加坐标轴
		axis(1, at = 1:length(center), labels = time.labels, 
				 cex.axis = 1.5, col.axis = "#333333", col = "gray70", lwd = 1.5)
		axis(2, cex.axis = 1.5, col.axis = "#333333", col = "gray70", lwd = 1.5)
		
		# 添加网格线
		grid(NA, NULL, col = "gray90", lty = 1, lwd = 0.8)
		abline(h = 0, col = "gray70", lwd = 1.5)
		
		# 添加聚类中心线
		lines(1:length(center), center, 
					col = "#2c3e50", lwd = 3.5, type = "o", pch = 19, cex = 1.5)
		
		# 添加聚类成员通路（透明度较低）
		cluster_members <- exprs(eset)[cl$cluster == i, , drop = FALSE]
		for (j in 1:nrow(cluster_members)) {
			lines(1:length(center), cluster_members[j, ], 
						col = adjustcolor("#3498db", alpha.f = 0.5), 
						lwd = 1.2)
		}
		
		# 添加坐标轴标签
		mtext("Cell State", side = 1, line = 3.5, cex = 1.2, font = 2, col = "#333333")
		mtext("Standardized Activity", side = 2, line = 3.5, cex = 1.2, font = 2, col = "#333333")
		
		# 添加背景色
		rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], 
				 col = adjustcolor("#f8f9fa", alpha.f = 0.5), border = NA)
		
		# 添加边框
		box(lwd = 2, col = "gray70")
	}
}

# 使用自定义函数绘制美化版图形
pdf("plot_PTMD_cluster.pdf", width = 14, height = 10)
mfuzz_plot(
	mfuzz_class, 
	mfuzz_cluster, 
	mfrow = c(2, 3),  # 2行3列布局
	colo = colorRampPalette(c("#2c7bb6", "#ffffbf", "#d7191c"))(100),  # 蓝-黄-红渐变
	time.labels = colnames(mfuzz_class)  # 使用状态作为标签
)
dev.off()
#####拟时序聚类热图####
library(ClusterGVis)
diff_test_res <- differentialGeneTest(cds_seurat,
																			fullModelFormulaStr = "~sm.ns(Pseudotime)")
diff_test_res1 <- diff_test_res %>%
	filter(num_cells_expressed > 100)
df=plot_pseudotime_heatmap2(cds_seurat[row.names(subset(diff_test_res1,qval<1e-4)),],
														num_clusters=6)
gene=sample(df$wide.res$gene,20,replace=F)

# 创建 PDF 文件
pdf("plot_genes_heatmap.PDF", width=6, height=8, onefile=FALSE)
visCluster(object=df, plot.type="heatmap", markGenes=gene)
dev.off()

#####差异分析####
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(ggpubr)

# 提取State 1和State 3的细胞
state_subset <- subset(UC_subset, subset = Monocle2_State %in% c(1, 3))

# 获取所有可用的通路名称
available_ptms <- names(gene_sets)[names(gene_sets) %in% colnames(state_subset@meta.data)]

# 创建差异分析数据框
diff_results <- data.frame(
	Pathway = character(),
	Avg_State1 = numeric(),
	Avg_State3 = numeric(),
	Log2FC = numeric(),
	p_value = numeric(),
	stringsAsFactors = FALSE
)

# 循环分析每个通路
for (ptm in available_ptms) {
	# 提取数据
	state1_data <- state_subset@meta.data %>%
		filter(Monocle2_State == 1) %>%
		pull(!!ptm)
	
	state3_data <- state_subset@meta.data %>%
		filter(Monocle2_State == 3) %>%
		pull(!!ptm)
	
	# 计算平均值
	avg1 <- mean(state1_data, na.rm = TRUE)
	avg3 <- mean(state3_data, na.rm = TRUE)
	
	# 计算log2 fold change (State3 vs State1)
	log2fc <- log2(avg3 / avg1)
	
	# 执行Wilcoxon秩和检验
	p_val <- wilcox.test(state1_data, state3_data)$p.value
	
	# 添加到结果
	diff_results <- rbind(diff_results, data.frame(
		Pathway = ptm,
		Avg_State1 = avg1,
		Avg_State3 = avg3,
		Log2FC = log2fc,
		p_value = p_val
	))
}

# 多重检验校正
diff_results$p_adj <- p.adjust(diff_results$p_value, method = "BH")

# 添加显著性标记
diff_results$Significance <- cut(
	diff_results$p_adj,
	breaks = c(0, 0.001, 0.01, 0.05, 1),
	labels = c("***", "**", "*", "NS"),
	include.lowest = TRUE
)

# 保存结果
write.csv(diff_results, "pathway_diff_state1_vs_state3.csv", row.names = FALSE)

# 创建美化版火山图
volcano_plot <- ggplot(diff_results, aes(x = Log2FC, y = -log10(p_adj))) +
	# 添加渐变填充和大小的点
	geom_point(
		aes(fill = -log10(p_adj), size = -log10(p_adj)), 
		shape = 21, 
		color = "black", 
		stroke = 0.5,
		alpha = 0.9
	) +
	# 添加参考线
	geom_vline(xintercept = 0, linetype = "dashed", color = "grey50", size = 0.8) +
	geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey50", size = 0.8) +
	
	# 添加通路标签
	geom_text_repel(
		data = subset(diff_results, p_adj < 0.05 & abs(Log2FC) > 0.5),
		aes(label = Pathway),
		size = 4.5,
		fontface = "bold",
		box.padding = 0.5,
		point.padding = 0.2,
		max.overlaps = 30,
		segment.color = "grey40",
		segment.size = 0.4,
		min.segment.length = 0.1,
		direction = "both",
		nudge_y = 0.2
	) +
	
	# 添加顶部箭头标注
	annotate(
		"text",
		x = max(diff_results$Log2FC, na.rm = TRUE) * 0.9,
		y = max(-log10(diff_results$p_adj), na.rm = TRUE) * 1.05,
		label = "Enriched in State 3",
		size = 5.5,
		color = "#d73027",
		fontface = "bold",
		hjust = 1
	) +
	# 添加底部箭头标注
	annotate(
		"text",
		x = min(diff_results$Log2FC, na.rm = TRUE) * 0.9,
		y = max(-log10(diff_results$p_adj), na.rm = TRUE) * 1.05,
		label = "Enriched in State 1",
		size = 5.5,
		color = "#4575b4",
		fontface = "bold",
		hjust = 0
	) +
	# 颜色和大小渐变设置
	scale_fill_gradientn(
		name = bquote(atop(-Log[10]~"adjusted",
											 "p-value")),
		colours = c("#4575b4", "#74add1", "#e0f3f8", "#ffffbf", "#fee090", "#fdae61", "#d73027"),
		limits = c(0, max(-log10(diff_results$p_adj), na.rm = TRUE)),
		breaks = scales::pretty_breaks(n = 5),
		guide = guide_colorbar(
			title.position = "top",
			title.hjust = 0.5,
			barwidth = unit(3, "cm"),
			barheight = unit(0.3, "cm")
		)
	) +
	scale_size_continuous(
		name = bquote(atop(-Log[10]~"adjusted",
											 "p-value")),
		range = c(2, 8),
		breaks = scales::pretty_breaks(n = 5),
		guide = guide_legend(
			title.position = "top",
			title.hjust = 0.5,
			override.aes = list(color = "black")
		)
	) +
	
	# 坐标轴和标签
	labs(
		x = expression(Log[2]~Fold~Change~(State~3~vs~State~1)),
		y = expression(-Log[10]~adjusted~p~value),
		title = "Pathway Activity Differences",
		subtitle = "State 1 vs State 3"
	) +
	
	# 主题设置
	theme_minimal(base_size = 14) +
	theme(
		legend.position = "bottom",
		legend.box = "horizontal",
		legend.direction = "horizontal",
		legend.title = element_text(face = "bold", size = 12, vjust = 0.5),
		legend.text = element_text(size = 10),
		legend.spacing.x = unit(0.5, "cm"),
		panel.border = element_rect(color = "black", fill = NA, size = 1.2),
		axis.text = element_text(color = "black", face = "bold", size = 12),
		axis.title = element_text(face = "bold", size = 14),
		plot.title = element_text(face = "bold", hjust = 0.5, size = 20, margin = margin(b = 10)),
		plot.subtitle = element_text(hjust = 0.5, size = 14, color = "grey40", margin = margin(b = 15)),
		panel.grid.major = element_line(color = "grey92", size = 0.3),
		plot.background = element_rect(fill = "white", color = NA),
		plot.margin = margin(20, 20, 20, 20)
	) +
	
	# 扩展绘图区域以容纳顶部标签
	coord_cartesian(
		ylim = c(0, max(-log10(diff_results$p_adj), na.rm = TRUE) * 1.1),
		clip = "off"
	)

# 保存图形
ggsave("pathway_volcano_state1_vs_state3.pdf", volcano_plot, width = 10, height = 9)

#####小提琴图####
plot_subtype_pathways <- function(pathway_list, title) {
	# 数据转换
	plot_data <- as.data.frame(state_subset@meta.data[,pathway_list]) %>%
		mutate(Subtype = state_subset$Monocle2_State) %>%
		pivot_longer(
			cols = -Subtype,
			names_to = "Pathway",
			values_to = "Score"
		) %>%
		mutate(
			Pathway = factor(Pathway, levels = pathway_list),
			Subtype = as.factor(Subtype)
		)
	
	# 计算显著性标记
	p_values <- sapply(pathway_list, function(p) {
		wilcox.test(Score ~ Subtype, data = filter(plot_data, Pathway == p))$p.value
	})
	
	sig_labels <- ifelse(p_values < 0.001, "***",
											 ifelse(p_values < 0.01, "**",
											 			 ifelse(p_values < 0.05, "*", "")))
	
	# 创建精美绘图
	p <- ggplot(plot_data, aes(x = Pathway, y = Score, fill = Subtype)) +
		# 添加组间分隔线（竖虚线）
		geom_vline(
			xintercept = seq(1.5, length(pathway_list) - 0.5),
			color = "gray70",
			linetype = "dashed",
			linewidth = 0.5
		) +
		# 小提琴图 - 使用半边效果
		gghalves::geom_half_violin(
			aes(fill = Subtype),
			position = position_dodge(0.8),
			side = "l", 
			scale = "width",
			width = 0.7,
			alpha = 0.5,
			color = NA
		) +
		# 箱线图 - 带缺口
		geom_boxplot(
			aes(color = Subtype),
			width = 0.3,
			position = position_dodge(0.8),
			outlier.shape = NA,
			notch = TRUE,
			notchwidth = 0.5,
			alpha = 0.8,
			linewidth = 0.6
		) +
		# 抖动点 - 半透明
		geom_point(
			aes(color = Subtype),
			position = position_jitterdodge(jitter.width = 0.15, dodge.width = 0.8),
			size = 0.4,
			alpha = 0.4
		) +
		# 显著性标记
		geom_text(
			data = data.frame(Pathway = pathway_list, label = sig_labels),
			aes(x = Pathway, y = max(plot_data$Score) * 1.15, label = label),
			size = 5, 
			vjust = 0.5,
			fontface = "bold",
			inherit.aes = FALSE
		) +
		# 颜色方案
		scale_fill_manual(
			values = c("3" = "#E64B35", "1" = "#4DBBD5"),
			name = "Group"
		) +
		scale_color_manual(
			values = c("3" = "#B71C1C", "1" = "#006064"),
			name = "Group",
			guide = "none"
		) +
		# 标签和标题
		labs(
			title = title,
			x = "",
			y = "Pathway Activity Score"
		) +
		# 主题设置
		theme_minimal(base_size = 13) +
		theme(
			axis.text.x = element_text(
				angle = 45, 
				hjust = 1, 
				face = "bold", 
				size = 11,
				color = "#333333"
			),
			axis.text.y = element_text(
				face = "bold",
				size = 11,
				color = "#333333"
			),
			axis.title.y = element_text(
				face = "bold",
				size = 12,
				margin = margin(r = 10)
			),
			plot.title = element_text(
				hjust = 0.5, 
				size = 16, 
				face = "bold",
				margin = margin(b = 8)
			),
			plot.subtitle = element_text(
				hjust = 0.5, 
				size = 12, 
				color = "#666666",
				margin = margin(b = 15)
			),
			legend.position = "top",
			legend.title = element_text(face = "bold", size = 12),
			legend.text = element_text(size = 11),
			panel.grid.major.y = element_line(color = "grey92", linewidth = 0.6),
			panel.grid.minor.y = element_blank(),
			panel.grid.major.x = element_blank(),
			panel.grid.minor.x = element_blank(),
			panel.background = element_rect(fill = "white", color = NA),
			plot.background = element_rect(fill = "white", color = NA),
			panel.border = element_rect(color = "grey80", fill = NA, linewidth = 0.8),
			plot.margin = margin(15, 15, 15, 15)
		) +
		# 坐标轴范围
		coord_cartesian(ylim = c(min(plot_data$Score), max(plot_data$Score) * 1.2))
	
	return(p)
}

# 示例使用
# 假设 sig_pathways 是显著通路的列表
sig_plot <- plot_subtype_pathways(
	pathway_list = diff_results$Pathway[diff_results$p_adj < 0.05],
	title = "Significantly Different Pathways"
)

# 保存图形
ggsave("signature_pathways_plot.pdf", sig_plot, width = 12, height = 7)