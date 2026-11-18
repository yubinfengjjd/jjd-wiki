# 设置knitr的全局代码块选项 / Set global chunk options for knitr


library(reshape2)   # 数据重塑工具（如宽表转长表） Data reshaping tools (e.g., wide to long format)
library(ggplot2)    # 高级数据可视化 Advanced data visualization
library(cowplot)    # 提供图形排版功能 Enhanced plot arrangement tools
library(plyr)       # 数据分割-应用-合并工具 Tools for splitting-applying-combining data

# 设置环境语言为英文（显示英文错误信息） / Set system language to English (for English error messages)
Sys.setenv(LANGUAGE = "en") 

# 防止字符串自动转换为因子 / Prevent automatic conversion of strings to factors
options(stringsAsFactors = FALSE)  

# 设置目标基因 / Set target gene symbol
symbol <- "HDAC1"  # 这里以组蛋白去乙酰化酶1基因为例 / Example: Histone Deacetylase 1 gene

# 设置选取的Top基因数量 / Set number of top genes to select
topnumber = 6  # 选取正相关和负相关各Top 6的基因 / Select top 6 positively and negatively correlated genes

# 绘图设置：通过将基因表达水平分组到等大小的区间来绘制特殊点
# Plot settings: Group gene expression levels into equally sized bins for special points
pointnumber = 20  # 设置每个区间包含20个点 / Set 20 points per bin

# 可选：不使用分组区间的绘图方式
# Alternative: Plot without binning
# pointnumber = NULL  # 取消分组区间设置 / Disable binning

# 读取TCGA表达数据 / Read TCGA expression data
# 从CSV文件读取表达矩阵，第一列作为行名 / Read expression matrix from CSV file, using first column as row names
tcga_expr <- read.csv("easy_input.csv", row.names = 1)

# 查看数据前3行和前3列 / Display first 3 rows and first 3 columns
# 用于快速检查数据格式和内容 / Quick check of data format and content
tcga_expr[1:3, 1:3]

# 获取目标基因的表达数据 / Extract expression data of target gene
# 从表达矩阵中提取目标基因(symbol)的表达值 / Get expression values of target gene from expression matrix
target.exps <- tcga_expr[symbol,]

# 获取其他基因的表达数据 / Extract expression data of other genes
# 从表达矩阵中移除目标基因所在行 / Remove target gene row from expression matrix
other.expr <- tcga_expr[-which(rownames(tcga_expr)==symbol),]

# 计算Pearson相关系数 / Calculate Pearson correlation
# 转置矩阵后计算各基因与目标基因的相关性 / Transpose matrix and calculate correlation with target gene
sgcor <- as.data.frame(cor(t(other.expr), t(target.exps))) #默认pearson / Default is Pearson
colnames(sgcor) <- "r_pearson"  # 重命名列 / Rename column

# 计算Pearson相关系数的p值（耗时操作） / Calculate p-values for Pearson correlation (time-consuming)
sgcor$pval_pearson <- apply(other.expr, 1, function(x) (cor.test(x, t(target.exps))$p.value))


# 计算Spearman相关系数 / Calculate Spearman correlation
sgcor_spearman <- as.data.frame(cor(t(other.expr), t(target.exps), method = "spearman"))
colnames(sgcor_spearman) <- "r_spearman"  # 重命名列 / Rename column
sgcor_spearman$pval_spearman <- apply(other.expr, 1, function(x)(cor.test(x, t(target.exps), method = "spearman")$p.value))

# 合并两种相关系数结果 / Combine both correlation results
cors <- cbind(sgcor, sgcor_spearman)
cors$gene <- rownames(other.expr)  # 添加基因名列 / Add gene name column
head(cors)  # 查看前几行结果 / Preview results

# 筛选有效结果（去除NA值） / Filter valid results (remove NAs)
newcor <- cors[!(is.na(cors$r_pearson)),]
dim(newcor)  # 查看剩余基因数量 / Check remaining gene count

# 按Pearson相关系数排序 / Sort by Pearson correlation coefficient
sortcor <- newcor[order(newcor$r_pearson, newcor$r_spearman, decreasing = T),]

# 提取Top相关基因 / Extract top correlated genes
# 获取正相关Top6和负相关Top6 / Get top 6 positive and negative correlated genes
topcor <- sortcor[c(1:topnumber, #正相关Top 6 / Top 6 positive
                   (nrow(sortcor) - topnumber + 1):nrow(sortcor)),] #负相关Top 6 / Top 6 negative
rownames(topcor)  # 显示Top基因名 / Show top gene names

# 准备可视化数据 / Prepare visualization data
genes <- c(symbol,rownames(topcor))  # 合并目标基因和Top相关基因 / Combine target and top genes
genesexps <- as.data.frame(t(tcga_expr[genes,]))  # 转置表达矩阵 / Transpose expression matrix
sortgenesexps <- genesexps[order(genesexps[,1]),]  # 按目标基因表达量排序 / Sort by target gene expression
samplenum <- nrow(sortgenesexps)  # 获取样本数量 / Get sample count

# 设置绘图点数 / Set number of points for plotting
# 如果未指定pointnumber，则使用所有样本 / If pointnumber is NULL, use all samples
if(is.null(pointnumber)){
  pointnumber = samplenum
}

# 将样本分组为等大小的区间 / Group samples into equally sized bins
# 创建分组因子变量 / Create grouping factor variable
group <- as.integer(cut(1:samplenum, 
                       breaks = c(seq(from = 0.5, to = samplenum, 
                                     by = samplenum/pointnumber), 
                                 samplenum + 0.5)))

# 初始化数据框用于存储结果 / Initialize dataframe for storing results
ddf <- data.frame(row.names = 1:pointnumber)

# 计算每个基因在每个区间的中位数表达值 / Calculate median expression for each gene in each bin
for(i in 1:(1 + topnumber*2)){  # 遍历目标基因和所有top基因 / Loop through target and top genes
  ddf <- cbind(ddf, tapply(sortgenesexps[,i], group, median))
}

# 设置列名 / Set column names
colnames(ddf) <- c(symbol, topcor$gene)

# 转换数据为长格式便于ggplot绘图 / Melt data to long format for ggplot
mddf <- melt(ddf, id.vars = symbol)

# 添加相关系数和p值信息 / Add correlation coefficients and p-values
# 使用Pearson相关结果 / Using Pearson correlation results
# 如需Spearman结果，可替换为r_spearman和pval_spearman / For Spearman, replace with r_spearman and pval_spearman
mddf$r <- topcor[mddf$variable, ]$r_pearson
mddf$P <- topcor[mddf$variable, ]$pval_pearson

# 选择特定基因的数据 / Select data for specific gene
friend <- "EIF3I"  # 设置要分析的基因 / Set gene to analyze
df <- mddf[mddf$variable == friend,]  # 筛选该基因的数据 / Filter data for this gene

# 格式化相关系数r的显示 / Format correlation coefficient r display
# 创建斜体r值和数值的表达式 / Create expression with italic r and value
rvalue <- as.character(as.expression(substitute(~~italic(r)~"="~rvalue, list(rvalue = format(round(unique(df$r),2), nsmall= 2)))))

# 格式化p值的显示 / Format p-value display
# 创建斜体P值和科学计数法数值的表达式 / Create expression with italic P and scientific notation
pvalue <- as.character(as.expression(substitute(~~italic(P)~"="~pvalue, list(pvalue = format(sprintf("%1.1e", unique(df$P)), nsmall= 2)))))

# 绘制散点图 / Create scatter plot
ggplot(df, aes_string(x = symbol, y = "value")) +
  geom_point() +  # 添加散点 / Add points
  ylab(friend) +  # 设置y轴标签为基因名 / Set y-axis label as gene name
  theme_classic() +  # 使用经典主题 / Use classic theme
  
  # 添加统计注释 / Add statistical annotations
  # 需要根据数据范围调整x,y坐标位置 / Need to adjust x,y positions based on data range
  annotate("text", x = 334, y = 350, label = rvalue, parse = TRUE) +  # 添加r值 / Add r value
  annotate("text", x = 340, y = 300, label = pvalue, parse = TRUE) +  # 添加p值 / Add p value
  
  # 添加线性回归线 / Add linear regression line
  geom_smooth(method = "lm", se = FALSE, colour = "#206BB5")  # 蓝色回归线 / Blue regression line

# 保存图形 / Save plot
ggsave(paste0(symbol, "_", friend, ".pdf"))  # 输出PDF文件 / Output PDF file

# 使用dlply按基因拆分数据并创建多个ggplot对象
# Split data by gene using dlply and create multiple ggplot objects
# 对mddf数据框按variable(基因名)分组，为每个基因创建一个散点图
# Group mddf dataframe by variable (gene name), create scatter plot for each gene
plist <- dlply(mddf, .(variable), function(trig) {
  ggplot(trig, aes_string(x = symbol, y = "value")) +
    geom_point() +  # 添加散点 / Add scatter points
    ylab(unique(trig$variable)) +  # 设置y轴标签为当前基因名 / Set y-axis label to current gene name
    theme_classic() +  # 使用简洁的经典主题 / Use clean classic theme
    
    # 添加标题显示相关系数和p值
    # Add title showing correlation coefficient and p-value
    ggtitle(paste0("r = ", round(unique(trig$r), 2),  # 显示r值并保留2位小数 / Show r rounded to 2 decimal places
            "\nP = ", sprintf("%1.1e", unique(trig$P)))) +  # 显示科学计数法p值 / Show p-value in scientific notation
    
    # 添加线性回归线(蓝色，无置信区间)
    # Add linear regression line (blue, no confidence interval)
    geom_smooth(method = "lm", se = FALSE, colour = "#206BB5")
})

# 使用cowplot包的plot_grid将所有图形排列成网格
# Arrange all plots into grid using plot_grid from cowplot package
pg <- plot_grid(
  plotlist = plist,  # 图形列表 / List of plots
  ncol = 3,  # 每行3个图 / 3 plots per row
  align = "hv"  # 水平和垂直对齐 / Align horizontally and vertically
)

# 显示组合后的图形
# Display combined plot
pg

# 保存图形为PDF文件
# Save plot as PDF file
filename <- paste0(symbol, "_cor.pdf")  # 生成文件名(如"HDAC1_cor.pdf") / Generate filename (e.g., "HDAC1_cor.pdf")
ggsave(
  filename, 
  width = 8,  # 宽度8英寸 / Width 8 inches
  height = 10  # 高度10英寸 / Height 10 inches
)
