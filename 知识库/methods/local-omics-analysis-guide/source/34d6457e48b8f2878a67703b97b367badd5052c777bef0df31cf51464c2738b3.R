library(Seurat)
library(GSVA)
library(GSEABase)
library(dplyr)
library(tidyverse)
rm(list = ls())
setwd("D:\\fyb\\UC-20\\19.细胞通讯")
# 获取metadata数据
meta_data <- UC@meta.data

# 按细胞类型分组并计算中位数
meta_data <- meta_data %>%
  group_by(celltype) %>%
  mutate(
    median = median(ISGylation, na.rm = TRUE),  # 计算当前细胞类型的中位数
    group = if_else(ISGylation > median,        # 高于中位数为high，否则为low
                    paste0("high_", celltype),
                    paste0("low_", celltype))
  ) %>%
  ungroup()

# 将分组信息添加回Seurat对象
UC$celltype <- meta_data$group

table(UC$celltype)

library(CellChat)
library(patchwork)
library(Seurat)
library(dplyr)
create_cellchat <- function(subset_obj, group_name) {
  # 提取数据
  data_input <- subset_obj@assays$RNA$data
  meta_data <- subset_obj@meta.data[, c("celltype"),drop=F]
  colnames(meta_data) <- c("labels")
  
  # 创建CellChat对象
  cellchat <- createCellChat(object = data_input, meta = meta_data, group.by = "labels")
  cellchat <- addMeta(cellchat, meta = meta_data)
  cellchat <- setIdent(cellchat, ident.use = "labels")
  
  # 设置数据库参数
  CellChatDB.use <- subsetDB(CellChatDB.human, search = "Secreted Signaling")
  cellchat@DB <- CellChatDB.use
  
  # 标准分析流程
  cellchat <- subsetData(cellchat)
  cellchat <- identifyOverExpressedGenes(cellchat)
  cellchat <- identifyOverExpressedInteractions(cellchat)
  cellchat <- projectData(cellchat, PPI.human)
  
  # 计算通讯概率
  cellchat <- computeCommunProb(cellchat, raw.use = TRUE)
  #cellchat <- filterCommunication(cellchat, min.cells = 10)
  cellchat <- computeCommunProbPathway(cellchat)
  cellchat <- aggregateNet(cellchat)
  
  return(cellchat)
}

cellchat <- create_cellchat(UC,"UC")
cellchat <- netAnalysis_computeCentrality(cellchat, slot.name = "netP")
######可视化####
library(ggplotify)
library(ggplot2)
# 转成 ggplot 对象
p_num <- as.ggplot(function() {
  netVisual_circle(
    cellchat@net$count,
    weight.scale = TRUE,
    label.edge = FALSE
  )
})

p_wgt <- as.ggplot(function() {
  netVisual_circle(
    cellchat@net$weight,
    weight.scale = TRUE,
    label.edge = FALSE
  )
})

# 定义一个统一的标题样式
title_theme <- theme(
  plot.title = element_text(hjust = 0.5, vjust = -0.5, face = "bold", size = 16),
  plot.margin = ggplot2::margin(t = 5, r = 5, b = 5, l = 5)  # 上边距缩小
)

# 保存 PDF
ggsave(
  "netVisual_circle_Number.pdf",
  p_num + ggtitle("Number of interactions") + title_theme,
  width = 8, height = 8
)

ggsave(
  "netVisual_circle_weight.pdf",
  p_wgt + ggtitle("Interaction weights/strength") + title_theme,
  width = 8, height = 8
)


library(CellChat)
library(grid)
library(ComplexHeatmap)
library(circlize)   # colorRamp2
# -----
pathways.show <- c("CXCL","SPP1","WNT")
pw.avail <- intersect(pathways.show, cellchat@netP$pathways)

for (pw in pw.avail) {
  df_comm <- tryCatch(subsetCommunication(cellchat, signaling = pw),
                      error = function(e) NULL)
  if (is.null(df_comm) || nrow(df_comm) == 0) next
  
  ht <- netVisual_heatmap(cellchat, signaling = pw,
                          measure = "weight", color.heatmap = "Reds")
  
  pdf(paste0("CellChat_", pw, "_heatmap.pdf"), width = 8.5, height = 6.5)
  
  grid.newpage()
  # 三行：标题 / 热图 / 色带
  lay <- grid.layout(nrow = 3, ncol = 1,
                     heights = unit.c(unit(6, "mm"), unit(1, "null"), unit(7, "mm")))
  pushViewport(viewport(layout = lay))
  
  ## 行1：标题
  pushViewport(viewport(layout.pos.row = 1, layout.pos.col = 1))
  grid.text(paste0(pw, " signaling network"),
            gp = gpar(fontsize = 14, fontface = "bold"))
  popViewport()
  
  ## 行2：热图（不要新开页）
  pushViewport(viewport(layout.pos.row = 2, layout.pos.col = 1))
  ComplexHeatmap::draw(ht, heatmap_legend_side = "right", newpage = FALSE)
  popViewport()
  
  ## 行3：自定义水平色带 + 左右标签
  pushViewport(viewport(layout.pos.row = 3, layout.pos.col = 1))
  
  # 画一个从红到蓝的水平渐变条（左=高 / 右=低）
  n <- 400
  cols <- colorRampPalette(c("red", "blue"))(n)
  mat_cols <- matrix(cols, nrow = 1, ncol = n, byrow = TRUE)  # 1行n列
  
  grid.raster(mat_cols,
              width = unit(0.75, "npc"), height = unit(3, "mm"),
              x = 0.5, y = 0.55, interpolate = TRUE)
  
  # 左右文字
  grid.text("High",
            x = unit(0.5, "npc") - unit(0.375, "npc"), y = unit(0.55, "npc"),
            just = c("right", "center"),
            gp = gpar(col = "red", fontsize = 10, fontface = "bold"))
  grid.text("Low",
            x = unit(0.5, "npc") + unit(0.375, "npc"), y = unit(0.55, "npc"),
            just = c("left", "center"),
            gp = gpar(col = "blue", fontsize = 10, fontface = "bold"))
  
  popViewport()
  dev.off()
}

library(CellChat)
library(ggplot2)
library(ggalluvial)

# 取簇
clusters       <- levels(cellchat@idents)
high_clusters  <- grep("^high_", clusters, value = TRUE)
low_clusters   <- grep("^low_",  clusters, value = TRUE)
stopifnot(length(high_clusters) > 0, length(low_clusters) > 0)

# 右侧接收者 = low_*
vertex.receiver <- which(clusters %in% high_clusters)

# 想画的通路（可自定义）
pathways.want <- c("CXCL","SPP1","WNT")

# 仅保留对象里存在且“有边”的通路
pathways.ok <- intersect(pathways.want, cellchat@netP$pathways)
pathways.use <- Filter(function(pw) {
  df <- subsetCommunication(cellchat, signaling = pw)
  !is.null(df) && nrow(df) > 0
}, pathways.ok)
stopifnot(length(pathways.use) > 0)

for (pw in pathways.use) {
  pdf(paste0("hierarchy_high2low1_", pw, ".pdf"), width = 15, height = 6.5)
  p <- netVisual_aggregate(
    object = cellchat,
    signaling = pw,
    layout = "hierarchy",
    vertex.receiver = vertex.receiver
  )
  dev.off()
}

## =========================
## A) 在整个对象内：按“每个基础细胞类型”的中位数定义 RA_group
## =========================
library(Seurat); library(dplyr)
md <- UC@meta.data

# 去掉旧的 high_/low_ 前缀，还原基础类型名
base_type <- gsub("^high_|^low_", "", md$celltype)
UC$celltype0 <- base_type

# 计算每个基础类型的 RA 代谢中位数
ra_medians <- tapply(md$ISGylation, UC$celltype0, median, na.rm = TRUE)
UC$RA_group <- ifelse(md$ISGylation > ra_medians[UC$celltype0], "ISGylation_high", "ISGylation_low")

## =========================
## B) 仅保留 RA_high 的细胞，且在其中把 AEC 按 RCC2 中位数再分 high/low
## =========================
cells_ra_high <- rownames(UC@meta.data)[UC$RA_group == "ISGylation_high"]
oc_ra <- subset(UC, cells = cells_ra_high)

md_ra <- oc_ra@meta.data
base_type_ra <- oc_ra$celltype0
is_AEC_ra <- base_type_ra == "Epithelial"     # 若你的命名是 AT1/AT2，请改成 %in% c("AT1","AT2")

# RCC2 表达（log-normalized）
rcc2_gene <- grep("^UBE2L6$", rownames(oc_ra[["RNA"]]), ignore.case = TRUE, value = TRUE)
stopifnot(length(rcc2_gene) == 1)
rcc2_vec <- as.numeric(GetAssayData(oc_ra, assay = "RNA", slot = "data")[rcc2_gene, ])

rcc2_med_AEC_ra <- median(rcc2_vec[is_AEC_ra], na.rm = TRUE)
oc_ra$RCC2_group <- NA_character_
oc_ra$RCC2_group[is_AEC_ra] <- ifelse(rcc2_vec[is_AEC_ra] > rcc2_med_AEC_ra, "UBE2L6_high", "UBE2L6_low")

# 生成绘图/CellChat 用标签：
# - AEC → “RAhigh_AEC_RCC2_high/low”
# - 其他细胞类型（都已是 RA_high） → 用其基础类型名
labels_ra <- ifelse(is_AEC_ra,
                    paste0(oc_ra$RCC2_group,"_Epithelial"),
                    base_type_ra)
labels_ra <- factor(labels_ra, levels = unique(labels_ra))
table(labels_ra)   # 自查

## =========================
## C) 用 “RA_high 子集 + 新标签” 创建 CellChat 并计算通路级网络
## =========================
library(CellChat)
data_input <- oc_ra@assays$RNA$data
meta_df <- data.frame(labels = labels_ra, row.names = colnames(data_input))

cellchat_ra <- createCellChat(object = data_input, meta = meta_df, group.by = "labels")
CellChatDB.use <- subsetDB(CellChatDB.human, search = "Secreted Signaling")
cellchat_ra@DB <- CellChatDB.use

cellchat_ra <- subsetData(cellchat_ra)
cellchat_ra <- identifyOverExpressedGenes(cellchat_ra)
cellchat_ra <- identifyOverExpressedInteractions(cellchat_ra)
cellchat_ra <- projectData(cellchat_ra, PPI.human)

cellchat_ra <- computeCommunProb(cellchat_ra, raw.use = TRUE)
# 可选：若有极小簇，可设最小细胞数过滤
# cellchat_ra <- filterCommunication(cellchat_ra, min.cells = 10)

cellchat_ra <- computeCommunProbPathway(cellchat_ra)  # 关键：得到 netP$prob（源×靶×通路）
cellchat_ra <- aggregateNet(cellchat_ra)

# 设置信号源为两种AEC
sources.use <- c("UBE2L6_high_Epithelial", "UBE2L6_low_Epithelial")

# 目标细胞类型（除AEC外的所有合并类型）
targets.use <- setdiff(levels(cellchat_ra@idents), sources.use)

# 可选：分别绘制high_AEC和low_AEC的信号
pdf("UBE2L6_high_Epithelial_to_Merged_bubble.pdf", width = 14, height = 6)
bubble_plot = netVisual_bubble(
  cellchat_ra,
  sources.use = "UBE2L6_high_Epithelial",
  targets.use = targets.use,
  remove.isolate = FALSE,
  angle.x = 90
) +
  coord_flip() +
  ggtitle("Signaling from UBE2L6_high_Epithelial to Merged Cell Types")
# 增强气泡大小和可读性
enhanced_plot <- bubble_plot +
  # 增大气泡尺寸
  scale_size_continuous(
    range = c(3, 10),  # 最小和最大气泡尺寸
    name = "Interaction\nStrength",  # 图例标题
    breaks = seq(0, max(bubble_plot$data$prob, na.rm = TRUE), length.out = 5)  # 图例断点
  ) +
  # 增强颜色对比度
  scale_color_gradientn(
    colors = c("blue", "yellow", "red"),  # 使用更鲜明的颜色梯度
    name = "Communication\nProbability",
    limits = c(0, 1)
  )
print(enhanced_plot)
dev.off()

pdf("UBE2L6_low_Epithelial_to_Merged_bubble.pdf", width = 14, height = 6)  # 增加画布尺寸以适应更大气泡

# 创建基础气泡图
bubble_plot <- netVisual_bubble(
  cellchat_ra,
  sources.use = "UBE2L6_low_Epithelial",
  targets.use = targets.use,
  remove.isolate = FALSE,
  angle.x = 90
) +
  coord_flip() +
  ggtitle("Signaling from UBE2L6_low_Epithelial to Merged Cell Types")

# 增强气泡大小和可读性
enhanced_plot <- bubble_plot +
  # 增大气泡尺寸
  scale_size_continuous(
    range = c(3, 10),  # 最小和最大气泡尺寸
    name = "Interaction\nStrength",  # 图例标题
    breaks = seq(0, max(bubble_plot$data$prob, na.rm = TRUE), length.out = 5)  # 图例断点
  ) +
  # 增强颜色对比度
  scale_color_gradientn(
    colors = c("blue", "yellow", "red"),  # 使用更鲜明的颜色梯度
    name = "Communication\nProbability",
    limits = c(0, 1)
  )
print(enhanced_plot)
dev.off()

##计算网络中心评分
cellchat_ra <- netAnalysis_computeCentrality(cellchat_ra, slot.name = "netP")
# Visualize the computed centrality scores using heatmap, allowing ready identification of major signaling roles of cell groups
pdf("netAnalysis_signalingRole_scatter.pdf",width = 6,height = 6)
netAnalysis_signalingRole_scatter(cellchat_ra)
dev.off()

pdf("netAnalysis_signalingRole_heatmap.pdf",width = 10,height = 6)
ht1 <- netAnalysis_signalingRole_heatmap(cellchat_ra, pattern = "outgoing")
ht2 <- netAnalysis_signalingRole_heatmap(cellchat_ra, pattern = "incoming")
ht1 + ht2
dev.off()

# 循环生成每个通路的热图
pathways.show = c("OSM","VISFATIN")
for (pathway in pathways.show) {
  # 动态生成文件名
  pdf_filename <- paste0("netAnalysis_signalingRole_heatmap_", pathway, ".pdf")
  
  # 打开 PDF 设备
  pdf(pdf_filename, width = 8, height = 6)
  
  # 调用 netAnalysis_signalingRole_network 函数
  netAnalysis_signalingRole_network(cellchat, pathway, width = 12, height = 4, font.size = 6)
  
  # 关闭 PDF 设备
  dev.off()
}
