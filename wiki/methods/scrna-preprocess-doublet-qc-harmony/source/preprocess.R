library(Seurat)
library(stringr)
library(dplyr)
library(ggplot2)
library(patchwork)
library(RColorBrewer)
library(cowplot)

# ============================================================
# GSE251716 - 青光眼单细胞数据预处理
# 数据来源: GEO GSE251716
# 两个样本: GSM7986396, GSM7986397 (LXB4)
# ============================================================

# #####处理读入原始文件####

# 清理旧结果，确保每次运行一致
unlink("./GSE251716_RAW", recursive = TRUE)

untar("GSE251716_RAW.tar", exdir = "GSE251716_RAW")

# 只匹配 .gz 文件，避免子目录干扰
fs <- list.files('./GSE251716_RAW', '^GSM.*\\.gz$')

# 从 barcodes 文件名提取样本标识
samples <- fs[grepl("barcodes", fs)]
# 文件名格式: GSM7986396_barcodes.tsv.gz / GSM7986397_barcodes_LXB4.tsv.gz
# 取 _ 分割后第一段即为 GSM ID
samples <- str_split(samples, "_", simplify = TRUE)[, 1]

# 把每个样本的三个文件放在以样本名字命名的文件夹中
lapply(samples, function(x) {
  y <- fs[grepl(x, fs)]
  dir <- paste0("./GSE251716_RAW/", x)
  dir.create(dir)
  # 按名称排序后: barcodes < features < matrix
  file.rename(paste0("./GSE251716_RAW/", y[1]), file.path(dir, "barcodes.tsv.gz"))
  file.rename(paste0("./GSE251716_RAW/", y[2]), file.path(dir, "features.tsv.gz"))
  file.rename(paste0("./GSE251716_RAW/", y[3]), file.path(dir, "matrix.mtx.gz"))
})

# 创建 Seurat 对象列表
sample_dirs <- list.dirs('./GSE251716_RAW/', full.names = TRUE, recursive = FALSE)
names(sample_dirs) <- list.files('./GSE251716_RAW/', recursive = FALSE)

sceList <- lapply(sample_dirs, function(dir) {
  counts <- Read10X(dir)
  CreateSeuratObject(
    counts = counts,
    min.cells = 5,
    min.features = 300,
    project = basename(dir)
  )
})

do.call(rbind, lapply(sceList, dim))

# ============================================================
# 去除双细胞 (DoubletFinder, 每样本独立运行)
# ============================================================

library(DoubletFinder)

sceList <- lapply(sceList, function(obj) {
  cat(sprintf("\n[DoubletFinder] 处理 %s ...\n", obj$orig.ident[1]))

  # 常规预处理
  obj <- obj %>%
    NormalizeData(verbose = FALSE) %>%
    FindVariableFeatures(selection.method = "vst", nfeatures = 2000, verbose = FALSE) %>%
    ScaleData(verbose = FALSE) %>%
    RunPCA(verbose = FALSE) %>%
    FindNeighbors(dims = 1:10) %>%
    FindClusters(resolution = 0.5, verbose = FALSE) %>%
    RunUMAP(dims = 1:10, verbose = FALSE)

  # 参数扫描 → 最优 pK
  sweep_res <- paramSweep(obj, PCs = 1:10, sct = FALSE)
  sweep_stats <- summarizeSweep(sweep_res, GT = FALSE)
  bcmvn <- find.pK(sweep_stats)
  optimal_pk <- as.numeric(as.character(bcmvn$pK[which.max(bcmvn$BCmetric)]))

  # 同型双细胞比例估算
  annotations <- obj@meta.data$seurat_clusters
  homotypic_prop <- modelHomotypic(annotations)
  nExp_poi <- round(0.075 * ncol(obj))           # 7.5% 预期双细胞率
  nExp_poi_adj <- round(nExp_poi * (1 - homotypic_prop))

  # 分类双细胞
  obj <- doubletFinder(
    obj,
    PCs = 1:10,
    pN = 0.25,
    pK = optimal_pk,
    nExp = nExp_poi_adj,
    reuse.pANN = FALSE,
    sct = FALSE
  )

  # 取最后一列作为 DoubletFinder 分类结果
  df_col <- grep("^DF\\.classifications", colnames(obj@meta.data), value = TRUE)[1]
  obj$doublet <- obj@meta.data[[df_col]]

  cat(sprintf("  Doublet: %d / %d (%.1f%%)\n",
              sum(obj$doublet == "Doublet"), ncol(obj),
              100 * mean(obj$doublet == "Doublet")))

  # 清除仅用于 DoubletFinder 的中间图层，保留 counts
  obj@assays$RNA$data     <- NULL
  obj@assays$RNA$scale.data <- NULL
  obj@commands            <- list()
  obj@reductions          <- list()

  # 过滤双细胞
  obj <- subset(obj, subset = doublet == "Singlet")

  obj
})

do.call(rbind, lapply(sceList, dim))

# 合并样本
sce.all <- merge(
  x = sceList[[1]],
  y = sceList[-1],
  add.cell.ids = samples
)

# 查看 merged 对象的 layers 结构（Seurat v5 每个样本一个 layer）
names(sce.all@assays$RNA@layers)
sce.all[["RNA"]]$counts
LayerData(sce.all, assay = "RNA", layer = "counts")

# Seurat v5: 合并 layers
GLC <- JoinLayers(sce.all)
dim(GLC[["RNA"]]$counts)

# ============================================================
# QC 与过滤
# ============================================================

# 创建样本分组映射表（请根据实际实验设计修改分组）
# GSM7986396 → Control, GSM7986397 → Glaucoma (LXB4)
GLC$phenotype <- ifelse(
  str_detect(GLC$orig.ident, "GSM7986396"),
  "Control",
  "Glaucoma"
)

# 计算质控指标（小鼠数据: 线粒体 mt- 小写，核糖体 RP[SL]，血红蛋白 HB[^(P)]）
GLC[["percent.mt"]] <- PercentageFeatureSet(GLC, pattern = "^mt-")
GLC[["percent.rp"]] <- PercentageFeatureSet(GLC, pattern = "^Rp[sl]")
GLC[["percent.hb"]] <- PercentageFeatureSet(GLC, pattern = "^Hb[^(p)]")

# 先查看 QC 指标分布，再确定过滤阈值
cat("\n=== QC 指标分布 ===\n")
cat("nFeature_RNA:\n")
print(summary(GLC$nFeature_RNA))
cat("nCount_RNA:\n")
print(summary(GLC$nCount_RNA))
cat("percent.mt:\n")
print(summary(GLC$percent.mt))
cat("percent.rp:\n")
print(summary(GLC$percent.rp))
cat("percent.hb:\n")
print(summary(GLC$percent.hb))

# 基于 MAD 的自适应过滤，同时处理全零指标
feat_upper <- median(GLC$nFeature_RNA) + 3 * mad(GLC$nFeature_RNA)
feat_lower <- median(GLC$nFeature_RNA) - 3 * mad(GLC$nFeature_RNA)
feat_lower <- max(feat_lower, 200)

cat(sprintf("\n过滤阈值: nFeature=[%.0f, %.0f]\n", feat_lower, feat_upper))

# 构建过滤条件
cells_keep <- rep(TRUE, ncol(GLC))
cells_keep <- cells_keep & (GLC$nFeature_RNA >= feat_lower & GLC$nFeature_RNA <= feat_upper)

# 仅在全零或 MAD=0 时跳过对应过滤
if (max(GLC$percent.mt) > 0) {
  mt_mad <- mad(GLC$percent.mt)
  if (mt_mad > 0) {
    mt_upper <- median(GLC$percent.mt) + 3 * mt_mad
    cat(sprintf("percent.mt <= %.2f\n", mt_upper))
    cells_keep <- cells_keep & (GLC$percent.mt <= mt_upper)
  } else {
    cat("percent.mt 的 MAD=0，跳过该过滤\n")
  }
} else {
  cat("percent.mt 全为零，跳过该过滤\n")
}

if (max(GLC$percent.hb) > 0) {
  hb_mad <- mad(GLC$percent.hb)
  if (hb_mad > 0) {
    hb_upper <- median(GLC$percent.hb) + 3 * hb_mad
    cat(sprintf("percent.hb <= %.4f\n", hb_upper))
    cells_keep <- cells_keep & (GLC$percent.hb <= hb_upper)
  } else {
    cat("percent.hb 的 MAD=0，跳过该过滤\n")
  }
} else {
  cat("percent.hb 全为零，跳过该过滤\n")
}

GLC <- subset(GLC, cells = colnames(GLC)[cells_keep])

cat(sprintf("过滤后: %d cells, %d genes\n", ncol(GLC), nrow(GLC)))

# ============================================================
# 可视化: 小提琴图
# ============================================================

# 定义颜色方案（2 个样本）
glc_colors <- c("#71ad96", "#5d5c84")

vln_plots <- VlnPlot(GLC,
  features = c("nFeature_RNA", "nCount_RNA", "percent.mt"),
  ncol = 3,
  pt.size = 0,
  group.by = "orig.ident",
  cols = glc_colors,
  combine = FALSE
)

vln_plots <- lapply(vln_plots, function(p) {
  p +
    theme_classic(base_size = 14, base_family = "Arial") +
    theme(
      axis.text.x = element_text(size = 12, angle = 30, hjust = 1),
      axis.text.y = element_text(size = 12),
      axis.title.x = element_text(size = 14),
      axis.title.y = element_text(size = 14),
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "none",
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.margin = margin(10, 10, 10, 10)
    ) +
    scale_fill_manual(values = glc_colors)
})

combined_plot <- cowplot::plot_grid(plotlist = vln_plots, ncol = 3)
ggsave("VlnPlot.pdf", plot = combined_plot, width = 10, height = 4,
       device = cairo_pdf, dpi = 300)

# ============================================================
# 标准化与高变基因
# ============================================================

DefaultAssay(GLC) <- "RNA"
GLC <- GLC %>%
  NormalizeData(verbose = FALSE) %>%
  FindVariableFeatures(selection.method = "vst", nfeatures = 2000, verbose = FALSE)

top10 <- head(x = VariableFeatures(object = GLC), 10)

# 高变基因图
var_feature_colors <- c("#f6ae2d", "#92c1db")
highlight_color <- "black"

cairo_pdf(file = "featureVar.pdf", width = 10, height = 6, family = "Arial")

plot1 <- VariableFeaturePlot(object = GLC,
  cols = var_feature_colors,
  pt.size = 1.5
) +
  theme_classic(base_size = 14, base_family = "Arial") +
  theme(
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12)
  )

plot2 <- LabelPoints(plot = plot1,
  points = top10,
  repel = TRUE,
  color = highlight_color,
  size = 5
)

CombinePlots(plots = list(plot1, plot2))
dev.off()

# ============================================================
# PCA 降维 + Harmony 去批次
# ============================================================

library(harmony)

GLC <- GLC %>%
  ScaleData(verbose = FALSE, features = VariableFeatures(GLC)) %>%
  RunPCA(npcs = 50, verbose = FALSE, features = VariableFeatures(GLC))

# Harmony 校正样本间批次效应
GLC <- RunHarmony(GLC, group.by.vars = "orig.ident")

# PCA vs Harmony 对比图
p_before <- DimPlot(GLC, reduction = "pca", group.by = "orig.ident", cols = glc_colors) +
  theme_classic(base_size = 14, base_family = "Arial") +
  theme(
    axis.text = element_text(size = 11),
    axis.title = element_text(size = 13),
    plot.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12),
    legend.position = "right"
  ) +
  ggtitle("Before Harmony (PCA)")

p_after <- DimPlot(GLC, reduction = "harmony", group.by = "orig.ident", cols = glc_colors) +
  theme_classic(base_size = 14, base_family = "Arial") +
  theme(
    axis.text = element_text(size = 11),
    axis.title = element_text(size = 13),
    plot.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12),
    legend.position = "right"
  ) +
  ggtitle("After Harmony")

cairo_pdf(file = "harmony.pdf", width = 16, height = 7, family = "Arial")
wrap_plots(p_before, p_after, ncol = 2)
dev.off()

# ============================================================
# UMAP 降维 + 多分辨率聚类
# ============================================================

GLC <- FindNeighbors(GLC, reduction = "harmony", dims = 1:30)
GLC <- RunUMAP(GLC, reduction = "harmony", dims = 1:30)

resolutions <- c(0.05, 0.1, 0.2, 0.3, 0.5, 0.8, 1, 1.2)
for (res in resolutions) {
  cat(sprintf("聚类 resolution = %.2f\n", res))
  GLC <- FindClusters(GLC, graph.name = "RNA_snn", resolution = res, algorithm = 1)
}

# UMAP 多分辨率总览
cluster_umap <- wrap_plots(ncol = 4,
  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.0.05", label = TRUE) +
    NoAxes() + ggtitle("res = 0.05") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none"),

  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.0.1", label = TRUE) +
    NoAxes() + ggtitle("res = 0.1") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none"),

  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.0.2", label = TRUE) +
    NoAxes() + ggtitle("res = 0.2") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none"),

  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.0.3", label = TRUE) +
    NoAxes() + ggtitle("res = 0.3") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none"),

  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.0.5", label = TRUE) +
    NoAxes() + ggtitle("res = 0.5") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none"),

  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.0.8", label = TRUE) +
    NoAxes() + ggtitle("res = 0.8") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none"),

  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.1", label = TRUE) +
    NoAxes() + ggtitle("res = 1") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none"),

  DimPlot(GLC, reduction = "umap", group.by = "RNA_snn_res.1.2", label = TRUE) +
    NoAxes() + ggtitle("res = 1.2") +
    theme_classic(base_family = "Arial") +
    theme(plot.title = element_text(size = 11, face = "bold", family = "Arial"),
          legend.position = "none")
)

ggsave("cluster_umap.pdf", plot = cluster_umap,
       width = 20, height = 16, device = cairo_pdf)

# ============================================================
# 聚类树：选择合适分辨率
# ============================================================

library(clustree)

p1 <- clustree(GLC@meta.data, prefix = "RNA_snn_res.")

ggsave("聚类树.pdf", plot = p1, width = 12, height = 8)

# ============================================================
# CNS 风格 UMAP 图
# ============================================================

library(ggunchull)
library(grid)

# 使用最粗分辨率
GLC$plot_group <- GLC$RNA_snn_res.0.05

# 提取 UMAP 坐标（Seurat v5 语法）
plotData <- as.data.frame(Embeddings(GLC, "umap"))
colnames(plotData) <- c("umap_1", "umap_2")
plotData$cluster <- factor(GLC$plot_group)

# 17 种自定义离散配色
umap_palette <- c(
  "#E64B35",   # 红
  "#4DBBD5",   # 青
  "#00A087",   # 绿
  "#3C5488",   # 蓝
  "#F39B7F",   # 橙
  "#8491B4",   # 灰紫
  "#91D1C2",   # 薄荷
  "#DC0000",   # 深红
  "#7E6148",   # 棕
  "#B09C85",   # 浅棕
  "#E18727",   # 橘
  "#20854E",   # 深绿
  "#7876B1",   # 紫
  "#6F99AD",   # 灰蓝
  "#FFDC91",   # 浅黄
  "#EE4C97",   # 粉
  "#A6CEE3"    # 浅蓝
)
n_levels <- nlevels(plotData$cluster)
mycols <- setNames(umap_palette[seq_len(n_levels)], levels(plotData$cluster))

# 簇中心标签坐标
centroids <- aggregate(cbind(umap_1, umap_2) ~ cluster, data = plotData, FUN = median)

# 坐标范围（紧凑留白）
x_range <- range(plotData$umap_1, na.rm = TRUE)
y_range <- range(plotData$umap_2, na.rm = TRUE)
x_min <- x_range[1]; x_max <- x_range[2]
y_min <- y_range[1]; y_max <- y_range[2]
x_span <- x_max - x_min; y_span <- y_max - y_min
x_pad <- x_span * 0.04; y_pad <- y_span * 0.04
x_lim <- c(x_min - x_pad, x_max + x_pad)
y_lim <- c(y_min - y_pad, y_max + y_pad)

# 短坐标轴
x_axis_len <- x_span * 0.12
y_axis_len <- y_span * 0.12
x_axis_start <- x_lim[1] + x_pad
y_axis_start <- y_lim[1] + y_pad

# 绘制 UMAP
p <- ggplot(plotData, aes(x = umap_1, y = umap_2, color = cluster, fill = cluster)) +
  stat_unchull(alpha = 0.22, size = 0.35, delta = 0.45, linetype = "dashed") +
  geom_point(size = 0.9, alpha = 0.85, stroke = 0) +
  # 簇标签
  geom_text(data = centroids,
            aes(x = umap_1, y = umap_2, label = cluster),
            color = "grey20", size = 4.5, fontface = "bold",
            family = "Arial", inherit.aes = FALSE) +
  scale_color_manual(values = mycols, name = NULL) +
  scale_fill_manual(values = mycols, name = NULL) +
  coord_fixed(xlim = x_lim, ylim = y_lim, clip = "off") +
  labs(x = NULL, y = NULL) +
  theme_classic(base_size = 12, base_family = "Arial") +
  theme(
    aspect.ratio       = 1,
    panel.background   = element_blank(),
    panel.grid         = element_blank(),
    axis.line          = element_blank(),
    axis.ticks         = element_blank(),
    axis.text          = element_blank(),
    axis.title         = element_blank(),
    legend.position    = "right",
    legend.title       = element_blank(),
    legend.text        = element_text(size = 9, family = "Arial"),
    legend.key.size    = unit(0.35, "cm"),
    legend.background  = element_blank(),
    legend.key         = element_blank(),
    plot.margin        = margin(5, 5, 5, 5)
  ) +
  # 左下角短箭头坐标轴
  annotate("segment",
    x = x_axis_start, xend = x_axis_start + x_axis_len,
    y = y_axis_start, yend = y_axis_start,
    linewidth = 0.45, color = "black",
    arrow = arrow(length = unit(0.12, "cm"), type = "closed")
  ) +
  annotate("segment",
    x = x_axis_start, xend = x_axis_start,
    y = y_axis_start, yend = y_axis_start + y_axis_len,
    linewidth = 0.45, color = "black",
    arrow = arrow(length = unit(0.12, "cm"), type = "closed")
  ) +
  annotate("text",
    x = x_axis_start + x_axis_len * 0.55,
    y = y_axis_start - y_span * 0.025,
    label = "UMAP_1", size = 3.5, fontface = "italic", family = "Arial"
  ) +
  annotate("text",
    x = x_axis_start - x_span * 0.025,
    y = y_axis_start + y_axis_len * 0.55,
    label = "UMAP_2", size = 3.5, fontface = "italic", family = "Arial", angle = 90
  ) +
  guides(
    color = guide_legend(override.aes = list(size = 2.5, alpha = 1)),
    fill  = guide_legend(override.aes = list(alpha = 0.25))
  )

ggsave("UMAP.pdf", plot = p, width = 7.5, height = 6.5, device = cairo_pdf)
cat("\nUMAP 图已保存至: UMAP.pdf\n")

# ============================================================
# 保存
# ============================================================

save(GLC, file = "GSE251716_seurat.Rdata")
cat("\n已保存至: GSE251716_seurat.Rdata\n")
