## =========================================================
## Script: Fig2_CAF_program_distribution_progeny.R
## Purpose:
##   1. 读取 CAF 子集对象
##   2. 计算 CAF programs / module scores
##   3. 绘制 FeaturePlot / FeatureDimPlot
##   4. 结合 metadata 统计不同样本中 CAF 亚群比例
##   5. 绘制 boxplot / barplot / Roe distribution
##   6. 进行 PROGENy 通路分析
##   7. 绘制 chemokine / MHC 热图
##
## Input:
##   - result/fig2_CAF/sub_caf.qs
##   - metadata.csv
##   - code/distribution_Roe.R
##   - code/ratio.plot.R
##   - rawdata/gene_chemokines.csv
##   - rawdata/gene_MHC.csv
##
## Output:
##   - result/fig2_CAF/*.pdf
##   - result/fig2_CAF/*.rds
##   - result/fig2_CAF/*.qs
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
library(progeny)
library(tibble)
library(scater)
library(dendextend)
library(readxl)
library(RColorBrewer)
library(matrixStats)
library(pheatmap)
library(grid)

dir.create("result/fig2_CAF", recursive = TRUE, showWarnings = FALSE)


## =========================================================
## 2. Read CAF object
## =========================================================
sub_CAF <- qread("result/fig2_CAF/sub_caf.qs")


## =========================================================
## 3. Define CAF-related gene programs
## =========================================================
caf_programs <- list(
  rCAF =  c("CCL21", "CCL19", "ACTA2"),
  iCAF = c("PLA2G2A", "CFD", "C3", "CD34", "CXCL12", "CXCL14", "IL6", "CD248"),
  mCAF = c("MMP11", "COL1A2", "POSTN", "CDH11", "COL10A1", "COL11A1", "COL8A1",
           "COL12A1", "COL3A1", "COL5A2", "COMP", "LRRC15", "LRRC17", "ASPN",
           "SULF1", "INHBA", "VCAN", "CTHRC1", "MGP"),
  tCAF = c("PDPN", "MME", "TMEM158", "NDRG1", "ENO1", "VEGFA", "CA9", "CAIX",
           "HSPH1", "GAPDH", "HSP90AA1"),
  dCAF = c("MKI67", "TUBA1B"),
  ifnCAF = c("IDO1", "IL32", "CXCL9", "CXCL10", "CXCL11"),
  apCAF =  c("CD74", "HLA-DRA", "HLA-DRB1"),
  vCAF = c("NOTCH3", "COL18A1", "ACTA2", "MCAM", "CD146", "RERGL", "MYH11", "RGS5"),
  LipCAF = c("APOA2", "FABP1", "FABP4", "FRZB", "CFD", "APOD")
)


## =========================================================
## 4. Add module scores
## =========================================================
## 为避免按固定列号重命名，这里逐个添加并手动命名
for (prog_name in names(caf_programs)) {
  sub_CAF <- AddModuleScore(
    sub_CAF,
    features = list(caf_programs[[prog_name]]),
    name = paste0(prog_name, "_Score")
  )
  
  ## AddModuleScore 默认会生成 xxx1，这里统一改成 program 名
  old_col <- paste0(prog_name, "_Score1")
  if (old_col %in% colnames(sub_CAF@meta.data)) {
    colnames(sub_CAF@meta.data)[colnames(sub_CAF@meta.data) == old_col] <- prog_name
  }
}


## =========================================================
## 5. Visualize selected CAF programs
## =========================================================
programs_to_plot <- c("iCAF", "mCAF", "tCAF", "ifnCAF")

plots <- vector("list", length(programs_to_plot))
for (i in seq_along(programs_to_plot)) {
  plots[[i]] <- FeaturePlot_scCustom(
    seurat_object = sub_CAF,
    reduction = "HarmonyUMAP2D",
    pt.size = 0.05,
    colors_use = colorRampPalette(c("#3288BD", "white", "#D53E4F"))(50),
    features = programs_to_plot[i]
  ) + NoAxes()
}

p_program <- wrap_plots(plots, ncol = 2)
ggsave(p_program, file = "result/fig2_CAF/CAF_genesets.pdf", height = 5, width = 6)

FeatureDimPlot(
  srt = sub_CAF,
  features = programs_to_plot,
  pt.size = 1.5,
  pt.alpha = 1,
  bg_color = "grey80",
  density_color = "white",
  reduction = "HarmonyUMAP2D",
  theme_use = "theme_blank"
)
ggsave("result/fig2_CAF/genesetcaf_FeatureDimPlot.pdf", height = 5, width = 6)

## 单独展示 LipCAF
FeatureDimPlot(
  srt = sub_CAF,
  features = "LipCAF",
  pt.size = 1.5,
  pt.alpha = 1,
  bg_color = "grey80",
  density_color = "white",
  reduction = "HarmonyUMAP2D",
  theme_use = "theme_blank"
)


## =========================================================
## 6. Add sample metadata
## =========================================================
df_meta <- read.csv("metadata.csv")
mate <- sub_CAF@meta.data
mate$orig.ident <- as.character(mate$orig.ident)

## 查看哪些样本没有匹配到 metadata
df_filtered <- mate[!mate$orig.ident %in% intersect(df_meta$orig.ident, mate$orig.ident), ]
unique(df_filtered$orig.ident)

mate1 <- left_join(mate, df_meta, by = "orig.ident")
sub_CAF <- AddMetaData(sub_CAF, metadata = mate1)

## 每个样本保留一条 metadata
mate2 <- mate1[!duplicated(mate1$orig.ident), ]


## =========================================================
## 7. Calculate CAF subtype proportion across samples
## =========================================================
counts <- as.data.frame(table(mate1$orig.ident))
df_count <- as.data.frame(table(mate1$orig.ident, mate1$subclusters))

df_count2 <- merge(df_count, counts, by = "Var1")
df_count2$pct <- df_count2$Freq.x / df_count2$Freq.y
df_stat <- merge(df_count2, mate2, by.x = "Var1", by.y = "orig.ident")
saveRDS(df_stat, "result/fig2_CAF/matedata_cli_cluters.rds")


## =========================================================
## 8. Boxplot / barplot for subtype proportion
## =========================================================
df_plot <- readRDS("result/fig2_CAF/matedata_cli_cluters.rds")

caf_levels <- c(
  "C1_Fib_ACTA2", "C2_Fib_HSPA6",
  "C3_Fib_PLA2G2A", "C4_Fib_BNC2",
  "C5_Fib_CXCL8", "C6_Fib_NFKB1",
  "C7_Fib_APOD", "C8_Fib_CCL19",
  "C9_Fib_COL12A1", "C10_Fib_ABCA8",
  "C11_Fib_ENO1", "C12_Fib_CD74",
  "C13_Fib_LUM", "C14_Fib_A2M"
)

df_plot$Var2 <- factor(df_plot$Var2, levels = caf_levels)
df_plot <- df_plot[, c("Var2", "pct", "Tissue")]
df_plot$Type <- factor(
  df_plot$Tissue,
  levels = c("Normal", "Tumor", "Lymphnode")
)
df_plot$pct <- as.numeric(df_plot$pct)

## 仅展示指定组织类型
df_plot <- dplyr::filter(df_plot, Type %in% c("Normal", "Tumor", "Lymphnode"))

p_box <- ggboxplot(
  df_plot,
  x = "Var2",
  y = "pct",
  color = "Type",
  add = c("mean_se", "jitter"),
  palette = "Accent",
  ylab = "number of cell (%)"
) +
  stat_compare_means(aes(group = Type), label = "p.signif") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5),
    legend.position = "top"
  )

ggsave(plot = p_box, filename = "result/fig2_CAF/CAF_cluters_barplot.pdf", width = 6, height = 4)

p_bar <- ggbarplot(
  df_plot,
  x = "Var2",
  y = "pct",
  color = "Type",
  add.params = list(size = 1),
  palette = "Dark2",
  ylab = "% str cells in sample",
  add = c("mean_se", "jitter"),
  position = position_dodge(0.9)
) +
  stat_compare_means(aes(group = Type), label = "p.signif") +
  theme_classic() +
  scale_y_continuous(expand = c(0, 0)) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5),
    legend.position = "top"
  ) +
  coord_flip()

ggsave(plot = p_bar, filename = "result/fig2_CAF/CAF_barplot.pdf", width = 4, height = 6)


## =========================================================
## 9. Roe distribution analysis
## =========================================================
source("code/distribution_Roe.R")

metainfo <- sub_CAF@meta.data
metainfo <- dplyr::filter(metainfo, Tissue %in% c("Normal", "Tumor", "Lymphnode"))
metainfo$Tissue <- factor(metainfo$Tissue, levels = c("Normal", "Tumor", "Lymphnode"))
metainfo$subclusters <- factor(metainfo$subclusters, levels = caf_levels)

distribution_Roe(
  meta_data = metainfo,
  celltype_column = "subclusters",
  condition_column = "Tissue",
  add_label = "number",
  tile_color = "grey",
  tile_fill = "D"
)

celltype_color <- c(
  "C1_Fib_ACTA2" = "#b3d1e3",
  "C2_Fib_HSPA6" = "#7ec6da",
  "C3_Fib_PLA2G2A" = "#398caa",
  "C4_Fib_BNC2" = "#2a9948",
  "C5_Fib_CXCL8" = "#63b246",
  "C6_Fib_NFKB1" = "#9dca86",
  "C7_Fib_APOD" = "#eb986d",
  "C8_Fib_CCL19" = "#e13d28",
  "C9_Fib_COL12A1" = "#91656d",
  "C10_Fib_ABCA8" = "#cfb3cb",
  "C11_Fib_ENO1" = "#845796",
  "C12_Fib_CD74" = "#33A02C",
  "C13_Fib_LUM" = "#A98AC1",
  "C14_Fib_A2M" = "#b3d135"
)

distribution_Roe(
  meta_data = metainfo,
  celltype_column = "subclusters",
  celltype_level = names(celltype_color),
  condition_column = "Tissue",
  add_label = "sign",
  celltype_color = celltype_color,
  condition_level = c("Normal", "Tumor", "Lymphnode"),
  relative_width = 0.7,
  tile_color = NA
)

ggsave("result/fig2_CAF/subclusters_Poe.pdf", width = 13, height = 17, units = "cm")


## =========================================================
## 10. Ratio plot
## =========================================================
source("code/ratio.plot.R")

sub_CAF1 <- subset(sub_CAF, Tissue %in% c("Normal", "Tumor", "Lymphnode"))

## 10.1 Tissue 组成中的 CAF 亚群比例
id.vars1 <- "subclusters"
id.vars2 <- "Tissue"

a <- sort(table(sub_CAF1@meta.data[, id.vars2]), decreasing = TRUE)
cluster.number <- data.frame(Cluster = names(a), number = as.numeric(a))
cluster.number$Cluster <- factor(cluster.number$Cluster, c("Normal", "Tumor", "Lymphnode"))

patient.Cluster.ratio <- table(sub_CAF1@meta.data[, c(id.vars1, id.vars2)]) %>%
  as.data.frame()

cell.num <- tapply(patient.Cluster.ratio$Freq, patient.Cluster.ratio[, id.vars2], sum)
cell.num <- rep(cell.num, each = length(unique(sub_CAF1@meta.data[, id.vars1])))
patient.Cluster.ratio$ratio <- patient.Cluster.ratio$Freq / cell.num
patient.Cluster.ratio[, id.vars2] <- factor(patient.Cluster.ratio[, id.vars2], levels = cluster.number$Cluster)

colnames(patient.Cluster.ratio)[1:2] <- c("Type1", "Type2")
patient.Cluster.ratio$Type2 <- factor(patient.Cluster.ratio$Type2, levels = c("Normal", "Tumor", "Lymphnode"))

p_ratio1 <- ggplot(patient.Cluster.ratio, aes(x = Type2, y = ratio, fill = Type1)) +
  theme_bw() +
  geom_bar(stat = "identity", position = "fill", width = 0.5) +
  labs(x = "", y = "Ratio", fill = NULL) +
  scale_fill_manual(values = celltype_color) +
  scale_y_continuous(labels = c("0%", "25%", "50%", "75%", "100%")) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank(),
    legend.position = "right",
    legend.key.height = unit(0.6, "cm")
  )

ggsave("result/fig2_CAF/CAF_cluster_Poe_top.pdf", plot = p_ratio1, height = 5, width = 7)

ratio.plot(
  seurat.object = sub_CAF1,
  id.vars1 = "subclusters",
  color.len = celltype_color,
  id.vars2 = "Tissue"
)
dev.off()


## =========================================================
## 11. PROGENy pathway analysis
## =========================================================
sub_CAF <- qread("result/fig2_CAF/sub_caf.qs")

Idents(sub_CAF) <- sub_CAF$subclusters
CellsClusters <- data.frame(
  Cell = names(Idents(sub_CAF)),
  CellType = as.character(Idents(sub_CAF)),
  stringsAsFactors = FALSE
)

DimPlot(
  sub_CAF,
  group.by = "subclusters",
  reduction = "HarmonyUMAP2D",
  label = TRUE,
  pt.size = 0.5
) + NoLegend()

sub_CAF <- progeny(
  sub_CAF,
  scale = FALSE,
  organism = "Human",
  top = 500,
  perm = 1,
  return_assay = TRUE
)

sub_CAF <- Seurat::ScaleData(sub_CAF, assay = "progeny")

progeny_scores_df <- as.data.frame(
  t(GetAssayData(sub_CAF, slot = "scale.data", assay = "progeny"))
) %>%
  rownames_to_column("Cell") %>%
  gather(Pathway, Activity, -Cell)

progeny_scores_df <- inner_join(progeny_scores_df, CellsClusters)

summarized_progeny_scores <- progeny_scores_df %>%
  group_by(Pathway, CellType) %>%
  summarise(avg = mean(Activity), std = sd(Activity), .groups = "drop")

summarized_progeny_scores_df <- summarized_progeny_scores %>%
  dplyr::select(-std) %>%
  spread(Pathway, avg) %>%
  data.frame(row.names = 1, check.names = FALSE, stringsAsFactors = FALSE)

paletteLength <- 100
myColor <- colorRampPalette(c("Darkblue", "white", "red"))(paletteLength)

progenyBreaks <- c(
  seq(min(summarized_progeny_scores_df), 0, length.out = ceiling(paletteLength / 2) + 1),
  seq(max(summarized_progeny_scores_df) / paletteLength,
      max(summarized_progeny_scores_df),
      length.out = floor(paletteLength / 2))
)

pdf("result/fig2_CAF/progeny.pdf", width = 5, height = 5)
pheatmap(
  t(summarized_progeny_scores_df[caf_levels, ]),
  color = myColor,
  breaks = progenyBreaks,
  cluster_cols = TRUE,
  fontsize = 12,
  fontsize_row = 10
)
dev.off()



## =========================================================
## 12. Heatmap helper function
## =========================================================
standardize_fun <- function(indata = NULL, halfwidth = NULL, centerFlag = TRUE, scaleFlag = TRUE) {
  outdata <- t(scale(t(indata), center = centerFlag, scale = scaleFlag))
  if (!is.null(halfwidth)) {
    outdata[outdata > halfwidth] <- halfwidth
    outdata[outdata < (-halfwidth)] <- -halfwidth
  }
  return(outdata)
}


## =========================================================
## 13. Chemokine heatmap
## =========================================================
gene_chemokines <- read_csv("rawdata/gene_chemokines.csv")

subclusters_expr1 <- AverageExpression(
  sub_CAF,
  assays = "RNA",
  features = gene_chemokines$gene,
  group.by = "subclusters"
)

df1 <- as.data.frame(subclusters_expr1$RNA)
df1 <- standardize_fun(df1, halfwidth = 1)

hm1 <- Heatmap(
  t(df1),
  cluster_rows = FALSE,
  cluster_columns = TRUE,
  column_dend_height = unit(1.5, "cm"),
  clustering_distance_columns = "pearson",
  col = colorRamp2(
    c(seq(-1, 0.5, length.out = 9), 1),
    rev(brewer.pal(9, "RdBu"))[c(1:9, 9)]
  ),
  rect_gp = gpar(col = "white", lty = 1, lwd = 1),
  column_title = NULL,
  row_title = NULL,
  column_names_gp = gpar(fontsize = 8),
  row_names_gp = gpar(fontsize = 8),
  name = "scale"
)


## =========================================================
## 14. MHC heatmap
## =========================================================
gene_mhc <- read_csv("rawdata/gene_MHC.csv")

subclusters_expr2 <- AverageExpression(
  sub_CAF,
  assays = "RNA",
  features = gene_mhc$gene,
  group.by = "subclusters"
)

df2 <- as.data.frame(subclusters_expr2$RNA)
df2 <- standardize_fun(df2, halfwidth = 1)

hm2 <- Heatmap(
  t(df2),
  cluster_rows = FALSE,
  cluster_columns = FALSE,
  column_dend_height = unit(1.5, "cm"),
  clustering_distance_columns = "pearson",
  col = colorRamp2(
    c(seq(-1, 0.5, length.out = 9), 1),
    rev(brewer.pal(9, "RdBu"))[c(1:9, 9)]
  ),
  rect_gp = gpar(col = "white", lty = 1, lwd = 1),
  column_title = NULL,
  row_title = NULL,
  column_names_gp = gpar(fontsize = 8),
  row_names_gp = gpar(fontsize = 8),
  name = "scale"
)

pdf("result/fig2_CAF/CAF_chemokines.pdf", width = 10, height = 4)
draw(hm1 + hm2)
dev.off()