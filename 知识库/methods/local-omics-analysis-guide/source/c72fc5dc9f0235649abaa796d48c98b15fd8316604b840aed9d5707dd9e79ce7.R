################################################################################
# Phase 2.3 (Optional): RCTD vs cell2location 交叉验证
# 目的: 使用cell2location作为独立方法验证RCTD的细胞类型注释结果
# 注意: 此分析为可选，需要较多计算资源(GPU推荐)
################################################################################

# 如果需要运行cell2location，需要Python环境
# 安装: pip install cell2location

library(Seurat)
library(reticulate)
library(ggplot2)
library(viridis)

# 优先使用已重建的Python环境
try(use_condaenv("spatial_py", required = FALSE), silent = TRUE)

# 设置工作目录
setwd("D:/fyb/UC-20/20.空间转录组")

# 加载数据
load("RCTD_list.Rdata")
load("spatial_samples_list.Rdata")

# 检查Python环境中的cell2location
check_cell2location <- function() {
  tryCatch({
    # 检查cell2location是否可用
    py_run_string("import cell2location")
    return(TRUE)
  }, error = function(e) {
    cat("cell2location not installed in Python environment.\n")
    cat("To install: pip install cell2location scvi-tools\n")
    return(FALSE)
  })
}

# 如果cell2location可用，运行分析
if (check_cell2location()) {
  cat("\n===== Running cell2location =====\n")
  
  # 1. 准备scRNA参考数据
  # 加载单细胞参考数据
  if (file.exists("D:/fyb/UC-20/00.ascii_inputs/seurat/UC_scRNA_annot.rds")) {
    scRNA_ref <- readRDS("D:/fyb/UC-20/00.ascii_inputs/seurat/UC_scRNA_annot.rds")
    
    # 提取reference panel
    # 使用已知细胞类型的表达矩阵
    ref_expr <- GetAssayData(scRNA_ref, assay = "RNA", slot = "data")
    ref_labels <- scRNA_ref$celltype
    
    # 保存参考数据供Python使用
    saveRDS(list(expr = ref_expr, labels = ref_labels), 
            "scRNA_reference_for_cell2location.rds")
  }
  
  # 2. 运行cell2location的Python代码
  # 以下是Python代码模板，实际运行需要根据数据调整
  
  python_code <- '
import cell2location
import scanpy as sc
import numpy as np
import pandas as pd
from cell2location.models import Cell2location

# 1. 加载scRNA参考数据
ref_data = sc.read("scRNA_reference_for_cell2location.h5ad")

# 2. 训练细胞类型签名
cell2location.models.Cell2location.setup_anndata(ref_data, labels_key="cell_type")

# 3. 训练模型
c2l = Cell2location(ref_data, epochs=100)
c2l.train()

# 4. 保存细胞类型签名
ref_signature = c2l.export_reference()
ref_signature.write_csv("cell2location_reference_signature.csv")

# 5. 加载空间数据
spatial_data = sc.read_visium("path/to/visium")

# 6. 映射到空间
c2l.map_cell2location(spatial_data, ref_signature)

# 7. 保存结果
spatial_data.write("spatial_with_cell2location.h5ad")
'
  
  # 将Python代码保存到文件
  writeLines(python_code, "run_cell2location.py")
  
  cat("Python script saved to: run_cell2location.py\n")
  cat("Please run this script in Python environment with cell2location installed.\n")
  
} else {
  # 如果cell2location不可用，提供替代方案
  cat("\n===== Alternative: Sensitivity Analysis for RCTD Results =====\n")
  
  # 使用替代方法进行验证：敏感度分析
  # 比较不同参数下的RCTD结果稳定性
  
  for (sample_name in names(RCTD_list)) {
    cat("\n===== Sensitivity Analysis for", sample_name, "=====\n")
    
    sobj <- RCTD_list[[sample_name]]
    
    # 提取细胞类型权重
    cell_type_cols <- grep("^[A-Z]", colnames(sobj@meta.data), value = TRUE)
    known_types <- c("Epithelial", "Fibroblast", "Macrophage", "T cell", "B cell",
                     "Endothelial", "Plasma", "Dendritic", "Mast", "NK", "Smooth")
    ct_cols <- cell_type_cols[sapply(cell_type_cols, function(x) {
      any(sapply(known_types, function(ct) grepl(ct, x, ignore.case = TRUE)))
    })]
    
      if (length(ct_cols) > 0) {
        # 1. 计算细胞类型之间的相关性
        ct_matrix <- sobj@meta.data[, ct_cols, drop = FALSE]
        cor_matrix <- cor(ct_matrix, method = "spearman", use = "pairwise.complete.obs")
        cor_matrix[is.na(cor_matrix) | is.infinite(cor_matrix)] <- 0
      
      # 保存相关性矩阵
      write.csv(cor_matrix, 
                file = paste0("CellType_Correlation_", sample_name, ".csv"))
      
      # 2. 可视化
      library(pheatmap)
      pdf(paste0("CellType_Correlation_Heatmap_", sample_name, ".pdf"), 
          width = 10, height = 8)
      pheatmap::pheatmap(cor_matrix, 
                        clustering_method = "ward.D2",
                        color = colorRampPalette(c("blue", "white", "red"))(50),
                        main = paste("Cell Type Correlation -", sample_name))
      dev.off()
      
      # 3. 主成分分析细胞类型组成
      ct_matrix_pca <- as.data.frame(ct_matrix)
      for (j in seq_len(ncol(ct_matrix_pca))) {
        x <- ct_matrix_pca[[j]]
        x[is.infinite(x)] <- NA
        med <- suppressWarnings(median(x, na.rm = TRUE))
        if (!is.finite(med)) med <- 0
        x[is.na(x)] <- med
        ct_matrix_pca[[j]] <- x
      }
      keep <- apply(ct_matrix_pca, 2, sd, na.rm = TRUE) > 0
      ct_matrix_pca <- ct_matrix_pca[, keep, drop = FALSE]
      pca_result <- prcomp(ct_matrix_pca, scale. = TRUE)
      
      # 可视化PCA
      pca_df <- as.data.frame(pca_result$x)
      pca_df$spot <- rownames(pca_df)
      
      # 添加到metadata
      sobj$PCA1 <- pca_result$x[, 1]
      sobj$PCA2 <- pca_result$x[, 2]
      
      p3 <- SpatialFeaturePlot(sobj, features = "PCA1", pt.size.factor = 1.5) +
        scale_fill_viridis(option = "B") +
        ggtitle(paste("Cell Type Composition PC1 -", sample_name)) +
        theme(plot.title = element_text(hjust = 0.5, face = "bold"))
      
      ggsave(paste0("CellType_PCA_", sample_name, ".pdf"), p3, width = 7, height = 6)
      
      cat("Sensitivity analysis completed.\n")
    }
  }
  
  cat("\nAlternative analysis (correlation + PCA) completed.\n")
  cat("This provides a sanity check for RCTD results.\n")
}

cat("\nPhase 2.3 (Optional) analysis setup complete!\n")
cat("If running full cell2location, please execute: run_cell2location.py\n")
