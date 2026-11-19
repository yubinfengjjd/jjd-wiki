# =========================================================
# Script: ST_RCTD_CAF_analysis.R
# Purpose: Run RCTD deconvolution on multiple ST samples for CAF cells
# Input:
#   - ST Seurat object (.qs) per sample
#   - RCTD reference (.qs)
# Output:
#   - RCTD results (.qs)
#   - Annotated Seurat objects with cell type weights (.qs)
#   - SpatialFeaturePlot PDFs
# =========================================================

library(Seurat)
library(SCP)
library(RCTD)
library(ggplot2)
library(dplyr)
library(qs)
library(patchwork)

# --------------------------
# 1. Define function for a single sample
# --------------------------
run_RCTD_on_sample <- function(
    sample_id, 
    st_path_prefix = "/home/data/caixing/CAF/result/fig_ST/",
    reference_file = "/home/data/caixing/CAF/rawdata/RCTD_reference_caf_all.qs",
    output_dir = "/home/data/caixing/CAF/result/fig_ST/"
){
  message("Processing sample: ", sample_id)
  
  # 1.1 Load ST data
  ST_data <- qread(paste0(st_path_prefix, sample_id, ".qs"))
  
  # 1.2 Load RCTD reference
  reference <- qread(reference_file)
  
  # 1.3 Prepare RCTD puck object
  sp_counts <- as.matrix(ST_data[['Spatial']]@counts)
  sp_nUMI <- colSums(sp_counts)
  coords <- GetTissueCoordinates(ST_data, cols = c("row", "col"), scale = NULL)
  
  puck <- SpatialRNA(coords, sp_counts, sp_nUMI)
  
  # 1.4 Run RCTD (doublet mode)
  RCTD_obj <- create.RCTD(puck, reference, max_cores = 8)
  RCTD_obj <- run.RCTD(RCTD_obj, doublet_mode = "doublet")
  
  # Add doublet results back to Seurat metadata
  ST_data <- AddMetaData(ST_data, metadata = RCTD_obj@results$results_df)
  
  # Visualize first_type and second_type
  p1 <- SpatialDimPlot(ST_data, group.by = "first_type")
  p2 <- SpatialDimPlot(ST_data, group.by = "second_type")
  print(p1 | p2)
  
  # 1.5 Run RCTD (full mode)
  RCTD_obj <- run.RCTD(RCTD_obj, doublet_mode = "full")
  
  # Add full mode weights
  weights_df <- as.data.frame(RCTD_obj@results)
  ST_data <- AddMetaData(ST_data, metadata = weights_df)
  
  # Clean column names
  colnames(ST_data@meta.data) <- gsub("weights.", '', colnames(ST_data@meta.data))
  
  # Replace NA with 0
  ST_data@meta.data[is.na(ST_data@meta.data)] <- 0
  
  # 1.6 Plot SpatialFeaturePlot for all cell types
  feature_cols <- colnames(ST_data@meta.data)[13:35]
  SpatialFeaturePlot(ST_data, features = feature_cols, image.alpha = 0)
  ggsave(paste0(output_dir, sample_id, "-caf-RCTDfull.pdf"), width = 18, height = 16)
  
  # 1.7 Save RCTD object and updated Seurat object
  qsave(RCTD_obj, paste0(output_dir, sample_id, "-caf-RCTD-full.qs"))
  qsave(ST_data, file = paste0(output_dir, sample_id, ".qs"))
  
  return(ST_data)
}

# --------------------------
# 2. Process multiple samples
# --------------------------
sampleID <- c("CAA_ST",'CAB_ST','CAC_ST','CAD_ST', 'LNA_ST','LNB_ST','LNC_ST','LND_ST')

for(i in sampleID){
  run_RCTD_on_sample(i)
}