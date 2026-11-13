library(Seurat)
library(tidyverse)
library(cowplot)
library(patchwork)
library(WGCNA)
library(hdWGCNA)
setwd("D:\\哮喘乳酸化单细胞开篇\\5.hdWGCNA")
theme_set(theme_cowplot()) #用cowplot主题进行绘图set.seed(12345)
oc <- SetupForWGCNA(oc,  gene_select = "fraction",  # 基因选择方法  
														fraction = 0.05,  # 基因在细胞中的表达比例阈值（表示基因需要在 5% 的细胞中表达才能被包括在内）  
														wgcna_name = "tutorial"  # hdWGCNA 实验的名称
														)
# ---- k-sweep diagnostic (add BEFORE your final MetacellsByGroups) ----
library(Matrix)

k_grid <- c(10, 25, 50)
k_stats <- purrr::map_dfr(k_grid, function(k0){
  
  tmp <- oc
  tmp <- SetupForWGCNA(
    tmp,
    gene_select = "fraction",
    fraction = 0.05,
    wgcna_name = "tutorial"
  )
  
  tmp <- MetacellsByGroups(
    seurat_obj = tmp,
    group.by = c("celltype","orig.ident"),
    k = k0,
    reduction = "harmony",
    slot = "counts",
    ident.group = "celltype",
    max_shared = 10  # 建议显式写出，避免默认值变动
  )
  
  tmp <- NormalizeMetacells(tmp)
  
  mc <- GetMetacellObject(tmp)
  mat <- GetAssayData(mc, slot = "data")  # normalized metacell matrix
  
  # sparsity = proportion of zeros
  sparsity <- 1 - (Matrix::nnzero(mat) / (nrow(mat) * ncol(mat)))
  data.frame(
    k = k0,
    n_metacells = ncol(mat),
    sparsity = sparsity
  )
})

# plot elbow-like curves
p1 <- ggplot(k_stats, aes(k, sparsity)) + geom_line() + geom_point() +
  labs(x="k (cells per metacell neighborhood)", y="Metacell matrix sparsity")
p2 <- ggplot(k_stats, aes(k, n_metacells)) + geom_line() + geom_point() +
  labs(x="k (cells per metacell neighborhood)", y="Number of metacells")

p1 | p2
# save to Supplementary Fig Sx
ggsave("k_sweep_diagnostic.pdf", width=9, height=4)

#创建metacells
oc <- MetacellsByGroups(
	seurat_obj = oc,# 输入的 Seurat 对象  
	group.by = c("celltype","orig.ident"),  # 按 "cluster" 和 "orig.ident" 这两列信息分组  
	k = 25,# 近邻参数，用于构建 k 近邻图，表示每个细胞的近邻数量  
	reduction = "harmony",# 降维方法，使用 "PCA" 进行批次效应矫正后降维  
	slot = 'counts',# 使用计数数据进行分析  
	ident.group = 'celltype'# 设置元细胞 Seurat 对象的 Idents（身份）
	)

# 标准化元细胞表达矩阵
oc <- NormalizeMetacells(oc)# 提取metacell
metacell_obj <- GetMetacellObject(oc)
table(metacell_obj$celltype,metacell_obj$orig.ident)

#提取感兴趣的细胞亚群
oc <- SetDatExpr(oc,group_name = "Mono/Mac",  # 感兴趣的分组名称，在 group.by 列中指定
												 group.by = 'celltype',  # 元数据列中包含细胞类型信息的列名。此列应在 MetacellsByGroups 中也使用过  
												 assay = 'RNA',  # 使用 RNA assay  
								         use_metacells = TRUE,  # 是否使用元细胞数据 (TRUE) 或全表达矩阵 (FALSE)  
												 slot = 'data'  # 使用标准化后的数据
												 )

oc <- TestSoftPowers(oc, 
										 powers = c(seq(1, 10, by = 1), 
														 seq(12, 30, by = 2))  # 选择要测试的软阈值范围  # networkType = 'signed'  # 可选的网络类型（"unsigned" 或 "signed hybrid"）
														 )
power_table <- GetPowerTable(oc)
pdf("power1.pdf", 6, 6)

# 第一个图：Scale Free Topology Model Fit, signed R^2
plot(power_table[,1], -sign(power_table[,3]) * power_table[,2],
		 xlab = "Soft Threshold (power)", ylab = "Scale Free Topology Model Fit, signed R^2", type = "n",
		 main = paste("Scale independence"))
# 用气泡代替文字
points(power_table[,1], -sign(power_table[,3]) * power_table[,2], pch = 19, col = "#7AC5CD", cex = 1.5)
abline(h = 0.8, col = "red")  # 设定R^2
grid()  # 添加背景网格

dev.off()

pdf("power2.pdf", 6, 6)

# 第二个图：Mean Connectivity
plot(power_table[,1], power_table[,5],
		 xlab = "Soft Threshold (power)", ylab = "Mean Connectivity", type = "n",
		 main = paste("Mean connectivity"))
# 用气泡代替文字
points(power_table[,1], power_table[,5], pch = 19, col = "#7AC5CD", cex = 1.5)
grid()  # 添加背景网格

dev.off()
oc <- ConstructNetwork(oc,soft_power = 5,# 使用前面选择的软阈值  
															 setDatExpr = FALSE,        # 不重新设置表达矩阵  
															 corType = "pearson",       # 使用 Pearson 相关性计算基因之间的相似性  
															 networkType = "signed",    # 构建签名网络（signed network）  
															 TOMType = "signed",        # 使用签名的拓扑重叠矩阵（TOM）  
															 minModuleSize = 50,        # 模块中基因的最小数量  
											         detectCutHeight=0.995,
															 mergeCutHeight = 0.25,      # 模块合并剪枝高度，越低模块越少  
															 tom_outdir = "TOM",        # TOM 矩阵的输出文件夹  
															 tom_name = 'Epi'           # TOM 矩阵文件的名称
															 )
pdf(file = "Dendrogram_tree.PDF",width = 8,height = 6)
PlotDendrogram(oc, main='Epi hdWGCNA Dendrogram')
dev.off()
#模块特征值(ME)
#归一化数据
oc <- ScaleData(oc, features=VariableFeatures(oc))
#计算ME值
oc <- ModuleEigengenes(oc,scale.model.use = "linear", # 使用线性模型进行归一化，其他选择为 "poisson" 或 "negbinom"  
															 assay = NULL, # 使用 Seurat 对象中的默认 assay
															 pc_dim = 1, # 只使用第一个主成分  
															 group.by.vars = "orig.ident"# 根据样本进行批次效应的去除
															 )
#提取样本harmonize去批次化后的harmonized module eigengenes (hMEs)数值
hMEs <- GetMEs(oc)
#提取未校正的（原始的）模块特征向量 (MEs)
MEs <- GetMEs(oc, harmonized = FALSE)
#查看
colnames(oc@misc[["tutorial"]][["hMEs"]])
seurat_obj <- ModuleConnectivity(oc,# 输入的 Seurat 对象，包含单细胞 RNA-seq 数据  
																 group.by = 'celltype', # 指定用于分组的元数据列，这里是 'celltype' 列，按细胞类型分组  
																 corFnc = "bicor",       # 使用双稳态相关性（bicor）计算皮尔逊相关系数  
																 corOptions = "use='p'", # 计算相关性时忽略缺失值（use='p'）  
																 harmonized = TRUE,      # 使用批次效应校正后的数据  
																 assay = NULL,           # 默认使用 Seurat 对象中的默认数据集  
																 slot = "data",          # 使用归一化数据（data）槽  
																 group_name = 'Mono/Mac'      # 感兴趣的细胞群名称
																 )

#改名后后模块赋予新的名称，以new_name为基础，后续附加个数字
seurat_obj <- ResetModuleNames(seurat_obj,new_name = "Epi")
#模块可视化
pdf(file = "KMEs.PDF",width = 12,height = 6)
PlotKMEs(seurat_obj, ncol=5)#by kME for each module
dev.off()
# 获取 Seurat 对象中的模块信息
modules <- GetModules(seurat_obj)
p <- PlotKMEs(seurat_obj,ncol = 3,# 设置绘图的列数为 5
							n_hubs = 20,         # 显示每个模块中的前20个关键基因（hub genes）
							text_size = 2,       # 设置关键基因名称的字体大小为 2
							plot_widths = c(3, 2) # 设置 kME 排名图和关键基因文本之间的相对宽度
							)
p
seurat_obj$Scoreing<-as.numeric(seurat_obj$Scoreing)
seurat_obj$phenotype <- ifelse(seurat_obj$phenotype == "AA", 1, 0)
seurat_obj$phenotype = as.factor(seurat_obj$phenotype)
cur_traits<-c("Scoreing","phenotype")

str(seurat_obj@meta.data[,cur_traits])
seurat_obj<-ModuleTraitCorrelation(
	seurat_obj,
	traits=cur_traits,
	features="hMEs",
	cor_method="pearson",
	group.by='celltype'
)
mt_cor<-GetModuleTraitCorrelation(seurat_obj)

#####相关性热图的绘制####
library(ggplot2)
library(reshape2)
library(dplyr)
library(ggnewscale)

# 从hdWGCNA结果中提取数据
moduleTraitCor <- t(mt_cor[["cor"]][["Mono/Mac"]])  # 转置矩阵（行=模块，列=特征）
moduleTraitPvalue <- t(mt_cor[["pval"]][["Mono/Mac"]])  # 转置矩阵

# 将矩阵转换为长格式
cor_long <- melt(moduleTraitCor, varnames = c("Module", "Group"))
pvalue_long <- melt(moduleTraitPvalue, varnames = c("Module", "Group"))

# 合并两个长格式数据框
data_long <- merge(cor_long, pvalue_long, by = c("Module", "Group"))
names(data_long) <- c("Module", "Group", "Correlation", "Pvalue")

# 将 Group 和 Module 转换为数值类型
data_long$Group_num <- as.numeric(factor(data_long$Group))
data_long$Module_num <- as.numeric(factor(data_long$Module))

# 生成上三角和下三角的坐标
triangle <- function(pairs, type = "upper") {
	x = c(0, 0, 1)
	y = c(0, 1, 1)
	if (type == "lower") {
		x = c(0, 1, 1)
		y = c(0, 0, 1)
	}
	mat = do.call(
		rbind,
		apply(pairs, 1, function (row) {
			a = row[1]
			b = row[2]
			data.frame(
				x = x + a - 0.5,
				y = y + b - 0.5,
				group = paste(a, b, sep = "-")
			)
		}))
	return(mat)
}

# 生成所有组合
pairs <- expand.grid(Group_num = unique(data_long$Group_num), Module_num = unique(data_long$Module_num))

# 获取上三角和下三角坐标
upper <- triangle(pairs, type = "upper")
lower <- triangle(pairs, type = "lower")

# 合并坐标
upper_lower <- cbind(upper, lower[, c("x", "y")])
colnames(upper_lower) <- c("upper.x", "upper.y", "group", "lower.x", "lower.y")

# 将坐标信息合并到数据中
data_long <- data_long %>%
	mutate(group = paste(Group_num, Module_num, sep = "-")) %>%
	left_join(upper_lower, by = "group")

# 计算文本位置
data_long$text_x <- data_long$Group_num
data_long$text_y <- data_long$Module_num
data_long$cor_x <- data_long$text_x - 0.2
data_long$cor_y <- data_long$text_y + 0.2
data_long$pval_x <- data_long$text_x + 0.2
data_long$pval_y <- data_long$text_y - 0.2

# 绘制热图
p <- ggplot(data_long, aes(x = Group_num, y = Module_num)) +
	geom_polygon(aes(x = upper.x, y = upper.y, fill = Correlation, group = group), color = "black") +
	scale_fill_gradient(low = "#c79cc3", high = "#ffa288", name = "Correlation", limits = c(-1, 1)) +
	new_scale_fill() +  # 使用 ggnewscale 包添加新的颜色填充
	geom_polygon(aes(x = lower.x, y = lower.y, fill = Pvalue, group = group), color = "black") +
	scale_fill_gradient(low = "#FFFAFA", high = "#0475b7", name = "P-value", limits = c(0, 0.5)) +
	geom_text(aes(x = cor_x, y = cor_y, label = round(Correlation, 2)), vjust = 0.5, hjust = 0.5, size = 3, color = "black") +
	geom_text(aes(x = pval_x, y = pval_y, label = formatC(Pvalue, format = "e", digits = 2)), vjust = 0.5, hjust = 0.5, size = 3, color = "black") +
	scale_x_continuous(breaks = unique(data_long$Group_num), labels = unique(data_long$Group)) +
	scale_y_continuous(breaks = unique(data_long$Module_num), labels = unique(data_long$Module)) +
	labs(x = "Group", y = "Module") +
	theme_minimal() +
	theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 10),
				axis.text.y = element_text(size = 10),
				legend.position = "right") +
	ggtitle("Module-trait relationships")

# 保存到 PDF 文件
ggsave("Heatmap.pdf", plot = p, width = 6, height = 6)

library(UCell)
library(ggplot2)
library(dplyr)
library(ggrepel)
library(colorspace)

# 步骤1：准备模块颜色信息（修正版）
modules_score <- modules %>%
	# 过滤保留有效模块（根据实际数据调整）
	filter(!grepl("grey", module, ignore.case = TRUE)) %>%
	# 每个模块保留唯一颜色信息
	group_by(module, color) %>%
	summarise() %>%
	ungroup()

# WGCNA标准颜色十六进制对照表（重要修正）
color_hex <- c(
	turquoise = "#1F77B4",
	blue = "#0000FF",
	yellow = "#FFD700",
	brown = "#8B4513",
	green = "#00FF00",
	grey = "#808080"
)

# 添加十六进制颜色代码
modules_score <- modules_score %>%
	mutate(
		color_hex = color_hex[tolower(color)],
		# 创建显示用模块标签
		module_label = paste0(module, " (", color, ")")
	)

# 步骤2：生成模块评分（保持不变）
seurat_obj <- ModuleExprScore(seurat_obj, n_genes = 25, method='UCell')

# 步骤3：创建绘图数据框（增加名称检查）
df <- data.frame(
	seurat_obj@misc$tutorial$module_scores,
	seurat_obj@reductions[["umap"]]@cell.embeddings,
	seurat_obj@meta.data
)

# 验证评分列与模块名称匹配性
valid_modules <- intersect(modules_score$module, colnames(df))
if (length(valid_modules) == 0) {
	stop("模块名称与评分列不匹配，请检查以下可能原因：
       1. ModuleExprScore生成的列名是否包含模块编号（如Epi1）
       2. modules数据框中的module列是否对应这些编号")
}

# 步骤4：创建颜色映射（使用验证后的模块）
color_mapping <- setNames(modules_score$color_hex, modules_score$module)

# 步骤5：预先计算标签位置（保持不变）
class_avg <- df %>%
	group_by(celltype) %>%
	summarise(umap_1 = median(umap_1),
						umap_2 = median(umap_2))

# 步骤6：优化后的绘图循环
for (method in valid_modules) {
	current_module <- modules_score %>% filter(module == method)
	current_color <- current_module$color_hex
	
	# 创建渐变颜色（带异常处理）
	tryCatch({
		gradient_colors <- c("#f0f0f0", lighten(current_color, 0.4), current_color)
	}, error = function(e) {
		message("颜色渐变生成失败，使用默认渐变")
		gradient_colors <- c("#f0f0f0", "#C0C0C0", current_color)
	})
	
	pdf(file = paste0(method, "_umap.pdf"), width = 7, height = 6)
	
	p <- ggplot(df, aes(x = umap_1, y = umap_2)) +
		geom_point(
			aes_string(color = method),  # 确保使用模块名称而非颜色名称
			size = 0.8,
			alpha = 0.9,
			shape = 16,
			stroke = 0
		) +
		ggrepel::geom_label_repel(
			aes(label = celltype),
			data = class_avg,
			size = 3.5,
			box.padding = 0.4,
			label.padding = 0.1,
			segment.color = "gray60",
			label.size = 0.3,
			color = "black",
			fill = alpha("white", 0.8)
		) +
		scale_color_gradientn(
			colors = gradient_colors,
			breaks = c(0, 0.5, 1),
			labels = scales::percent_format(),
			name = "Module Score",
			guide = guide_colorbar(
				barwidth = 1,
				barheight = 8,
				title.position = "top",
				title.hjust = 0.5,
				frame.colour = "black",
				ticks.colour = "black"
			)
		) +
		theme_classic(base_size = 12) +
		labs(
			x = "UMAP1", 
			y = "UMAP2", 
			title = current_module$module_label,
			subtitle = paste("Signature Score |", nrow(filter(modules, module == method)), "genes")
		) +
		theme(
			axis.title = element_text(face = "bold", colour = "black"),
			axis.text = element_text(color = "gray40"),
			plot.title = element_text(hjust = 0.5, face = "bold", size = 14, colour = current_color),
			plot.subtitle = element_text(hjust = 0.5, color = "gray50"),
			panel.border = element_rect(color = "gray30", fill = NA, size = 0.8),
			plot.background = element_rect(fill = "white"),
			legend.background = element_rect(fill = "white")
		)
	
	print(p)
	dev.off()
}

hdWGCNAgene=modules$gene_name[modules$module == "Epi1"]
write.table(hdWGCNAgene, file = "hdWGCNAgene.txt", sep = "\t", quote = F, 
						col.names = F,row.names = F)
saveRDS(oc, "hdwgcna.rds")
