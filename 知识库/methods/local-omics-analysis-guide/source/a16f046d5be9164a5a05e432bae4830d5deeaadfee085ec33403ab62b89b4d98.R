################################################################################
# Phase 2.1: 邻域生态位分析
# 目的: 计算每个spot的细胞类型邻域组成，识别UBE2L6相关微环境
################################################################################

library(Seurat)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)
library(viridis)

# 设置工作目录
setwd("D:/fyb/UC-20/20.空间转录组")

# 加载数据 (假设Phase 1已完成)
load("spatial_samples_list.Rdata")  # 基础样本列表
load("RCTD_list.Rdata")  # 包含细胞类型注释

# 获取细胞类型列名 (根据RCTD结果)
# 通常RCTD会添加多个细胞类型的权重列

# ==================== 邻域分析函数 ====================

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

# ==================== 运行邻域分析 ====================

for (sample_name in names(RCTD_list)) {
  cat("\n===== Neighborhood Analysis for", sample_name, "=====\n")
  
  # 获取样本
  sobj <- RCTD_list[[sample_name]]
  
  # 识别细胞类型列
  # RCTD结果通常包含多个细胞类型权重列
  cell_type_cols <- grep("^[A-Z]", colnames(sobj@meta.data), value = TRUE)
  # 过滤掉非细胞类型的列
  known_cell_types <- c("Epithelial", "Fibroblast", "Macrophage", "T cell", 
                        "B cell", "Endothelial", "Smooth muscle", "Plasma cell",
                        "Dendritic", "Mast", "NK")
  cell_type_cols <- cell_type_cols[sapply(cell_type_cols, function(x) {
    any(sapply(known_cell_types, function(ct) grepl(ct, x, ignore.case = TRUE)))
  })]
  if (length(cell_type_cols) > 0) {
    cell_type_cols <- cell_type_cols[sapply(sobj@meta.data[, cell_type_cols, drop = FALSE], is.numeric)]
  }
  
  if (length(cell_type_cols) == 0) {
    cat("No cell type columns found. Using first 10 metadata columns.\n")
    numeric_cols <- colnames(sobj@meta.data)[sapply(sobj@meta.data, is.numeric)]
    cell_type_cols <- head(numeric_cols, 10)
  }
  
  cat("Using cell type columns:\n")
  print(cell_type_cols)

  # 为包含空格/特殊字符的列创建安全别名，避免可视化报错
  safe_cols <- make.names(cell_type_cols)
  names(safe_cols) <- cell_type_cols
  for (ct in cell_type_cols) {
    sobj[[safe_cols[[ct]]]] <- as.numeric(sobj@meta.data[[ct]])
  }
  cell_type_cols <- unname(safe_cols)
  
  # 计算邻域组成
  nhood_comp <- compute_neighborhood(sobj, cell_type_cols, k = 6)
  
  # 将邻域组成添加到metadata
  for (ct in colnames(nhood_comp)) {
    sobj[[paste0("nhood_", ct)]] <- nhood_comp[, ct]
  }
  
  # 更新列表
  RCTD_list[[sample_name]] <- sobj
  
  # ==================== 可视化 ====================
  
  # 1. 邻域组成热图
  nhood_df <- as.data.frame(nhood_comp)
  nhood_df$spot <- rownames(nhood_df)
  
  # 使用pheatmap或ggplot2简化版
  # 随机采样避免太大
  set.seed(42)
  if (nrow(nhood_df) > 500) {
    idx <- sample(1:nrow(nhood_df), 500)
    nhood_df <- nhood_df[idx, ]
  }
  
  # 计算平均邻域组成
  avg_nhood <- colMeans(nhood_comp)
  
  p1 <- ggplot(data.frame(cell_type = names(avg_nhood), 
                          composition = avg_nhood),
               aes(x = reorder(cell_type, -composition), y = composition)) +
    geom_bar(stat = "identity", fill = "#4A90D9") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = paste("Average Neighborhood Composition -", sample_name),
         x = "Cell Type", y = "Mean Proportion")
  
  ggsave(paste0("Nhood_Composition_", sample_name, ".pdf"), 
         p1, width = 10, height = 6)
  
  # 2. 细胞类型空间分布 vs 邻域组成空间分布 对比
  # 选择主要细胞类型可视化
  main_ct <- names(sort(avg_nhood, decreasing = TRUE))
  main_ct <- main_ct[!is.na(main_ct) & nzchar(main_ct) & main_ct %in% colnames(sobj@meta.data)]
  main_ct <- head(main_ct, 4)
  
  pdf(paste0("Nhood_vs_Actual_", sample_name, ".pdf"), width = 12, height = 8)
  
  for (ct in main_ct) {
    if (is.na(ct) || !ct %in% colnames(sobj@meta.data)) next
    # 实际细胞类型组成
    p_actual <- SpatialFeaturePlot(sobj, features = ct, pt.size.factor = 1.5) +
      scale_fill_viridis(option = "B") +
      ggtitle(paste(ct, "(Actual)")) +
      theme(plot.title = element_text(size = 10, face = "bold"))
    
    # 邻域细胞类型组成
    nhood_ct <- paste0("nhood_", ct)
    if (nhood_ct %in% colnames(sobj@meta.data)) {
      p_nhood <- SpatialFeaturePlot(sobj, features = nhood_ct, pt.size.factor = 1.5) +
        scale_fill_viridis(option = "B") +
        ggtitle(paste(ct, "(Neighborhood)")) +
        theme(plot.title = element_text(size = 10, face = "bold"))
      
      print(p_actual | p_nhood)
    }
  }
  
  dev.off()
  
  # 3. UBE2L6邻域分析
  if ("UBE2L6" %in% rownames(sobj)) {
    # 获取UBE2L6表达
    assay_name <- if ("Spatial" %in% Assays(sobj)) "Spatial" else DefaultAssay(sobj)
    expr_mat <- suppressWarnings(GetAssayData(sobj, assay = assay_name, layer = "data"))
    if (nrow(expr_mat) == 0 || ncol(expr_mat) == 0) {
      expr_mat <- suppressWarnings(GetAssayData(sobj, assay = assay_name, layer = "counts"))
      expr_mat <- log1p(expr_mat)
    }
    if (!"UBE2L6" %in% rownames(expr_mat)) next
    ube2l6_expr <- as.numeric(expr_mat["UBE2L6", ])
    names(ube2l6_expr) <- colnames(expr_mat)
    
    # 按UBE2L6表达分组
    ube2l6_quantiles <- quantile(ube2l6_expr, c(0.25, 0.5, 0.75))
    ube2l6_group <- ifelse(ube2l6_expr < ube2l6_quantiles[1], "Low",
                            ifelse(ube2l6_expr > ube2l6_quantiles[3], "High", "Medium"))
    names(ube2l6_group) <- names(ube2l6_expr)
    
    # 添加到metadata
    sobj$UBE2L6_group <- ube2l6_group
    
    # 计算各组的平均邻域组成
    nhood_with_group <- as.data.frame(nhood_comp)
    nhood_with_group$UBE2L6_group <- ube2l6_group[rownames(nhood_comp)]
    
    nhood_by_group <- nhood_with_group %>%
      group_by(UBE2L6_group) %>%
      summarise(across(everything(), mean), .groups = "drop")
    
    # 保存结果
    write.csv(nhood_by_group, 
              file = paste0("Nhood_by_UBE2L6_Group_", sample_name, ".csv"))
    
    # 可视化
    nhood_long <- nhood_by_group %>%
      pivot_longer(cols = -UBE2L6_group, 
                   names_to = "Cell_Type", 
                   values_to = "Mean_Proportion")
    
    p2 <- ggplot(nhood_long, 
                 aes(x = Cell_Type, y = Mean_Proportion, fill = UBE2L6_group)) +
      geom_bar(stat = "identity", position = "dodge") +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(title = paste("Neighborhood Composition by UBE2L6 Expression -", sample_name),
           x = "Cell Type", y = "Mean Proportion", fill = "UBE2L6 Group")
    
    ggsave(paste0("Nhood_UBE2L6_", sample_name, ".pdf"), p2, width = 10, height = 6)
    
    # 更新列表
    RCTD_list[[sample_name]] <- sobj
  }
}

# 保存结果
save(RCTD_list, file = "RCTD_list_with_nhood.Rdata")

cat("\n邻域生态位分析完成！\n")
cat("输出文件:\n")
cat("- Nhood_Composition_*.pdf\n")
cat("- Nhood_vs_Actual_*.pdf\n")
cat("- Nhood_UBE2L6_*.pdf\n")
cat("- Nhood_by_UBE2L6_Group_*.csv\n")
