library(clusterProfiler)
library(GSVA)
library(GSEABase)
library(org.Hs.eg.db)
library(KEGGREST)
setwd("D:\\UC-20种修饰\\20.空间转录组")
library(readxl)
# 从Excel文件读取PTM基因集
ptm_data <- read_excel("inline-supplementary-material-2.xlsx", sheet = "Sheet1", skip = 1)

# 构建基因集列表
gene_sets <- list()
for (ptm in colnames(ptm_data)) {
	genes <- ptm_data[[ptm]]
	genes <- na.omit(genes)  # 移除NA值
	genes <- as.character(genes)
	genes <- genes[genes != "" & !grepl("^\\d{4}-\\d{2}-\\d{2}", genes)]  # 过滤日期值
	genes <- toupper(genes)  # 转为大写
	if (length(genes) > 0) {
		gene_sets[[ptm]] <- genes
	}
}

library(AUCell)
library(Seurat)
library(ggplot2)

# 假设 RCTD_list 是包含两个Seurat对象的列表
# 每个Seurat对象已包含空间转录组数据
RCTD_list$GSM5695834_B8$Structure
# 遍历每个Seurat对象
for (obj_name in names(RCTD_list)) {
	seurat_obj <- RCTD_list[[obj_name]]
	
	# 提取表达矩阵（确保使用正确的assay和slot）
	expr_matrix <- GetAssayData(seurat_obj, assay = "SCT", slot = "data")
	expr_matrix <- as.matrix(expr_matrix)  # 转换为普通矩阵
	
	# 计算细胞排名（耗时步骤）
	cells_rankings <- AUCell_buildRankings(expr_matrix, nCores = 1)
	
	# 对每个基因集进行评分
	for (pathway in names(gene_sets)) {
		genes <- gene_sets[[pathway]]
		
		# 检查基因是否存在于数据中
		valid_genes <- intersect(genes, rownames(seurat_obj))
		if (length(valid_genes) < 1) {
			warning(paste("Insufficient valid genes (", length(valid_genes), ") for", pathway, "in", obj_name))
			next
		}
		
		# 计算AUC值
		cells_AUC <- AUCell_calcAUC(
			geneSets = setNames(list(valid_genes), pathway),
			rankings = cells_rankings,
			aucMaxRank = ceiling(nrow(cells_rankings) * 0.05)  # 前5%基因
		)
		
		# 将评分结果存入metadata
		seurat_obj[[pathway]] <- getAUC(cells_AUC)[pathway, ]
	}
	# 更新对象
	RCTD_list[[obj_name]] <- seurat_obj
}

plot_ptm_bubble <- function(seurat_obj, sample_name) {
	# 获取metadata数据
	meta_df <- seurat_obj@meta.data
	
	# 提取Structure列和所有PTM评分列
	ptm_cols <- names(gene_sets)[names(gene_sets)%in%colnames(meta_df)]
	plot_df <- meta_df %>%
		dplyr::select(Structure, all_of(ptm_cols)) %>%
		pivot_longer(
			cols = -Structure,
			names_to = "Pathway",
			values_to = "Score"
		)
	
	# 计算每个通路-结构的平均评分
	agg_df <- plot_df %>%
		group_by(Structure, Pathway) %>%
		summarise(Avg_Score = mean(Score, na.rm = TRUE), .groups = "drop")
	
	# 计算每个通路的全局平均分（用于排序）
	pathway_global_avg <- agg_df %>%
		group_by(Pathway) %>%
		summarise(Global_Avg = mean(Avg_Score, na.rm = TRUE), .groups = "drop")
	
	# 将全局平均分合并到agg_df中
	agg_df <- agg_df %>%
		left_join(pathway_global_avg, by = "Pathway")
	
	# 选择评分最高的前20个通路（按全局平均分排序）
	top_pathways <- pathway_global_avg %>%
		arrange(desc(Global_Avg)) %>%
		head(20) %>%
		pull(Pathway)
	
	# 过滤数据
	filtered_df <- agg_df %>%
		filter(Pathway %in% top_pathways)
	
	# 创建美观的气泡图
	p <- ggplot(filtered_df, aes(x = Structure, y = reorder(Pathway, Global_Avg))) +
		# 添加气泡点
		geom_point(
			aes(size = Avg_Score, fill = Avg_Score),
			shape = 21,           # 使用带轮廓的圆点
			color = "black",      # 轮廓颜色
			stroke = 0.3,         # 轮廓粗细
			alpha = 0.9           # 透明度
		) +
		# 设置尺寸比例
		scale_size_continuous(
			name = "Average Score",
			range = c(3, 10),
			breaks = seq(0, max(filtered_df$Avg_Score), length.out = 5),
			limits = c(0, max(filtered_df$Avg_Score))
		) +
		# 设置填充颜色渐变
		scale_fill_gradientn(
			name = "Average Score",
			colors = c("#4575B4", "#74ADD1", "#FFFFBF", "#F46D43", "#D73027"),  # 蓝-青-黄-橙-红
			breaks = seq(0, max(filtered_df$Avg_Score), length.out = 5),
			limits = c(0, max(filtered_df$Avg_Score))
		) +
		# 坐标轴和标题
		labs(
			x = "Spatial Structure",
			y = "PTM Pathway",
			title = paste("PTM Pathway Activity in", sample_name),
			subtitle = "Bubble size and color indicate pathway activity score"
		) +
		# 使用经典主题作为基础
		theme_classic(base_size = 12) +
		# 自定义主题元素
		theme(
			# 坐标轴文本
			axis.text.x = element_text(
				angle = 45,
				hjust = 1,
				vjust = 1,
				size = 10,
				face = "bold"
			),
			axis.text.y = element_text(
				size = 10,
				face = "bold"
			),
			# 坐标轴标题
			axis.title.x = element_text(
				size = 12,
				face = "bold",
				margin = margin(t = 10)
			),
			axis.title.y = element_text(
				size = 12,
				face = "bold",
				margin = margin(r = 10)
			),
			# 图例
			legend.position = "right",
			legend.title = element_text(face = "bold"),
			legend.text = element_text(size = 9),
			# 标题居中
			plot.title = element_text(
				hjust = 0.5,
				face = "bold",
				size = 14,
				margin = margin(b = 10)
			),
			plot.subtitle = element_text(
				hjust = 0.5,
				size = 11,
				margin = margin(b = 15)
			),
			# 绘图区域
			panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
			# 移除背景网格（确保没有网格线）
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			# 绘图边距
			plot.margin = margin(20, 20, 20, 20)
		) +
		# 添加坐标轴线（确保坐标轴可见）
		coord_cartesian(clip = "off") +
		# 添加参考线（可选）
		geom_hline(
			yintercept = seq(0.5, length(top_pathways) + 0.5),
			color = "grey90",
			linewidth = 0.2
		)
	
	return(list(plot = p, agg_df = agg_df))
}

# 为每个样本生成气泡图并输出agg_df
for (obj_name in names(RCTD_list)) {
	# 运行绘图函数
	result <- plot_ptm_bubble(RCTD_list[[obj_name]], obj_name)
	
	# 提取结果
	p <- result$plot
	agg_df <- result$agg_df
	
	# 保存图像
	ggplot2::ggsave(
		filename = paste0("PTM_Bubble_", obj_name, ".PDF"),
		plot = p,
		width = 8,
		height = 12,
		dpi = 300
	)
	
	# 保存agg_df为CSV文件
	write.csv(agg_df, file = paste0("PTM_Scores_", obj_name, ".csv"), row.names = FALSE)
	
	# 显示图像
	print(p)
	
	# 在控制台输出agg_df
	cat("\n\nAggregated data for", obj_name, ":\n")
	print(head(agg_df))
}
#####小提琴图#####
# 使用lapply替代循环
RCTD_list <- lapply(RCTD_list, function(seurat_obj) {
	# 替换列名
	colnames(seurat_obj@meta.data) <- gsub("-", ".", colnames(seurat_obj@meta.data))
	return(seurat_obj)
})
library(SCP)
pdf(file = "GSM5695834_B8_score.PDF",width = 10,height = 6)
FeatureStatPlot(
	srt = RCTD_list$GSM5695834_B8, 
	group.by = "Structure",
	stat.by = c("S.nitrosylation"), 
	add_box = TRUE,
	comparisons = list(
		c("Mucosa", "Submucosa"),
		c("Mucosa", "Muscularis propria"),
		c("Serosa", "Mucosa"),
		c("Mucosa", "Lymphoid Nodule")
	))
dev.off()

pdf(file = "GSM5695835_B9_score.PDF",width = 10,height = 6)
FeatureStatPlot(
	srt = RCTD_list$GSM5695835_B9, 
	group.by = "Structure",
	stat.by = c("S.nitrosylation"), 
	add_box = TRUE,
	comparisons = list(
		c("Mucosa", "Submucosa"),
		c("Mucosa", "Muscularis propria"),
		c("Serosa", "Mucosa"),
		c("Mucosa", "Lymphoid Nodule")
	))
dev.off()
save(RCTD_list,file = "PTM_ST.Rdata")

#####结构区域富集分析####
# 设置输出目录
output_dir <- "Structure_DEG_and_GO"
if (!dir.exists(output_dir)) {
	dir.create(output_dir)
}

# 循环1: 差异表达分析和GO富集分析
for (obj_name in names(RCTD_list)) {
	seurat_obj <- RCTD_list[[obj_name]]
	
	# 为当前样本创建输出子目录
	sample_dir <- file.path(output_dir, obj_name)
	if (!dir.exists(sample_dir)) {
		dir.create(sample_dir)
	}
	
	# 获取样本中的所有结构区域
	structures <- unique(seurat_obj@meta.data$Structure)
	
	# 存储所有结构区域的富集结果
	all_enrichments <- list()
	
	# 循环处理每个结构区域
	for (struct in structures) {
		# 设置当前结构为关注的组，其他所有结构作为背景
		Idents(seurat_obj) <- "Structure"
		
		# 执行差异表达分析
		degs <- FindMarkers(
			object = seurat_obj,
			ident.1 = struct,  # 当前结构
			ident.2 = NULL,    # 与其他所有结构比较
			min.pct = 0.1,     # 基因在至少10%的细胞中表达
			logfc.threshold = 0.25
		)
		
		# 筛选显著差异基因
		sig_degs <- degs %>%
			filter(p_val_adj < 0.05) %>%
			arrange(desc(avg_log2FC))
		
		# 如果没有显著差异基因，跳过富集分析
		if (nrow(sig_degs) == 0) {
			message(paste("No significant DEGs found for", struct, "in", obj_name))
			next
		}
		
		# 获取基因列表（转换为ENTREZID）
		gene_symbols <- rownames(sig_degs)
		gene_entrez <- bitr(
			gene_symbols,
			fromType = "SYMBOL",
			toType = "ENTREZID",
			OrgDb = org.Hs.eg.db
		)$ENTREZID
		
		# 执行GO_BP富集分析
		go_enrich <- enrichGO(
			gene = gene_entrez,
			OrgDb = org.Hs.eg.db,
			keyType = "ENTREZID",
			ont = "BP",  # 生物过程
			pvalueCutoff = 0.05,
			pAdjustMethod = "BH",
			qvalueCutoff = 0.2,
			readable = TRUE  # 将ENTREZID转换为基因符号
		)
		
		# 保存富集结果
		if (nrow(go_enrich) > 0) {
			# 保存到文件
			deg_file <- file.path(sample_dir, paste0(struct, "_DEGs.csv"))
			go_file <- file.path(sample_dir, paste0(struct, "_GO_BP.csv"))
			
			write.csv(sig_degs, deg_file, row.names = TRUE)
			write.csv(go_enrich@result, go_file, row.names = FALSE)
			
			# 添加到汇总列表
			go_result <- go_enrich@result %>%
				mutate(Structure = struct, Sample = obj_name)
			
			all_enrichments[[struct]] <- go_result
		} else {
			message(paste("No significant GO terms found for", struct, "in", obj_name))
		}
	}
	
	# 合并并保存所有结构区域的富集结果
	if (length(all_enrichments) > 0) {
		combined_go <- bind_rows(all_enrichments)
		combined_file <- file.path(sample_dir, "All_Structures_GO_BP.csv")
write.csv(combined_go, combined_file, row.names = FALSE)

# 将富集结果添加到Seurat对象
seurat_obj@misc$GO_BP_Enrichment <- all_enrichments
RCTD_list[[obj_name]] <- seurat_obj
	}
}

# 保存更新后的RCTD_list
saveRDS(RCTD_list, file.path(output_dir, "RCTD_list_with_GO.rds"))

# 清理内存
rm(all_enrichments, combined_go, degs, sig_degs, go_enrich, go_result)
gc()  # 强制垃圾回收

# 重新加载数据（如果内存不足）
if (!exists("RCTD_list")) {
	RCTD_list <- readRDS(file.path(output_dir, "RCTD_list_with_GO.rds"))
}

# 加载必要的包
library(ggplot2)
library(dplyr)
library(tidyr)

# 为每个样本创建合并气泡图
for (obj_name in names(RCTD_list)) {
	seurat_obj <- RCTD_list[[obj_name]]
	sample_dir <- file.path(output_dir, obj_name)
	
	# 检查是否有富集结果
	if (!is.null(seurat_obj@misc$GO_BP_Enrichment)) {
		all_enrichments <- seurat_obj@misc$GO_BP_Enrichment
		
		# 合并所有结构区域的富集结果
		combined_go <- bind_rows(all_enrichments)
		
		# 如果没有结果，跳过
		if (nrow(combined_go) == 0) next
		
		# 为每个结构选择前5个最显著的GO term
		top_go_terms <- combined_go %>%
			group_by(Structure) %>%
			arrange(p.adjust) %>%
			slice_head(n = 5) %>%
			ungroup() %>%
			# 添加区域分隔信息
			mutate(Region = Structure)
		
		# 创建合并气泡图
		# 创建合并气泡图（美化版）
		p_combined <- ggplot(top_go_terms, aes(x = Region, y = Description)) +
			# 气泡点
			geom_point(aes(size = Count, fill = -log10(p.adjust)), 
								 shape = 21, color = "black", stroke = 0.3) +
			# 添加区域分隔线
			geom_vline(
				xintercept = seq(1.5, length(unique(top_go_terms$Region)) - 0.5, by = 1),
				color = "grey50",
				linetype = "dashed",
				size = 0.5
			) +
			# 尺寸和颜色比例
			scale_size_continuous(
				name = "Gene Count",
				range = c(3, 10),
				breaks = scales::pretty_breaks(n = 4)
			) +
			scale_fill_gradientn(
				name = "-log10(Adj.P)",
				colors = c("#4575B4", "#74ADD1", "#FFFFBF", "#F46D43", "#D73027")
			) +
			# 坐标轴和标题
			labs(
				title = paste("Top GO_BP Terms by Structure in", obj_name),
				subtitle = "Each structure shows top 5 enriched pathways",
				x = "Spatial Structure",
				y = "GO Biological Process"
			) +
			# 主题设置 - 主要变更在这里
			theme_bw(base_size = 12) +  # 使用带边框的主题
			theme(
				plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
				plot.subtitle = element_text(hjust = 0.5, size = 12),
				axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 11),
				axis.text.y = element_text(size = 10),
				axis.title.x = element_text(face = "bold", size = 13, margin = margin(t = 10)),
				axis.title.y = element_text(face = "bold", size = 13, margin = margin(r = 10)),
				# 移除所有网格线
				panel.grid.major = element_blank(),
				panel.grid.minor = element_blank(),
				# 增强边框效果
				panel.border = element_rect(color = "black", size = 1),
				# 图例设置
				legend.position = "right",
				legend.box = "vertical"
			) +
			# 确保所有区域都显示
			scale_x_discrete(drop = FALSE)
		
		# 保存合并气泡图
		combined_file <- file.path(sample_dir, "Combined_GO_Bubble.pdf")
ggsave(combined_file, p_combined, width = 10, height = 14)

# 输出消息
message(paste("Created combined bubble plot for", obj_name, "with", 
							length(unique(top_go_terms$Region)), "structures"))
	}
}