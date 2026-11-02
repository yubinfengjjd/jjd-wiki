# Part 1: Data Assessment 数据评估 ----

## 1.1 数据读取与预处理
# 设置工作目录为项目文件夹根目录
setwd("F:\\代谢组学")   # <- 按你的实际路径修改
rm(list = ls())

# 加载必要的包
library(readxl)        # 读取Excel文件
library(dplyr)         # 数据清洗与操作
library(tidyr)         # 数据整理（如pivot）
library(Hmisc)         # 相关性分析（rcorr）

# 作图
library(ggplot2)       # 基础绘图
library(ggrepel)       # 标签防重叠
library(RColorBrewer)  # 颜色调色板
library(pheatmap)      # 热图绘制

# 主成分分析与可视化
library(FactoMineR)    # PCA分析
library(factoextra)    # PCA作图与解释

# 富集分析
library(clusterProfiler) # 富集分析与可视化
library(enrichplot)      # 富集结果作图

# 网络分析
library(igraph)        # 代谢物相关性网络
# 读取数据
data_all <- read_xlsx("TSSGS-25-531-a/all_sample_data.xlsx")

# 读取样本分组信息表
sample_info <- read_xlsx("TSSGS-25-531-a/sample_info.xlsx")

# 将数据框按内容拆分：代谢物定量矩阵与注释信息
sample_names <- sample_info$Sample                           # 实验样本名称列表
qc_names <- grep("^QC", colnames(data_all), value=TRUE)      # QC样品名称列表，如存在QC样品
intensity_cols <- c(sample_names, qc_names)                  # 所有定量列（实验样本 + QC）
annot_cols <- setdiff(colnames(data_all), intensity_cols)    # 注释列

# 提取注释和定量矩阵
annotation_df <- data_all[, annot_cols]
expr_sample = as.data.frame(data_all[, sample_names])   

# 将代谢物名称作为行名方便分析
if("Compounds" %in% colnames(annotation_df)){
	rownames(expr_sample) <- annotation_df$Compounds
} else if("Index" %in% colnames(annotation_df)){
	rownames(expr_sample) <- annotation_df$Index
}


## 2.1 准备OPLS-DA分析所需的数据结构
group1 <- "16HBE-si-RCC2-hdm"  # 请根据实际分组名称修改
group2 <- "16HBE-hdm"          # 请根据实际分组名称修改

# 提取对应分组的样本名称
samples_group1 <- sample_info$Sample[sample_info$Group == group1]
samples_group2 <- sample_info$Sample[sample_info$Group == group2]
samples_compare <- c(samples_group1, samples_group2)

# 提取对应样本的表达矩阵
expr_compare <- expr_sample[, samples_compare]

# 构建分组因子变量（Y变量）
group_factor <- factor(c(rep(group1, length(samples_group1)), 
												 rep(group2, length(samples_group2))),
											 levels = c(group1, group2))
library(tidyverse)
temp_data = as.data.frame(t(expr_compare)) %>% 
	rownames_to_column("Patient ID") 
temp_data$`Muscle loss` = ifelse(str_detect(temp_data$`Patient ID`,"16HBE-si-RCC2-hdm"),"treat","con")
temp_data <- temp_data %>%
	relocate(`Muscle loss`, .after = `Patient ID`)
write.table(temp_data, "temp_data.txt", sep = "\t", quote = FALSE,row.names = F)

library(MetaboAnalystR)
mSet<-InitDataObjects("conc", "stat", FALSE)
mSet<-Read.TextData(mSet, "./temp_data.txt", "rowu", "disc")
mSet<-SanityCheckData(mSet)
mSet<-ReplaceMin(mSet)
mSet<-PreparePrenormData(mSet)
mSet<-Normalization(mSet, "NULL", "LogNorm", "MeanCenter", "S10T0", ratio=FALSE, ratioNum=20)

# Perform oPLS-DA analysis
mSet <- OPLSR.Anal(mSet, reg=T)
# Create a 2D oPLS-DA score plot
mSet<-PlotOPLS2DScore(mSet, "output/oplsr", format = "PDF", dpi=72)


## 1) 固定随机性 & 做置换
B_target <- 200              # 你也可以改成 2000 提高稳定性
mSet <- OPLSDA.Permut(mSet, B_target)
mSet <- PlotOPLS.Permutation(mSet, "Permutation", format="PDF", dpi=100)

oplsDF <- mSet$analSet$oplsda$modelDF
summDF <- mSet$analSet$oplsda$summaryDF

# 提取VIP值
vipValue <- as.data.frame(mSet$analSet$oplsda$vipVn)
colnames(vipValue) <- "VIP"
vipTab <- cbind(id=row.names(vipValue), vipValue)
vipTab <- vipTab[order(as.numeric(vipTab$VIP), decreasing=T),]
write.table(vipTab, file="output/vip.txt", sep="\t", quote=F, row.names=F)

# 绘制VIP的气泡图（前30个）
if (nrow(vipTab) > 30) {
	vipTab_top <- vipTab[1:30,]
} else {
	vipTab_top <- vipTab
}

vipTab_top$id <- factor(vipTab_top$id, levels=rev(vipTab_top$id))
vipTab_top$VIP <- as.numeric(vipTab_top$VIP)

vipPlot <- ggplot(vipTab_top, aes(VIP, id)) + 
	geom_segment(aes(x=0, xend=VIP, y=id, yend=id), color="grey", cex=1.5) + 
	geom_point(aes(color=VIP), cex=4) +
	scale_colour_gradient(low="#008280FF", high="#BB0021FF") + 
	labs(x="VIP", y="") +
	theme(axis.text.x=element_text(color="black", size=10),
				axis.text.y=element_text(color="black", size=10)) +
	theme_bw()

# 输出VIP图
pdf(file="output/vip.pdf", width=7.5, height=5.5)
print(vipPlot)
dev.off()

# === 兼容抽取置换结果（list 或 data.frame）===
perm.res <- mSet$analSet$oplsda$perm.res
if (is.null(perm.res)) stop("没有找到置换结果：请先运行 OPLSDA.Permut().")

# r/q 置换向量（第1个元素=原始模型；其余为置换）
if (is.data.frame(perm.res)) {
	# ropls风格：可能列名是 "R2Y(cum)" / "Q2(cum)" 或 "R2Y"/"Q2"
	nm <- names(perm.res)
	r.col <- grep("^R2Y(\\(cum\\))?$", nm, ignore.case = TRUE, value = TRUE)
	q.col <- grep("^Q2(\\(cum\\))?$",  nm, ignore.case = TRUE, value = TRUE)
	stopifnot(length(r.col)==1, length(q.col)==1)
	r_all <- as.numeric(perm.res[[r.col]])
	q_all <- as.numeric(perm.res[[q.col]])
} else {
	# MetaboAnalystR风格：list(r.vec, q.vec, perm/perm.num)
	r_all <- as.numeric(perm.res$r.vec)
	q_all <- as.numeric(perm.res$q.vec)
}
stopifnot(length(r_all) > 1, length(q_all) > 1)

# 观察值与置换次数
r_obs <- r_all[1]; q_obs <- q_all[1]
r_perm <- r_all[-1]; q_perm <- q_all[-1]
B <- length(r_perm)

# 经验p值（保守法 (K+1)/(B+1)）
K_R <- sum(r_perm >= r_obs, na.rm = TRUE)
K_Q <- sum(q_perm >= q_obs, na.rm = TRUE)
pR  <- (K_R + 1) / (B + 1)
pQ  <- (K_Q + 1) / (B + 1)

# 读原模型 summary（为了标签显示 R2X/R2Y/Q2）
summDF <- mSet$analSet$oplsda$summaryDF
nms <- tolower(names(summDF))
pick <- function(keys) unname(summDF[[ which(nms %in% keys)[1] ]])
R2X <- suppressWarnings(pick(c("r2x","r2x(cum)","r2x.cum")))
R2Y <- suppressWarnings(pick(c("r2y","r2y(cum)","r2y.cum")))
Q2  <- suppressWarnings(pick(c("q2","q2(cum)","q2.cum","q2y")))
if (is.null(R2Y)) R2Y <- r_obs
if (is.null(Q2))  Q2  <- q_obs

# 直方图需要的y上限（用 base hist 先估计最大柱高）
hmax <- max(hist(r_perm, plot = FALSE)$counts,
						hist(q_perm, plot = FALSE)$counts)

# 组装画图数据
library(dplyr); library(tidyr); library(ggplot2); library(grid)
permTab <- bind_rows(
	data.frame(Type = "R2Y", value = r_perm),
	data.frame(Type = "Q2",  value = q_perm)
)

labels_data <- data.frame(
	x = c(R2Y, Q2),
	y = c(hmax*1.05, hmax*1.20),
	lab = c(sprintf("R2Y: %.3f\np=%.3f (%d/%d)", R2Y, pR, K_R, B),
					sprintf("Q2: %.3f\np=%.3f (%d/%d)", Q2,  pQ, K_Q, B))
)

# 输出目录
if (!dir.exists("output")) dir.create("output", recursive = TRUE)

# 作图
PermPlot <- ggplot(permTab, aes(x = value, fill = Type)) +
	geom_histogram(bins = 30, alpha = 0.6, size = 0.3, color = "black") +
	geom_label(data = labels_data,
						 aes(x = x, y = y, label = lab),
						 size = 3, color = "darkred",
						 fill = "white", label.padding = unit(0.1, "lines"),
						 label.size = 0.25, inherit.aes = FALSE) +
	geom_segment(data = labels_data,
							 aes(x = x, xend = x, y = 0, yend = y),
							 arrow = arrow(type = "closed", length = unit(0.15, "cm")),
							 alpha = 0.5, inherit.aes = FALSE) +
	labs(title = "Permutation of OPLS-DA", x = "Permutations", y ="Frequency") +
	theme_bw() +
	theme(plot.title = element_text(hjust = 0.5))

ggsave("output/Permutation.pdf", PermPlot, width = 6, height = 4)

# Part 2: Basic Analysis 基础分析 ----
## ===== Part 2: Basic Analysis —— 差异分析（VIP + p）并绘制火山图 =====
library(limma)
if (!dir.exists("output")) dir.create("output", recursive = TRUE)

# 1) 取出当前比较的表达矩阵（特征在行、样本在列）并 log2 以稳定方差
expr_mat <- as.matrix(expr_compare)
expr_mat <- log2(expr_mat + 1)   # 与火山图定义一致 -> x 轴用 log2FC ；也与 limma 假设更匹配  :contentReference[oaicite:2]{index=2}

# 2) 设计矩阵（treat vs con）
#   这里把 group1 当作 "treat"、group2 当作 "con"，可按需要交换
Type <- ifelse(colnames(expr_mat) %in% samples_group1, "treat", "con")
Type <- factor(Type, levels = c("con", "treat"))
design <- model.matrix(~0 + Type)
colnames(design) <- c("con","treat")

fit  <- lmFit(expr_mat, design)
cont <- makeContrasts(treat - con, levels = design)
fit2 <- eBayes(contrasts.fit(fit, cont))

# 3) 取完整差异表（全部代谢物），并合并 VIP
Diff <- topTable(fit2, number = Inf, sort.by = "none")  # logFC >0 表示 treat>con
Diff$Compound <- rownames(Diff)

# 从 mSet 中取 VIP（具名数值向量），转成表后合并
vip_vec <- mSet$analSet$oplsda$vipVn
vip_df  <- data.frame(Compound = names(vip_vec), VIP = as.numeric(vip_vec), row.names = NULL)
Diff    <- merge(Diff, vip_df, by = "Compound", all.x = TRUE)

# 4) 设定阈值：p 与 logFC；并用 VIP>1 + p<0.05 作为“显著”前提
alpha_p   <- 0.05          # 用原始 p；若想改为 FDR，请把 P.Value 换成 adj.P.Val
fc_cutoff <- 1             # |log2FC|>1
Diff$Significant <- "Not"
Diff$Significant[ Diff$P.Value < alpha_p & Diff$VIP > 1 & Diff$logFC >=  fc_cutoff ] <- "Up"
Diff$Significant[ Diff$P.Value < alpha_p & Diff$VIP > 1 & Diff$logFC <= -fc_cutoff ] <- "Down"
Diff$Significant <- factor(Diff$Significant, levels = c("Up","Not","Down"))

# 5) 输出结果表
write.csv(Diff, "output/Diff_with_VIP.csv", row.names = FALSE)
Diff_SIG <- subset(Diff, Significant != "Not")
write.csv(Diff_SIG, "output/Diff_SIG_VIP.csv", row.names = FALSE)

# 6) 火山图 —— 样式与示例保持一致（颜色、阈值线、标签阈值）
#    颜色来自你给的参数（highcol: 上调；lowcol: 下调；中性灰）
highcol <- "#EFC000FF"; lowcol <- "#0073C2FF"
adjP <- alpha_p    # 横线用同一 p 阈值（若用 FDR，请改为 -log10(0.05) 对应 adj.P.Val）
aflogFC <- fc_cutoff
point.Pvalue <- 0.01
point.logFc  <- 2

Diff$symbol <- Diff$Compound
plot_df <- Diff   # 已包含 logFC、P.Value、adj.P.Val、VIP、Significant

library(ggplot2); library(ggrepel)
p <- ggplot(plot_df, aes(x = logFC, y = -log10(P.Value))) +
	geom_point(aes(colour = Significant), size = 3, na.rm = TRUE) +
	scale_color_manual(values = c("Up" = highcol, "Not" = "#838B8B", "Down" = lowcol),
										 breaks = c("Up","Not","Down")) +
	labs(title = "Volcano (VIP>1 & p<0.05)", x = "log2 Fold Change (16HBE-si-RCC2-hdm vs 16HBE-hdm)", y = "-log10(p)") +
	theme(plot.title = element_text(size = 16, hjust = 0.5, face = "bold")) +
	geom_hline(yintercept = -log10(adjP), colour = "gray", linetype = "twodash", size = 1) +
	geom_vline(xintercept =  aflogFC,   colour = "gray", linetype = "twodash", size = 1) +
	geom_vline(xintercept = -aflogFC,   colour = "gray", linetype = "twodash", size = 1)

# 仅对“既满足 VIP>1 & p<0.01 且 |logFC|>2”的点加标签（可按需调整）
for_label <- subset(plot_df, P.Value < point.Pvalue & abs(logFC) > point.logFc & VIP > 1)
if (nrow(for_label) > 0) {
	p <- p +
		geom_point(data = for_label, size = 1.5, shape = 1) +
		ggrepel::geom_label_repel(
			data = for_label, aes(label = symbol),
			color = "black", label.size = 0.1, max.overlaps = 20)
}

ggsave("output/Volcano_VIP.pdf", p, width = 6.5, height = 6)


## 2.3 差异代谢物聚类热图
## 2.3 差异代谢物复杂热图（ComplexHeatmap）
# 依赖
library(ComplexHeatmap)
library(circlize)
library(grid)
library(scales)   # hue_pal()

if (!dir.exists("output")) dir.create("output", recursive = TRUE)

## —— 1) 选择要画的代谢物矩阵
if (exists("Diff_SIG") && nrow(Diff_SIG) > 0) {
	sig_ids <- Diff_SIG$Compound
} else if (exists("sig_metabolites") && length(sig_metabolites) > 0) {
	sig_ids <- sig_metabolites
} else {
	stop("没有可用的差异代谢物列表：请先生成 Diff_SIG 或 sig_metabolites。")
}

mat <- expr_sample[rownames(expr_sample) %in% sig_ids, sample_names, drop = FALSE]

# 行向 Z-score
mat_z <- t(scale(t(as.matrix(mat))))
mat_z[!is.finite(mat_z)] <- 0

## —— 2) 构造"代谢物类别"向量：使用 Class I 列
class_colname <- "Class I"  # 直接指定使用 Class I 列
if (!class_colname %in% names(annotation_df)) {
	metab_class <- factor(rep("Unclassified", nrow(mat_z)), levels = "Unclassified")
} else {
	# 确保 annotation_df 的行名与表达矩阵一致
	if (!all(rownames(mat_z) %in% rownames(annotation_df))) {
		if ("Compounds" %in% names(annotation_df)) {
			rownames(annotation_df) <- annotation_df$Compounds
		} else if ("Index" %in% names(annotation_df)) {
			rownames(annotation_df) <- annotation_df$Index
		}
	}
	# 按行名取出类别向量并处理缺失
	map_class <- annotation_df[rownames(mat_z), class_colname, drop = TRUE]
	map_class[is.na(map_class)] <- "Unclassified"
	metab_class <- droplevels(factor(map_class))
}

# 为每个类别指定颜色
class_lvls <- levels(metab_class)
if (length(class_lvls) <= 12) {
	class_pal <- setNames(RColorBrewer::brewer.pal(max(3, length(class_lvls)), "Set3")[seq_along(class_lvls)],
												class_lvls)
} else {
	class_pal <- setNames(scales::hue_pal()(length(class_lvls)), class_lvls)
}

## —— 3) 样本注释（顶部）：按 Group 着色
if (!exists("Ccol")) Ccol <- "#0073C2FF"
if (!exists("Pcol")) Pcol <- "#EFC000FF"
group_vec <- sample_info$Group[match(colnames(mat_z), sample_info$Sample)]
grp_cols <- setNames(c(Ccol, Pcol), c("16HBE-hdm","16HBE-si-RCC2-hdm"))
top_ha <- HeatmapAnnotation(
	Group = group_vec,
	col = list(Group = grp_cols),
	annotation_name_side = "left"
)

## —— 4) 使用 anno_mark 标注每种类别随机5个代谢物
# 获取每种类别中随机5个代谢物的索引
set.seed(123)  # 设置随机种子保证可重复
mark_indices <- unlist(lapply(levels(metab_class), function(cls) {
	cls_indices <- which(metab_class == cls)
	if (length(cls_indices) > 2) {
		sample(cls_indices, 2)
	} else {
		cls_indices
	}
}))

mark_labels <- rownames(mat_z)[mark_indices]

# 创建右侧标注
right_ha <- rowAnnotation(
	mark = anno_mark(
		at = mark_indices,
		labels = mark_labels,
		labels_gp = gpar(fontsize = 8)
	)
)

## —— 5) 色标
if (!exists("lowcol")) lowcol <- "#0073C2FF"
if (!exists("midcol")) midcol <- "white"
if (!exists("highcol")) highcol <- "#EFC000FF"
col_fun <- circlize::colorRamp2(c(-2, 0, 2), c(lowcol, midcol, highcol))

## —— 6) 组装热图
ht_main <- Heatmap(
	mat_z, name = "Z",
	col = col_fun,
	top_annotation = top_ha,
	right_annotation = right_ha,  # 添加右侧标注
	row_split = metab_class,
	show_row_names = FALSE,  # 不显示行名，使用anno_mark代替
	show_column_names = FALSE,
	cluster_rows = TRUE, 
	cluster_columns = TRUE,  # 对列进行聚类
	row_title = NULL,
	heatmap_legend_param = list(title = "Z-score")
)

# 左侧类别色条 - 启用图例并设置在右侧显示
left_bar <- rowAnnotation(
	Class = metab_class,
	col = list(Class = class_pal),
	show_annotation_name = FALSE,
	gp = gpar(col = NA),
	show_legend = TRUE,  # 启用图例
	annotation_legend_param = list(
		Class = list(
			title = "Metabolite Class",
			title_position = "topleft",
			direction = "vertical"
		)
	)
)

# 组合图形
ht_all <- left_bar + ht_main

## —— 7) 输出
ht_h <- unit(max(5, min(12, nrow(mat_z) * 0.12)), "in")
pdf("output/Diff_Metabolites_ComplexHeatmap.pdf", width = 14, height = convertUnit(ht_h, "in", valueOnly = TRUE))
draw(ht_all, 
		 merge_legend = TRUE,
		 heatmap_legend_side = "right",  # Z-score图例在底部
		 annotation_legend_side = "right")  # 分类图例在右侧
dev.off()

## ---------- 3.1  KEGG pathway enrichment ---------- ##
library(clusterProfiler)
library(dplyr)
library(tidyr)
library(Hmisc)
library(igraph)
library(RColorBrewer)
library(scales)

if (!dir.exists("output")) dir.create("output", recursive = TRUE)

## === 小工具：统一拆分分隔符（支持 | , ;，自动去空格/“-”） ===
split_one <- function(s) {
	if (length(s) == 0 || all(is.na(s))) return(character(0))
	x <- trimws(unlist(strsplit(s, "\\s*[\\|,;]+\\s*")))
	x <- x[!is.na(x) & x != "" & x != "-"]
	unique(x)
}

## === 1) 选择差异代谢物 ID（cpd_ID；支持多 ID 合一格） ===
sig_ids_raw <- if (exists("Diff_SIG") && nrow(Diff_SIG) > 0) {
	annotation_df$cpd_ID[match(Diff_SIG$Compound, annotation_df$Compounds)]
} else {
	annotation_df$cpd_ID[match(sig_metabolites, annotation_df$Compounds)]
}
sig_ids <- unique(unlist(lapply(sig_ids_raw, split_one)))
if (length(sig_ids) < 3) stop("显著代谢物太少，无法做富集")

## === 2) TERM2GENE：逐行做 (kegg_map × cpd_ID) 的笛卡尔积，再合并（NEW：支持“|”） ===
kegg_col <- "kegg_map"
term2gene_list <- vector("list", nrow(annotation_df))
for (i in seq_len(nrow(annotation_df))) {
	kvec <- split_one(annotation_df[[kegg_col]][i])
	cvec <- split_one(annotation_df$cpd_ID[i])
	if (length(kvec) == 0 || length(cvec) == 0) next
	term2gene_list[[i]] <- expand.grid(
		PathwayID    = kvec,
		MetaboliteID = cvec,
		stringsAsFactors = FALSE
	)
}
term2gene_df <- bind_rows(term2gene_list) %>%
	mutate(PathwayID = sub("^path:", "", PathwayID)) %>%     # 统一去掉可能的 "path:" 前缀
	distinct()

## === 3) TERM2NAME：自适配列名；首轮下载后缓存（沿用你的思路，稍做稳健化） ===
tn_file <- "output/kegg_path_id2name.rds"
if (!file.exists(tn_file)) {
	kegg_db <- clusterProfiler::download_KEGG("ko")
	tn <- as.data.frame(kegg_db$KEGGPATHID2NAME, stringsAsFactors = FALSE)
	nm <- names(tn)
	id_col   <- grep("path.*id|^from$|^id$|^term$", nm, ignore.case = TRUE, value = TRUE)[1]
	name_col <- grep("name|desc|title",          nm, ignore.case = TRUE, value = TRUE)[1]
	if (is.na(id_col) || is.na(name_col)) stop("无法在 KEGGPATHID2NAME 中识别 ID/Name 列，请先查看 names()。")
	term2name_df <- data.frame(
		PathwayID   = sub("^path:", "", as.character(tn[[id_col]])),
		PathwayName = as.character(tn[[name_col]]),
		stringsAsFactors = FALSE
	)
	saveRDS(term2name_df, tn_file)
} else {
	term2name_df <- readRDS(tn_file)
}
colnames(term2name_df) <- c("PathwayID","PathwayName")


## === 4) 富集（保留你原设置；如果想更稳健，可把 minGSSize 改成 2 或 3） ===
enrich_res <- enricher(
	gene         = sig_ids,
	TERM2GENE    = term2gene_df,
	TERM2NAME    = term2name_df,
	pvalueCutoff = 1,
	qvalueCutoff = 1,
	minGSSize    = 1
)

## === 5) 美化KEGG富集分析dotplot（添加边框）===
if (exists("enrich_res") && nrow(as.data.frame(enrich_res)) > 0) {
	# 提取富集结果数据
	enrich_df <- as.data.frame(enrich_res)
	
	# 选择显示的通路数量（最多20条）
	show_category <- min(20, nrow(enrich_df))
	enrich_df <- enrich_df[1:show_category, ]
	
	# 计算富集因子 (Enrichment Factor)
	enrich_df$Enrichment_Factor <- as.numeric(sub("/\\d+", "", enrich_df$GeneRatio)) / 
		as.numeric(sub("\\d+/", "", enrich_df$GeneRatio)) /
		(as.numeric(sub("/\\d+", "", enrich_df$BgRatio)) / 
		 	as.numeric(sub("\\d+/", "", enrich_df$BgRatio)))
	
	# 美化描述文本：换行处理长文本
	wrap_text <- function(x, width = 40) {
		sapply(x, function(text) {
			paste(strwrap(text, width = width), collapse = "\n")
		})
	}
	
	enrich_df$Description <- wrap_text(enrich_df$Description)
	
	# 创建美观的dotplot
	p <- ggplot(enrich_df, aes(x = Enrichment_Factor, y = reorder(Description, Enrichment_Factor))) +
		geom_point(aes(size = Count, color = -log10(p.adjust))) +
		scale_color_gradientn(
			colors = rev(brewer.pal(11, "Spectral")),
			name = expression(-log[10](FDR)),
			guide = guide_colorbar(reverse = FALSE)
		) +
		scale_size_continuous(
			range = c(3, 8),
			name = "Metabolite Count",
			breaks = pretty(range(enrich_df$Count))
		) +
		labs(
			x = "Enrichment Factor",
			y = "",
			title = "KEGG Pathway Enrichment Analysis",
			subtitle = "Differentially Expressed Metabolites"
		) +
		theme_minimal(base_size = 12) +
		theme(
			plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
			plot.subtitle = element_text(hjust = 0.5, color = "gray40", size = 12),
			axis.text.y = element_text(color = "black", lineheight = 0.8),
			axis.text.x = element_text(color = "black"),
			axis.title.x = element_text(margin = margin(t = 10)),
			panel.grid.major = element_line(color = "grey90", linewidth = 0.2),
			panel.grid.minor = element_blank(),
			legend.position = "right",
			legend.box = "vertical",
			legend.key.height = unit(0.8, "cm"),
			plot.margin = margin(1, 1, 1, 1.5, "cm"),
			# 添加边框相关设置
			panel.border = element_rect(color = "black", fill = NA, size = 1),  # 面板边框
		) +
		geom_vline(xintercept = 1, linetype = "dashed", color = "red", alpha = 0.5)
	
	# 保存图形
	pdf("output/KEGG_Enrichment_Dotplot_Enhanced.pdf", width = 8, height = 8)
	print(p)
	dev.off()
	
	message("美化后的KEGG富集图（带边框）已保存至输出文件夹")
} else {
	message("没有富集结果可供绘图")
}

## === 5) 通路-代谢物 cnetplot（NEW：foldChange 用 cpd_ID 命名，自动处理一对多） ===
## ---- 依赖 ----
library(FELLA)
library(igraph)
library(dplyr)
library(stringr)

dir.create("output", showWarnings = FALSE, recursive = TRUE)

## ---- 1) 取差异代谢物的 KEGG Compound ID（cpd_ID）并清洗 ----
# 支持分隔符：逗号/分号/竖线/空格
split_id <- function(x) unique(trimws(unlist(strsplit(x, "[,;|\\s]+"))))

sig_ids_raw <- if (exists("Diff_SIG") && nrow(Diff_SIG) > 0) {
	annotation_df$cpd_ID[match(Diff_SIG$Compound, annotation_df$Compounds)]
} else {
	annotation_df$cpd_ID[match(sig_metabolites, annotation_df$Compounds)]
}
sig_ids <- split_id(paste(sig_ids_raw, collapse = ";"))
sig_ids <- sig_ids[grepl("^C\\d{5}$", sig_ids)]  # 只保留合法 KEGG 化合物
stopifnot(length(sig_ids) >= 3)

## （可选）定义背景：用你检测到并成功注释为 KEGG 的全部化合物
bg_ids_raw <- annotation_df$cpd_ID
bg_ids <- split_id(paste(bg_ids_raw, collapse = ";"))
bg_ids <- bg_ids[grepl("^C\\d{5}$", bg_ids)]

## ---- 2) 准备/加载 FELLA 数据库（按物种）----
organism <- "mmu"   # 人类 16HBE 细胞建议用 hsa；小鼠 mmu；大鼠 rno；通用图 ko
db_dir   <- file.path("output", paste0("fella_db_", organism))

if (!dir.exists(db_dir)) {
	message(">> 首次构建 FELLA 数据库（仅需一次，时间较长）")
	g <- buildGraphFromKEGGREST(organism = organism) 
	# 过滤 KEGG 概览图，避免过度泛化通路。
	buildDataFromGraph(
		keggdata.graph = g,
		databaseDir    = db_dir,
		internalDir    = FALSE,  # 存到你自定义目录
		matrices       = c("hypergeom","diffusion","pagerank"),
		normality      = c("diffusion","pagerank"),  # 建议同时生成归一化向量
		dampingFactor  = 0.85,   # PageRank 的 d
		niter          = 100     # CC size 的近似迭代次数，可按机器/需求增大
	)  # 随机图估计连通分量阈值用到，200 已够用。:contentReference[oaicite:3]{index=3}
}

fella.data <- loadKEGGdata(databaseDir = db_dir, internalDir = FALSE,
													 loadMatrix = c("diffusion","pagerank"))  # 只加载需要的矩阵:contentReference[oaicite:4]{index=4}
getInfo(fella.data)  # 查看 KEGG 版本等信息（可选）:contentReference[oaicite:5]{index=5}

## ---- 3) 映射并富集（扩散/或 PageRank）----
user <- defineCompounds(compounds = sig_ids,
												data = fella.data)                                          #:contentReference[oaicite:6]{index=6}
user <- runDiffusion(object = user, data = fella.data, approx = "normality")         #:contentReference[oaicite:7]{index=7}
# 如需，也可以再跑 PageRank：
# user <- runPagerank(object = user, data = fella.data, approx = "normality")        #:contentReference[oaicite:8]{index=8}

## ---- 4) 取子网并自定义配色/形状后绘图 ----
# ... [前面的代码保持不变] ...

## ---- 4) 取子网并自定义配色/形状后绘图 ----
g.res <- generateResultsGraph(method = "diffusion",
															threshold = 0.05, nlimit = 250,
															object = user, data = fella.data)

# 识别节点类别
id <- V(g.res)$name
guess_cat <- function(x){
	if (grepl("^C\\d{5}$", x)) return("compound")
	if (grepl("^R\\d{5}$", x)) return("reaction")
	if (grepl("^M\\d{5}$", x)) return("module")
	if (grepl("^\\d+\\.\\d+\\.\\d+\\.\\d+$", x)) return("enzyme")
	if (grepl("^(map|hsa|mmu|rno|ko)\\d{5}$", x)) return("pathway")
	return(NA_character_)
}
cat_vec <- if (!is.null(V(g.res)$category)) V(g.res)$category else vapply(id, guess_cat, "")
V(g.res)$category <- cat_vec

# 配色与形状：按你的报告规范定制
cols <- c(pathway = "#E31A1C",  # 红
					enzyme  = "#FFD000",  # 黄
					compound= "#2ECC71",  # 绿
					module  = "#8A2BE2",  # 紫
					reaction= "#377EB8")  # 蓝
V(g.res)$color <- cols[ V(g.res)$category ]
V(g.res)$shape <- "circle"

# 差异化节点大小：Pathway > 种子化合物 > 其他
V(g.res)$size <- 4  # 默认大小更小
pathway_idx <- which(cat_vec == "pathway")
seed <- getInput(user)
seed_idx <- which(id %in% seed)

V(g.res)$size[pathway_idx] <- 6    # Pathway节点更大
V(g.res)$size[seed_idx] <- 6       # 种子化合物中等

# 形状：种子化合物用方块
V(g.res)$shape[seed_idx] <- "square"

# 标签：仅显示Pathway和种子化合物
labs <- rep("", length(id))
labs[pathway_idx | id %in% seed] <- id
V(g.res)$label <- labs

# 方法1: 使用Fruchterman-Reingold布局并大幅增加排斥力参数
set.seed(123)
lay <- layout_with_fr(g.res, 
											repulserad = vcount(g.res)^3 * 10,  # 大幅增加排斥力
											niter = 10000,                      # 增加迭代次数
											start.temp = sqrt(vcount(g.res)))   # 增加初始温度

# 方法2: 尝试使用Kamada-Kawai布局（通常能产生更分散的布局）
# set.seed(123)
# lay <- layout_with_kk(g.res, maxiter = 10000)

# 方法3: 使用多级布局算法（适合大型网络）
# set.seed(123)
# lay <- layout_with_lgl(g.res, maxiter = 100, maxdelta = vcount(g.res))

# 方法4: 使用DrL布局算法（力导向布局的变种，适合大型网络）
# set.seed(123)
# lay <- layout_with_drl(g.res, options = list(initial.temp = 1000))

# 导出PDF（进一步增大画布尺寸）
pdf("output/FELLA_network_custom.pdf", width = 12, height = 12)
plot(g.res, layout = lay, 
		 vertex.label.cex = 0.6, 
		 vertex.label.color = "black",
		 vertex.frame.color = NA,
		 edge.arrow.size = 0.2,  # 减小箭头大小
		 edge.curved = 0.2,      # 添加轻微曲线使边不重叠
		 main = "Regulatory network (FELLA, diffusion)")
legend(
	x = "bottom", horiz = TRUE, inset = c(0, -0.06), bty = "n", xpd = NA,
	legend = c("Pathway","Enzyme","Compound","Module","Reaction","Seed compounds"),
	pch = c(19, 19, 19, 19, 19, 15), pt.cex = c(2, 1, 1, 1, 1, 1.5),
	col = c(cols["pathway"], cols["enzyme"], cols["compound"],
					cols["module"], cols["reaction"], cols["compound"])
)
dev.off()

## 依赖 ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(forcats)
library(scales)

if (!dir.exists("output")) dir.create("output", recursive = TRUE)

## 先决对象（沿用你前面的环境）---------------------------------------
# 需要已有：
# - annotation_df：包含至少列  Compounds, cpd_ID, kegg_map
# - Diff_SIG 或 diff_table：差异代谢物及 log2FC、p 值等
# - enrich_res 或 enrich_df：来自 clusterProfiler::enricher() 的富集结果
# - 可选 term2name_df：PathwayID 到 PathwayName 的映射（若没有，下面会自动兜底）

## 1) 构建通路-代谢物映射（支持一行多ID/多通路，逐行笛卡尔积）---------
make_term2gene <- function(anno, id_col = "cpd_ID", path_col = "kegg_map") {
	stopifnot(all(c(id_col, path_col) %in% names(anno)))
	kmap_chr <- ifelse(is.na(anno[[path_col]]), "", anno[[path_col]])
	id_chr   <- ifelse(is.na(anno[[id_col]]),   "", anno[[id_col]])
	out <- vector("list", nrow(anno))
	for (i in seq_len(nrow(anno))) {
		kvec <- str_split(kmap_chr[i], "[,;|]+")[[1]] |> str_trim()
		cvec <- str_split(id_chr[i],    "[,;|]+")[[1]] |> str_trim()
		kvec <- kvec[kvec != "" & kvec != "-"]
		cvec <- cvec[cvec != "" & cvec != "-"]
		if (length(kvec) && length(cvec)) {
			out[[i]] <- expand.grid(
				PathwayID    = kvec,
				MetaboliteID = cvec,
				stringsAsFactors = FALSE
			)
		}
	}
	bind_rows(out) |> distinct()
}

t2g <- make_term2gene(annotation_df)  # 两列：PathwayID, MetaboliteID

## 2) 取差异代谢物及方向（Up/Down）------------------------------------
if (exists("Diff_SIG") && nrow(Diff_SIG) > 0) {
	diff_used <- Diff_SIG |> transmute(Compound, logFC)
} else if (exists("diff_table")) {
	# 若使用 diff_table，请确保其中有 p_adj 或 p_value；这里以 p_adj<0.05 为例
	pcol <- if ("p_adj" %in% names(diff_table)) "p_adj" else "p_value"
	diff_used <- diff_table |>
		filter(.data[[pcol]] < 0.05) |>
		transmute(Compound, logFC)
} else {
	stop("未找到 Diff_SIG 或 diff_table；请先完成差异分析。")
}

# 映射到 cpd_ID（可能一行多个，用 ;/ , / | 分隔）
map_cpd <- annotation_df |> select(Compounds, cpd_ID)
diff_used <- diff_used |>
	left_join(map_cpd, by = c("Compound" = "Compounds")) |>
	filter(!is.na(cpd_ID) & cpd_ID != "-") |>
	mutate(MetaboliteID = str_split(cpd_ID, "[,;|]+")) |>
	unnest(MetaboliteID) |>
	mutate(
		MetaboliteID = str_trim(MetaboliteID),
		Direction = case_when(
			logFC >  0 ~ "Up",
			logFC <  0 ~ "Down",
			TRUE        ~ "Neutral"
		)
	) |>
	filter(MetaboliteID != "")

## 3) 计算 DA Score -----------------------------------------------------
# 3a) 每条通路被“注释到的代谢物个数”（分母，按注释唯一ID计数）
denom_tab <- t2g |>
	group_by(PathwayID) |>
	summarise(N_total = n_distinct(MetaboliteID), .groups = "drop")

# 3b) 通路内差异代谢物的 Up/Down 计数（分子）
num_tab <- t2g |>
	inner_join(diff_used, by = "MetaboliteID") |>
	group_by(PathwayID) |>
	summarise(
		N_up   = sum(Direction == "Up"),
		N_down = sum(Direction == "Down"),
		N_diff = n_distinct(MetaboliteID),
		.groups = "drop"
	)

# 3c) 合并并求分数
da_tab <- denom_tab |>
	left_join(num_tab, by = "PathwayID") |>
	mutate(across(c(N_up, N_down, N_diff), ~ replace_na(., 0L))) |>
	mutate(DA = (N_up - N_down) / N_total)

## 4) 合并富集 P 值并取 Top 20（按 p.adjust 升序）-----------------------
if (exists("enrich_res")) {
	enr_df <- as.data.frame(enrich_res)
} else if (exists("enrich_df")) {
	enr_df <- enrich_df
} else {
	stop("未找到 enrich_res/enrich_df；请先完成富集分析（clusterProfiler::enricher）。")
}

# 兼容不同列名
# 小工具：在候选列名里挑第一个存在的
pick_col <- function(df, candidates, default = NULL) {
	hit <- intersect(candidates, names(df))
	if (length(hit)) hit[1] else default
}

# 先把 enrich 结果变成普通 data.frame
enr_df <- if (inherits(enrich_res, "enrichResult")) as.data.frame(enrich_res) else enrich_df

# 找列名（按常见命名优先级）
id_col    <- pick_col(enr_df, c("ID", "PathwayID", "Term", "term", "pathway", "pathway_id"))
p_col     <- pick_col(enr_df, c("pvalue", "PValue"))
padj_col  <- pick_col(enr_df, c("p.adjust", "p_adj", "adj.P.Val", "FDR", "qvalue", "padj"))
count_col <- pick_col(enr_df, c("Count", "k", "n"))

if (is.null(id_col))   stop("在 enrich 结果里找不到通路ID列（例如 ID / PathwayID）")
if (is.null(padj_col)) stop("在 enrich 结果里找不到校正后p值列（例如 p.adjust / qvalue）")

# 用“基于 data.frame 的”方式构造，避免 dplyr 在 NSE 中访问不存在列
pdat <- data.frame(
	PathwayID = enr_df[[id_col]],
	pvalue    = if (!is.null(p_col))    enr_df[[p_col]]    else NA_real_,
	p.adjust  = if (!is.null(padj_col)) enr_df[[padj_col]] else NA_real_,
	Count     = if (!is.null(count_col)) enr_df[[count_col]] else NA_integer_,
	stringsAsFactors = FALSE
)

# 合并并计算 -log10(padj)，顺手把 0 替换成最小正数避免 -Inf
plot_df <- da_tab |>
	dplyr::inner_join(pdat, by = "PathwayID") |>
	dplyr::mutate(
		p.adjust  = ifelse(is.na(p.adjust) | p.adjust <= 0, .Machine$double.xmin, p.adjust),
		neglog10p = -log10(p.adjust)
	)


# 通路中文名/英文名（若你之前已生成 term2name_df，这里合并；否则就用 ID 作为名字）
if (exists("term2name_df")) {
	plot_df <- plot_df |>
		left_join(term2name_df |> distinct(PathwayID, PathwayName),
							by = "PathwayID") |>
		mutate(PathwayName = coalesce(PathwayName, PathwayID))
} else {
	plot_df$PathwayName <- plot_df$PathwayID
}

top20 <- plot_df |>
	arrange(p.adjust) |>
	slice_head(n = 20) |>
	mutate(PathwayName = fct_reorder(PathwayName, p.adjust, .desc = FALSE))

## 5) 绘图（线段=|DA|；点大小=N_diff；颜色=P 值，红=小/紫=大）-------------
p_da <- ggplot(top20, aes(x = DA, y = PathwayName)) +
	geom_segment(aes(x = 0, xend = DA, yend = PathwayName, color = p.adjust),
							 linewidth = 1.4, lineend = "round") +
	geom_point(aes(size = N_diff, color = p.adjust)) +
	scale_size_continuous(name = "# Diff metabolites", range = c(2.5, 7)) +
	scale_color_gradientn(
		colours = c("#E31A1C", "#6A3D9A"), # 红→紫
		values  = rescale(c(0, 1)),
		trans   = "reverse",               # 小 p 更红
		name    = "Adjusted p"
	) +
	labs(
		x = "DA Score = (Up - Down) / Total annotated in pathway",
		y = NULL,
		title = "Top 20 pathways by adjusted p-value",
		subtitle = "Segment length = |DA|; point size = # differential metabolites"
	) +
	theme_bw(base_size = 11) +
	theme(
		axis.text.y  = element_text(size = 10),
		legend.position = "right"
	)

ggsave("output/DA_score_top20.pdf", p_da, width = 8, height = 6)

#####小提琴图#####
## =========================
## 自动筛“乳酸化相关” + 小提琴图（p 来自差异分析）
## 需已在环境中有：annotation_df, expr_sample, sample_info
## 以及差异结果表 Diff 或 Diff_SIG（若只有文件，会自动读 output/Diff_SIG_VIP.csv）
## =========================

suppressPackageStartupMessages({
	library(dplyr); library(stringr); library(tidyr)
	library(ggplot2); library(grid)
})

## --- 读取差异结果（优先对象，其次CSV） ---
if (!exists("Diff_SIG") && file.exists("output/Diff_SIG_VIP.csv")) {
	Diff_SIG <- read.csv("output/Diff_SIG_VIP.csv", check.names = FALSE)
}
if (!exists("Diff") && file.exists("output/Diff_with_VIP.csv")) {
	Diff <- read.csv("output/Diff_with_VIP.csv", check.names = FALSE)
}
# 用于取 p 值的差异表（优先 Diff，其次 Diff_SIG）
diff_for_p <- if (exists("Diff")) Diff else if (exists("Diff_SIG")) Diff_SIG else stop("找不到差异结果表 Diff/Diff_SIG")

# 兼容列名
stopifnot(all(c("Compound") %in% names(diff_for_p)))
p_col <- if ("P.Value" %in% names(diff_for_p)) "P.Value" else if ("p_value" %in% names(diff_for_p)) "p_value" else NA
if (is.na(p_col)) stop("差异表中未发现 P.Value 或 p_value 列")

## --- 构建乳酸化相关的“名称关键词 + KEGG ID 白名单” ---
# 文献支撑：lactate(乳酸)、pyruvate(丙酮酸)、S-lactoylglutathione(乳酰谷胱甘肽)、methylglyoxal(甲基乙二醛)、
# glutathione/GSH(谷胱甘肽)、lactyl/lactoyl-CoA、NADH/NAD+、glucose(葡萄糖) 等
lactyl_name_terms <- c(
	# 乳酸/丙酮酸/葡萄糖
	"lactate", "lactic\\s*acid", "乳酸",
	"pyruvate", "丙酮酸",
	"glucose", "葡萄糖",
	# 甲基乙二醛 + 乳酰谷胱甘肽 + 谷胱甘肽
	"methylglyoxal", "甲基乙二醛",
	"lactoylglutathione", "s-?lactoylglutathione", "乳酰谷胱甘肽",
	"glutathione", "GSH", "谷胱甘肽",
	# 乳酰-/乳酰辅酶A
	"lactyl[- ]?coa", "lactoyl[- ]?coa", "乳酰辅酶\\s*a",
	# 氧化还原偶联
	"NADH", "NAD\\+"
)

# KEGG cpd_ID 白名单（只是加速/兜底；仍以名称匹配为主）
lactyl_kegg_ids <- c("C00186", # L-Lactate
										 "C00256", # D-Lactate
										 "C00022", # Pyruvate
										 "C03451", # S-lactoylglutathione
										 "C00546", # Methylglyoxal
										 "C00031", # D-Glucose
										 "C00024", # Acetyl-CoA
										 "C00004"  # NADH
)

## --- 安全清洗注释表关键列 ---
annotation_df$Compounds <- as.character(annotation_df$Compounds)
if (!("cpd_ID" %in% names(annotation_df))) annotation_df$cpd_ID <- NA_character_

## --- 在差异代谢物中做“乳酸化相关”筛选 ---
# 差异集合（名称与 annotation_df$Compounds 一致）
sig_set <- if (exists("Diff_SIG") && nrow(Diff_SIG) > 0) Diff_SIG$Compound else diff_for_p$Compound

# 名称正则
name_regex <- paste0("(?i)(", paste(lactyl_name_terms, collapse = "|"), ")")

# 命中逻辑：名称命中 OR cpd_ID 含白名单ID
is_hit <- function(nm, id){
	nm_hit <- !is.na(nm) && str_detect(nm, name_regex)
	id_hit <- !is.na(id) && str_detect(id, paste(lactyl_kegg_ids, collapse="|"))
	nm_hit || id_hit
}

hit_idx <- which(mapply(is_hit, annotation_df$Compounds, annotation_df$cpd_ID))
hits_all <- annotation_df$Compounds[hit_idx]
hits_in_diff <- intersect(hits_all, sig_set)

if (length(hits_in_diff) == 0) {
	stop("未在差异代谢物里检出与乳酸化相关的目标（名称/ID未命中）。可检查注释是否使用了其他同义名。")
}

message("检测到与乳酸化相关且显著差异的代谢物（n=", length(hits_in_diff), "）：\n  ",
				paste0(utils::head(hits_in_diff, 20), collapse="; "),
				if (length(hits_in_diff) > 20) " ..." else "")

## --- 组装小提琴图数据 ---
control_name <- "16HBE-hdm"
treat_name   <- "16HBE-si-RCC2-hdm"
color_palette <- c(control = "#2874C5", treat = "#EABF00")

plot_df <- expr_sample[rownames(expr_sample) %in% hits_in_diff, , drop = FALSE] %>%
	as.data.frame() %>%
	tibble::rownames_to_column("metabolite") %>%
	tidyr::pivot_longer(-metabolite, names_to = "Sample", values_to = "count") %>%
	dplyr::left_join(sample_info[, c("Sample","Group")], by = "Sample") %>%
	dplyr::mutate(
		type = dplyr::case_when(
			Group == control_name ~ "control",
			Group == treat_name   ~ "treat",
			TRUE ~ NA_character_
		),
		type = factor(type, levels = c("control","treat"),
									labels = c(control_name, treat_name))
	) %>%
	dplyr::filter(!is.na(type))

## --- 从差异表取 p 值并做named向量 ---
p_map <- diff_for_p %>%
	dplyr::transmute(Compound, p = .data[[p_col]]) %>%
	dplyr::filter(!is.na(Compound)) %>%
	{ stats::setNames(.$p, .$Compound) }

## --- 小提琴绘图函数（p 用差异分析中的） ---
dir.create("Results", showWarnings = FALSE, recursive = TRUE)

generate_violin_with_p <- function(df_one, metabolite_label){
	if (nrow(df_one) < 2 || nlevels(df_one$type) < 2) return(invisible(NULL))
	# 取差异分析p
	pval <- unname(p_map[metabolite_label])
	y_top <- max(df_one$count, na.rm = TRUE)
	p_lab <- ifelse(is.na(pval), "p = NA", paste0("p = ", formatC(pval, format="e", digits=2)))
	
	p <- ggplot(df_one, aes(x = type, y = count, fill = type)) +
		scale_fill_manual(values = setNames(unname(color_palette), c(control_name, treat_name))) +
		geom_violin(alpha = 0.4, position = position_dodge(width = .75),
								linewidth = 0.8, color = "black") +
		geom_boxplot(notch = TRUE, outlier.size = -1, linewidth = 0.8,
								 alpha = 0.7, color = "black",
								 position = position_dodge(width = .75)) +
		geom_point(shape = 21, size = 2, color = "black",
							 position = position_jitterdodge(dodge.width = .75)) +
		scale_x_discrete(drop = FALSE) +
		annotate("text", x = 1.5, y = y_top * 1.08, label = p_lab, size = 4.5) +
		expand_limits(y = y_top * 1.12) +
		theme_bw() +
		labs(title = metabolite_label, x = "", y = "Abundance") +
		theme(
			panel.background  = element_blank(),
			panel.grid        = element_blank(),
			axis.text.x       = element_text(size = 8, color = "black"),
			axis.text.y       = element_text(size = 8, color = "black"),
			axis.title        = element_text(size = 8),
			axis.ticks        = element_line(linewidth = 0.2, color = "black"),
			axis.ticks.length = unit(0.2, "cm"),
			legend.position   = "none",
			plot.title        = element_text(face = "bold", hjust = 0.5)
		)
	
	fn <- file.path("Results", paste0(gsub("[^A-Za-z0-9_]+","_", metabolite_label), "_violin.pdf"))
	ggsave(fn, p, width = 4, height = 6)
	message("Saved: ", fn)
}

## --- 批量输出 ---
for (met in unique(plot_df$metabolite)) {
	df_one <- dplyr::filter(plot_df, metabolite == !!met)
	generate_violin_with_p(df_one, met)
}
