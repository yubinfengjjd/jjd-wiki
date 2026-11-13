library(limma)
library(WGCNA)
library(org.Hs.eg.db)
rm(list = ls())
setwd("D:\\UC-20种修饰\\4.WGCNA")
expFile="./bindgeo.txt"   

rt=read.table(expFile, header=T, sep="\t", check.names=F) 
rt=as.matrix(rt)
rownames(rt)=rt[,1]
exp=rt[,2:ncol(rt)]
dimnames=list(rownames(exp),colnames(exp))
data=matrix(as.numeric(as.matrix(exp)),nrow=nrow(exp),dimnames=dimnames)
data=avereps(data)
dim(data)
datavar=apply(data,1,var)
data=data[which(datavar>quantile(datavar, probs = seq(0, 1, 0.25))[4]),]

# 查看结果维度
dim(data)

#定义分组
sample=gsub("(.*)_(.*)","\\2",colnames(data))
conData=data[,which(sample=="control")]
treatData=data[,which(sample=="treat")]
data=cbind(conData,treatData)
conCount=ncol(conData)
treatCount=ncol(treatData)
datExpr0 = t(data)
nGenes <- ncol(datExpr0)
nSamples <- nrow(datExpr0)
dim(datExpr0)
###剔除离群???
gsg = goodSamplesGenes(datExpr0, verbose = 3);
gsg$allOK

# 如果是False则运行下面这部分
if (!gsg$allOK){
	# Optionally, print the gene and sample names that were removed:
	if (sum(!gsg$goodGenes)>0) 
		printFlush(paste("Removing genes:", paste(names(data)[!gsg$goodGenes], collapse = ", ")));
	if (sum(!gsg$goodSamples)>0) 
		printFlush(paste("Removing samples:", paste(rownames(data)[!gsg$goodSamples], collapse = ", ")));
	# Remove the offending genes and samples from the data:
	data = data[gsg$goodSamples, gsg$goodGenes]
}

sampleTree <- hclust(dist(datExpr0), method = "average")
pdf(file = "1_sample_cluster.pdf", width = 9, height = 6)
par(cex = 0.6)
par(mar = c(0,4,2,0))
plot(sampleTree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.5, cex.axis = 1.5, cex.main = 2)
###??????
abline(h = 100, col = "red")
dev.off()
clust = cutreeStatic(sampleTree, cutHeight = 100, minSize = 10)
table(clust)
ks = (clust==1)
datExpr = datExpr0[ks, ]

powers = c(c(1:10), seq(from = 12, to=20, by=2))
SoftTh= pickSoftThreshold(datExpr, powerVector = powers, verbose = 5)
pdf("power1.pdf", 6, 6)

# 第一个图：Scale Free Topology Model Fit, signed R^2
plot(SoftTh$fitIndices[,1], -sign(SoftTh$fitIndices[,3]) * SoftTh$fitIndices[,2],
		 xlab = "Soft Threshold (power)", ylab = "Scale Free Topology Model Fit, signed R^2", type = "n",
		 main = paste("Scale independence"))
# 用气泡代替文字
points(SoftTh$fitIndices[,1], -sign(SoftTh$fitIndices[,3]) * SoftTh$fitIndices[,2], pch = 19, col = "#7AC5CD", cex = 1.5)
abline(h = 0.8, col = "red")  # 设定R^2
grid()  # 添加背景网格

dev.off()

pdf("power2.pdf", 6, 6)

# 第二个图：Mean Connectivity
plot(SoftTh$fitIndices[,1], SoftTh$fitIndices[,5],
		 xlab = "Soft Threshold (power)", ylab = "Mean Connectivity", type = "n",
		 main = paste("Mean connectivity"))
# 用气泡代替文字
points(SoftTh$fitIndices[,1], SoftTh$fitIndices[,5], pch = 19, col = "#7AC5CD", cex = 1.5)
grid()  # 添加背景网格

dev.off()

#查看最佳power值
SoftTh$powerEstimate
mypower =18
adjacency = adjacency(datExpr, power = mypower)
TOM = TOMsimilarity(adjacency)
dissTOM = 1-TOM

geneTree = hclust(as.dist(dissTOM), method = "average");
pdf(file="4_gene_clustering.pdf", width=8, height=6)
plot(geneTree, xlab="", sub="", main = "Gene clustering on TOM-based dissimilarity",
		 labels = FALSE, hang = 0.04)
dev.off()
minModuleSize = 70
dynamicMods = cutreeDynamic(dendro = geneTree, distM = dissTOM,
														deepSplit = 2, pamRespectsDendro = FALSE,
														minClusterSize = minModuleSize);
table(dynamicMods)
dynamicColors = labels2colors(dynamicMods)
table(dynamicColors)
pdf(file="5_Dynamic_Tree.pdf", width=8, height=6)
plotDendroAndColors(geneTree, dynamicColors, "Dynamic Tree Cut",
										dendroLabels = FALSE, hang = 0.03,
										addGuide = TRUE, guideHang = 0.05,
										main = "Gene dendrogram and module colors")
dev.off()

#####合并模块####
MEList = moduleEigengenes(datExpr0, colors = dynamicColors)
MEs = MEList$eigengenes
MEDiss = 1-cor(MEs);
METree = hclust(as.dist(MEDiss), method = "average")
pdf(file="6_Clustering_module.pdf", width=7, height=6)
plot(METree, main = "Clustering of module eigengenes",
		 xlab = "", sub = "")
MEDissThres = 0.2     #???и߶ȿ??޸?
abline(h=MEDissThres, col = "red")
dev.off()


merge = mergeCloseModules(datExpr0, dynamicColors, cutHeight = MEDissThres, verbose = 3)
mergedColors = merge$colors
mergedMEs = merge$newMEs
pdf(file="7_merged_dynamic.pdf", width=8, height=6)
plotDendroAndColors(geneTree, mergedColors, "Merged dynamic",
										dendroLabels = FALSE, hang = 0.03,
										addGuide = TRUE, guideHang = 0.05,
										main = "Gene dendrogram and module colors")
dev.off()
moduleColors = mergedColors
table(moduleColors)
colorOrder = c("grey", standardColors(50))
moduleLabels = match(moduleColors, colorOrder)-1
MEs = mergedMEs



group=gsub("(.*)_(.*)","\\2",rownames(datExpr))
design <- model.matrix(~0+group)  # 构建模型矩阵
colnames(design)= c("control","treat")  # 修改列名，获取分组信???
MES0 <- moduleEigengenes(datExpr,moduleColors)$eigengenes  # 计算模块特征向量
MEs = orderMEs(MES0)  # 对模块特征向量排???
moduleTraitCor <- cor(MEs,design,use = "p")  # 计算模块特征向量与表型的相关系数矩阵
moduleTraitPvalue <- corPvalueStudent(moduleTraitCor,nSamples)  # 计算相关系数矩阵的p???
textMatrix = paste(signif(moduleTraitCor,2),"\n(",
									 signif(moduleTraitPvalue,1),")",sep = "")  # 构建绘图时用的文本矩???
dim(textMatrix)=dim(moduleTraitCor)  # 修改文本矩阵的维度，与相关系数矩阵相???

pdf("Heatmap.pdf", 8, 12)  # 增加图像宽度
labeledHeatmap(
	Matrix = moduleTraitCor,
	xLabels = colnames(design),
	yLabels = names(MEs),
	ySymbols = names(MEs),
	colorLabels = FALSE,
	colors = blueWhiteRed(50),
	textMatrix = textMatrix,
	setStdMargins = TRUE,
	cex.text = 1,  # 更小的文本大小
	zlim = c(-1, 1),
	main = paste("Module-trait relationships")
)
dev.off()
# 加载必要的库
# 加载必要的库
# 加载必要的库
library(ggplot2)
library(reshape2)
library(dplyr)
library(ggnewscale)

# 假设 moduleTraitCor 和 moduleTraitPvalue 是两个矩阵
# moduleTraitCor 的行是颜色模块，列是 con 和 treat 组
# moduleTraitPvalue 的格式与 moduleTraitCor 相同

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
	geom_text(aes(x = cor_x, y = cor_y, label = round(Correlation, 2)), vjust = 0.5, hjust = 0.5, size = 5, color = "black") +
	geom_text(aes(x = pval_x, y = pval_y, label = formatC(Pvalue, format = "e", digits = 2)), vjust = 0.5, hjust = 0.5, size = 3, color = "black") +
	scale_x_continuous(breaks = unique(data_long$Group_num), labels = unique(data_long$Group)) +
	scale_y_continuous(breaks = unique(data_long$Module_num), labels = unique(data_long$Module)) +
	labs(x = "Group", y = "Module") +
	theme_minimal() +
	theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 12),
				axis.text.y = element_text(size = 12),
				legend.position = "right") +
	ggtitle("Module-trait relationships")

# 保存到 PDF 文件
ggsave("Heatmap.pdf", plot = p, width = 6, height = 6)


#####基因特征与模块相关性绘图
modNames = substring(names(MEs), c(3))  # 提取模块名称
geneModuleMembership = as.data.frame(cor(datExpr, MEs,
																				 use = "p",method = "spearman"))  #计算基因与模块的相关系数矩阵
MMPvalue = as.data.frame(corPvalueStudent(as.matrix(geneModuleMembership), nSamples))  # 计算相关系数矩阵的p???
dim(datExpr)
geneTraitSignificance <- as.data.frame(cor(datExpr,as.numeric(as.factor(group)),use = "p"))  # 计算基因与表型的相关系数矩阵
GSPvalue <- as.data.frame(corPvalueStudent(as.matrix(geneTraitSignificance),nSamples))  # 计算相关系数矩阵的p???
names(geneTraitSignificance) = paste("GS.", "AA", sep="")
names(GSPvalue) = paste("p.GS.", "AA", sep="")
# 定义需要分析的模块列表
module_list <- c("grey","green","brown","black")  # 在此处填入需要分析的模块名称

# 创建存储结果的列表
WGCNAgene_list <- list()

# 批量处理函数（美化 + 添加相关性趋势线）
analyze_module <- function(module) {
	column <- match(module, modNames)
	moduleGenes <- moduleColors == module
	module_genes <- dimnames(data.frame(datExpr))[[2]][moduleGenes]
	
	# 创建数据框
	c <- data.frame(
		MM = abs(geneModuleMembership[moduleGenes, column]),
		GS = abs(geneTraitSignificance[moduleGenes, 1]),
		row.names = module_genes
	)
	c$group <- ifelse(c$MM > 0.6 & c$GS > 0.2, TRUE, FALSE)
	
	# Spearman 相关性
	cor_result <- cor.test(c$MM, c$GS, method = "spearman", exact = FALSE)
	cor_label <- sprintf(
		"Spearman's rho = %.2f\np = %s",
		cor_result$estimate,
		ifelse(cor_result$p.value < 0.001, "< 0.001", format(cor_result$p.value, digits = 2))
	)
	
	p <- ggplot(c, aes(x = MM, y = GS, color = group)) +
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
		geom_vline(xintercept = 0.6, linetype = "dotted", color = "grey60",size = 1.2) +
		geom_hline(yintercept = 0.2, linetype = "dotted", color = "grey60",size = 1.2) +
		annotate("text",
						 x = min(c$MM) + 0.05 * diff(range(c$MM)),
						 y = max(c$GS) - 0.05 * diff(range(c$GS)),
						 label = cor_label, hjust = 0, color = "black", size = 5) +
		labs(
			title = paste("Module Membership vs. Gene Significance -", module),
			x = paste("Module Membership (", module, ")", sep = ""),
			y = "Gene Significance for RA"
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
	ggsave(paste0("MM_vs_GS_", module, ".pdf"), p, width = 7, height = 7, dpi = 300)
	
	# 返回符合条件的基因名
	rownames(c)[c$group]
}


# 批量执行分析
WGCNAgene_list <- lapply(module_list, function(mod) {
	analyze_module(mod)
})
names(WGCNAgene_list) <- module_list

# 查看结果
str(WGCNAgene_list)
selected_genes <- unlist(WGCNAgene_list)
union_genes <- unique(selected_genes)
write.table(union_genes, file = "WGCNA.txt", sep = "\t", quote = F, col.names = F,row.names = F)
