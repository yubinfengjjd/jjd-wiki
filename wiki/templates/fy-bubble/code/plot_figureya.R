library(ggplot2)

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor prohibit the conversion of chr to factor

df <- read.table("easy_input.txt", header = T, sep = "\t", as.is = T)
head(df)
# 算一下gene ratio
# calculate the gene ratio
df$GeneRatio <- df$Pop.Hits/df$Count

# 查看GeneRatio的最大值和最小值，可以用来确定合理的x轴范围
# viewing the maximum and minimum values of GeneRatio can be used to determine a reasonable range for the x-axis
summary(df$GeneRatio)

# 为了画出对角线排列的效果，按GeneRatio排序
# To draw a diagonal arrangement effect, sorted by GeneRatio
sortdf <- df[order(df$GeneRatio), ] #如果想按Pvalue排序，就把GeneRatio改为PValue If you want to sort by Pvalue, change the GeneRatio to PValue
sortdf$Term <- factor(sortdf$Term, levels = sortdf$Term)

pl <- ggplot(sortdf, aes(GeneRatio, Term, #横坐标、纵坐标 horizontal and vertical coordinates
              colour = PValue)) + # 颜色代表p-value color represents p-values
  geom_point(aes(size= Count)) + #圆点的大小代表组内基因数 the size of the dots represents the number of genes in the group
  scale_size_continuous(range = c(2,10)) + #圆点的大小范围 size range of the dot
  scale_color_gradientn(colours=c("red", "yellow")) + #可以自己改颜色 you can change the color yourself
  #scale_x_continuous(limits = c(0.2,1)) + #设置x轴范围 set the x-axis range
  theme_bw() + 
  ylab("") + 
  theme(legend.position=c(1,0), legend.justification = c(1, 0)) + #legend画在右下角 the legend is drawn in the lower right corner
  #下面两行让legend融入图
  #the next two lines make the legend fit into the plot
  theme(legend.background = element_blank()) + #移除legend整体的边框 remove the overall border of the legend
  theme(legend.key = element_blank())#移除legend每个项目周围的边框 remove the border around each item in the legend
pl

ggsave("dot.pdf", width = 7, height = 6)
# 还可以直接保存为png、tiff等格式
# you can also save directly as png, tiff, etc.
#ggsave("dot.png", width = 7, height = 6)
#ggsave("dot.tiff", width = 7, height = 6)

sortdf <- df[order(df$GeneRatio, decreasing = T), ] #降序 descending order
sortdf$Term <- factor(sortdf$Term, levels = sortdf$Term)

pr <- ggplot(sortdf, aes(GeneRatio, Term, 
              colour=PValue)) + 
  geom_point(aes(size=Count)) + 
  scale_color_gradientn(colours=c("red", "yellow")) + 
  scale_size_continuous(range = c(2, 10)) + 
  #scale_x_continuous(limits = c(0.2, 1)) + 
  ylab("") + 
  scale_y_discrete(position = "right") + #把term放到右侧 put term on the right
  
  theme_bw() + 
  theme(legend.position=c(0, 0), legend.justification = c(0, 0)) + #legend画在左下角 the legend is drawn in the lower left corner
  theme(legend.background = element_blank()) + 
  theme(legend.key = element_blank())
pr

library(cowplot)
plot_grid(pl, pr, labels = "")
ggsave(file="bubbles.pdf")
