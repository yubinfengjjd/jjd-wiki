#加载包
library(openxlsx)
library(seqinr)
library(plyr)
library(randomForestSRC)
library(glmnet)
library(plsRglm)
library(gbm)
library(caret)
library(mboost)
library(e1071)
library(BART)
library(MASS)
library(snowfall)
library(xgboost)
library(ComplexHeatmap)
library(RColorBrewer)
library(pROC)

rm(list = ls())
#设置工作目录
setwd("D:\\哮喘乳酸化单细胞开篇\\8.百种机器学习\\15.ML")
source("refer2.ML.R")

#读取训练集数据文件
Train_data <- read.table("data.train.txt", header = T, sep = "\t", check.names=F, row.names=1, stringsAsFactors=F)
Train_expr=Train_data[,1:(ncol(Train_data)-1),drop=F]
Train_class=Train_data[,ncol(Train_data),drop=F]

#读取验证集数据文件
Test_data <- read.table("data.test.txt", header=T, sep="\t", check.names=F, row.names=1, stringsAsFactors = F)
Test_expr=Test_data[,1:(ncol(Test_data)-1),drop=F]
Test_class=Test_data[,ncol(Test_data),drop=F]
Test_class$Cohort=gsub("(.*)\\_(.*)\\_(.*)", "\\1", row.names(Test_class))
Test_class=Test_class[,c("Cohort", "Type")]

#读取训练集和验证集的共同基因
comgene <- intersect(colnames(Train_expr), colnames(Test_expr))
Train_expr <- as.matrix(Train_expr[,comgene])
Test_expr <- as.matrix(Test_expr[,comgene])
Train_set = scaleData(data=Train_expr, centerFlags=T, scaleFlags=T) 
names(x = split(as.data.frame(Test_expr), f = Test_class$Cohort))
Test_set = scaleData(data = Test_expr, cohort = Test_class$Cohort, centerFlags = T, scaleFlags = T)

#读取机器学习模型列表文件
methodRT <- read.table("refer.methodLists.txt", header=T, sep="\t", check.names=F)
methods=methodRT$Model
methods <- gsub("-| ", "", methods)


#准备机器学习模型的参数
classVar = "Type"         #设置分类变量名
min.selected.var = 5      #基因数量最小值
Variable = colnames(Train_set)
preTrain.method =  strsplit(methods, "\\+")
#preTrain.method = lapply(preTrain.method, function(x) rev(x)[-1])
preTrain.method = unique(unlist(preTrain.method))


######################开始训练集数据构建机器学习模型######################
#模型构建的第一步：机器学习算法筛选变量
preTrain.var <- list()       #用于保存各算法筛选的变量
set.seed(seed = 123)         #设置随机种子
for (method in preTrain.method){
	preTrain.var[[method]] = RunML(method = method,              #机器学习算法
																 Train_set = Train_set,        #训练集的标准化数据
																 Train_label = Train_class,    #训练集的分类标签
																 mode = "Variable",            #选择运行模式(筛选变量)
																 classVar = classVar)
}
preTrain.var[["simple"]] <- colnames(Train_set)

# 清除变量名中的反引号
preTrain.var <- lapply(preTrain.var, function(vars) {
	gsub("`", "", vars)
})


### 第一步：过滤 preTrain.var 中特征数 <5 的方法 ###
# -------------------------------------------------
# 计算每个方法选出的特征数量
feature_counts <- sapply(preTrain.var, length)

# 筛选保留特征数 >=5 的方法
valid_methods <- names(feature_counts)[feature_counts >= 5]
preTrain.var_filtered <- preTrain.var[valid_methods]

# 注意保留 "simple" 方法（原始特征集）
if ("simple" %in% names(preTrain.var)) {
	preTrain.var_filtered[["simple"]] <- preTrain.var[["simple"]]
}
# -------------------------------------------------
# 生成需要排除的方法列表（被移除的方法）
excluded_methods <- setdiff(names(preTrain.var), names(preTrain.var_filtered))

# 定义判断函数：检查组合中的每个方法是否都有效
is_valid_combination <- function(method_str) {
	# 拆分组合方法（如 "Lasso+Stepglm" 拆分为 c("Lasso", "Stepglm")）
	components <- unlist(strsplit(method_str, "\\+"))
	
	# 检查每个子方法是否都存在于有效方法中
	all(components %in% names(preTrain.var_filtered))
}

# 应用判断函数过滤 methods
methods <- methods[sapply(methods, is_valid_combination)]

### 结果验证 ###
# -------------------------------------------------
# 打印过滤前后的数量变化
cat("原始方法数:", length(preTrain.var), "→ 过滤后方法数:", length(preTrain.var_filtered), "\n")
cat("原始组合数:", length(methods), "→ 过滤后组合数:", length(methods), "\n")

# 查看被排除的典型组合示例（如有）
if (length(excluded_methods) > 0) {
	excluded_examples <- methods[grep(paste(excluded_methods, collapse = "|"), methods)]
	cat("\n被排除的组合示例（前5个）:\n")
	print(head(excluded_examples, 5))
}


#模型构建的第二步：机器学习算法构建模型
model <- list()            #初始化模型结果列表
set.seed(seed = 123)       #设置随机种子
Train_set_bk = Train_set
for (method in methods){
	cat(match(method, methods), ":", method, "\n")
	method_name = method
	method <- strsplit(method, "\\+")[[1]]
	if (length(method) == 1) method <- c("simple", method)
	Variable = preTrain.var[[method[1]]]
	Train_set = Train_set_bk[, Variable, drop=FALSE]
	Train_label = Train_class
	model[[method_name]] <- RunML(method = method[2],           #机器学习算法
																Train_set = Train_set,        #训练集的标准化数据
																Train_label = Train_label,    #训练集的分类标签
																mode = "Model",               #选择运行模式(构建模型)
																classVar = classVar)
	
	#如果某种机器学习算法筛选的变量数量小于最小值，则删除该模型
	if(length(ExtractVar(model[[method_name]])) <= min.selected.var) {
		model[[method_name]] <- NULL
	}
}
Train_set = Train_set_bk; rm(Train_set_bk)
#保存构建的机器学习模型结果
saveRDS(model, "model.MLmodel.rds")

#根据构建的模型计算每个样本的分类得分
model <- readRDS("model.MLmodel.rds")            #使用各机器学习模型的计算结果和分类得分
#model <- readRDS("model.logisticmodel.rds")     #使用多因素逻辑回归模型计算得分
methodsValid <- names(model)                     #根据模型列表名称获取验证模型
#根据构建的模型预测验证集的分类风险得分
RS_list <- list()
for (method in methodsValid){
	RS_list[[method]] <- CalPredictScore(fit = model[[method]], new_data = rbind.data.frame(Train_set,Test_set))
}
riskTab=as.data.frame(t(do.call(rbind, RS_list)))
riskTab=cbind(id=row.names(riskTab), riskTab)
write.table(riskTab, "model.riskMatrix.txt", sep="\t", row.names=F, quote=F)

#根据构建的模型预测样本的分类
Class_list <- list()
for (method in methodsValid){
	Class_list[[method]] <- PredictClass(fit = model[[method]], new_data = rbind.data.frame(Train_set,Test_set))
}
Class_mat <- as.data.frame(t(do.call(rbind, Class_list)))
#Class_mat <- cbind.data.frame(Test_class, Class_mat[rownames(Class_mat),]) # 需要合并自己的样本信息文件时使用
classTab=cbind(id=row.names(Class_mat), Class_mat)
write.table(classTab, "model.classMatrix.txt", sep="\t", row.names=F, quote=F)

#获取每种机器学习算法筛选的变量
fea_list <- list()
for (method in methodsValid) {
	fea_list[[method]] <- ExtractVar(model[[method]])
}
fea_df <- lapply(model, function(fit){
	data.frame(ExtractVar(fit))
})
fea_df <- do.call(rbind, fea_df)
fea_df$algorithm <- gsub("(.+)\\.(.+$)", "\\1", rownames(fea_df))
colnames(fea_df)[1] <- "features"
write.table(fea_df, file="model.genes.txt", sep = "\t", row.names = F, col.names = T, quote = F)

#计算每个模型的AUC值
AUC_list <- list()
for (method in methodsValid){
	AUC_list[[method]] <- RunEval(fit = model[[method]],      #机器学习模型
																Test_set = Test_set,        #验证集的标准化数据
																Test_label = Test_class,    #验证集的分类标签
																Train_set = Train_set,      #训练集的标准化数据
																Train_label = Train_class,  #训练集的分类标签
																Train_name = "Train",       #训练集的标签
																cohortVar = "Cohort",       #GEO数据集id
																classVar = classVar)        #分类变量名
}
AUC_mat <- do.call(rbind, AUC_list)
aucTab=cbind(Method=row.names(AUC_mat), AUC_mat)
write.table(aucTab, "model.AUCmatrix.txt", sep="\t", row.names=F, quote=F)


##############################绘制AUC热图##############################
#准备绘图的数据
AUC_mat <- read.table("model.AUCmatrix.txt", header=T, sep="\t", check.names=F, row.names=1, stringsAsFactors=F)

#计算AUC的均值并对机器学习模型进行排序
avg_AUC <- apply(AUC_mat, 1, mean)
avg_AUC <- sort(avg_AUC, decreasing = T)
AUC_mat <- AUC_mat[names(avg_AUC),]
#获取最佳模型(训练集+验证集AUC值最高)
fea_sel <- fea_list[[rownames(AUC_mat)[1]]]
avg_AUC <- as.numeric(format(avg_AUC, digits = 3, nsmall = 3))

#设置热图注释的颜色
CohortCol <- brewer.pal(n = ncol(AUC_mat), name = "Paired")
names(CohortCol) <- colnames(AUC_mat)
CohortCol=CohortCol[1:2]
#绘制热图
cellwidth = 1; cellheight = 0.5
hm <- SimpleHeatmap(Cindex_mat = AUC_mat,       #AUC矩阵
										avg_Cindex = avg_AUC,       #AUC均值
										CohortCol = CohortCol,      #数据集颜色
										barCol = "steelblue",       #右侧柱状图颜色
										cellwidth = cellwidth, cellheight = cellheight,    #热图每个单元的宽度和高度
										cluster_columns = F, cluster_rows = F)      #是否对数据进行聚类

#保存热图
pdf(file="model.AUCheatmap.pdf", width=cellwidth * ncol(AUC_mat) + 6, height=cellheight * nrow(AUC_mat) * 0.45)
draw(hm, heatmap_legend_side="right", annotation_legend_side="right")
dev.off()
