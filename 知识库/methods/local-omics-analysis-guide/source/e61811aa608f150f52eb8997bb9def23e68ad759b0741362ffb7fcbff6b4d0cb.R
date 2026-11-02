library(Seurat)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(GSEABase)
library(AUCell)
library(GSVA)
library(UCell)
library(singscore)
library(tidyverse)
setwd("D:\\UC-20种修饰\\16.20种修饰量化")
Addsingscore<-function(oc,signatures,seed=123,assay=null,slot="data"){
	set.seed(seed)
	if(is.null(assay)){
		assay=Seurat::DefaultAssay(UC)
	}
	matrix=Seurat::GetAssayData(object=UC,slot=slot,assay=assay)
	
	markers=signatures
	h.gsets.list=markers %>% purrr::compact()
	
	singscore.rank=singscore::rankGenes(as.data.frame(matrix))
	#calculate separately
	singscore.scores=list()
	for (i in seq_along(h.gsets.list)){
		if (any(stringr::str_detect(h.gsets.list[[i]],pattern = "\\+$|-$"))){
			h.gsets.list.positive=stringr::str_match(h.gsets.list[[i]],pattern="(.+)\\+")[,2] %>% purrr::discard(is.na)
			h.gsets.list.negative=stringr::str_match(h.gsets.list[[i]],pattern="(.+)-")[,2] %>% purrr::discard(is.na)
			if(length(h.gsets.list.positive)==0){
				singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list.negative,centerScore=F)
			}
			if(length(h.gsets.list.negative)==0){
				singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list.positive,centerScore=F)
			}
			if((length(h.gsets.list.positive)!=0)&(length(h.gsets.list.negative)!=0)){
				singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list.positive,downSet=h.gsets.list.negative,centerScore=F)
			}
		}else{
			singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list[[i]],centerScore=F)
		}
		TotalScore=NULL
		singscore.scores[[i]]=singscore.scores[[i]] %>% 
			dplyr::select(TotalScore) %>% 
			magrittr::set_colnames(names(h.gsets.list)[i])}
	names(singscore.scores)=names(h.gsets.list)
	singscore.scores=do.call(cbind,singscore.scores)
	UC=Seurat::AddMetaData(UC,as.data.frame(singscore.scores))
	return(UC)
}
DefaultAssay(UC) <- "RNA"

######获取评分基因集#####
library(readxl)
# 从Excel文件读取PTM基因集
ptm_data <- read_excel("inline-supplementary-material-2.xlsx", sheet = "Sheet1", skip = 1)

# 构建基因集列表
gene_sets <- list()
for (ptm in colnames(ptm_data)) {
	genes <- ptm_data[[ptm]]
	genes <- na.omit(genes)  # 移除NA值
	genes <- as.character(genes)
	genes <- genes[genes != "" & !grepl("^\\d{4}-\\d{2}-\\d{2}", genes)]  # 过滤日期值
	genes <- toupper(genes)  # 转为大写
	if (length(genes) > 0) {
		gene_sets[[ptm]] <- genes
	}
}

####循环处理####
for (pathway_name in names(gene_sets)) {
	genes <- gene_sets[[pathway_name]]
	cat("Processing pathway:", pathway_name, "\n")
	genes_list <- list(genes)
	genes_vector <- as.character(genes)
	##### AddModuleScore #####
	UC <- AddModuleScore(UC,
											 features = genes_list,
											 name = paste0(pathway_name, "_Add_Score"),
											 slot = "data")
	# 获取最后添加的列并重命名
	new_col <- paste0(pathway_name, "_AddModule")
	colnames(UC@meta.data)[ncol(UC@meta.data)] <- new_col
	
	##### AUCell #####
	cells_rankings <- AUCell_buildRankings(UC@assays$RNA$data, nCores=1)
	cells_AUC <- AUCell_calcAUC(list(genes = genes_vector), cells_rankings, 
															aucMaxRank = nrow(cells_rankings)*0.05)
	UC@meta.data[[paste0(pathway_name, "_AUCell")]] <- getAUC(cells_AUC)["genes", ]
	
	##### ssGSEA #####
	genes_ssGSEA = as.data.frame(genes)
	gene.expr <- as.matrix(UC@assays$RNA$data)
	ssGSEA.result <- ssgseaParam(gene.expr, genes_ssGSEA)
	ssGSEA.result <- gsva(ssGSEA.result)
	UC@meta.data[[paste0(pathway_name, "_ssGSEA")]] <- ssGSEA.result["genes", ]
	
	##### Ucell #####
	UC <- AddModuleScore_UCell(UC, features = list(temp = genes_vector),
														 name = paste0(pathway_name, "_Ucell_"),
														 assay = "RNA", slot = "data")
	colnames(UC@meta.data)[ncol(UC@meta.data)] <- paste0(pathway_name, "_Ucell")
	
	##### singscore #####
	UC <- Addsingscore(oc = UC, signatures = list(temp = genes_vector),
										 assay = "RNA", slot = "data")
	colnames(UC@meta.data)[ncol(UC@meta.data)] <- paste0(pathway_name, "_singscore")
	
	##### 综合评分 #####
	score_columns <- c(
		paste0(pathway_name, "_AddModule"),
		paste0(pathway_name, "_AUCell"),
		paste0(pathway_name, "_ssGSEA"),
		paste0(pathway_name, "_Ucell"),
		paste0(pathway_name, "_singscore"))
	
	UC@meta.data[[pathway_name]] <- rowSums(
		UC@meta.data[, score_columns], na.rm = TRUE
	)
}
save(UC,file = "PTMD_UC.Rdata")

#####随机森林#####
library(randomForest)
library(tidyverse)
library(dplyr)
library(stringr)
meta <- data.frame(UC@meta.data)
df = df[colnames(df)%in%gsub("-",".",names(gene_sets))]
#随机森林树
phenotype = ifelse(UC$phenotype == "UC",1,0)
y = phenotype
table(y)
x=as.matrix(cbind(y=y,df))
rf=randomForest(as.factor(y)~., data=x, ntree=500,nodesize = 5,importance = T,
								proximity = T,
								forest = T)
pdf(file="forest.pdf", width=6, height=6)
plot(rf, main="Random forest", lwd=4)
dev.off()

#查看基因的重要性
importance=importance(x=rf)

# 生成变量重要性条形图（深蓝色主题）
pdf(file="geneImportance.pdf", width=8, height=6)
par(mar = c(5, 12, 4, 2), mgp = c(3, 0.5, 0))  # 增大左侧边距

imp_scores <- importance[, "MeanDecreaseAccuracy"]
imp_sorted <- sort(imp_scores, decreasing = FALSE)

bar_col <- "#087687"

# 修改xlim左边界为0，并调整标签边距
bp <- barplot(imp_sorted, 
							horiz = TRUE, 
							las = 1,
							col = bar_col,
							border = NA,
							space = 0.5,
							xlab = "Mean Decrease Accuracy",
							main = "Feature Importance Ranking\n(Random Forest)",
							cex.names = 0.7,
							xlim = c(0, max(imp_sorted)*1.1),  # 左边界设为0
							mgp = c(3.5, 0.5, 0))  # 调整轴标签位置

grid(nx = NA, ny = NULL, col = "gray90", lty = 2)

legend("bottomright", 
			 legend = "Mean Decrease Accuracy",
			 fill = bar_col,
			 bty = "n", 
			 cex = 0.8)

dev.off()

#####最佳修饰水平小提琴图####
output_dir <- "MetaAnalysis_Results"
type_groups <- c("UC", "HC")
color_scheme <- c("#FF7F0E", "#1F77B4")
plot_data <- UC@meta.data %>% 
	rownames_to_column("CellID") %>% 
	filter(phenotype %in% type_groups) %>%
	mutate(Group = factor(phenotype, levels = type_groups)) %>% 
	dplyr::select(CellID, Group, celltype, Glycosylation)  # 确保包含celltype和Scoreing列

#统计学检验
# 按celltype分组计算统计量
stat_data <- plot_data %>%
	group_by(celltype) %>%  # 按细胞类型分组
	summarise(
		p_value = wilcox.test(Glycosylation ~ Group)$p.value,  # 组间比较
		y_max = max(Glycosylation) * 1.1,  # 自动计算标注高度
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
		mean = mean(Glycosylation, na.rm = TRUE),
		sd = sd(Glycosylation, na.rm = TRUE),
		y_pos = quantile(Glycosylation, 0.95),  # 自动定位到小提琴图上部
		.groups = "drop"
	) %>%
	mutate(label = sprintf("Mean: %.2f\nSD: %.2f", mean, sd))

ggplot(plot_data, aes(x = celltype, y = Glycosylation)) +  # x轴改为celltype
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
	labs(title = "Glycosylation Comparison Across Cell Types",
			 y = "Pathway Combined Score",
			 x = "Cell Types") +  # 修改x轴标签
	# 主题设置
	theme_classic(base_size = 14) +
	theme(
		plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
		axis.text.x = element_text(angle = 30, hjust = 1, size = 8),
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

#####评分气泡图####
source("./1.R")
library(RColorBrewer)
library(viridis)
library(wesanderson)
library(cowplot)
n=30
qual_col_pals=brewer.pal.info[brewer.pal.info$category == "qual",]
col_vector=unlist(mapply(brewer.pal,qual_col_pals$maxcolors,rownames(qual_col_pals)))
pie(rep(1,n),col=sample(col_vector,n))
color=grDevices::colors()[grep('gr(a|e)y',grDevices::colors(),invert=T)]
pie(rep(6,n),col=sample(color,n))
col_vector

col_vector=c(wes_palette("Darjeeling1"),wes_palette("GrandBudapest1"),wes_palette("Cavalcanti1"),wes_palette("GrandBudapest2"),wes_palette("FantasticFox1"))
pal=wes_palette("Zissou1",10,type="continuous")
pal2=wes_palette("Zissou1",5,type="continuous")
pal[3:10]
pdf(file="scoredotplot.pdf", width=6, height=8)
DotPlotScores(object = UC, scores = c("Glycosylation_AddModule","Glycosylation_AUCell",
																			"Glycosylation_ssGSEA","Glycosylation_Ucell",
																			"Glycosylation_singscore","Glycosylation"), dot.scale = 6) +
	RotatedAxis() +
	scale_x_discrete( labels = function(x) {
		sapply(x, function(single_x) {
			parts <- strsplit(single_x, "_", fixed = TRUE)[[1]]
			if (length(parts) > 1) {
				return(parts[2])
			} else {
				return(single_x)
			}
		})
	}) +  # 修改坐标轴标签
	theme(axis.text.x = element_text(angle = 45, face = "italic", hjust = 1),
				axis.text.y = element_text(face = "bold")) +
	scale_colour_gradientn(colours = pal) +
	theme(legend.position = "right") +
	labs(title = "Glycosylation_score", y = "", x = "")
dev.off()

library(SCP)
UC[["RNA"]] <- as(object = UC[["RNA"]], Class = "Assay")
table(UC$celltype)
pdf(file="Glycosylation_violin.pdf", width=10, height=6)
FeatureStatPlot(
	srt = UC, 
	group.by = "celltype",
	stat.by = c("Glycosylation"), 
	add_box = TRUE)
dev.off()
#####UMAP图####
library(ggplot2)
library(dplyr)
library(ggrepel)
library(viridis)
# 假设df是您的数据框
df <- data.frame(UC@meta.data, UC@reductions[["umap"]]@cell.embeddings)

# 预先计算细胞类型标签位置（只需计算一次）
class_avg <- df %>%
	group_by(celltype) %>%
	summarise(umap_1 = median(umap_1),
						umap_2 = median(umap_2))
colnames(df)
# 需要绘制的评分方法列表
score_methods <- c("Glycosylation")

# 循环生成UMAP图
for (method in score_methods) {
	# 动态生成文件名
	pdf(file = paste0(method, "_umap.pdf"), width = 7, height = 6)
	
	# 创建基础绘图对象
	p <- ggplot(df, aes(x = umap_1, y = umap_2)) +
		# 动态映射颜色到当前方法
		geom_point(aes_string(color = method), size = 0.5, alpha = 0.8) +
		# 细胞类型标签
		ggrepel::geom_label_repel(
			aes(label = celltype),
			data = class_avg,
			size = 3,
			box.padding = 0.35,
			segment.color = NA,
			label.size = 0.25,
			color = "black",
			fill = "white"
		) +
		# 颜色标度
		scale_color_viridis(
			option = "I",
			name = "Score",
			guide = guide_colorbar(
				barwidth = 0.8,
				barheight = 5,
				title.position = "top",
				title.hjust = 0.5
			)
		) +
		# 主题设置
		theme_classic() +
		labs(x = "UMAP1", y = "UMAP2", title = paste(method, "Score")) +
		theme(
			axis.title = element_text(size = 12, face = "bold"),
			axis.text = element_text(color = "black"),
			plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
			panel.border = element_rect(color = "#256a53", size = 1.5, fill = NA),
			panel.background = element_rect(fill = "#f5f5f5"),
			legend.position = "right"
		)
	
	print(p)
	dev.off()
}