library(qs)
library(Seurat)
library(tidyverse)
library(ComplexHeatmap)
library(AnnoProbe)
library(psych)
library(qgraph)
library(igraph)
library(CellChat)
library(RColorBrewer)
library(svglite)


downsample_sce <- function(sce, n_cells=1000) {
  sce@meta.data$id <- rownames(sce@meta.data)
  sampled_df <- sce@meta.data %>%
    group_by(subclusters) %>%
    summarise(sampled=list(sample_n(cur_data(), min(n_cells, n())))) %>%
    tidyr::unnest(sampled)
  
  sce_subset <- subset(sce, id %in% sampled_df$id)
  return(sce_subset)
}


prepare_cellphonedb <- function(sce, out_dir="result/cellphoneDB") {
  exp <- as.data.frame(sce@assays$RNA@data)
  ids <- annoGene(rownames(exp),'SYMBOL','human')
  ids <- ids[!duplicated(ids$ENSEMBL),]
  ids <- ids[!duplicated(ids$SYMBOL),]
  
  counts <- exp[ids$SYMBOL,]
  rownames(counts) <- ids$ENSEMBL
  counts <- cbind(Gene=rownames(counts), counts)
  
  meta <- data.frame(
    Cell = rownames(sce@meta.data),
    cell_type = gsub("[ +]","_",sce$subclusters)
  )
  
  write.table(counts, file.path(out_dir,"test_counts.txt"), row.names=F, sep="\t", quote=F)
  write.table(meta, file.path(out_dir,"test_meta.txt"), row.names=F, sep="\t", quote=F)
}


plot_heatmap <- function(expr_matrix, rows, cols, filename=NULL, row_ha=NULL, col_ha=NULL,
                         cluster_rows=FALSE, cluster_cols=FALSE, cellheight=10, cellwidth=12) {
  ht <- ComplexHeatmap::pheatmap(
    expr_matrix[rows, cols],
    border_color = 'white',
    color = colorpanel(64, low="#7570B3", mid="white", high="#D95F02"),
    show_rownames = TRUE,
    show_colnames = TRUE,
    cellheight = cellheight,
    cellwidth = cellwidth,
    top_annotation = col_ha,
    right_annotation = row_ha,
    name = "interactions",
    cluster_rows = cluster_rows,
    cluster_cols = cluster_cols
  )
  if(!is.null(filename)) {
    pdf(filename, height=6, width=12)
    draw(ht)
    dev.off()
  }
  return(ht)
}


plot_cellchat_point <- function(df_net, filename=NULL, color_palette=NULL, flip=TRUE, width=8, height=20) {
  p <- ggplot(df_net, aes(x=cell_inter, y=interaction_name)) +
    geom_point(aes(size=prob, color=prob), shape=21) +
    scale_color_gradientn('Communication\nProbability', colors=color_palette %||% colorRampPalette(rev(brewer.pal(9,"PRGn")))(100)) +
    theme_bw() +
    theme(axis.text=element_text(size=10, colour="black"),
          axis.text.x=element_text(angle=90,hjust=1,vjust=0,size=10),
          axis.text.y=element_text(size=8, colour="black"),
          axis.title=element_blank(),
          panel.border=element_rect(size=0.7, linetype="solid", colour="black"))
  if(flip) p <- p + coord_flip()
  if(!is.null(filename)) ggsave(filename, plot=p, width=width, height=height, limitsize=FALSE)
  return(p)
}


run_cellchat <- function(sce, group.by="subclusters", out_dir="result/fig5/cellchat") {
  cellchat <- createCellChat(object=sce, group.by=group.by)
  CellChatDB.use <- CellChatDB.human
  cellchat@DB <- CellChatDB.use
  
  cellchat <- subsetData(cellchat)
  future::plan("multisession", workers=14)
  cellchat <- identifyOverExpressedGenes(cellchat)
  cellchat <- identifyOverExpressedInteractions(cellchat)
  cellchat <- smoothData(cellchat, adj=PPI.human)
  options(future.globals.maxSize=4000000000)
  cellchat <- computeCommunProb(cellchat, raw.use=TRUE)
  cellchat <- filterCommunication(cellchat, min.cells=10)
  cellchat <- computeCommunProbPathway(cellchat)
  cellchat <- aggregateNet(cellchat)
  
  qsave(cellchat, file=file.path(out_dir, "cellchat.qs"))
  return(cellchat)
}

plot_cellchat_all <- function(cellchat, sources=NULL, targets=NULL, out_dir="result/fig5/cellchat_str",
                              color_palette=NULL, flip=TRUE, width=8, height=20) {
  if(!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  n_cells <- length(cellchat@idents)
  sources <- sources %||% seq_len(n_cells)
  targets <- targets %||% seq_len(n_cells)
  
  ids <- gsub("\\+","",names(table(cellchat@idents)))
  
  for(s in sources) {
    for(t in targets) {
      df.net <- subsetCommunication(cellchat, slot.name = "net",
                                    sources.use = s, targets.use = t, thresh = 0.05)
      if(nrow(df.net)==0) next
      df.net$cell_inter <- paste0(df.net$source,"->",df.net$target)
      
      filename <- paste0(out_dir,"/",ids[s],"_to_",ids[t],"_point.pdf")
      plot_cellchat_point(df.net, filename=filename,
                          color_palette=color_palette, flip=flip,
                          width=width, height=height)
    }
  }
}

# -----------------------------
# CellChat 特定 pathway 循环绘图函数
# -----------------------------
plot_cellchat_pathways_all <- function(cellchat, pathways, sources=NULL, targets=NULL, out_dir="result/fig5/cellchat_pathways",
                                       color_palette=NULL, flip=TRUE, width=8, height=20) {
  if(!dir.exists(out_dir)) dir.create(out_dir, recursive=TRUE)
  
  for(pathway in pathways) {
    df.net <- subsetCommunication(cellchat, slot.name="net", sources.use=sources, targets.use=targets, thresh=0.05)
    df.net <- dplyr::filter(df.net, pathway_name %in% pathway)
    if(nrow(df.net) == 0) next
    df.net$cell_inter <- paste0(df.net$source,"->",df.net$target)
    
    filename <- file.path(out_dir, paste0(pathway, "_point.pdf"))
    plot_cellchat_point(df.net, filename=filename,
                        color_palette=color_palette, flip=flip,
                        width=width, height=height)
  }
}


run_full_analysis <- function() {
  sce <- qread("rawdata/sce-all.qs")
  
  sce_subset <- downsample_sce(sce, n_cells=1000)
  
  prepare_cellphonedb(sce_subset)
  
  wide_data <- read.delim("result/cellphoneDB/out/means.txt", check.names=FALSE)
  
  # Heatmap 示例
  CAF <- c("C1_CAF_ACTA2","C2_CAF_HSPA6","C3_CAF_PLA2G2A")
  ECs <- c("C1_ArtECs_SEMA3G","C2_ArtECs_DLL4")
  PVL <- c("C1_MLY9SMC","C2_FN1SMC")
  plot_heatmap(wide_data, rows=CAF, cols=c(CAF,ECs,PVL), filename="result/fig5/ECs_stromal.pdf")
  
  # CellChat 分析
  cellchat <- run_cellchat(sce_subset)
  
  # 全循环绘制 CellChat 点图
  plot_cellchat_all(cellchat, out_dir="result/fig5/cellchat_str")
  
  # 7. 特定通路绘制示例（CAF->immune, EC->immune 等）
  pathways <- c('CXCL','CCL','MIF','CSF','GALECTIN','LAMININ','TGFb','VEGF','NOTCH','PDGF')
  
  # CAF->immune
  plot_cellchat_pathways_all(cellchat, pathways=pathways, sources=5, targets=37:57, 
                             out_dir="result/fig5/cellchat_pathways/CAF_to_immune")
  
  # EC->immune
  plot_cellchat_pathways_all(cellchat, pathways=pathways, sources=37:41, targets=37:57, 
                             out_dir="result/fig5/cellchat_pathways/EC_to_immune")
  
  # PVL->immune
  plot_cellchat_pathways_all(cellchat, pathways=pathways, sources=23, targets=c(4,15,16,19,20,22,25,28,31),
                             out_dir="result/fig5/cellchat_pathways/PVL_to_immune")
  
  return(list(sce=sce, sce_subset=sce_subset, cellchat=cellchat))
  
}

# -----------------------------
# 运行整个流程
# -----------------------------
results <- run_full_analysis()



results <- run_full_analysis()