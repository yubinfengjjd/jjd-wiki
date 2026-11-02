# 加载必要的包
library(limma)   # 用于基因表达数据分析，提供avereps函数处理重复基因
library(sva)     # 包含ComBat函数，用于校正批次效应

# 设置工作目录和输入文件
geneFile <- "intersectGenes.txt"        # 指定包含目标基因列表的文件
setwd("D:\\UC-20种修饰\\6.GMM-LR")  # 设置工作路径

# 获取当前目录下所有以"normalize.txt"结尾的文件名
files <- dir()
files <- grep("normalize.txt$", files, value = TRUE)
geneList <- list()  # 初始化列表，用于存储各文件的唯一基因名

# 遍历所有文件，提取每个文件中的唯一基因名并存入geneList
for (file in files) {
	rt <- read.table(file, header = TRUE, sep = "\t", check.names = FALSE)
	geneNames <- as.vector(rt[, 1])  # 提取第一列基因名
	uniqGene <- unique(geneNames)    # 去除重复基因名
	header <- unlist(strsplit(file, "\\.|\\-"))  # 分割文件名获取数据集标识
	geneList[[header[1]]] <- uniqGene  # 以数据集标识为键存储基因列表
}

# 计算所有数据集的共有基因交集
interGenes <- Reduce(intersect, geneList)

# 合并所有数据集并进行批次效应校正
allTab <- data.frame()  # 初始化合并后的表达矩阵
batchType <- c()        # 记录每个样本的批次来源

for (i in seq_along(files)) {
	inputFile <- files[i]
	header <- unlist(strsplit(inputFile, "\\.|\\-"))  # 解析文件名
	
	# 读取并处理表达数据
	rt <- read.table(inputFile, header = TRUE, sep = "\t", check.names = FALSE)
	rt <- as.matrix(rt)
	rownames(rt) <- rt[, 1]  # 设置基因名为行名
	exp <- rt[, -1, drop = FALSE]  # 提取表达量数据（排除第一列基因名）
	
	# 转换数据为数值矩阵并处理重复基因（取平均值）
	dimnames <- list(rownames(exp), colnames(exp))
	data <- matrix(as.numeric(exp), nrow = nrow(exp), dimnames = dimnames)
	rt <- avereps(data)  # 对重复基因取平均表达值
	
	# 添加数据集前缀到列名（样本名）
	colnames(rt) <- paste0(header[1], "_", colnames(rt))
	
	# 按列合并表达矩阵
	if (i == 1) {
		allTab <- rt[interGenes, ]  # 仅保留共有基因
	} else {
		allTab <- cbind(allTab, rt[interGenes, ])
	}
	
	# 记录当前数据集的批次编号
	batchType <- c(batchType, rep(i, ncol(rt)))
}

# 使用ComBat校正批次效应
#svaTab <- ComBat(allTab, batchType, par.prior = TRUE)  # 参数par.prior=TRUE表示使用参数先验
svaTab = allTab
# 根据目标基因列表筛选并转置矩阵（样本为行，基因为列）
geneRT <- read.table(geneFile, header = FALSE, sep = "\t", check.names = FALSE)
geneTab <- svaTab[intersect(rownames(svaTab), geneRT[, 1]), ]  # 保留目标基因
geneTab <- t(geneTab)  # 转置矩阵

#####按比例划分训练集测试集####
# 划分训练集和测试集（在merge数据集内部分为7:3）
merge_samples <- grepl("^merge", rownames(geneTab), ignore.case = TRUE)  # 识别merge样本
merge_data <- geneTab[merge_samples, ]  # 提取merge数据

# 设置随机种子保证可重复性
set.seed(2025)
# 生成随机索引
train_indices <- sample(1:nrow(merge_data), size = round(0.7 * nrow(merge_data)))
test_indices <- setdiff(1:nrow(merge_data), train_indices)

# 创建训练集和测试集
trainExp <- merge_data[train_indices, , drop = FALSE]
testExp <- merge_data[test_indices, , drop = FALSE]

#####处理样本标签：将行名中的"Control"标记为0，其他为1#####
allType <- gsub("(.*)\\_(.*)", "\\2", rownames(geneTab))  # 提取标签
trainType <- gsub("(.*)\\_(.*)", "\\2", rownames(trainExp))  # 提取标签
testType <- gsub("(.*)\\_(.*)", "\\2", rownames(testExp))    # 同上
allType <- ifelse(allType == "control", 0, 1)  # 转换为二进制标签
trainType <- ifelse(trainType == "control", 0, 1)  # 转换为二进制标签
testType <- ifelse(testType == "control", 0, 1)

# 添加标签列并输出数据
allExp <- cbind(geneTab, Type = allType)
trainExp <- cbind(trainExp, Type = trainType)
testExp <- cbind(testExp, Type = testType)

# 写入训练集和测试集文件（包含标题行）
allOut <- rbind(id = colnames(allExp), allExp)  # 添加列名作为首行
write.table(allOut, file = "data.all.txt", sep = "\t", quote = FALSE, col.names = FALSE)
trainOut <- rbind(id = colnames(trainExp), trainExp)  # 添加列名作为首行
write.table(trainOut, file = "data.train.txt", sep = "\t", quote = FALSE, col.names = FALSE)
testOut <- rbind(id = colnames(testExp), testExp)
write.table(testOut, file = "data.test.txt", sep = "\t", quote = FALSE, col.names = FALSE)

#####GMM_LR####
library(caret)
library(pROC)
library(doParallel)
setwd("D:\\UC-20种修饰\\6.GMM-LR")
rm(list = ls())
# 读取数据
data_file <- "data.train.txt"
if (!file.exists(data_file)) {
	stop("Data file does not exist!")
}
surv.expr <- read.table(data_file, sep = "\t", row.names = 1, 
												stringsAsFactors = FALSE, check.names = FALSE, header = TRUE)
colnames(surv.expr) <- gsub("-", "_", colnames(surv.expr))

# 设置响应变量
response_variable <- "Type"

#将响应变量转换为因子并修复水平名称
surv.expr[[response_variable]] <- as.factor(surv.expr[[response_variable]])
levels(surv.expr[[response_variable]]) <- make.names(levels(surv.expr[[response_variable]]))

# 验证水平名称
cat("修复后的响应变量水平:\n")
print(levels(surv.expr[[response_variable]]))

ctrl <- trainControl(
	method = "cv",         # 交叉验证
	number = 5,            # 5折交叉验证
	savePredictions = "final",
	classProbs = TRUE,     # 需要概率预测
	summaryFunction = twoClassSummary,  # 用于二分类
	allowParallel = TRUE   # 允许并行
)
# 准备数据
predictors <- colnames(surv.expr)[colnames(surv.expr) != response_variable]
response <- surv.expr[[response_variable]]

# 检查因子水平
if (length(levels(surv.expr[[response_variable]])) != 2) {
	stop("响应变量必须是二分类因子")
}

# 生成所有可能的特征组合
generate_combinations <- function(predictors) {
	n <- length(predictors)
	all_combinations <- unlist(
		lapply(1:n, function(k) combn(predictors, k, simplify = FALSE)),
		recursive = FALSE
	)
	return(all_combinations)
}

feature_combinations <- generate_combinations(predictors)
n.model <- length(feature_combinations)

# 自定义进度显示函数
display.progress <- function(index, totalN, breakN = 20) {
	if (index %% ceiling(totalN / breakN) == 0) {
		cat(paste(round(index * 100 / totalN), "% ", sep = ""))
	}
}

run_models_caret <- function(feature_combinations, data, response_var) {
	aucDF <- data.frame(model = integer(), auc = numeric(), 
											n.mRNA = integer(), stringsAsFactors = FALSE)
	formula_list <- list()
	model_list <- list()  # 初始化模型列表
	
	# 设置并行计算
	cl <- makePSOCKcluster(detectCores() - 1)
	registerDoParallel(cl)
	on.exit(stopCluster(cl))
	
	for (i in 1:length(feature_combinations)) {
		# 显示进度（确保已定义n.model）
		if(exists("display.progress") && exists("n.model")) {
			display.progress(i, n.model)
		}
		
		current_features <- feature_combinations[[i]]
		formula <- as.formula(paste(response_var, "~", paste(current_features, collapse = " + ")))
		formula_list[[i]] <- formula
		
		tryCatch({
			set.seed(123)
			model <- train(
				formula,
				data = data,
				method = "glm",
				family = "binomial",
				trControl = ctrl,
				metric = "ROC"
			)
			
			auc_value <- max(model$results$ROC)
			model_list[[i]] <- model  # 存储模型对象
			
			aucDF <- rbind(aucDF, data.frame(
				model = i,
				auc = auc_value,
				n.mRNA = length(current_features)
			))
		}, error = function(e) {
			message("\n模型 ", i, " 出错: ", e$message)
			model_list[[i]] <- NULL  # 出错时存储NULL
			
			aucDF <- rbind(aucDF, data.frame(
				model = i,
				auc = NA,
				n.mRNA = length(current_features)
			))
		})
	}
	
	# 返回包含三个元素的列表
	return(list(
		aucDF = aucDF,
		formula_list = formula_list,
		model_list = model_list
	))
}

# 运行函数
results <- run_models_caret(feature_combinations, surv.expr, response_variable)

# 提取结果
aucDF <- results$aucDF
formula_list <- results$formula_list
model_list <- results$model_list

#####高斯混合模型聚类####
library(pROC)
library(mclust)
library(lares)
mod <- Mclust(aucDF[, 1:2])
aucDF$mclust <- as.numeric(mod$classification)
table(aucDF$mclust)

# 保存结果
write.table(aucDF, "all_models_with_GMM_clusters.txt", sep = "\t", row.names = FALSE, quote = FALSE)

col.cluster <- c('#1C79B7', '#F38329', '#2DA248', '#DC403E', 
								 '#976BA6', '#8D574C',"#DC4055","#F38367","#2DA788")

pdf("GMM_cluster_of_all_auc_model_combination.pdf", width = 7, height = 6)
par(bty = "o", mgp = c(2, 0.5, 0), mar = c(3.1, 4.1, 1.1, 1.1), tcl = -.25, las = 1)

# 绘制主图
plot(mod, what = "classification", 
		 colors = col.cluster[1:mod$G],  # 仅使用实际聚类数的颜色
		 xlab = paste0("Sorted logistic regression models (1:", n.model, ")"), 
		 ylab = "")
mtext("Training models", side = 2, line = 2.5, las = 3)

# 添加自定义图例（右下角）
legend(
	"bottomright",   # 修改为右下角
	legend = paste("Cluster", 1:mod$G),  
	col = col.cluster[1:mod$G],          
	pch = 16,        
	pt.cex = 1.5,    
	cex = 0.8,       
	bty = "n",       
	title = "GMM Clusters"   
)

dev.off()

#####AUC山脊图#####
library(RColorBrewer)
library(ggplot2)
library(ggridges)
library(RColorBrewer)
# 清洗auc列的字符串污染
aucDF$auc <- gsub("Area under the curve: ", "", aucDF$auc) %>% 
	as.numeric()

# 验证数据类型
str(aucDF$auc)  # 应显示为 num
aucDF$mclust = as.factor(aucDF$mclust)
pdf("custom_ridgeline.pdf",width = 6,height = 8)
ggplot(aucDF, aes(x = auc, y = mclust, fill = ..density..)) +
	geom_density_ridges_gradient(scale = 1, rel_min_height = 0, size = 1) + 
	scale_fill_gradientn(colours = colorRampPalette(rev(brewer.pal(11,"Spectral")))(32)) +
	theme(
		# 移除默认的坐标轴线和刻度
		axis.line = element_blank(),
		axis.ticks = element_blank(),
		# 添加围绕绘图区域的矩形边框（替代坐标轴）
		panel.border = element_rect(color = "black", size = 1.5, fill = NA),
		# 可选：移除背景网格线，使边框更明显
		panel.grid = element_blank()
	)
dev.off()

##### 曲线图 ####
library(ggplot2)
library(ggridges)
library(patchwork)

plot_cluster_auc_with_density <- function(aucDF, clusters, outdir = ".") {
	if (!dir.exists(outdir)) dir.create(outdir)
	
	for (cluster_num in clusters) {
		# === 提取 cluster 数据 ===
		cluster_data <- subset(aucDF, mclust == cluster_num)
		cluster_data$auc <- as.numeric(gsub("Area under the curve: ", "", cluster_data$auc))
		cluster_data <- cluster_data[order(-cluster_data$auc), ]
		cluster_data$rank <- 1:nrow(cluster_data)
		
		# === 主图：AUC 排名曲线 ===
		p_auc = ggplot(cluster_data, aes(x = auc, y = rank)) +
			geom_segment(
				aes(
					x = min(cluster_data$auc),  # 从x=0开始
					xend = max(cluster_data$auc), 
					y = 0, 
					yend = 0
				),size = 2) +
			geom_ribbon(
				aes(ymin = 0, ymax = rank),  # 从 y=0 开始填充
				fill = "#ffe7c5", 
				alpha = 0.5
			) +
			geom_smooth(se = FALSE, color = "#eba85b", size = 2.5, span = 0.4) +
			geom_point(
				data = cluster_data[which.max(cluster_data$auc), ], 
				aes(x = auc, y = 0), 
				color = "#a3570b", 
				size = 6
			) +
			annotate(
				"text", 
				x = cluster_data[which.max(cluster_data$auc), "auc"], 
				y = cluster_data[which.max(cluster_data$auc), "rank"]+0.03*nrow(cluster_data), 
				label = round(max(cluster_data$auc), 4), 
				color = "#a0570d", 
				size = 6
			) +
			# 坐标轴修正
			scale_y_continuous(
				trans = "reverse",
				expand = expansion(mult = c(0.05, 0.05))
			) +
			scale_x_continuous(
				limits = c(min(cluster_data$auc), max(cluster_data$auc) + 0.005),
				expand = c(0, 0)
			) +
			labs(
				x = "AUC Value",
				y = "Model Rank (Descending)",
				title = paste0("AUC Ranking of Cluster ",cluster_num," Models"),
				subtitle = paste0(nrow(cluster_data),"Models Ordered by AUC (Highest to Lowest)")
			) +
			theme_minimal() +
			theme(
				plot.background = element_blank(),
				panel.grid = element_blank(),
				panel.border = element_rect(color = "black", size = 2, fill = NA),
				axis.text = element_text(color = "black"),
				plot.title = element_text(hjust = 0.5, face = "bold"),
				plot.subtitle = element_text(hjust = 0.5, color = "grey40")
			)
		
		# === 左侧密度数据 + 山脊图 ===
		dens <- density(cluster_data$auc)
		ridge_df <- data.frame(x = dens$x, height = dens$y, y = 1)
		
		p_ridge <- ggplot(ridge_df, aes(x = x, y = y, height = height)) +
			geom_ridgeline(fill = "grey80", color = "grey40", alpha = 0.7, scale = 0.9) +
			annotate("text",
							 x = min(cluster_data$auc), y = 1.2,
							 label = paste0(nrow(cluster_data), " models"),
							 hjust = 0, size = 4.5, fontface = "bold"
			) +
			theme_void() +
			theme(
				plot.margin = margin(0, 0, 0, 0),
				panel.border = element_blank()
			)
		
		# === 拼图输出 ===
		final_plot <- p_ridge + p_auc + plot_layout(ncol = 2, widths = c(2, 4))
		
		ggsave(
			filename = file.path(outdir, paste0("cluster_auc_C", cluster_num, ".pdf")),
			plot = final_plot,
			width = 6, height = 8
		)
	}
}
plot_cluster_auc_with_density(aucDF, clusters = c(4), outdir = "cluster_auc_plots")

#####筛选最佳模型#####
# 提取cluster4中的模型
cluster4_models <- subset(aucDF, mclust == 4)
best_model_row <- cluster4_models[which.max(cluster4_models$auc), ]
best_model_index <- best_model_row$model
best_model_formula <- formula_list[[best_model_index]]
# 提取公式中的变量
all_vars <- all.vars(best_model_formula)
model_mRNA <- setdiff(all_vars, response_variable)
model_mRNA = gsub("_","-",model_mRNA)
# 保存筛选到的mRNA
write.table(model_mRNA, "output_mRNA_selected.txt", row.names = FALSE, col.names = T,sep = "\t",quote = F)

final_model = model_list[[best_model_index]]

#####ROC####
# 生成预测概率
train_prob <- predict(final_model, newdata = surv.expr, type = "prob")
positive_class_prob <- train_prob[["X1"]]
# 创建ROC对象
library(pROC)

# 生成ROC对象
roc_obj <- roc(
	response = surv.expr[[response_variable]],
	predictor = positive_class_prob
)

# 计算AUC的置信区间（建议至少2000次bootstrap）
set.seed(2025)
auc_ci <- ci.auc(roc_obj, method = "bootstrap", boot.n = 2000)

# 计算敏感性和特异性的置信区间（耗时操作，按需调整boot.n）
sp_ci <- ci.sp(roc_obj, sensitivities = seq(0, 1, 0.01), boot.n = 2000, progress = "none")

# 创建更专业的ROC曲线图
pdf("Best_Model_Training_ROC.pdf", width = 7, height = 6)
par(mar = c(4.5, 4.5, 2, 2), mgp = c(2.5, 1, 0))

# 绘制基础ROC曲线
plot(roc_obj,
		 print.auc = FALSE,  # 禁用默认AUC显示
		 grid = c(0.2, 0.2), # 更精细的网格线
		 grid.col = "lightgray",
		 legacy.axes = TRUE,
		 xlab = "False Positive Rate (1 - Specificity)",
		 ylab = "True Positive Rate (Sensitivity)",
		 main = "ROC Curve For Train Set",
		 col = "#2c7fb8",
		 lwd = 2)

# 添加敏感性和特异性的置信区间
plot(sp_ci, 
		 type = "shape", 
		 col = alpha("#5bd1d7", 0.3), # 使用透明度
		 border = NA)

# 添加AUC文本注释
auc_text <- sprintf("AUC = %.3f (95%% CI: %.3f-%.3f)", 
										auc(roc_obj), 
										auc_ci[1], 
										auc_ci[3])
text(x = 0.6, y = 0.2,  # 调整文本位置
		 labels = auc_text,
		 col = "#2c7fb8",
		 cex = 1.2)


# 添加图例
legend("bottomright",
			 legend = c("ROC Curve", "95% Confidence Band"),
			 col = c("#2c7fb8", alpha("#5bd1d7", 0.3)),
			 lwd = c(2, 10),
			 bty = "n",
			 cex = 0.9)

dev.off()

#####测试集####
test.expr <- read.table("./data.test.txt", sep = "\t", row.names = 1, stringsAsFactors = FALSE, check.names = FALSE, header = TRUE)
colnames(test.expr) = gsub("-","_",colnames(test.expr))
# 生成预测概率
test_prob <- predict(final_model, type = "prob",newdata = test.expr)
auc_test <- auc(response = test.expr$Type, predictor = test_prob[["X1"]])
# 创建ROC对象
library(pROC)

# 生成ROC对象
roc_obj <- roc(
	response = test.expr[[response_variable]],
	predictor = test_prob[["X1"]]
)

# 计算AUC的置信区间（建议至少2000次bootstrap）
set.seed(123)
auc_ci <- ci.auc(roc_obj, method = "bootstrap", boot.n = 2000)

# 计算敏感性和特异性的置信区间（耗时操作，按需调整boot.n）
sp_ci <- ci.sp(roc_obj, sensitivities = seq(0, 1, 0.01), boot.n = 2000, progress = "none")

# 创建更专业的ROC曲线图
pdf("Best_Model_Testing_ROC.pdf", width = 7, height = 6)
par(mar = c(4.5, 4.5, 2, 2), mgp = c(2.5, 1, 0))

# 绘制基础ROC曲线
plot(roc_obj,
		 print.auc = FALSE,  # 禁用默认AUC显示
		 grid = c(0.2, 0.2), # 更精细的网格线
		 grid.col = "lightgray",
		 legacy.axes = TRUE,
		 xlab = "False Positive Rate (1 - Specificity)",
		 ylab = "True Positive Rate (Sensitivity)",
		 main = "ROC Curve For Test Set",
		 col = "#2c7fb8",
		 lwd = 2)

# 添加敏感性和特异性的置信区间
plot(sp_ci, 
		 type = "shape", 
		 col = alpha("#5bd1d7", 0.3), # 使用透明度
		 border = NA)

# 添加AUC文本注释
auc_text <- sprintf("AUC = %.3f (95%% CI: %.3f-%.3f)", 
										auc(roc_obj), 
										auc_ci[1], 
										auc_ci[3])
text(x = 0.6, y = 0.2,  # 调整文本位置
		 labels = auc_text,
		 col = "#2c7fb8",
		 cex = 1.2)


# 添加图例
legend("bottomright",
			 legend = c("ROC Curve", "95% Confidence Band"),
			 col = c("#2c7fb8", alpha("#5bd1d7", 0.3)),
			 lwd = c(2, 10),
			 bty = "n",
			 cex = 0.9)

dev.off()

#####SHAP####
# === 加载必要库 ===
library(caret)       # 模型训练
library(pROC)        # ROC分析
library(ggplot2)     # 画图
library(shapviz)     # SHAP可视化
library(kernelshap)  # 计算 SHAP

# === 自定义预测函数（返回正类概率） ===
pred_fun <- function(model, newdata) {
	prob_matrix <- predict(model, newdata = newdata, type = "prob")
	return(as.numeric(prob_matrix[, 2]))  # 二分类任务：返回正类概率
}

# === 构造模型输入数据（X） ===
X <- as.data.frame(test.expr[, model_mRNA])
X <- X[, colnames(X) != "(Intercept)"]  # 可选：去掉多余列（如果有）

# === 计算 SHAP 值 ===
shap_values <- kernelshap(
	object = final_model,
	X = X,
	pred_fun = pred_fun
)

# === 创建 shapviz 对象，确保特征顺序匹配 ===
X <- X[, colnames(shap_values$S)]  # 强制列名一致顺序
shap_vis <- shapviz(shap_values, X = X)

# === 计算特征重要性 ===
feature_importance <- colMeans(abs(shap_values$S))
sorted_features <- names(sort(feature_importance, decreasing = TRUE))

# === 可视化主题设置 ===
visualization_theme <- theme_minimal() +
	theme(
		plot.title = element_text(face = "bold", size = 14),
		axis.title = element_text(size = 12)
	)

# === 1. 特征重要性柱状图（全局解释） ===
pdf("2_SHAP_Feature_Importance_Barplot.pdf", width = 8, height = 6)
sv_importance(shap_vis, kind = "bar", show_numbers = TRUE) +
	visualization_theme +
	labs(
		title = "Feature Importance (Mean Absolute SHAP)",
		subtitle = "Average impact magnitude of each feature on model predictions",
		x = "Mean |SHAP value|",
		y = "Feature",
		caption = "Bar height indicates feature importance, with value showing mean absolute SHAP"
	)
dev.off()

# === 2. 蜂群图（特征效应分布） ===
pdf("3_SHAP_BeeSwarm_Plot.pdf", width = 9, height = 7)
sv_importance(shap_vis, kind = "bee", show_numbers = TRUE) +
	visualization_theme +
	labs(
		title = "SHAP Value Distribution (Bee Swarm)",
		subtitle = "Each point represents one sample, color indicates feature value",
		x = "SHAP value (impact on model output)",
		y = "Feature",
		caption = "Red: high feature values | Blue: low feature values | Horizontal spread: direction of effect"
	)
dev.off()

# === 3. 特征依赖图（修复颜色图例错位问题） ===
for (feat in sorted_features[1:3]) {
	pdf(paste0("4_SHAP_Feature_Dependence_fixe_",feat,".PDF"), width = 6, height = 6)
	p <- sv_dependence(
		object = shap_vis,
		feature = feat,
		v = feat,
		jitter_width = 0.2
	) +
		labs(
			title = paste("SHAP Dependence Plot:", feat),
			color = feat
		)
	print(p)  # 强制打印单图
	dev.off()
}

# 瀑布图（单个样本解释）
pdf("5_SHAP_Sample_Waterfall_treat.pdf", width=9, height=6)
sv_waterfall(shap_vis, row_id=124) +  # Explaining sample #2
	labs(
		title = "Prediction Breakdown (Waterfall Plot)",
		subtitle = "Cumulative contribution of features to final prediction",
		caption = "E[f(x)] = base value | f(x) = model output\nBar length: feature contribution | Direction: sign of effect"
	)
dev.off()

pdf("5_SHAP_Sample_Waterfall_control.pdf", width=9, height=6)
sv_waterfall(shap_vis, row_id=5) +  # Explaining sample #2
	labs(
		title = "Prediction Breakdown (Waterfall Plot)",
		subtitle = "Cumulative contribution of features to final prediction",
		caption = "E[f(x)] = base value | f(x) = model output\nBar length: feature contribution | Direction: sign of effect"
	)
dev.off()
# 单样本力图（特征贡献可视化）
pdf("6_SHAP_Force_Plot_treat.pdf", width=10, height=6)
sv_force(shap_vis, row_id=115) +  # Analyzing sample #2
	labs(
		title = "Feature Contributions (Force Plot)",
		subtitle = "Visual forces pushing prediction from base value to output"
	)
dev.off()

pdf("6_SHAP_Force_Plot_control.pdf", width=10, height=6)
sv_force(shap_vis, row_id=5) +  # Analyzing sample #2
	labs(
		title = "Feature Contributions (Force Plot)",
		subtitle = "Visual forces pushing prediction from base value to output"
	)
dev.off()

#####LIME####
library(lime)
library(caret)
exp <- lime(test.expr[, model_mRNA], final_model)
explaintion <- lime::explain(test.expr[, model_mRNA][5, , drop = FALSE],
														 explainer = exp,
														 n_labels = 2,
														 n_features = 6)
pdf("6_LIME_Plot_control.pdf", width=12, height=6)
plot_features(explaintion)
dev.off()

explaintion <- lime::explain(test.expr[, model_mRNA][115, , drop = FALSE],
														 explainer = exp,
														 n_labels = 2,
														 n_features = 6)
pdf("6_LIME_Plot_treat.pdf", width=12, height=6)
plot_features(explaintion)
dev.off()