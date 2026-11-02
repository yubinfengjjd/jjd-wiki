################################################################################
# Phase 2.2: 空间配体-受体分析
# 目的: 识别空间临近细胞间的配体-受体互作
# 方法: 使用CellPhoneDB v5或自定义方法
################################################################################

library(Seurat)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)
library(viridis)

# 设置工作目录
setwd("D:/fyb/UC-20/20.空间转录组")

# 加载数据
load("RCTD_list.Rdata")

# ==================== 方法1: 使用R实现简化版LR分析 ====================

# 定义重要的配体-受体对 (基于炎症和UBE2L6相关)
# 这些是肠炎研究中常见的互作对

lr_pairs <- list(
  # 炎症相关
  "IL6-IL6R" = list(ligand = "IL6", receptor = "IL6R"),
  "IL1B-IL1R1" = list(ligand = "IL1B", receptor = "IL1R1"),
  "TNF-TNFR1" = list(ligand = "TNF", receptor = "TNFR1"),
  "TNF-TNFR2" = list(ligand = "TNF", receptor = "TNFR2"),
  "IL10-IL10RA" = list(ligand = "IL10", receptor = "IL10RA"),
  "IL10-IL10RB" = list(ligand = "IL10", receptor = "IL10RB"),
  "IFNG-IFNGR1" = list(ligand = "IFNG", receptor = "IFNGR1"),
  "CXCL8-CXCR1" = list(ligand = "CXCL8", receptor = "CXCR1"),
  "CXCL8-CXCR2" = list(ligand = "CXCL8", receptor = "CXCR2"),
  "CXCL12-CXCR4" = list(ligand = "CXCL12", receptor = "CXCR4"),
  "CXCL12-CXCR7" = list(ligand = "CXCL12", receptor = "CXCR7"),
  "CCL2-CCR2" = list(ligand = "CCL2", receptor = "CCR2"),
  "CCL2-CCR4" = list(ligand = "CCL2", receptor = "CCR4"),
  "CCL5-CCR5" = list(ligand = "CCL5", receptor = "CCR5"),
  # 泛素化相关 (UBE2L6可能相关的)
  "UBE2L6-TNF" = list(ligand = "UBE2L6", receptor = "TNF"),  # 假设
  # 上皮-免疫互作
  "FLG-TLR2" = list(ligand = "FLG", receptor = "TLR2"),
  "FLG-TLR4" = list(ligand = "FLG", receptor = "TLR4"),
  "MUC1-TLR2" = list(ligand = "MUC1", receptor = "TLR2"),
  "MUC1-TLR4" = list(ligand = "MUC1", receptor = "TLR4"),
  # 生长因子
  "EGF-EGFR" = list(ligand = "EGF", receptor = "EGFR"),
  "HGF-MET" = list(ligand = "HGF", receptor = "MET"),
  "FGF2-FGFR1" = list(ligand = "FGF2", receptor = "FGFR1"),
  "FGF2-FGFR2" = list(ligand = "FGF2", receptor = "FGFR2"),
  # 趋化因子受体
  "CXCL9-CXCR3" = list(ligand = "CXCL9", receptor = "CXCR3"),
  "CXCL10-CXCR3" = list(ligand = "CXCL10", receptor = "CXCR3"),
  "CXCL11-CXCR3" = list(ligand = "CXCL11", receptor = "CXCR3")
)

# ==================== 计算空间LR分数 ====================

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

# ==================== 运行LR分析 ====================

for (sample_name in names(RCTD_list)) {
  cat("\n===== Running LR Analysis for", sample_name, "=====\n")
  
  sobj <- RCTD_list[[sample_name]]
  
  # 计算空间LR分数
  sobj <- compute_spatial_lr(sobj, lr_pairs, k = 6)
  
  # 更新列表
  RCTD_list[[sample_name]] <- sobj
  
  # ==================== 可视化 ====================
  
  # 获取计算得到的LR分数列
  lr_cols <- names(lr_pairs)
  lr_cols <- lr_cols[lr_cols %in% colnames(sobj@meta.data)]
  
  if (length(lr_cols) == 0) {
    cat("No LR pairs found in data.\n")
    next
  }
  
  # 1. LR分数热图 (按细胞类型区域)
  # 获取Structure注释
  if ("Structure" %in% colnames(sobj@meta.data)) {
    # 计算各Structure的平均LR分数
    lr_df <- sobj@meta.data[, c("Structure", lr_cols), drop = FALSE]
    lr_by_structure <- lr_df %>%
      group_by(Structure) %>%
      summarise(across(everything(), mean), .groups = "drop")
    
    # 转换为矩阵格式
    lr_matrix <- as.matrix(lr_by_structure[, -1])
    rownames(lr_matrix) <- lr_by_structure$Structure
    
    # 绘制热图
    p1 <- ggplot(lr_by_structure %>% pivot_longer(cols = -Structure,
                                                    names_to = "LR_Pair",
                                                    values_to = "Score"),
                 aes(x = LR_Pair, y = Structure, fill = Score)) +
      geom_tile() +
      scale_fill_gradientn(colours = c("white", "yellow", "red")) +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
            axis.text.y = element_text(size = 10)) +
      labs(title = paste("LR Scores by Structure -", sample_name),
           x = "Ligand-Receptor Pair", y = "Structure", fill = "LR Score")
    
    ggsave(paste0("LR_by_Structure_", sample_name, ".pdf"), 
           p1, width = 14, height = 6)
  }
  
  # 2. 关键LR对的空间分布
  # 选择top 6个变化的LR对
  lr_var <- sapply(lr_cols, function(x) var(sobj@meta.data[[x]]))
  top_lr <- names(sort(lr_var, decreasing = TRUE))[1:min(6, length(lr_cols))]
  
  pdf(paste0("LR_Spatial_", sample_name, ".pdf"), width = 12, height = 10)
  
  for (lr in top_lr) {
    p_lr <- SpatialFeaturePlot(sobj, features = lr, pt.size.factor = 1.5) +
      scale_fill_viridis(option = "B") +
      ggtitle(lr) +
      theme(plot.title = element_text(size = 10, face = "bold"))
    
    print(p_lr)
  }
  
  dev.off()
  
  # 3. UBE2L6相关LR分析
  # 找到UBE2L6高表达区域的LR模式
  if ("UBE2L6" %in% rownames(sobj)) {
    expr_u <- suppressWarnings(GetAssayData(sobj, assay = "Spatial", layer = "data"))
    if (nrow(expr_u) == 0 || ncol(expr_u) == 0) {
      expr_u <- suppressWarnings(GetAssayData(sobj, assay = "Spatial", layer = "counts"))
      expr_u <- log1p(expr_u)
    }
    if (!"UBE2L6" %in% rownames(expr_u)) next
    ube2l6_expr <- as.numeric(expr_u["UBE2L6", ])
    names(ube2l6_expr) <- colnames(expr_u)
    
    # 按UBE2L6表达分组
    ube2l6_quantiles <- quantile(ube2l6_expr, c(0.33, 0.67))
    ube2l6_group <- ifelse(ube2l6_expr < ube2l6_quantiles[1], "Low",
                            ifelse(ube2l6_expr > ube2l6_quantiles[2], "High", "Medium"))
    names(ube2l6_group) <- names(ube2l6_expr)
    
    # 添加到metadata
    sobj$UBE2L6_group <- ube2l6_group
    
    # 计算各组的LR分数
    lr_df <- data.frame(LR_Pair = lr_cols)
    for (group in c("Low", "Medium", "High")) {
      spots <- names(ube2l6_group[ube2l6_group == group])
      lr_df[[paste0(group, "_Mean")]] <- sapply(lr_cols, function(x) {
        mean(sobj@meta.data[spots, x], na.rm = TRUE)
      })
    }
    
    # 保存结果
    write.csv(lr_df, file = paste0("LR_by_UBE2L6_", sample_name, ".csv"))
    
    # 可视化
    lr_long <- lr_df %>%
      pivot_longer(cols = -LR_Pair,
                   names_to = "Group",
                   values_to = "Mean_Score")
    
    p2 <- ggplot(lr_long, aes(x = LR_Pair, y = Mean_Score, fill = Group)) +
      geom_bar(stat = "identity", position = "dodge") +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
      labs(title = paste("LR Scores by UBE2L6 Expression Group -", sample_name),
           x = "Ligand-Receptor Pair", y = "Mean LR Score", fill = "UBE2L6 Group")
    
    ggsave(paste0("LR_UBE2L6_", sample_name, ".pdf"), p2, width = 12, height = 6)
    
    # 更新列表
    RCTD_list[[sample_name]] <- sobj
  }
}

# 保存结果
save(RCTD_list, file = "RCTD_list_with_LR.Rdata")

cat("\n空间配体-受体分析完成！\n")
cat("输出文件:\n")
cat("- LR_by_Structure_*.pdf\n")
cat("- LR_Spatial_*.pdf\n")
cat("- LR_UBE2L6_*.pdf\n")
cat("- LR_by_UBE2L6_*.csv\n")
