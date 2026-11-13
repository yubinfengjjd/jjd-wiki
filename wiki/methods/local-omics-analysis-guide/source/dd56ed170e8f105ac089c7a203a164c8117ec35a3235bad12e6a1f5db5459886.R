library(Seurat)
library(GSVA)
library(GSEABase)
library(dplyr)
library(tidyverse)
rm(list = ls())
setwd("D:\\UC-20种修饰\\19.细胞通讯")
main_gene = data.table::fread("./output_mRNA_selected.txt")
rt = data.table::fread("./PTMDS1_vs_PTMDS2_DEG.csv")
rt = rt %>% 
	dplyr::select(logFC,symbol) %>% 
	column_to_rownames("symbol")
data = rt[main_gene$x,,drop = F]

up_ragulate = rownames(data)[which(data$logFC > 0)]
down_ragulate = rownames(data)[which(data$logFC < 0)]
gene_sets = list("PTMD_up" = up_ragulate,
								 "PTMD_down" = down_ragulate)

exp <- UC@assays$RNA$data
exp <- as.matrix(exp)

# 创建GeneSetCollection对象
gsc <- GeneSetCollection(lapply(names(gene_sets), function(name) {
	# 创建GeneSet
	GeneSet(
		geneIds = gene_sets[[name]],
		collectionType = KEGGCollection(),
		setName = name,
		organism = "Homo sapiens"
	)
}))
# 执行GSVA分析
gsva_results <- ssgseaParam(
	exp, 
	gsc,normalize = F
)

result <- gsva(gsva_results)
result <- t(scale(t(result)))
# 提取评分结果
scores <- t(result)  # 转置为样本×基因集
# 计算PTMDs评分 = PTMD_up - PTMD_down
scores_df <- as.data.frame(scores) %>%
	mutate(PTMDs = PTMD_down - PTMD_up)
UC$PTMDs = scores_df$PTMDs

library(dplyr)

# 获取metadata数据
meta_data <- UC@meta.data

# 按细胞类型分组并计算中位数
meta_data <- meta_data %>%
	group_by(celltype) %>%
	mutate(
		median_ptmd = median(PTMDs, na.rm = TRUE),  # 计算当前细胞类型的中位数
		group = if_else(PTMDs > median_ptmd,        # 高于中位数为high，否则为low
										paste0("high_", celltype),
										paste0("low_", celltype))
	) %>%
	ungroup()

# 将分组信息添加回Seurat对象
UC$celltype <- meta_data$group

table(UC$celltype)
library(CellChat)
library(patchwork)
library(Seurat)
library(dplyr)
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

cellchat <- create_cellchat(UC,"UC")
cellchat <- netAnalysis_computeCentrality(cellchat, slot.name = "netP")
######可视化####
#所有互作网络
groupSize <- as.numeric(table(cellchat@idents))
pdf(file = 'netVisual_circle_Number.pdf',height = 8, width = 8)
netVisual_circle(cellchat@net$count, 
								 vertex.weight = groupSize, 
								 weight.scale = T, 
								 label.edge= F, 
								 title.name = "Number of interactions")
dev.off()
pdf(file = 'netVisual_circle_weight.pdf',height = 8, width = 8)
netVisual_circle(cellchat@net$weight, 
								 vertex.weight = groupSize, 
								 weight.scale = T, 
								 label.edge= F, 
								 title.name = "Interaction weights/strength")
dev.off()


#展示每个亚群作为source的信号传递
mat <- cellchat@net$weight
# 检查每种细胞发出的信号 （每种细胞和其他细胞的互作情况）

for (i in c("low_Epithelial","high_Epithelial")){
	pdf(file = paste(i,"_netVisual_circle.PDF"),width = 6,height = 6)
	mat2 <- matrix(0,nrow = nrow(mat),ncol = ncol(mat),dimnames = dimnames(mat))
	mat2[i,] <- mat[i,]
	netVisual_circle(mat2,vertex.weight = groupSize, weight.scale = T, arrow.width = 0.2,
									 arrow.size = 0.1, edge.weight.max = max(mat),title.name = rownames(mat)[i])
	dev.off()
}


# 气泡图（全部配体-受体）
levels(cellchat@idents)
# show all the significant interactions (L-R pairs)
main=c(3,13) #目的细胞的排序
pdf("netVisual_bubble.pdf", width = 6, height = 10)
netVisual_bubble(cellchat, sources.use = main,
								 targets.use = levels(cellchat@idents)[-main],remove.isolate = FALSE,angle.x = 45)
dev.off()
pdf("netVisual_bubble1.pdf", width = 6, height = 10)
netVisual_bubble(cellchat, sources.use = levels(cellchat@idents)[-main],
								 targets.use = main,remove.isolate = FALSE,angle.x = 45)
dev.off()
##计算网络中心评分
cellchat <- netAnalysis_computeCentrality(cellchat, slot.name = "netP")# the slot 'netP' means the inferred intercellular communication network of signaling pathways
# Visualize the computed centrality scores using heatmap, allowing ready identification of major signaling roles of cell groups
pdf("netAnalysis_signalingRole_scatter.pdf",width = 6,height = 6)
netAnalysis_signalingRole_scatter(cellchat)
dev.off()

pdf("netAnalysis_signalingRole_heatmap.pdf",width = 10,height = 6)
ht1 <- netAnalysis_signalingRole_heatmap(cellchat, pattern = "outgoing")
ht2 <- netAnalysis_signalingRole_heatmap(cellchat, pattern = "incoming")
ht1 + ht2
dev.off()