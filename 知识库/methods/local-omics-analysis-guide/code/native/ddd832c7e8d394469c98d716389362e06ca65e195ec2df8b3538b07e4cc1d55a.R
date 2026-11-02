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
