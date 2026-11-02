compute_spatial_lr <- function(sobj, lr_pairs, k = 6) {
  # 获取表达矩阵
  if ("SCT" %in% Assays(sobj)) {
    expr_matrix <- suppressWarnings(GetAssayData(sobj, assay = "SCT", layer = "data"))
  } else {
    expr_matrix <- suppressWarnings(GetAssayData(sobj, assay = "Spatial", layer = "data"))
  }
  if (nrow(expr_matrix) == 0 || ncol(expr_matrix) == 0) {
    assay_name <- if ("Spatial" %in% Assays(sobj)) "Spatial" else DefaultAssay(sobj)
    expr_matrix <- suppressWarnings(GetAssayData(sobj, assay = assay_name, layer = "counts"))
    expr_matrix <- log1p(expr_matrix)
  }
  
  # 获取细胞类型组成
  cell_type_cols <- grep("^[A-Z]", colnames(sobj@meta.data), value = TRUE)
  known_cell_types <- c("Epithelial", "Fibroblast", "Macrophage", "T cell", 
                        "B cell", "Endothelial", "Smooth muscle", "Plasma cell",
                        "Dendritic", "Mast", "NK")
  cell_cols <- cell_type_cols[sapply(cell_type_cols, function(x) {
    any(sapply(known_cell_types, function(ct) grepl(ct, x, ignore.case = TRUE)))
  })]
  
  # 获取空间坐标和距离矩阵
  coords <- GetTissueCoordinates(sobj)
  coords <- coords[colnames(expr_matrix), , drop = FALSE]
  dist_mat <- as.matrix(dist(coords))
  
  # 计算每对LR的空间互作分数
  lr_scores <- list()
  
  for (lr_name in names(lr_pairs)) {
    ligand <- lr_pairs[[lr_name]]$ligand
    receptor <- lr_pairs[[lr_name]]$receptor
    
    # 检查基因是否在数据中
    if (!ligand %in% rownames(expr_matrix) || !receptor %in% rownames(expr_matrix)) {
      next
    }
    
    # 获取配体和受体表达
    ligand_expr <- expr_matrix[ligand, ]
    receptor_expr <- expr_matrix[receptor, ]
    
    # 计算空间LR分数
    # 对于每个spot，计算配体在邻近spot的表达 * 受体在当前spot的表达
    n_spots <- ncol(expr_matrix)
    lr_score <- numeric(n_spots)
    
    for (i in 1:n_spots) {
      # 找到k个最近邻
      neighbors <- order(dist_mat[i, ])[2:(k+1)]
      
      # LR分数 = 平均配体表达 * 当前spot受体表达
      lr_score[i] <- mean(ligand_expr[neighbors]) * receptor_expr[i]
    }
    
    lr_scores[[lr_name]] <- lr_score
    sobj[[lr_name]] <- lr_score
  }
  
  return(sobj)
}
