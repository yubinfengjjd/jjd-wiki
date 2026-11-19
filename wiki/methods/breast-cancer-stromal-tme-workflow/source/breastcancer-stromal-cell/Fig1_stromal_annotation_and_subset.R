## =========================================================
## Script: Fig1_stromal_annotation_and_subset.R
## Purpose:
##   1. 读取基质细胞对象并补充样本元信息
##   2. 按 subclusters 归类为 CAF / PVL / Endo
##   3. 绘制 UMAP、DotPlot、FeaturePlot
##   4. 提取 CAF / PVL / Endo 子集用于后续分析
##
## Input:
##   - rawdata/sub_CAF_pre.qs
##   - /home/data/caixing/CAF/metadata.csv
##
## Output:
##   - rawdata/breatcaner_str.qs
##   - result/fig1/*.pdf
##   - result/fig2_CAF/sub_caf.qs
##   - result/fig3_PVL/sub_PVL.qs
##   - result/fig4_Endo/sub_Endo.qs
## =========================================================


## =========================================================
## 1. Load packages
## =========================================================
library(SCP)
library(harmony)
library(Seurat)
library(ggpubr)
library(dplyr)
library(tidyverse)
library(patchwork)
library(ComplexHeatmap)
library(circlize)
library(vegan)
library(openxlsx)
library(ggplot2)
library(qs)
library(cowplot)
library(tidyr)
library(stringr)
library(viridis)
library(scCustomize)

## 创建输出目录（避免保存时报错）
dir.create("result/fig1", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig2_CAF", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig3_PVL", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig4_Endo", recursive = TRUE, showWarnings = FALSE)
dir.create("rawdata", recursive = TRUE, showWarnings = FALSE)


## =========================================================
## 2. Read Seurat object and metadata
## =========================================================
sce <- qread("rawdata/sub_CAF_pre.qs")

## 查看已有亚群信息
table(sce$subclusters)

## 读取外部样本注释表
df <- read.csv("/home/data/caixing/CAF/metadata.csv")

## 提取对象元信息
mate <- sce@meta.data
mate$orig.ident <- as.character(mate$orig.ident)

## 查找 metadata 中未匹配到的样本（用于检查）
df_filtered <- mate[!mate$orig.ident %in% intersect(df$orig.ident, mate$orig.ident), ]
unique(df_filtered$orig.ident)

## 合并元信息
mate1 <- left_join(mate, df, by = "orig.ident")

## 简单检查合并结果
table(mate1$Tissue)
table(mate1$GSE_number)

## 将新元信息加入 Seurat 对象
sce <- AddMetaData(sce, metadata = mate1)


## =========================================================
## 3. Plot GSE_number on UMAP
## =========================================================
CellDimPlot(
  srt = sce,
  label = FALSE,
  group.by = "GSE_number",
  reduction = "HarmonyUMAP2D",
  theme_use = "theme_blank"
)
ggsave("result/fig1/allcelltype_GSE_number.pdf", width = 7, height = 5)

## 保存补充完metadata后的对象
qsave(sce, file = "rawdata/breatcaner_str.qs")


## =========================================================
## 4. Define marker genes for major cell types
## =========================================================
sce <- qread("rawdata/breatcaner_str.qs")

genes_to_check <- c(
  "PTPRC", "CD3D", "CD3E", "CD8A", "CD4", "CD8B",         # T cells
  "CD19", "CD79A", "MS4A1",                               # B cells
  "IGHG1", "MZB1", "SDC1",                                # Plasma cells
  "CD68", "CD163", "CD14",                                # Monocyte / macrophage
  "FGFBP2", "CX3CR1",                                     # NK cells
  "RCVRN",                                                # Photoreceptor cells
  "LYZ", "MARCO", "FCGR3A",                               # Myeloid cells
  "FGF7", "MME", "COL1A1", "COL1A2", "DCN",              # Fibroblasts
  "PECAM1", "VWF",                                        # Endothelial cells
  "EPCAM", "KRT18", "KRT8", "PROM1", "ALDH1A1", "CD24"   # Epithelial / tumor
)

## 绘制总体 marker DotPlot
DotPlot(
  sce,
  cols = c("#1e90ff", "#F15F30"),
  features = genes_to_check,
  group.by = "clusters",
  dot.scale = 3.5
) +
  scale_size(range = c(1, 6), breaks = c(0, 25, 50, 75)) +
  scale_colour_gradient2(
    low = "#242467",
    mid = "#f0f1f2",
    high = "#f20d0d",
    midpoint = 0.1
  ) +
  theme(axis.text.y = element_text(size = 4)) +
  theme(axis.text.x = element_text(size = 6, angle = 90)) +
  labs(x = "", y = "")

ggsave("result/fig1/all_DotPlot.pdf", width = 6, height = 4)


## =========================================================
## 5. Visualize existing clusters
## =========================================================
CellDimPlot(
  srt = sce,
  label = TRUE,
  group.by = "clusters",
  reduction = "HarmonyUMAP2D",
  theme_use = "theme_blank"
)
ggsave("result/fig1/sce_caf.pdf", width = 6, height = 5)

## =========================================================
## 6. FeaturePlot for representative markers
## =========================================================
marker_featureplot <- c(
  "COL1A1", "COL1A2", "DCN",
  "PECAM1", "VWF", "CD34",
  "ACTA2", "PDGFRB", "MCAM"
)

plots <- list()
for (i in seq_along(marker_featureplot)) {
  plots[[i]] <- FeaturePlot_scCustom(
    seurat_object = sce,
    reduction = "HarmonyUMAP2D",
    pt.size = 1,
    colors_use = colorRampPalette(c("white", "#D53E4F"))(100),
    features = marker_featureplot[i]
  ) + NoAxes()
}

p <- wrap_plots(plots, ncol = 3)
ggsave(p, file = "result/fig1/featureplot3.pdf", width = 8, height = 6)


## =========================================================
## 7. SCP FeatureDimPlot
## =========================================================
marker_density <- c(
  "COL1A1", "DCN",
  "PECAM1", "VWF",
  "ACTA2", "PDGFRB", "MCAM"
)

FeatureDimPlot(
  srt = sce,
  features = marker_density,
  pt.size = 1,
  pt.alpha = 1,
  bg_color = "grey80",
  density_color = "white",
  reduction = "HarmonyUMAP2D",
  theme_use = "theme_blank"
)
ggsave("result/fig1/caf-pvl-edno_FeatureDimPlot.pdf", width = 10, height = 10)


Idents(sce) <- sce$clusters
sce@graphs <- list()


sub_CAF <- subset(
  sce,
  subset = clusters %in% c('CAF'
  )
)

qsave(sub_CAF, file = "result/fig2_CAF/sub_caf.qs")


sub_PVL <- subset(
  sce,
  subset = clusters %in% c(
    "PVL"
  )
)

qsave(sub_PVL, file = "result/fig3_PVL/sub_PVL.qs")


sub_Endo <- subset(
  sce,
  subset = clusters %in% c(
    "Endo"
  )
)

qsave(sub_Endo, file = "result/fig4_Endo/sub_Endo.qs")
