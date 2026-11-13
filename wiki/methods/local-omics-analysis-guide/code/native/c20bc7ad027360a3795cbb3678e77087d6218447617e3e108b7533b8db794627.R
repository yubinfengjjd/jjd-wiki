create_cellchat <- function(subset_obj, group_name) {
	data_input <- subset_obj@assays$RNA$data
	meta_data <- subset_obj@meta.data[, c("celltype"),drop=F]
	colnames(meta_data) <- c("labels")

	cellchat <- createCellChat(object = data_input, meta = meta_data, group.by = "labels")
	cellchat <- addMeta(cellchat, meta = meta_data)
	cellchat <- setIdent(cellchat, ident.use = "labels")

	CellChatDB.use <- subsetDB(CellChatDB.human, search = "Secreted Signaling")
	cellchat@DB <- CellChatDB.use

	cellchat <- subsetData(cellchat)
	cellchat <- identifyOverExpressedGenes(cellchat)
	cellchat <- identifyOverExpressedInteractions(cellchat)
	cellchat <- projectData(cellchat, PPI.human)

	cellchat <- computeCommunProb(cellchat, raw.use = TRUE)
	#cellchat <- filterCommunication(cellchat, min.cells = 10)
	cellchat <- computeCommunProbPathway(cellchat)
	cellchat <- aggregateNet(cellchat)

	return(cellchat)
}
