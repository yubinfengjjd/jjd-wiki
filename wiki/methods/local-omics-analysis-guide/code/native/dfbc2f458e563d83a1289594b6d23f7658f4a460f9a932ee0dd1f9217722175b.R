compute_neighborhood <- function(sobj, cell_type_cols, k = 6) {
  # 获取空间坐标
  coords <- GetTissueCoordinates(sobj)
  coords <- as.data.frame(coords)
  
  # 计算距离矩阵
  dist_mat <- as.matrix(dist(coords))
  
  # 获取细胞类型比例矩阵
  cell_composition <- sobj@meta.data[, cell_type_cols, drop = FALSE]
  
  # 计算每个spot的邻域组成
  n_spots <- nrow(coords)
  n_cell_types <- length(cell_type_cols)
  
  neighborhood_composition <- matrix(0, nrow = n_spots, ncol = n_cell_types)
  colnames(neighborhood_composition) <- cell_type_cols
  rownames(neighborhood_composition) <- rownames(coords)
  
  for (i in 1:n_spots) {
    # 找到k个最近邻
    neighbors <- order(dist_mat[i, ])[2:(k+1)]
    
    # 邻域组成 = 邻居的平均细胞类型比例
    neighborhood_composition[i, ] <- colMeans(cell_composition[neighbors, , drop = FALSE])
  }
  
  return(neighborhood_composition)
}
