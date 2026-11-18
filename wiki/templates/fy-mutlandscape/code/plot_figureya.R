library(ComplexHeatmap)
library(RColorBrewer)

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 # error messages are displayed in English
options(stringsAsFactors = FALSE) #禁止chr转成factor  #chr is not allowed to be converted to factor

## 突变二值矩阵
## Mutation binary matrix
mut <- read.table("mutation.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)

## 突变频数
## Frequency of mutations
tmb <- read.table("TMB.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)

## 突变签名
## Mutation signature
mutsig <- read.csv("mutationsignature.cosmic2013.csv",row.names = 1,check.names = F,stringsAsFactors = F,header = T)
# 或者换成下面这行，读取FigureYa110mutationSignature的输出文件mutsig.weightMatrix.txt
# Or change it to the following line and read the output file of FigureYa110mutationSignature mutsig.weightMatrix.txt
# mutsig <- read.table("mutsig.weightMatrix.txt", row.names = 1, header = T) 

## 拷贝数GISTIC2.0结果（利用SNP segment文件在GenePattern上获得）
## Copy number GISTIC2.0 results (obtained on GenePattern using SNP segment file)
cna.region <- read.table("all_lesions.conf_90.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)
cna.gene <- read.table("all_thresholded.by_genes.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)

## 亚型数据
## Subtype data
subt <- read.table("subtype.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)

# 设置亚型颜色
# Set the subtype color
clust.col <- c("#DD492E","#40548A","#32A087","#EC7D21")
blue   <- "#5bc0eb"
red    <- "#f25f5c"

# 处理突变签名数据
# Handle mutation signature data
mutsig <- mutsig[,c("Signature.1","Signature.2","Signature.5","Signature.13")] # 文章中用到3种类型的signature， SBS1 (age-related), SBS2 and SBS13 (APOBEC activity-related) and SBS5 (ERCC2 mutation-related) # There are 3 types of signatures used in the article, SBS1 (age-related), SBS2 and SBS13 (APOBEC activity-related) and SBS5 (ERCC2 mutation-related)
mutsig$APOBEC <- mutsig$Signature.2 + mutsig$Signature.13 # APOBEC相关的签名由签名2和3叠加 # APOBEC-related signatures are overlaid by signatures 2 and 3
mutsig$CMOIC <- subt[rownames(mutsig),"CMOIC"] # 添加亚型结果 # Add subtype results
mutsig <- mutsig[order(mutsig$CMOIC,-mutsig$APOBEC,decreasing = F),] # 确定整个热图的排序，按照亚型升序以及APOBEC降序排列 # Determine the order of the entire heat map, in ascending order of subtype and descending order of APOBEC

# 挑选要展示的基因
# Pick the genes you want to display
mutgene <- c("FGFR3",
             "TP53",
             "RB1",
             "NFE2L2",
             "KIAA0947",
             "MEGF8",
             "STAG2",
             "SMARCA2",
             "RELN",
             "INO80",
             "TRANK1",
             "SPEN",
             "MED12",
             "KMT2A",
             "COL6A6",
             "AKAP9",
             "KIF21A",
             "ARID2",
             "DIDO1")

# 制作oncoprint的输入数据
# Create input data for oncoprint
onco.input <- mut[mutgene,rownames(mutsig),]
onco.input[onco.input == 1] <- "Mutated" # 二值矩阵中1记为突变 # 1 in the binary matrix is denoted as a mutation
onco.input[onco.input != "Mutated"] <- "" # 非“突变”给予空值 # Non-"mutations" are given null values
alter_fun = list(
  background = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = "#dcddde", col = "#dcddde"))
  },
  Mutated = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = "#A60000", col = "#A60000")) 
  }
)
col = c("Mutated" ="#A60000") # 突变颜色，注意这里只给了主图像的图例 # Mutate color, note that only the legend of the main image is given here

my_ann <- subt[rownames(mutsig),,drop = F]
my_annotation = HeatmapAnnotation(df = my_ann, 
                                  col = list(CMOIC = c("CS1" = clust.col[1],
                                                       "CS2" = clust.col[2],
                                                       "CS3" = clust.col[3],
                                                       "CS4" = clust.col[4])))

# 突变主区域的上部注释（突变负荷柱状图）
# Upper annotation of the main region of the mutation (histogram of mutation burden)
top_anno <- anno_barplot(as.numeric(tmb[rownames(mutsig),"log10TMB"]),
                         border = FALSE,
                         gp = gpar(fill = "#3379B4",border =NA,lty="blank"), 
                         height = unit(2.5, "cm"))

# 突变主区域的上部注释（突变签名柱状图）
# Upper annotation of the main region of the mutation (histogram of mutation signature)
tmp <- mutsig[,c("Signature.2","Signature.13","Signature.1","Signature.5")] # 只取和APOBEC有关的签名 # Only APOBEC-related signatures are taken
tmp$Others <- 1 - rowSums(tmp) # 计算其他签名的比例 # Calculate the proportion of other signatures
top_anno2 <- anno_barplot(as.matrix(tmp),
                          border = FALSE,
                          gp = gpar(fill = c(brewer.pal(6,"Paired")[c(2,1,6,5)],"grey90"), 
                                    border = NA, # 无边框 # Borderless
                                    lty = "blank"),
                          height = unit(2, "cm")) # 高度 # Height

tmp <- as.data.frame(t(mut[mutgene,rownames(mutsig),]))
mut.order <- names(sort(colSums(tmp),decreasing = T)) # 根据突变频数高低排序展示突变的顺序 # Displays the order of mutations according to the frequency of mutations
tmp$CMOIC <- subt[rownames(tmp),"CMOIC"]
pct <- NULL # 计算各个基因突变的百分比 # Calculate the percentage of mutations in each gene
for (i in mut.order) {
  tmp1 <- tmp[,c(i,"CMOIC")]
  tmp1 <- as.data.frame.array(table(tmp1[,1],tmp1$CMOIC))[2,]/sum(tmp1[,1])
  pct <- rbind.data.frame(pct,tmp1)
}
rownames(pct) <- mut.order

# 添加右侧百分比堆积柱状图
# Add the percentage stacked histogram on the right
right_anno <- anno_barplot(as.matrix(pct),
                           which = "row",
                           border = FALSE,
                           gp = gpar(fill = clust.col,border=NA,lty="blank"), 
                           bar_width = 0.6,
                           width = unit(1.8, "cm"),
                           height = unit(1, "cm"))
 
op1 <- oncoPrint(onco.input[mut.order,rownames(my_ann)], # 排序的突变矩阵 # Sorted mutation matrix
                 alter_fun = alter_fun,  # 主区域的函数，包括各单元格大小、背景颜色等等 # Functions in the main area, including cell size, background color, etc
                 col = col, # 突变颜色 # Mutate colors
                 bottom_annotation = NULL, # 无底部注释 # No bottom comment
                 top_annotation = c(HeatmapAnnotation(TMB = top_anno), # 顶部第一个注释：TMB # First note at the top: TMB
                                    my_annotation, # 顶部第二个注释：亚型 # Second note at the top: Isotype
                                    HeatmapAnnotation(MutSig = top_anno2)), # 顶部第三个注释：突变签名 # Third note at the top: Mutation signature
                 column_order = rownames(my_ann), # 样本的排序，根据突变签名的顺序 # Sorting of samples, according to the order of mutation signatures
                 right_annotation = rowAnnotation(PCT = right_anno), # 右侧堆叠柱状图注释 # Annotation of the stacked column chart on the right
                 show_pct = T, # 展示左侧的百分比 # Show the percentage on the left
                 column_title = "", # 不显示主题 # Topics are not displayed
                 show_heatmap_legend = T, # 展示图例 # Show legend
                 column_split = my_ann$CMOIC, # 根据亚型切分热图 # Slice the heat map according to the subtype
                 column_title_gp = gpar(fontsize = 8),
                 row_names_gp = gpar(fontsize = 8),
                 column_names_gp = gpar(fontsize = 8))
op1

# 选择要展示的拷贝数区域
# Select the copy number area you want to display
lesion.sig <- c("3p25.2-Amp",
                "7p15.3-Amp",
                "8p11.23-Amp",
                "10p14-Amp",
                "17q11.2-Amp",
                "17q12-Amp",
                "2q37.1-Del",
                "3p13-Del",
                "5q12.1-Del",
                "9p23-Del",
                "9p21.3-Del",
                "10q23.31-Del",
                "14q24.1-Del",
                "17p12-Del",
                "22q13.32-Del")

cna <- cna.region[1:(nrow(cna.region)/2),c(1,8,9:(ncol(cna.region)-1))] # 选取有效列 # Select a valid column
rownames(cna) <- paste0(gsub(" ","",cna$Descriptor),"-", substr(rownames(cna),1,3)) # 重命名行以确定扩增和缺失的位点 # Rename rows to identify amplified and missing sites
cna.modified <- cna[1:nrow(cna),3:ncol(cna)]
onco.input2 <- cna.modified[lesion.sig,rownames(mutsig)] # 选取要展示的拷贝数变异 # Select the copy number variation you want to display
tmp1 <- onco.input2[1:6,] # 前6个为扩增 # The first 6 are amplification
tmp1[tmp1 == 1] <- "Gain" # 数值大于0即为Gain # A value greater than 0 is considered a Gain
tmp1[tmp1 == 2] <- "Gain"
tmp1[tmp1 == 0] <- ""

tmp2 <- onco.input2[7:15,] # 后9个为缺失 # The last 9 are missing
tmp2[tmp2 == 1] <- "Loss"
tmp2[tmp2 == 2] <- "Loss"
tmp2[tmp2 == 0] <- ""
onco.input2 <- rbind.data.frame(tmp1,tmp2)

alter_fun2 = list(
  background = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = "#dcddde", col = "#dcddde"))
  },
  Gain = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = red, col = red)) 
  },
  Loss = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = blue, col = blue)) 
  }
)
col2 = c("Gain" = red,
         "Loss" = blue)
# 确定展示的顺序（看自己喜好，我这里是按照臂的顺序来的） 
# Determine the order of display (depending on your preference, I will follow the order of the arms here)
lesion.order <- c("3p25.2-Amp","7p15.3-Amp","8p11.23-Amp","10p14-Amp","17q11.2-Amp","17q12-Amp",
                  "2q37.1-Del","3p13-Del","5q12.1-Del","9p21.3-Del","9p23-Del","10q23.31-Del","14q24.1-Del","17p12-Del","22q13.32-Del")
tmp <- as.data.frame(t(cna.modified[lesion.order,rownames(mutsig),]))
tmp[tmp > 0] <- 1 # 所有大于1的均改为1以便计算变异频数 # All values greater than 1 are changed to 1 to calculate the variation frequency
tmp$CMOIC <- as.character(subt[rownames(tmp),"CMOIC"])
pct <- NULL
for (i in lesion.order) {
  tmp1 <- tmp[,c(i,"CMOIC")]
  tmp1 <- as.data.frame.array(table(tmp1[,1],tmp1$CMOIC))[2,]/sum(tmp1[,1])
  pct <- rbind.data.frame(pct,tmp1)
}
rownames(pct) <- lesion.order

# 右侧堆叠百分比柱状图
# Stacked percentage histogram on the right
right_anno2 <- anno_barplot(as.matrix(pct),
                            which = "row",
                            border = FALSE,
                            gp = gpar(fill = clust.col,
                                      border = NA,
                                      lty = "blank"), 
                            bar_width = 0.6,
                            width = unit(1.8, "cm"),
                            height = unit(1, "cm"))

# 同样的方式绘制热图
# Draw heatmaps the same way
op2 <- oncoPrint(onco.input2[lesion.order,rownames(my_ann)], 
                 alter_fun = alter_fun2, 
                 col = col2, 
                 bottom_annotation = NULL, 
                 top_annotation = NULL,
                 column_order = rownames(my_ann),
                 right_annotation = rowAnnotation(PCT = right_anno2),
                 row_order = lesion.order, 
                 show_pct = T,
                 column_title = "", 
                 show_heatmap_legend = T, 
                 column_split = my_ann$CMOIC,
                 column_title_gp = gpar(fontsize = 8),
                 row_names_gp = gpar(fontsize = 8),
                 column_names_gp = gpar(fontsize = 8))
op2

cna <- cna.gene
cna <- cna[c("IFNA1","MTAP","CDKN2A","CDKN2B"),rownames(mutsig)] # 文章筛选了4个基因 # Four genes were screened in this article
onco.input3 <- cna
# 由于上面的分析中缺失的部分不存在High balanced loss，所以直接让2也属于Gain而没有添加High balanced gain
# 这里小伙伴如果自己的数据满足要求，上面的拷贝数也可以分为4类
# Since there is no High balanced loss in the missing part of the above analysis, we directly let 2 also belong to Gain and do not add High balanced gain
# If your data meets the requirements, the number of copies above can also be divided into 4 categories
onco.input3[onco.input3 == 1] <- "Gain"
onco.input3[onco.input3 == 2] <- "High_balanced_gain"
onco.input3[onco.input3 == 0] <- ""
onco.input3[onco.input3 == -1] <- "Loss"
onco.input3[onco.input3 == -2] <- "High_balanced_loss"

alter_fun3 = list(
  background = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = "#dcddde", col = "#dcddde"))
  },
  Gain = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = brewer.pal(6,"Paired")[5], col = brewer.pal(6,"Paired")[5])) 
  },
  High_balanced_gain = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = brewer.pal(6,"Paired")[6], col = brewer.pal(6,"Paired")[6]))
  },
  Loss = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = brewer.pal(6,"Paired")[1], col = brewer.pal(6,"Paired")[1])) 
  },
  High_balanced_loss = function(x, y, w, h) {
    grid.rect(x, y, w-unit(0.5, "mm"), h-unit(0.5, "mm"), gp = gpar(fill = brewer.pal(6,"Paired")[2], col = brewer.pal(6,"Paired")[2]))
  }
)
col3 = c("Gain" = brewer.pal(6,"Paired")[5],
         "High_balanced_gain" =brewer.pal(6,"Paired")[6],
         "Loss" = brewer.pal(6,"Paired")[1],
         "High_balanced_loss" =brewer.pal(6,"Paired")[2])

op3 <- oncoPrint(onco.input3[,rownames(my_ann)], 
                 alter_fun = alter_fun3,  
                 col = col3, 
                 bottom_annotation = NULL, 
                 top_annotation = NULL,
                 column_order = rownames(my_ann), 
                 right_annotation = NULL,
                 show_pct = T, 
                 column_title = "", 
                 show_heatmap_legend=T, 
                 column_split = my_ann$CMOIC,
                 column_title_gp = gpar(fontsize = 8),
                 row_names_gp = gpar(fontsize = 8),
                 column_names_gp = gpar(fontsize = 8))
op3

# 构建额外图例
# Build additional legends
lgd.mutsig = Legend(labels = c("SBS2","SBS13","SBS1","SBS5","Others"), 
                    title = "MutSig", 
                    legend_gp = gpar(fill = c(brewer.pal(6,"Paired")[c(2,1,6,5)],"grey90")))

lgd.cna.region = Legend(labels = c("Gain","Loss"), 
                    title = "CNA (arm-level)", 
                    legend_gp = gpar(fill = c(red,blue)))
                    
lgd.cna.gene = Legend(labels = c("Gain","High_balanced_gain","Loss","High_balanced_loss"), 
                        title = "CNA (gene-level)", 
                        legend_gp = gpar(fill = brewer.pal(6,"Paired")[c(5,6,1,2)]))              

lgd_list <- list(lgd.mutsig, lgd.cna.region, lgd.cna.gene)

# 合并热图
# Merge heatmaps
pdf("mutational landscape in TCGA.pdf", width = 10,height = 10)
draw(op1 %v% op2 %v% op3, # 垂直叠加热图 # Vertical overlay heatmap
     annotation_legend_list = lgd_list) # 添加自定义的图例 # Add a custom legend
invisible(dev.off())
