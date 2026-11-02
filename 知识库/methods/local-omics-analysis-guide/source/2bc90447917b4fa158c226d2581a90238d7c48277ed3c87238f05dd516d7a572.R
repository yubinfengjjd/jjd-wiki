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
setwd("D:\\fyb\\UC-20\\16.20种修饰量化")
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

#####PTMD通路集评分#####
library(data.table)
library(dplyr)
library(tibble)
library(Seurat)
library(AUCell)
library(GSVA)

## =========================
## 0) 读入基因 & 构建 up/down gene sets
## =========================
gene_df   <- data.table::fread("./output_mRNA_selected.txt", data.table = FALSE)
main_gene <- unique(na.omit(as.character(gene_df[[1]])))

rt <- data.table::fread("./PTMDS1_vs_PTMDS2_DEG.csv") %>%
  dplyr::select(logFC, symbol) %>%
  tibble::column_to_rownames("symbol")

# 只保留在 DEG 表里出现的 main_gene
keep_gene <- intersect(main_gene, rownames(rt))
data      <- rt[keep_gene, , drop = FALSE]

up_ragulate   <- rownames(data)[data$logFC > 0]
down_ragulate <- rownames(data)[data$logFC < 0]

gene_sets_raw <- list(PTMDs_up = up_ragulate,
                      PTMDs_down = down_ragulate)

## =========================
## 1) 表达矩阵 & 与表达矩阵做交集
## =========================
gene.expr <- GetAssayData(UC, assay = "RNA", slot = "data")  # genes x cells

gene_sets <- lapply(gene_sets_raw, function(gs) intersect(gs, rownames(gene.expr)))

cat("PTMDs_up 交集基因数:", length(gene_sets$PTMDs_up), "\n")
cat("PTMDs_down交集基因数:", length(gene_sets$PTMDs_down), "\n")

if (length(gene_sets$PTMDs_up) == 0 || length(gene_sets$PTMDs_down) == 0) {
  stop("PTMDs_up 或 PTMDs_down 与表达矩阵无交集，无法进行 up-down 打分。")
}

## 一个小工具：每次调用“包装函数”后，把新增的最后一列重命名
.rename_last_col <- function(obj, new_name) {
  colnames(obj@meta.data)[ncol(obj@meta.data)] <- new_name
  obj
}

## =========================
## 2) AddModuleScore（Seurat）：分别 up / down，再做差
## =========================
UC <- AddModuleScore(
  object   = UC,
  features = list(gene_sets$PTMDs_up, gene_sets$PTMDs_down),
  name     = "PTMDs_Add_",
  assay    = "RNA",
  slot     = "data"
)
# 这两列顺序对应 features 的顺序：1=up, 2=down
colnames(UC@meta.data)[(ncol(UC@meta.data)-1)] <- "PTMDs_Add_up"
colnames(UC@meta.data)[(ncol(UC@meta.data))]   <- "PTMDs_Add_down"

## =========================
## 3) AUCell：分别 up / down，再做差
## =========================
cells_rankings <- AUCell_buildRankings(gene.expr, nCores = 1, plotStats = FALSE)
cells_AUC <- AUCell_calcAUC(
  geneSets   = gene_sets,
  rankings   = cells_rankings,
  aucMaxRank = nrow(cells_rankings) * 0.05
)
auc_mat <- getAUC(cells_AUC)  # rows=geneSets, cols=cells

UC@meta.data[["PTMDs_AUCell_up"]]   <- as.numeric(auc_mat["PTMDs_up",   rownames(UC@meta.data)])
UC@meta.data[["PTMDs_AUCell_down"]] <- as.numeric(auc_mat["PTMDs_down", rownames(UC@meta.data)])

## =========================
## 4) ssGSEA（GSVA）：分别 up / down，再做差
##   兼容 GSVA 新旧接口
## =========================
if (exists("ssgseaParam")) {
  ss_param <- ssgseaParam(as.matrix(gene.expr), gene_sets)
  ss_mat   <- gsva(ss_param)   # rows=geneSets, cols=cells
} else {
  ss_mat <- GSVA::gsva(as.matrix(gene.expr), gene_sets, method = "ssgsea", ssgsea.norm = TRUE)
}

UC@meta.data[["PTMDs_ssGSEA_up"]]   <- as.numeric(ss_mat["PTMDs_up",   rownames(UC@meta.data)])
UC@meta.data[["PTMDs_ssGSEA_down"]] <- as.numeric(ss_mat["PTMDs_down", rownames(UC@meta.data)])

## =========================
## 5) UCell（你的包装函数）：分别 up / down，再做差
## =========================
UC <- AddModuleScore_UCell(
  UC,
  features = list(PTMDs_up = gene_sets$PTMDs_up),
  name     = "PTMDs_Ucell_",
  assay    = "RNA",
  slot     = "data"
)
UC <- .rename_last_col(UC, "PTMDs_Ucell_up")

UC <- AddModuleScore_UCell(
  UC,
  features = list(PTMDs_down = gene_sets$PTMDs_down),
  name     = "PTMDs_Ucell_",
  assay    = "RNA",
  slot     = "data"
)
UC <- .rename_last_col(UC, "PTMDs_Ucell_down")

## =========================
## 6) singscore（你的包装函数）：分别 up / down，再做差
## =========================
UC <- Addsingscore(
  oc         = UC,
  signatures = list(PTMDs_up = gene_sets$PTMDs_up),
  assay      = "RNA",
  slot       = "data"
)
UC <- .rename_last_col(UC, "PTMDs_singscore_up")

UC <- Addsingscore(
  oc         = UC,
  signatures = list(PTMDs_down = gene_sets$PTMDs_down),
  assay      = "RNA",
  slot       = "data"
)
UC <- .rename_last_col(UC, "PTMDs_singscore_down")

## =========================
## 7) 循环生成：每种方法的差值列 = up - down
## =========================
methods <- c("Add", "AUCell", "ssGSEA", "Ucell", "singscore")

for (m in methods) {
  up_col   <- paste0("PTMDs_", m, "_up")
  down_col <- paste0("PTMDs_", m, "_down")
  diff_col <- paste0("PTMDs_", m)
  
  UC@meta.data[[diff_col]] <- UC@meta.data[[up_col]] - UC@meta.data[[down_col]]
}

## =========================
## 8) 综合评分：PTMDs = 五种方法差值求和（up-down 的综合评分）
##   （如果你更想“平均”，把 rowSums 换成 rowMeans 即可）
## =========================
diff_cols <- paste0("PTMDs_", methods)
UC@meta.data[["PTMDs"]] <- rowSums(UC@meta.data[, diff_cols, drop = FALSE], na.rm = TRUE)

## 可选：只保留 PTMDs 和各方法差值列（删除所有 *_up / *_down）
UC@meta.data <- UC@meta.data[, !grepl("PTMDs_.*_(up|down)$", colnames(UC@meta.data)), drop = FALSE]

cat("完成：新增差值列：", paste(diff_cols, collapse = ", "), "\n")
cat("完成：新增综合列：PTMDs (= Σ[方法(up-down)])\n")
#####随机森林#####
library(randomForest)
library(tidyverse)
library(dplyr)
library(stringr)
df <- data.frame(UC@meta.data)
selected_features <- gsub("-", ".", colnames(ptm_data))
df <- df %>% dplyr::select(all_of(c("PTMDs", intersect(colnames(df),selected_features))))

# 训练随机森林回归模型
rf_model <- randomForest(
  PTMDs ~ ., 
  data = df,
  ntree = 1000,
  importance = TRUE,
  proximity = TRUE
)

# 查看模型摘要
print(rf_model)

# 查看变量重要性
importance <- importance(rf_model)
colnames(importance)
# 需要：randomForest 已经训练好：rf_model
library(ggplot2)
library(dplyr)
library(scales)

# 1) 组织数据：OOB MSE 与 OOB R²
df_oob <- tibble(
  trees  = seq_along(rf_model$mse),
  OOB_MSE = rf_model$mse,
  OOB_R2  = rf_model$rsq
)

# 2) 找“拐点”（从某点起再多加树，改善 < 0.5%）
win <- 50
rel_improve <- c(
  rep(NA, win),
  (df_oob$OOB_MSE[(win+1):nrow(df_oob)] - zoo::rollmean(df_oob$OOB_MSE, k = win, align = "right")[1:(nrow(df_oob)-win)]) /
    zoo::rollmean(df_oob$OOB_MSE, k = win, align = "right")[1:(nrow(df_oob)-win)]
)
df_oob$rel_improve <- rel_improve
best_ntree <- df_oob %>%
  filter(!is.na(rel_improve)) %>%
  mutate(flag = abs(rel_improve) < 0.005) %>%  # <0.5% 改善
  summarize(best = if (any(flag)) trees[which(flag)[1]] else which.min(OOB_MSE)) %>%
  pull(best)

# 3) 为了在同图显示 R²，做个缩放（把 R² 映射到 MSE 轴的大致范围）
r2_min <- min(df_oob$OOB_R2, na.rm = TRUE)
r2_max <- max(df_oob$OOB_R2, na.rm = TRUE)
mse_min <- min(df_oob$OOB_MSE, na.rm = TRUE)
mse_max <- max(df_oob$OOB_MSE, na.rm = TRUE)

scale_r2_to_mse <- function(x) {
  (x - r2_min) / (r2_max - r2_min) * (mse_max - mse_min) + mse_min
}
scale_mse_to_r2 <- function(x) {
  (x - mse_min) / (mse_max - mse_min) * (r2_max - r2_min) + r2_min
}

df_oob <- df_oob %>%
  mutate(R2_on_MSE_axis = scale_r2_to_mse(OOB_R2))

# 4) 画图（线 + LOESS 平滑 + 拐点标注 + 双坐标轴）
p <- ggplot(df_oob, aes(trees)) +
  geom_line(aes(y = OOB_MSE), linewidth = 1) +
  geom_smooth(aes(y = OOB_MSE), method = "loess", se = FALSE, span = 0.15, linewidth = 0.6, linetype = 2) +
  geom_line(aes(y = R2_on_MSE_axis), linewidth = 0.9, alpha = 0.7) +
  geom_vline(xintercept = best_ntree, linewidth = 0.6, linetype = 3) +
  annotate("label",
           x = best_ntree, y = df_oob$OOB_MSE[best_ntree],
           label = paste0("拐点 ≈ ", best_ntree, " trees"),
           hjust = -0.05, vjust = -0.8, size = 3) +
  scale_y_continuous(
    name = "OOB MSE",
    labels = label_number(accuracy = 0.001),
    sec.axis = sec_axis(~ scale_mse_to_r2(.), name = "OOB R²")
  ) +
  scale_x_continuous(name = "Number of trees") +
  ggtitle("Random Forest (Regression): OOB Error vs Trees") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.02)
  )

# 5) 保存
ggsave("OOB_curves_beautified.pdf", p, width = 7, height = 5)
ggsave("OOB_curves_beautified.png", p, width = 7, height = 5, dpi = 300)

p

# 生成变量重要性条形图（纵向，从左到右升序排列，突出显示最重要通路）
pdf(file="geneImportance.pdf", width=12, height=8)
par(mar = c(6, 6, 4, 4) + 0.1, mgp = c(4, 1, 0), 
    bg = "white", fg = "black", col.axis = "black", col.lab = "black")  # 调整边距和颜色
# 按重要性升序排列（左小右大）
imp_scores <- importance[, "%IncMSE"]
imp_sorted <- sort(imp_scores, decreasing = FALSE)  # 升序排列，最小值在左，最大值在右

# 创建颜色向量（最重要通路为橙色，其余为蓝色）
top_index <- length(imp_sorted)  # 最大值在最后（最右侧）
bar_colors <- rep("#1F78B4", length(imp_sorted))  # 全部先设为蓝色
bar_colors[top_index] <- "#FF7F00"  # 最右侧的条形设为橙色

# 绘制纵向条形图（从左到右升序）
bp <- barplot(imp_sorted, 
              horiz = FALSE,  # 纵向条形图
              las = 1,
              col = bar_colors,
              border = "black",  # 黑色边框
              space = 0.3,
              ylab = "IncNodePurity",
              xlab = "Features (Ordered by Increasing Importance)",
              main = "Feature Importance Ranking\n(Random Forest)",
              ylim = c(0, max(imp_sorted) * 1.4),
              names.arg = rep("", length(imp_sorted)),  # 隐藏所有标签
              cex.axis = 1.0,
              cex.lab = 1.2,
              cex.main = 1.3)

# 添加画框
box(lwd = 2, col = "black")

# 添加网格线
grid(nx = NA, ny = NULL, col = "gray90", lty = 2)

# 添加图例
legend("topleft", 
       inset = c(0.02, 0.02),
       legend = c("Most Important Feature", "Other Features"),
       fill = c("#FF7F00", "#1F78B4"),
       border = "black",
       box.lwd = 1,
       bg = "white",
       cex = 0.9)

# 添加最重要通路的标签（最右侧的条形）
top_feature <- names(imp_sorted)[top_index]
top_value <- imp_sorted[top_index]

# 计算条形位置
bar_x <- bp[top_index]  # 最重要条形的x坐标
bar_y <- top_value * 1.05  # 引导线起点y坐标（条形顶部稍上方）

# 计算标签位置（图表中央）
label_x <- mean(par("usr")[1:2])  # 图表的水平中心
label_y <- max(imp_sorted) * 1.25  # 图表顶部稍下方

# 绘制引导线（从标签指向条形）
segments(
  x0 = label_x, y0 = label_y,
  x1 = bar_x, y1 = bar_y,
  col = "gray30", lwd = 1.5, lty = 2
)
arrows(
  x0 = bar_x, y0 = bar_y,
  x1 = bar_x, y1 = top_value * 0.98,  # 指向条形顶部
  length = 0.1, col = "gray30", lwd = 1.5
)

# 添加标签（在图表中央）
text(
  x = label_x, y = label_y,
  labels = paste0("Most Important Feature:\n", top_feature),
  pos = 3, cex = 1.0, col = "black", font = 2
)

dev.off()
UC$ISGylation
#####最佳修饰水平小提琴图####
output_dir <- "MetaAnalysis_Results"
type_groups <- c("UC", "HC")
color_scheme <- c("#FF7F0E", "#1F77B4")
plot_data <- UC@meta.data %>% 
	rownames_to_column("CellID") %>% 
	filter(phenotype %in% type_groups) %>%
	mutate(Group = factor(phenotype, levels = type_groups)) %>% 
	dplyr::select(CellID, Group, celltype, ISGylation)  # 确保包含celltype和Scoreing列

#统计学检验
# 按celltype分组计算统计量
stat_data <- plot_data %>%
	group_by(celltype) %>%  # 按细胞类型分组
	summarise(
		p_value = wilcox.test(ISGylation ~ Group)$p.value,  # 组间比较
		y_max = max(ISGylation) * 1.1,  # 自动计算标注高度
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
		mean = mean(ISGylation, na.rm = TRUE),
		sd = sd(ISGylation, na.rm = TRUE),
		y_pos = quantile(ISGylation, 0.95),  # 自动定位到小提琴图上部
		.groups = "drop"
	) %>%
	mutate(label = sprintf("Mean: %.2f\nSD: %.2f", mean, sd))

ggplot(plot_data, aes(x = celltype, y = ISGylation)) +  # x轴改为celltype
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
	labs(title = "ISGylation Comparison Across Cell Types",
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
		panel.grid.major.y = element_line(color = "grey90", linewidth = 0.3))
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
DotPlotScores(object = UC, scores = c("ISGylation_AddModule","ISGylation_AUCell",
																			"ISGylation_ssGSEA","ISGylation_Ucell",
																			"ISGylation_singscore","ISGylation"), dot.scale = 6) +
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
	labs(title = "ISGylation_score", y = "", x = "")
dev.off()

library(SCP)
UC[["RNA"]] <- as(object = UC[["RNA"]], Class = "Assay")
table(UC$celltype)
pdf(file="ISGylation_violin.pdf", width=10, height=6)
FeatureStatPlot(
	srt = UC, 
	group.by = "celltype",
	stat.by = c("ISGylation"), 
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
score_methods <- c("ISGylation")

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