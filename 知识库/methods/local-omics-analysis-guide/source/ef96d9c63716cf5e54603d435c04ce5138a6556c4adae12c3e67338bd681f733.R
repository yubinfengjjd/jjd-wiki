######芯片数据处理流程####
# 定义数据集文件名和名称
library(GEOquery)
library(tidyverse)
library(limma)
library(org.Hs.eg.db)
library(patchwork)
library(WGCNA)
library(GSEABase)
library(randomcoloR)
library(AnnoProbe)
library(dplyr)
setwd("D:\\UC乳酸化\\1.bulk数据下载")
files <- list.files("./series/", pattern = "*.txt", full.names = TRUE)
names <- gsub("(.*)_(.*)_(.*)\\.gz", "\\1", basename(files))
# 初始化列表
gsets <- list()
pds <- list()
exprSets <- list()

# 循环处理每个数据集
for (i in 1:length(files)) {
	file_path <- files[i]
	
	if (!file.exists(file_path)) {
		warning(paste("文件不存在:", file_path))
		next
	}
	
	gset <- tryCatch({
		getGEO(filename = file_path, getGPL = F)
	}, error = function(e) {
		warning(paste("获取GEO数据集时出错:", file_path, "错误信息:", e$message))
		return(NULL)
	})
	
	if (is.null(gset)) next
	
	if (is.list(gset)) {
		gset <- exprs(gset)
	}
	
	gsets[[names[i]]] <- gset
	
	pdata <- tryCatch({
		pData(gset)
	}, error = function(e) {
		warning(paste("提取表型数据时出错:", names[i], "错误信息:", e$message))
		return(NULL)
	})
	
	if (is.null(pdata)) next
	
	pds[[names[i]]] <- pdata
	
	exprSet <- tryCatch({
		read.table(file_path,
							 comment.char = "!",
							 stringsAsFactors = FALSE,
							 header = TRUE)
	}, error = function(e) {
		warning(paste("读取表达数据时出错:", file_path, "错误信息:", e$message))
		return(NULL)
	})
	
	if (is.null(exprSet)) next
	
	rownames(exprSet) <- exprSet[,1]
	exprSet <- exprSet[,-1]
	
	ex <- exprSet
	qx <- as.numeric(quantile(ex, c(0., 0.25, 0.5, 0.75, 0.99, 1.0), na.rm = TRUE))
	LogC <- (qx[5] > 100) ||
		(qx[6] - qx[1] > 50 && qx[2] > 0) ||
		(qx[2] > 0 && qx[2] < 1 && qx[4] > 1 && qx[4] < 2)
	
	if (LogC) {
		ex[ex <= 0] <- NaN
		exprSet <- log2(ex)
		print("log2 transform finished")
	} else {
		# 如果 LogC 为 FALSE，执行这个块的代码（如果需要）
		print("LogC is FALSE, no transformation performed")
	}
	#exprSet=normalizeBetweenArrays(exprSet)
	exprSet <- as.data.frame(exprSet)
	exprSets[[names[i]]] <- exprSet
}

for (dataset_name in names) {
	assign(paste0("gset_", dataset_name), gsets[[dataset_name]])
	assign(paste0("pdata_", dataset_name), pds[[dataset_name]])
	assign(paste0("exprSet_", dataset_name), exprSets[[dataset_name]])
}

names=names[names%in%names(exprSets)]

# 示例：打印处理后的数据集信息
for (dataset_name in names) {
	cat("数据集:", dataset_name, "\n")
	if (dataset_name %in% names(pds)) {
		cat("表型数据行数:", nrow(get(paste0("pdata_", dataset_name))), "\n")
	} else {
		cat("表型数据: 未找到\n")
	}
	cat("表达数据行数:", nrow(get(paste0("exprSet_", dataset_name))), ", 列数:", ncol(get(paste0("exprSet_", dataset_name))), "\n\n")
}
######清洗注释文件####
#index_GSE43696 <- gset_GSE43696@annotation
#index_GSE67472 = gset_GSE67472@annotation
anno_df_570=data.table::fread("./GPL570-55999.txt",data.table = F,skip = 16)
anno_df_6244=data.table::fread("./GPL6244-17930.txt",data.table = F)
anno_df_13158=data.table::fread("./GPL13158-5065.txt",data.table = F,skip = 16)
anno_df_15207=data.table::fread("./GPL15207-17536.txt",data.table = F,skip = 16)
######\\\型####
anno_df_570 <- anno_df_570 %>%
	mutate(`Gene Symbol` = str_replace_all(`Gene Symbol`, "---", "")) %>%
	filter(`Gene Symbol` != "") %>%
	separate(`Gene Symbol`, into = c("Gene Symbol","drop"), sep = "///") %>%
	mutate(`Gene Symbol` = str_replace_all(`Gene Symbol`, " ", "")) %>%
	dplyr::select(ID, `Gene Symbol`)
names(anno_df_570) <- c("probe_id", "symbol")
anno_df_570$probe_id=as.character(anno_df_570$probe_id)

anno_df_15207 <- anno_df_15207 %>%
	mutate(`Gene Symbol` = str_replace_all(`Gene Symbol`, "---", "")) %>%
	filter(`Gene Symbol` != "") %>%
	separate(`Gene Symbol`, into = c("Gene Symbol","drop"), sep = "///") %>%
	mutate(`Gene Symbol` = str_replace_all(`Gene Symbol`, " ", "")) %>%
	dplyr::select(ID, `Gene Symbol`)
names(anno_df_15207) <- c("probe_id", "symbol")
anno_df_15207$probe_id=as.character(anno_df_15207$probe_id)
######\\型####
anno_df_6244 <- anno_df_6244 %>%
	mutate(gene_assignment = str_replace_all(gene_assignment, "---", "")) %>%
	filter(gene_assignment != "") %>%
	separate(gene_assignment, into = c("drop1","Gene Symbol", "drop2"), sep = "//") %>%
	mutate(`Gene Symbol` = str_replace_all(`Gene Symbol`, " ", "")) %>%
	dplyr::select(ID, `Gene Symbol`)

names(anno_df_6244) <- c("probe_id", "symbol")
anno_df_6244$probe_id=as.character(anno_df_6244$probe_id)

######无\\型####
anno_df_13158 <- anno_df_13158 %>%
	mutate(`Gene Symbol` = str_replace_all(`Gene Symbol`, "---", "")) %>%
	filter(`Gene Symbol` != "") %>%
	mutate(`Gene Symbol` = str_replace_all(`Gene Symbol`, " ", "")) %>%
	dplyr::select(ID, `Gene Symbol`)

names(anno_df_13158) <- c("probe_id", "symbol")
anno_df_13158$probe_id=as.character(anno_df_13158$probe_id)
dataset_list <- list(
	list(expr = exprSet_GSE38713, anno = anno_df_570),
	list(expr = exprSet_GSE47908, anno = anno_df_570),
	list(expr = exprSet_GSE73661, anno = anno_df_6244),
	list(expr = exprSet_GSE75214, anno = anno_df_6244),
	list(expr = exprSet_GSE126124, anno = anno_df_6244),
	list(expr = exprSet_GSE87466, anno = anno_df_13158),
	list(expr = exprSet_GSE107499, anno = anno_df_15207)
)
names(dataset_list) = c("exprSet_GSE38713","exprSet_GSE47908","exprSet_GSE73661","exprSet_GSE75214",
												"exprSet_GSE126124","exprSet_GSE87466","exprSet_GSE107499")
process_exprset <- function(expr, anno) {
	expr %>%
		tibble::rownames_to_column("probe_id") %>%
		dplyr::inner_join(anno, by = "probe_id") %>%
		dplyr::select(-probe_id) %>%
		dplyr::select(symbol, dplyr::everything()) %>%
		dplyr::mutate(rowMean = rowMeans(.[, -1])) %>%
		dplyr::arrange(dplyr::desc(rowMean)) %>%
		dplyr::distinct(symbol, .keep_all = TRUE) %>%
		dplyr::select(-rowMean) %>%
		tibble::column_to_rownames("symbol")
}

# 2. 处理数据（保持原有名称）
processed_exprs <- lapply(dataset_list, function(x) process_exprset(x$expr, x$anno))

# 3. 保存表达矩阵到文件
if (!dir.exists("expr_data")) dir.create("expr_data", recursive = TRUE)

# 遍历处理后的数据
for (gse_id in names(processed_exprs)) {
	# 生成文件名（格式：exprSet_GSEXXXX_processed.txt）
	file_name <- paste0(gse_id, ".txt")
	
	# 获取当前数据集
	exprSet <- processed_exprs[[gse_id]]
	
	# 添加ID列并保存
	write.table(cbind(ID = rownames(exprSet), exprSet),
							file = file.path("expr_data", file_name),
							sep = "\t", quote = FALSE, row.names = FALSE)
	
	cat("成功保存:", file_name, "\n")
}

# 保存表达数据框和表型数据框的名称
pdata_names <- paste0("pdata_", names)
if (!dir.exists("pdata")) dir.create("pdata", recursive = TRUE)

# 保存表型数据框
for (name in pdata_names) {
	pdata <- get(name)
	file_name <- paste0(name, ".txt")
	write.table(cbind(ID=rownames(pdata),pdata), file = file.path("pdata",file_name), sep = "\t", quote = FALSE, row.names = F)
	cat("保存了表型数据:", file_name, "\n")
}

#####分组####
######读入#####
# 读取表达矩阵
rm(list=ls())
if (!dir.exists("nor")) dir.create("nor", recursive = TRUE)
exp_files <- list.files("./expr_data/", pattern = "*.txt", full.names = TRUE)
exp_data_list <- lapply(exp_files, function(file) {
	# 获取文件名后缀作为对象名称
	object_name <- gsub(".*_(.*)\\.txt", "\\1", basename(file))
	assign(object_name, read.table(file, sep="\t", header=TRUE, check.names=FALSE, row.names=1), envir = .GlobalEnv)
})

# 读取临床数据
pdata_files <- list.files("./pdata", pattern = "*.txt", full.names = TRUE)
pdata_data_list <- lapply(pdata_files, function(file) {
	# 获取文件名后缀作为对象名称
	object_name <- gsub(".*_(.*)\\.txt", "\\1", basename(file))
	assign(paste0("geo_cli_", object_name), data.table::fread(file, sep="\t", header=TRUE, check.names=FALSE), envir = .GlobalEnv)
})


######定义分组####
group_GSE107499 <- ifelse(str_detect(geo_cli_GSE107499$`tissue state:ch1`,"Non-lesional"), "Con",
												 "Treat")
geo_cli_GSE126124 <- geo_cli_GSE126124[str_detect(geo_cli_GSE126124$title, "control|ulcerative colitis"),]
group_GSE126124 <- ifelse(str_detect(geo_cli_GSE126124$title,"control"), "Con",
												 "Treat")
group_GSE38713 <- ifelse(str_detect(geo_cli_GSE38713$source_name_ch1,"control"), "Con",
												 "Treat")
group_GSE47908 <- ifelse(str_detect(geo_cli_GSE47908$title,"Control"), "Con",
												 "Treat")
geo_cli_GSE73661 <- geo_cli_GSE73661[str_detect(geo_cli_GSE73661$`week (w):ch1`, "CO|W0"),]
group_GSE73661 <- ifelse(str_detect(geo_cli_GSE73661$title,"Control"), "Con",
												 "Treat")
geo_cli_GSE75214 <- geo_cli_GSE75214[str_detect(geo_cli_GSE75214$title, "control_colon|UC_colon"),]
group_GSE75214 <- ifelse(str_detect(geo_cli_GSE75214$`disease:ch1`,"control"), "Con",
												 "Treat")
group_GSE87466 <- ifelse(str_detect(geo_cli_GSE87466$`disease:ch1`,"Normal"), "Con",
												 "Treat")
# 获取所有以 group_ 开头的变量名
group_vars <- ls(pattern = "^group_")

# 遍历每个分组变量并输出频数表
for (var in group_vars) {
	# 提取GSE编号用于输出说明
	gse_id <- gsub("group_", "", var)
	
	# 生成表格
	freq_table <- table(get(var))
	
	# 格式化输出
	cat("\n-------------------------------------\n")
	cat("Group distribution for", gse_id, "\n")
	cat("-------------------------------------\n")
	print(freq_table)
	cat("\n")
}

#####对齐样本####
# 生成映射列表（确保每个geo_cli_*对应正确的表达矩阵）
dataset_pairs <- list(
	list(geo_cli = "geo_cli_GSE126124", expr = "GSE126124"),
	list(geo_cli = "geo_cli_GSE73661", expr = "GSE73661"),
	list(geo_cli = "geo_cli_GSE75214", expr = "GSE75214")
)
process_alignment <- function(geo_cli_name, expr_name) {
	# 获取数据对象
	geo_cli <- get(geo_cli_name)
	expr <- get(expr_name)
	
	# 获取有效样本交集
	common_samples <- intersect(geo_cli$geo_accession, colnames(expr))
	
	# 样本对齐检查
	if(length(common_samples) == 0) {
		stop(paste0("No common samples between ", geo_cli_name, " and ", expr_name))
	}
	
	# 调整样本顺序
	expr <- expr[, common_samples]
	geo_cli <- geo_cli[geo_cli$geo_accession%in%common_samples, ]
	assign(expr_name, expr, envir = .GlobalEnv)
	assign(geo_cli_name, geo_cli, envir = .GlobalEnv)
	# 生成检查报告
	cat(paste0(
		"Processed ", expr_name, ":\n",
		"  Original columns: ", length(colnames(expr)), "\n",
		"  Matched samples: ", length(common_samples), "\n"
	))
}

invisible(lapply(dataset_pairs, function(pair) {
	process_alignment(pair$geo_cli, pair$expr)
}))

#####划分组别####
gse_vars <- ls(pattern = "^GSE")
exprSets <- lapply(gse_vars, get)
names(exprSets) <- gse_vars

group_vars <- ls(pattern = "^group_GSE")
groupLists <- lapply(group_vars, get)
names(groupLists) <- group_vars
exprSetNames <- gsub(".*_(.*)\\.txt", "\\1", basename(exp_files))

# 循环处理数据集
for (i in seq_along(exprSets)) {
	exprSet <- exprSets[[i]]
	groupList <- groupLists[[i]]
	
	# 初始化空数据集
	condata <- NULL
	treatdata <- NULL
	
	# 动态处理Control组
	if ("Con" %in% groupList) {
		condata <- exprSet[, which(groupList == "Con"), drop = FALSE]
		if(ncol(condata) > 0) {
			colnames(condata) <- paste0(colnames(condata), "_control")
		}
	} else {
		warning(paste("数据集", exprSetNames[i], "缺少Con组（Con）"))
	}
	
	# 动态处理Treatment组
	if ("Treat" %in% groupList) {
		treatdata <- exprSet[, which(groupList == "Treat"), drop = FALSE]
		if(ncol(treatdata) > 0) {
			colnames(treatdata) <- paste0(colnames(treatdata), "_treat")
		}
	} else {
		warning(paste("数据集", exprSetNames[i], "缺少处理组（Treat）"))
	}
	
	# 智能合并数据
	exprSet_combined <- if (!is.null(condata) && !is.null(treatdata)) {
		cbind(condata, treatdata)
	} else if (!is.null(condata)) {
		condata
	} else if (!is.null(treatdata)) {
		treatdata
	} else {
		stop(paste("数据集", exprSetNames[i], "无有效分组"))
	}
	
	# 保存结果
	output_file <- file.path("nor", paste0(exprSetNames[i], ".normalize.txt"))
	assign(exprSetNames[i], exprSet_combined)
	write.table(
		cbind(ID = rownames(exprSet_combined), exprSet_combined),
		file = output_file,
		sep = "\t",
		quote = FALSE,
		row.names = FALSE
	)
}

#####去批次#####
# 读取表达矩阵
rm(list = ls())
exp_files <- list.files("./sva/", pattern = "*.txt", full.names = TRUE)
exp_data_list <- lapply(exp_files, function(file) {
	# 获取文件名后缀作为对象名称
	object_name <- gsub(".*_(.*)\\.txt", "\\1", basename(file))
	assign(object_name, read.table(file, sep="\t", header=TRUE, check.names=FALSE, row.names=1), envir = .GlobalEnv)
})



#####表达矩阵整理####
common_genes <- Reduce(intersect, lapply(exp_data_list, rownames))

# 对每个数据集进行行过滤
exp_data_list_filtered <- lapply(exp_data_list, function(df) {
	df[common_genes, , drop = FALSE]
})

# 按列合并所有数据集
combined_data <- do.call(cbind, exp_data_list_filtered)

# 查看合并后的维度
dim(combined_data)
#####分组####
group_list <- gsub("(.*)_(.*)","\\2",colnames(combined_data))

###去批次前处理
###对分组进行处理
batchType=c(rep("GSE107499",119),rep("GSE73661",79),rep("GSE75214",108),rep("GSE87466",108))
modType=group_list
mod = model.matrix(~modType)

#绘制去批次前PCA图
library("FactoMineR")
library("factoextra")
dat.pca <- PCA(as.data.frame(t(combined_data)), graph = FALSE)
pca_plot <- fviz_pca_ind(dat.pca,
												 geom = ("point"),#仅显示"点(points)"（但不是“文本(text)”）（show "points" only (but not "text")）
												 col.ind = as.factor(batchType),
												 palette = c("#00AFBB", "#E7B800","red","green"),
												 addEllipses = TRUE, 
												 legend.title = "Groups")
pca_plot
ggsave(plot = pca_plot,filename ="prenormal_PCA.pdf")

library(sva)
bindgeo_ComBat=ComBat(dat=combined_data, batch=batchType, #使用ComBat法去批次
											mod=mod, par.prior=TRUE)

#绘制去批次后PCA图
dat.pca2 <- PCA(as.data.frame(t(bindgeo_ComBat)), graph = FALSE)
pca_plot2 <- fviz_pca_ind(dat.pca2,
													geom.ind = ("point"),#仅显示"点(points)"（但不是“文本(text)”）（show "points" only (but not "text")）
													col.ind = batchType,
													palette = c("#00AFBB", "#E7B800","red","green"),
													addEllipses = TRUE, 
													legend.title = "Groups")
pca_plot2
ggsave(plot = pca_plot2,filename ="afternormal_PCA.pdf")
write.table(file="bindgeo.txt", cbind(ID=rownames(bindgeo_ComBat),bindgeo_ComBat), sep="\t", quote=F, row.names=F)