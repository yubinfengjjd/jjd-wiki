## =========================================================
## Script: Monocle3_scTOUR_Pseudotime.R
## Purpose: 
##   Perform Monocle3 pseudotime analysis and scTOUR pseudotime
##   mapping for CAF, PVL, and Endothelial cells.
##
## Input:
##   - Seurat object (.qs)
##   - scTOUR pseudotime CSV file
##
## Output:
##   - Monocle3 CDS RDS
##   - Seurat object with pseudotime columns
##   - FeatureDimPlot PDFs
## =========================================================

library(Seurat)
library(monocle3)
library(tidyverse)
library(patchwork)
library(SCP)
library(viridis)

## =========================================================
## 1. Define function
## =========================================================
run_monocle3_pseudotime <- function(
    seurat_obj_file,       # path to Seurat object (.qs)
    scTOUR_file=NULL,      # path to scTOUR pseudotime CSV (optional)
    reduction="HarmonyUMAP2D", # Seurat reduction to use
    output_prefix=NULL     # prefix for output files
){
  ## Load Seurat object
  seurat_obj <- qread(seurat_obj_file)
  
  ## Create Monocle3 CDS
  data <- GetAssayData(seurat_obj, assay='RNA', slot='counts')
  cell_metadata <- seurat_obj@meta.data
  gene_annotation <- data.frame(gene_short_name = rownames(data))
  rownames(gene_annotation) <- rownames(data)
  
  cds <- new_cell_data_set(
    data,
    cell_metadata = cell_metadata,
    gene_metadata = gene_annotation
  )
  
  ## Preprocess + Dimensionality reduction
  cds <- preprocess_cds(cds, num_dim=50)
  cds <- reduce_dimension(cds, preprocess_method="PCA")
  
  ## Replace Monocle3 embedding with Seurat embedding
  cds.embed <- cds@int_colData$reducedDims$UMAP
  int.embed <- Embeddings(seurat_obj, reduction=reduction)
  int.embed <- int.embed[rownames(cds.embed), ]
  cds@int_colData$reducedDims$UMAP <- int.embed
  
  ## Cluster cells + learn trajectory
  cds <- cluster_cells(cds, reduction_method="UMAP")
  cds <- learn_graph(cds)
  cds <- order_cells(cds)
  
  ## Add pseudotime to Seurat object
  seurat_obj$pseudotime_monocle3 <- pseudotime(cds, reduction_method="UMAP")
  
  ## Optional: process scTOUR pseudotime
  if(!is.null(scTOUR_file)){
    ptime_sctour <- read_csv(scTOUR_file)
    p <- intersect(rownames(seurat_obj@meta.data), ptime_sctour$index)
    rownames(ptime_sctour) <- ptime_sctour$index
    ptime_sctour <- ptime_sctour[p, ]
    
    ## Add scTOUR pseudotime
    seurat_obj$scTOUR_psedutime <- ptime_sctour$ptime
  }
  
  ## Visualize Monocle3 pseudotime
  if(!is.null(output_prefix)){
    pdf(paste0(output_prefix, "_pseudotime_monocle3.pdf"), width=6, height=5)
    FeatureDimPlot(
      seurat_obj,
      features='pseudotime_monocle3',
      reduction=reduction,
      raster = TRUE,
      theme_use = "theme_blank",
      palette = "PiYG"
    )
    dev.off()
    
    ## If scTOUR is present, plot as well
    if(!is.null(scTOUR_file)){
      pdf(paste0(output_prefix, "_scTOUR_pseudotime.pdf"), width=6, height=5)
      FeatureDimPlot(
        seurat_obj,
        features='scTOUR_psedutime1',
        reduction=reduction,
        raster=TRUE,
        pt.size=2,
        pt.alpha=0.1,
        theme_use="theme_blank"
      ) + viridis::scale_color_viridis(option="viridis") + guides(alpha="none")
      dev.off()
    }
    
    ## Save Monocle3 CDS
    saveRDS(cds, paste0(output_prefix, "_monocle3.rds"))
    
    ## Save updated Seurat object
    qsave(seurat_obj, paste0(output_prefix, "_with_pseudotime.qs"))
  }
  
  return(list(seurat_obj=seurat_obj, cds=cds))
}


## =========================================================
## 2. Run function for CAF, PVL, Endothelial
## =========================================================

# CAF
res_CAF <- run_monocle3_pseudotime(
  seurat_obj_file="result/fig2_CAF/sub_caf.qs",
  scTOUR_file="rawdata/scTOUR/ptime_metadata_CAF.csv",
  reduction="HarmonyUMAP2D",
  output_prefix="result/fig2_CAF/sub_CAF"
)

# PVL
res_PVL <- run_monocle3_pseudotime(
  seurat_obj_file="result/fig3_PVL/sub_PVL.qs",
  scTOUR_file="rawdata/scTOUR/ptime_metadata_PVL.csv",
  reduction="HarmonyUMAP2D",
  output_prefix="result/fig3_PVL/sub_PVL"
)

# Endothelial
res_Endo <- run_monocle3_pseudotime(
  seurat_obj_file="result/fig4_Endo/sub_endo.qs",
  scTOUR_file="rawdata/scTOUR/ptime_metadata_Endo.csv",
  reduction="fastMNNUMAP2D",
  output_prefix="result/fig4_Endo/sub_Endo"
)