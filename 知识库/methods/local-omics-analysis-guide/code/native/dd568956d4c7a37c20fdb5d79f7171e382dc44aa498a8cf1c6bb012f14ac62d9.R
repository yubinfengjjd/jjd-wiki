create_cellchat <- function(subset_obj, group_name) {
  # 提取数据
  data_input <- subset_obj@assays$RNA$data
  meta_data <- subset_obj@meta.data[, c("celltype"),drop=F]
  colnames(meta_data) <- c("labels")
  
  # 创建CellChat对象
  cellchat <- createCellChat(object = data_input, meta = meta_data, group.by = "labels")
  cellchat <- addMeta(cellchat, meta = meta_data)
  cellchat <- setIdent(cellchat, ident.use = "labels")
  
  # 设置数据库参数
  CellChatDB.use <- subsetDB(CellChatDB.human, search = "Secreted Signaling")
  cellchat@DB <- CellChatDB.use
  
  # 标准分析流程
  cellchat <- subsetData(cellchat)
  cellchat <- identifyOverExpressedGenes(cellchat)
  cellchat <- identifyOverExpressedInteractions(cellchat)
  cellchat <- projectData(cellchat, PPI.human)
  
  # 计算通讯概率
  cellchat <- computeCommunProb(cellchat, raw.use = TRUE)
  #cellchat <- filterCommunication(cellchat, min.cells = 10)
  cellchat <- computeCommunProbPathway(cellchat)
  cellchat <- aggregateNet(cellchat)
  
  return(cellchat)
}
