fnames<-Sys.glob("*.csv")
fnames

fdataset<-lapply(fnames,read.csv)
names(fdataset) <- fnames

library(plyr)
result <- ldply(fdataset, data.frame)
head(result)

df<-result[,2:22]
df$module<-unlist(strsplit(result$.id,split = ".csv"))
head(df)

#先按module内基因的数量为module排序
#sort the module first by the number of genes in the module
module.num<-table(df$module)
module.num.sort<-module.num[order(module.num,decreasing =TRUE)]
module.num.sort
keys<-names(module.num.sort)
keysDF<-data.frame(module=keys,order=1:length(keys))
keysDF

#再按这个module的顺序为基因排序
#then sort the genes in the order of this module
df.merged<-merge(df,keysDF,by.x = 'module',by.y = 'module',all.x = T, all.y = F)
df.sort <- df.merged[order(df.merged$order),]
write.table(df.sort[1:22],"easy_input.txt",row.names = F, quote = F)

#读取带有module信息的基因表达量文件
#read gene expression file with module information
df.exp<-read.table("easy_input.txt",header = T, as.is = T)
row.names(df.exp)<-df.exp$X
head(df.exp)
dim(df.exp)

library(pheatmap)
#设置sample的分组
#set the grouping of sample
annotation_col = data.frame(
  type = factor(rep(c("BALB","C57","NOD","PWK","SPRET"),c(4,4,4,4,4))),
  treatment = factor(rep(c("notx","notx","KLA","KLA"),5))
)
rownames(annotation_col) = colnames(df.exp[,3:22])

#设置基因的分组，也就是module
#set the grouping of genes, also known as the module
annotation_row = data.frame(df.exp$module)
rownames(annotation_row) = df.exp$X
colnames(annotation_row)<-"WGCNA.module"

#为sample和基因的分组设置颜色
#module的名字作为module的颜色
#set colors for grouping of sample and gene
#the name of the module is used as the color of the module
module.name<-names(table(df.exp$module))
names(module.name)<-module.name

ann_colors = list(
  treatment = c(notx = "black", KLA = "white"),#给两种处理设置颜色 set colors for both treatments
  type = c(BALB = "orange", C57 = "#007C46", NOD = "#00D0D1", PWK = "#333D7E", SPRET = "#A25BAA"),
  WGCNA.module = module.name
)

#画heatmap
#draw heatmap
pheatmap(df.exp[,3:22],cellwidth = 12, cellheight = 0.2, fontsize = 8,
         scale="row", #为基因做scale scale for Genes
         cluster_rows=F,cluster_cols=F,#不聚类 not clustered
         color = colorRampPalette(c("#00A9E0", "white", "firebrick3"))(50),
         show_colnames=F,show_rownames =F,
         annotation_col = annotation_col,
         annotation_row = annotation_row,
         annotation_colors = ann_colors,
         border_color = "NA",
         filename = "heatmap.pdf")
