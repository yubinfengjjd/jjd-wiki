##加载R包
library(ggplot2)
library(patchwork)
library(scater)
library(harmony)
library(BayesSpace)
library(Seurat)
library(dplyr)
setwd("D:\\UC乳酸化单细胞开篇\\20.空间转录组")
untar("GSE189184_RAW.tar", exdir = "GSE189184_RAW")
fs = list.files('./GSE189184_RAW', '^GSM')
sample_dirs = list.dirs('./GSE189184_RAW/', full.names = TRUE, recursive = FALSE)
sample=gsub("(.*)_(.*)","\\2",fs)
sample_dirs=file.path(sample_dirs, sample)
names(sample_dirs) = list.files('./GSE189184_RAW/', recursive = FALSE)

library(Seurat)
library(dplyr)
read_spatial_sample <- function(sample_dirs) {
	# 1. 读取count矩阵
	count_dir <- file.path(sample_dirs, "raw_feature_bc_matrix")  # 如 A1/RA3A
	ct <- Read10X(count_dir)
	
	# 2. 读取空间信息（自动处理高低分辨率图像）
	spatial_dir <- file.path(sample_dirs, "spatial")
	
	# 检查是否存在低分辨率图像，若不存在则尝试创建符号链接
	lowres_img <- file.path(spatial_dir, "tissue_lowres_image.png")
	hires_img <- file.path(spatial_dir, "tissue_hires_image.png")
	
	# 修正此处：添加缺失的闭合括号 ')'
	if (!file.exists(lowres_img)) { 
		if (file.exists(hires_img)) {
			# 创建符号链接：将高分辨率图像链接为低分辨率（仅需一次）
			file.symlink(from = hires_img, to = lowres_img)
		} else {
			stop("No valid image found in ", spatial_dir)
		}
	}
	
	# 读取空间图像信息
	img <- Read10X_Image(image.dir = spatial_dir, filter.matrix = T)
	
	# 3. 创建Seurat对象
	sobj <- CreateSeuratObject(counts = ct, assay = "Spatial")
	cells_in_both <- intersect(Cells(sobj), rownames(img@coordinates))
	sobj <- subset(sobj, cells = cells_in_both)
	# 4. 关联空间图像
	img <- img[cells_in_both]
	DefaultAssay(img) <- "Spatial"
	sobj[[paste0("slice_", names(sample_dirs))]] <- img  # 切片名称唯一化
	
	return(sobj)
}


seurat_list <- lapply(sample_dirs, function(sample) {
	cat("Processing sample:", sample, "\n")
	read_spatial_sample(sample)
})

#####循环每个切片####
library(Seurat)
library(ggplot2)
library(patchwork)
library(data.table)
library(dplyr)
library(clustree)
library(SCpubr)
# 创建输出目录（如果不存在）
if (!dir.exists("single_sample_analysis")) {
	dir.create("single_sample_analysis")
}

# 单个样本分析函数
analyze_single_sample <- function(sobj, sample_id) {
	# 1. 基础质控
	sobj <- subset(sobj, subset = nCount_Spatial > 0 & nFeature_Spatial > 0)
	
	# 2. 数据标准化
	sobj <- SCTransform(sobj, assay = "Spatial", verbose = T)
	
	# 3. 降维和聚类
	sobj <- RunPCA(sobj, assay = "SCT", verbose = FALSE, npcs = 50)
	
	# 4. 聚类分析（去除了Harmony步骤）
	sobj <- RunUMAP(sobj, dims = 1:30)
	sobj <- FindNeighbors(sobj, dims = 1:30)
	
	# 多分辨率聚类
	resolutions <- c(0.05, 0.1, 0.2, 0.3, 0.5, 0.8, 1, 1.2)
	for (res in resolutions) {
		sobj <- FindClusters(sobj, resolution = res, algorithm = 1)
	}
	
	# 5. 可视化
	output_dir <- file.path("single_sample_analysis", sample_id)
	if (!dir.exists(output_dir)) dir.create(output_dir)
	
	# 聚类树
	pdf(file.path(output_dir, "clustree.pdf"), width = 12, height = 8)
	print(clustree(sobj@meta.data, prefix = "SCT_snn_res."))
	dev.off()
	
	return(sobj)
}

# 对每个样本进行分析
processed_samples <- lapply(names(sample_dirs), function(sample_id) {
	cat("\n====== Processing", sample_id, "======\n")
	sobj <- seurat_list[[sample_id]]
	analyze_single_sample(sobj, sample_id)
})

names(processed_samples) <- fs
#手动选择分辨率
# 定义每个样本选择的最佳分辨率
resolution_choices <- c(
	"GSM5695834_B8" = "SCT_snn_res.0.3",
	"GSM5695835_B9" = "SCT_snn_res.0.5"
)

# 设置可视化参数
my_theme <- theme(
	plot.title = element_text(size = 14, face = "bold"),
	legend.text = element_text(size = 10),
	legend.title = element_text(size = 12)
)

# 循环处理每个样本
for (sample_id in names(processed_samples)) {
	# 获取当前样本对象
	sobj <- processed_samples[[sample_id]]
	
	# 检查选择的分辨率是否存在
	if (!resolution_choices[sample_id] %in% colnames(sobj@meta.data)) {
		warning(paste("Resolution column not found in", sample_id, "Skipping..."))
		next
	}
	
	# 设置聚类标识
	sobj$seurat_clusters <- sobj[[resolution_choices[sample_id]]]
	Idents(sobj)=sobj$seurat_clusters
	# 创建输出目录
	output_dir <- file.path("single_sample_analysis", sample_id)
	if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
	
	# 生成UMAP图
	umap_plot <- DimPlot(sobj, 
											 reduction = "umap",
											 label = TRUE,
											 label.size = 4,
											 pt.size = 1.5) +
		ggtitle(paste(sample_id, "Clusters (", resolution_choices[sample_id], ")")) +
		my_theme
	
	# 保存图片
	ggsave(filename = file.path(output_dir, "final_clusters_umap.pdf"),
				 plot = umap_plot,
				 width = 8,
				 height = 6)
	
	# 保存更新后的对象
	saveRDS(sobj, file.path(output_dir, paste0(sample_id, "_final.rds")))
	
	# 更新对象到列表
	processed_samples[[sample_id]] <- sobj
}

# 保存完整处理结果
save(processed_samples, file = "processed_samples_final.RData")
#####自定义画图####
library(viridis)

mycolor <- c("#927A66","#DBAEA4","#97A4AB","#21A69A","#3A6688","#C98882","#C98896","#3A6666","#DB4567")

# 循环处理每个样本
for (sample_name in names(processed_samples)) {
	# 获取当前样本对象
	sobj <- processed_samples[[sample_name]]
	
	# 创建输出目录
	output_dir <- file.path("single_sample_analysis", sample_name)
	if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
	
	# 提取空间坐标（需根据实际数据结构调整）
	spatial_coord <- sobj@images[[1]]@coordinates[, c('col', 'row')]
	colnames(spatial_coord) <- c('s_1', 's_2')
	spatial_coord <- as.matrix(spatial_coord)
	
	# 创建临时空间降维对象
	sobj[["temp_spatial"]] <- CreateDimReducObject(
		embeddings = spatial_coord,
		assay = "SCT",
		key = "spatial_"
	)
	
	# 生成图形
	pdf(file.path(output_dir, paste0(sample_name, "_custom_spatial_plots.pdf")), 
			width = 18, height = 6)
	
	p1 <- FeaturePlot(sobj, "nCount_Spatial", 
										reduction = "temp_spatial", pt.size = 2) +
		scale_y_reverse() + 
		scale_color_viridis(option = "inferno") + 
		theme_void()
	
	p2 <- FeaturePlot(sobj, "nFeature_Spatial", 
										reduction = "temp_spatial", pt.size = 2) +
		scale_y_reverse() + 
		scale_color_viridis(option = "D") + 
		theme_void()
	
	p3 <- DimPlot(sobj, 
								reduction = "temp_spatial", 
								group.by = "seurat_clusters", # 确认使用的聚类列名
								cols = mycolor, 
								pt.size = 2, 
								label = TRUE,
								label.box = TRUE) +
		guides(color = guide_legend(override.aes = list(size = 6), ncol = 2)) +
		theme_void() + 
		scale_y_reverse()
	
	print(p1 + p2 + p3 + plot_layout(ncol = 3))
	dev.off()
}

#####根据病理切片划分区域####
celltype_map <- c(
	"0" = "Serosa",
	"1" = "Submucosa",
	"2" = "Muscularis propria",
	"3" = "Mucosa",
	"4" = "Lymphoid Nodule",
	"5" = "Serosa"
)

processed_samples$GSM5695834_B8$Structure <- factor(
	as.character(processed_samples$GSM5695834_B8$SCT_snn_res.0.3),  # 将聚类编号转换为字符
	levels = names(celltype_map),       # 自动获取聚类编号顺序
	labels = celltype_map               # 直接使用映射表
)

celltype_map <- c(
	"0" = "Submucosa",
	"1" = "Serosa",
	"2" = "Muscularis propria",
	"3" = "Muscularis propria",
	"4" = "Mucosa",
	"5" = "Serosa",
	"6" = "Lymphoid Nodule"
)

processed_samples$GSM5695835_B9$Structure <- factor(
	as.character(processed_samples$GSM5695835_B9$SCT_snn_res.0.5),  # 将聚类编号转换为字符
	levels = names(celltype_map),       # 自动获取聚类编号顺序
	labels = celltype_map               # 直接使用映射表
)

#####区域可视化####
# 加载必要包
library(Seurat)
library(ggplot2)
library(patchwork)
# -------------------------- 定义颜色方案 --------------------------
# 确保颜色与分层名称匹配
structure_colors <- c(
	"Serosa" = "#927A66",
	"Submucosa" = "#DBAEA4",
	"Muscularis propria" = "#97A4AB",
	"Mucosa" = "#21A69A",
	"Lymphoid Nodule" = "#3A6666"
)

# -------------------------- 可视化单个样本 --------------------------
# 样本1: GSM5695834_B8
p1 <- SpatialPlot(
	processed_samples$GSM5695834_B8,
	group.by = "Structure",          # 指定分层信息列
	cols = structure_colors,         # 自定义颜色
	pt.size.factor = 1.5,            # 点的大小（根据图像调整）
	alpha = c(0.8, 0.8),             # 透明度（避免重叠覆盖）
	image.alpha = 0.5            # 切片图像的透明度（若有背景HE图像）
) + 
	ggtitle("Sample GSM5695834_B8") +
	theme(plot.title = element_text(hjust = 0.5, face = "bold"))
ggsave("GSM5695834_structure.PDF", p1, width = 7, height = 6, dpi = 300)
# 样本2: GSM5695835_B9
p2 <- SpatialPlot(
	processed_samples$GSM5695835_B9,
	group.by = "Structure",
	cols = structure_colors,
	pt.size.factor = 1.5,
	alpha = c(0.8, 0.8),
	image.alpha = 0.5
) + 
	ggtitle("Sample GSM5695835_B9") +
	theme(plot.title = element_text(hjust = 0.5, face = "bold"))
ggsave("GSM5695835_structure.PDF", p2, width = 7, height = 6, dpi = 300)