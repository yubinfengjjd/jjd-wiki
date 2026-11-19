## =========================================================
## 1. Load required packages
## =========================================================
## SCP: 单细胞整合分析框架
## Seurat: 单细胞分析核心包
## scProgram: 功能富集分析
## qs: 快速读写对象
library(SCP)
library(harmony)
library(Seurat)
library(scProgram)
library(qs)

library(dplyr)
library(tidyverse)
library(ggplot2)
library(patchwork)
library(ggpubr)

library(ComplexHeatmap)
library(circlize)
library(philentropy)
library(data.table)
library(vegan)
library(openxlsx)

## =========================================================
## 2. Read and preprocess data
## =========================================================
## 读取CAF子集对象
sub_CAF <- qread("result/fig2_CAF/sub_caf.qs")

## 设置RNA为默认分析矩阵
DefaultAssay(sub_CAF) <- "RNA"

## 精简Seurat对象，仅保留RNA（减少内存）
sub_CAF <- DietSeurat(sub_CAF, assays = "RNA")


## =========================================================
## 3. Integration using fastMNN
## =========================================================
## fastMNN：适合处理批次效应较明显的数据
sub_CAF <- Integration_SCP(
  srtMerge = sub_CAF,
  batch = "batch",                  # 批次变量
  nHVF = 4000,                      # 高变基因数
  vars_to_regress = c("nCount_RNA", "percent_mito"),  # 回归掉测序深度和线粒体比例
  neighbor_k = 30L,                 # 邻居数
  cluster_resolution = c(0.6, 0.7, 0.8, 0.9),
  integration_method = "fastMNN"
)

## 可视化fastMNN聚类
p_fastmnn <- CellDimPlot(
  srt = sub_CAF,
  group.by = "fastMNN_SNN_res.0.6",
  label = TRUE,
  reduction = "fastMNNUMAP2D",
  theme_use = "theme_blank"
)


## =========================================================
## 4. Integration using Harmony
## =========================================================
## Harmony：适用于复杂多批次数据整合
sub_CAF <- Integration_SCP(
  srtMerge = sub_CAF,
  batch = "batch",
  nHVF = 4000,
  vars_to_regress = c("nCount_RNA", "percent_mito"),
  neighbor_k = 30L,
  linear_reduction_dims = 2:20,     # PCA维度
  nonlinear_reduction_dims = c(1, 2), # UMAP维度
  cluster_resolution = c(0.6, 0.7, 0.8, 0.9),
  integration_method = "Harmony"
)

## 保存cluster结果
sub_CAF$Harmonyclusters <- sub_CAF$Harmony_SNN_res.0.6
sub_CAF$fastMNNclusters <- sub_CAF$fastMNN_SNN_res.0.6

## UMAP展示
p_harmony <- CellDimPlot(
  srt = sub_CAF,
  group.by = "Harmonyclusters",
  label = TRUE,
  reduction = "HarmonyUMAP2D",
  theme_use = "theme_blank"
)

qsave(sub_CAF, "result/sub_CAF_re_analysis.qs")


## =========================================================
## 5. Marker gene identification
## =========================================================
## 设置cluster为分组依据
Idents(sub_CAF) <- sub_CAF$Harmonyclusters

## 找每个cluster的marker基因
sub_CAF_maker <- FindAllMarkers(
  sub_CAF,
  logfc.threshold = 1,   # log2FC > 1
  min.pct = 0.1,         # 至少10%细胞表达
  only.pos = TRUE        # 只取上调基因
)

qsave(sub_CAF_maker, "result/fig2_CAF/sub_CAF_maker.qs")


## =========================================================
## 7. Functional enrichment (cluster level)
## =========================================================
## 提取每个cluster的代表基因
FeatureMatrix <- GetFeatures(
  obj = sub_CAF,
  group.by = "Harmonyclusters",
  genenumber = 100,
  pct_exp = 0.1,
  mode = "fast"
)

## KEGG富集
GetProgram(
  features = FeatureMatrix,
  geneset = "KEGG",
  pvalue_cutoff = 0.05,
  cols = c("#F47E5D", "#CA3D74", "#7F2880", "#463873"),
  plot_term_number = 5
)
ggsave("result/fig2_CAF/scRNA_CAF_marker_KEGG.pdf", width = 10, height = 12)

## Hallmark富集
GetProgram(
  features = FeatureMatrix,
  geneset = "HALLMARK",
  pvalue_cutoff = 0.05,
  cols = c("#F47E5D", "#CA3D74", "#7F2880", "#463873"),
  plot_term_number = 5
)
ggsave("result/fig2_CAF/scRNA_CAF_marker_HALLMARK.pdf", width = 10, height = 12)


## =========================================================
## 8. DEG filtering and top marker selection
## =========================================================
DEGs <- sub_CAF_maker %>%
  filter(avg_log2FC > 1, p_val_adj < 0.05) %>%
  mutate(PCT = pct.1 - pct.2) %>%
  filter(PCT > 0.1)

## 若存在注释文件，则筛选已注释基因
if (exists("anno")) {
  DEGs <- DEGs %>% filter(gene %in% anno$gene_name)
}

## 每个cluster选top marker
top_markers <- DEGs %>%
  group_by(cluster) %>%
  slice_max(order_by = avg_log2FC, n = 5, with_ties = FALSE)


## =========================================================
## 9. Marker gene visualization (DotPlot)
## =========================================================
CAF_marker <- c(
  "RGS5","NDUFA4L2","ADIRF","MYH11","ACTA2",
  "FAP","TGFB1","MMP11","COL1A1","CTHRC1","COL11A1","POSTN","PLA2G2A",
  "CXCL8","MT-RNR2","MT-RNR1","MTATP6P1",
  "CFD","PTGDS","FBLN1","GSN","IGFBP6",
  "COX6C",
  "PLVAP","RAMP2","SLC9A3R2","RGCC","FLT1",
  "S100B","GPM6B","PLP1","LGI4","NRXN1",
  "HLA-DRA","CD74","CCL5","HLA-DRB1","HLA-DPB1",
  "APOC1","APOD","APOE"
)

## DotPlot展示marker表达情况
p_dot_harmony <- DotPlot(
  sub_CAF,
  cols = c("white", "#F15F30"),
  features = CAF_marker,
  group.by = "Harmonyclusters",
  dot.scale = 6
) +
  scale_size(range = c(1, 7), breaks = c(0, 25, 50, 75)) +
  scale_colour_gradient2(
    low = "#242467",
    mid = "#f0f1f2",
    high = "#f20d0d",
    midpoint = 0.5
  ) +
  NoLegend() +
  theme(
    axis.text.y = element_text(size = 4),
    axis.text.x = element_text(size = 6, angle = 90)
  )


## =========================================================
## 10. Manual subcluster annotation
## =========================================================
## 根据marker手动定义CAF亚群
sub_CAF$subclusters <- NA

sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("0","16"),"subclusters"] <- "C1_Fib_ACTA2"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("9"),"subclusters"] <- "C2_Fib_HSPA6"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("1"),"subclusters"] <- "C3_Fib_PLA2G2A"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("2"),"subclusters"] <- "C4_Fib_BNC2"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("7","5"),"subclusters"] <- "C5_Fib_CXCL8"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("6"),"subclusters"] <- "C6_Fib_NFKB1"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("3"),"subclusters"] <- "C7_Fib_APOD"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("4"),"subclusters"] <- "C8_Fib_CCL19"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("8"),"subclusters"] <- "C9_Fib_COL12A1"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("10"),"subclusters"] <- "C10_Fib_ABCA8"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("11"),"subclusters"] <- "C11_Fib_ENO1"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("14","12"),"subclusters"] <- "C12_Fib_CD74"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("13"),"subclusters"] <- "C13_Fib_LUM"
sub_CAF@meta.data[sub_CAF$Harmonyclusters %in% c("15"),"subclusters"] <- "C14_Fib_A2M"


## =========================================================
## 11. UMAP visualization
## =========================================================
p_umap <- CellDimPlot(
  srt = sub_CAF,
  group.by = "subclusters",
  label = TRUE,
  reduction = "HarmonyUMAP2D",
  theme_use = "theme_blank"
)

ggsave("result/fig2_CAF/CAF_UMAP.pdf", p_umap, width = 6, height = 5)


## =========================================================
## 12. Subcluster DEG analysis
## =========================================================
Idents(sub_CAF) <- sub_CAF$subclusters

sub_CAF_maker_subclusters <- FindAllMarkers(
  sub_CAF,
  logfc.threshold = 1,
  min.pct = 0.1,
  only.pos = TRUE
)

qsave(sub_CAF_maker_subclusters, "result/fig2_CAF/sub_CAF_maker_subclusters.qs")


## =========================================================
## 13. Export DEG table
## =========================================================
maker <- sub_CAF_maker_subclusters
maker$PCT <- maker$pct.1 - maker$pct.2

write_csv(maker, "result/fig2_CAF/CAF-DEGs.csv")

sub_CAFmaker <- c(
  'ACTA2','TAGLN','MYL9',#'POSTN' 0,16 
  'HAS1','BAG3','HSPA6',# hspCAF 9, 
  'CLEC3B','PLA2G2A','PI16','CD248',# 1,
  'RORA','BNC2','KCND2',#'PRKG1',2,
  'PRKG1','CXCL8','CXCL3','CXCL1',#iCAF1 CXCL8  7,5,
  'CXCL2','NFKB1','ZSWIM6', #iCAF2 CXCL2 6, 
  'APOD','APOE','ITM2A','PTGDS', #3, 
  'CCL19','CXCL10','CXCL9', #ifnCAF(干扰素相关CAF)4, 
  'COL12A1','COL10A1','SULF1', #ACTA2  8,
  'ABCA8','SVEP1','ABCA10', #10,
  'ENO1','TGFBI','CA9','PGK1',#tumor-like CAF 缺氧 11,
  'CD74','HLA-DRA',"HLA-DRB1", #14,12,
  'LUM','SFRP2','CCN5',#wnt通路活化 tumor-like 13,
  'NOTCH3','F2R','A2M' #15,
)


DotPlot(sub_CAF, cols = c("white", "#F15F30"), features =sub_CAFmaker, 
        group.by = "Harmonyclusters", dot.scale = 6) +   
  scale_size(range = c(1,4),breaks = c(0,25,50,75))+
  scale_colour_gradient2(low = "#242467", mid = "#f0f1f2", high = "#f20d0d",midpoint = 0.5)+ NoLegend() + theme(axis.text.y = element_text(size = 4)) + labs(x= "", y = "") + theme(axis.text.x = element_text(size = 6, angle = 90))

ggsave("result/fig2_CAF//CAF_maker.pdf",width = 10,height = 5)


