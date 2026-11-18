library(ComplexHeatmap)
Sys.setenv(LANGUAGE = "en") #显示英文报错信息
options(stringsAsFactors = FALSE) #禁止chr转成factor

logfc <- read.csv("easy_input_logFc.csv", row.names = 1)
logfc[1:2,]
p.val <- read.csv("easy_input_PVal.csv", row.names = 1)
p.val[1:2,]

genetype <- read.csv("genetype.csv")
head(genetype)
#为确保热图基因的顺序和分组文件的顺序是一致的
#因此按照基因分组文件里的顺序，对logfc和p.val两个文件排序
#To ensure that the order of heat map genes is consistent with the order of grouping files
#So sort the logfc and p.val files according to the order in the gene grouping file
logfcOrdered <- logfc[genetype$gene,]
p.valOrdered <- p.val[genetype$gene,]

## 对logfc进行分类
## Classify logfc
logfcCat <- apply(logfcOrdered, 2, function(x){
    cut(x, breaks = c(-Inf, -2, -1, 1, 2, Inf),
        labels = c("< -2", "-2 - -1", "-1 - 1", "1 - 2", "> 2"))
})
rownames(logfcCat) <- rownames(logfcOrdered)

## 确保两个数据集的列名和行名顺序一致
## Ensure that the order of column names and row names of the two datasets is consistent
if(!identical(rownames(logfcCat), rownames(p.valOrdered))) p.valOrdered <- p.valOrdered[rownames(logfcCat),]
if(!identical(colnames(logfcCat), colnames(p.valOrdered))) p.valOrdered <- p.valOrdered[colnames(logfcCat)]

## 把P> 0.05的数据标记为 P > 0.05
## Mark data with P> 0.05 as P > 0.05
logfcCat[p.valOrdered >= 0.05] <- "P >= 0.05"

## 查看有多少个分类
## Check how many categories there are
unique(matrix(logfcCat, ncol  = 1))
## 每个分类定义一个颜色
## Define a color for each category
col_cat <- c("> 2" = "#A80C3A", "1 - 2" = "#ED5E57", "-1 - 1" = "#DDD3D2",
             "-2 - -1" = "#6B9AB7", "< -2" = "#2F5B89", "P >= 0.05" = "white")

cell_fun <- function(logfc, dataP, logfcCutoff = 1, PCutoff = 0.05, 
                     darkcol = "black", lightcol = "white", digit = 2, fontsize  = 6){
    function(j, i, x, y, width, height, fill){
        if(abs(logfc[i,j]) > logfcCutoff & dataP[i,j] < PCutoff){
            grid.text(round(logfc, digit)[i, j], x, y, 
                      gp = gpar(fontsize = fontsize, col  = lightcol))
        }else{
            grid.text(round(logfc, digit)[i, j], x, y, 
                      gp = gpar(fontsize = fontsize, col  = darkcol))
        }
    }
}

## 定义注释信息的颜色
## Define the color of the annotation information
an_col <- c("#ED1450", "#FCCA02", "#A7CE35", "#2C92DA", "#59574A", "#FFF8AD", "#A2238E", "#BCBDBF")
names(an_col) <- unique(genetype$type)

## 定义注释信息
## Define the annotation information
row_an <-  HeatmapAnnotation(type = genetype$type, ##注释信息的内容 ##Content of the annotation information
                             show_annotation_name = F, ## 是否显示注释的标题
## Whether to display the title of the annotation
                             col = list(type = an_col), ## 注释信息的颜色
## The color of the annotation information
                             show_legend = T,  ## 是否显示注释信息的说明
 ## Whether to display the description of the annotation 
                             annotation_legend_param = list(title = "MMP Subtype"), ## 注释信息图例的标题
## The title of the annotation legend
                             which = "row") #对行或者列进行注释 
#Annotate rows or columns

pdf("rankHeatmap.pdf", width = 8, height = 4)
Heatmap(matrix = logfcCat, 
        name = "logFC", #主要图例的标题 #Title of the main legend
        rect_gp = gpar(col = "NA", lwd = 1), #不画边框，或者用col = "grey"画灰色边框 #No border, or use col = "grey" to draw a gray border
        col = col_cat, #热图颜色 #Heatmap color
        row_names_side = "left", 
        cell_fun = cell_fun(logfcOrdered, p.valOrdered), 
        row_names_gp = gpar(fontsize = 8), #基因名字号 #Gene name
        column_names_gp = gpar(fontsize = 8), #肿瘤类型字号 #Tumor type font size
        column_names_rot = 45, #肿瘤类型呈45度 #Tumor type at 45 degrees
        left_annotation = row_an) #左侧基因分类，如果不画，就筛掉这个参数 #Left gene classification, if not drawn, this parameter will be filtered out
dev.off()
