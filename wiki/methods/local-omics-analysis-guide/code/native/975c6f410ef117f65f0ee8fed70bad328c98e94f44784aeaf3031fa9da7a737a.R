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
