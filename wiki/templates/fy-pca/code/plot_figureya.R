library(ggplot2) # 强大的数据可视化工具 The powerful data visualization tool
library(plyr) # 数据处理 The data processing
library(dplyr) # 数据处理 The data processing
source("ggord.R") # from ggord packge, https://github.com/fawda123/ggord
source("geom_ord_ellipse.R") # from gglayer package, https://github.com/GuangchuangYu/gglayer
Sys.setenv(LANGUAGE = "en") #显示英文报错信息 display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor prohibit the conversion of chr to factor

expr_df <- read.csv(file='easy_input_expr.csv',row.names = 1, 
                    header = TRUE, sep=",", stringsAsFactors = FALSE)
meta_df <- read.csv(file='easy_input_meta.csv', row.names = 1,
                    header = TRUE, sep=",",stringsAsFactors = FALSE)
#查看前3个基因在前4个sample中的表达矩阵
#view the expression matrix of the first 3 genes in the first 4 samples
expr_df[1:3,1:4]
#查看样本信息前3行
#view the first 3 lines of sample information
head(meta_df, n=3)

#用`prcomp`进行PCA分析
#PCA analysis with `prcomp`
pca.results <- prcomp(expr_df, center = TRUE, scale. = FALSE)
head(pca.results$rotation[,1:3]) #查看前3个主成分的基因载荷 #view the gene loadings of the first 3 principal components
head(pca.results$x[,1:3]) #查看前3个主成分的样本坐标 #view the sample coordinates of the first 3 principal components

#定义足够多的颜色，用于展示分组
#define enough colors for display groupings
mycol <- c("#223D6C","#D20A13","#088247","#FFD121","#11AA4D","#58CDD9","#7A142C","#5D90BA","#431A3D","#91612D","#6E568C","#E0367A","#D8D155","#64495D","#7CC767")

#用ggord画基本PCA图
#draw basic PCA graph with ggord
ggord(pca.results, grp_in = meta_df$group, repel=TRUE,
      ellipse = FALSE, #不显示置信区间背景色 confidence interval background color is not displayed
      size = 2, #样本的点大小 point size of the sample
      alpha=0.5, #设置点为半透明，出现叠加的效果 set the point to be semi-transparent, resulting in an overlay effect.
      #如果用自定义的颜色，就运行下面这行
      #if using a custom color, run the following line
      cols = mycol[1:length(unique(meta_df$group))],
      arrow = NULL,txt = NULL) + #不画箭头和箭头上的文字 no drawing of arrows and text on arrows
  theme(panel.grid =element_blank()) + #去除网格线 remove gridlines
  
  #用gglayer添加置信区间圆圈
  #add confidence interval circles with gglayer
  geom_ord_ellipse(ellipse_pro = .95, #设置置信区间 set confidence interval
                   size=1.5, #线的粗细 thickness of the line
                   lty=1 ) #实线 solid line

#保存到pdf文件
#save to pdf file
ggsave("PCA_classic.pdf", width = 6, height = 6)

topN <- 3 # 定义要标出的基因数量

# 首先获取PCA解释的变异比例
# First get the proportion of variance explained by PCA
pca.pv <- summary(pca.results)$importance[2,]

# 计算每个基因对前两个主成分的贡献度
# Calculate the contribution of each gene to the first two principal components
gene_contributions <- rowSums(abs(pca.results$rotation[,1:2]) * pca.pv[1:2])

# 按贡献度排序，选择Top N 个基因
# Sort by contribution and select Top N genes
top_genes <- names(sort(gene_contributions, decreasing = TRUE))[1:topN]
cat("Top N contributing genes:", paste(top_genes, collapse = ", "), "\n")
cat("Gene contributions:", round(sort(gene_contributions, decreasing = TRUE)[1:topN], 3), "\n")

# 复制原始的PCA结果，但修改rotation只保留Top基因
# Copy original PCA results, but modify rotation to keep only Top genes
pca.results.top3 <- pca.results
pca.results.top3$rotation <- pca.results$rotation[top_genes,]

# 使用修改后的PCA结果画图（主成分仍基于所有基因）
# Use modified PCA results for plotting (principal components still based on all genes)
ggord(pca.results.top3, grp_in = meta_df$group, repel=TRUE,
      alpha = 0.6,#点和置信区间背景设为半透明，以凸显箭头和文字 the point and confidence interval backgrounds are set to semi-transparent to emphasize the arrows and the text
      ellipse_pro = 0.95,#置信区间 confidence interval
      size = 2,
      arrow=0.2, #箭头的头的大小 size of the head of the arrow
      vec_ext = 5,#箭头尾巴长短 length of arrow tail
      veccol="brown",#箭头颜色 arrow Color
      txt=3) + #箭头指向的基因名的字体大小 font size of the gene name pointed to by the arrow
  theme(panel.grid =element_blank()) +
  ggtitle("PCA with Top N Contributing Genes Highlighted") +
  
  #用gglayer继续添加虚线的置信区间
  #continue to add dashed confidence intervals with gglayer
  geom_ord_ellipse(ellipse_pro = .95, #先画个.95的圆圈 draw a .95 circle first
                   color='darkgrey', #圈圈的颜色 color of the circle
                   size=0.5,
                   lty=2 ) + #画成虚线，可以用1-6的数字设置为其他线型 draw as a dotted line, which can be set to other line types using the numbers 1-6
  geom_ord_ellipse(ellipse_pro = .98, #再画个.98的圆圈 draw another .98 circle
                   size=0.5, lty=2 )

#保存到pdf文件
#save to pdf file
ggsave("PCA_allgenes_topNarrows.pdf", width = 6, height = 6)

pca.rotation <- pca.results$rotation
pca.rotation
# pca.pv 在上面已经定义过了
# pca.pv was already defined above
pca.pv

low_dim_df <- as.data.frame(pca.results$x[,c(1,2)])
low_dim_df$group <- meta_df$group
#查看前3行
#view the first 3 rows
low_dim_df[1:3,]

add_ellipase <- function(p, x="PC1", y="PC2", group="group",
                         ellipase_pro = 0.95,
                         linetype="dashed",
                         colour = "black",
                         lwd = 2,...){
  obs <- p$data[,c(x, y, group)]
  colnames(obs) <- c("x", "y", "group")
  ellipse_pro <- ellipase_pro
  theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, length = 50))
  circle <- cbind(cos(theta), sin(theta))
  ell <- ddply(obs, 'group', function(x) {
    if(nrow(x) <= 2) {
      return(NULL)
    }
    sigma <- var(cbind(x$x, x$y))
    mu <- c(mean(x$x), mean(x$y))
    ed <- sqrt(qchisq(ellipse_pro, df = 2))
    data.frame(sweep(circle %*% chol(sigma) * ed, 2, mu, FUN = '+'))
    })
  names(ell)[2:3] <- c('x', 'y')
  
  ell <- ddply(ell, .(group) , function(x) x[chull(x$x, x$y), ])
  p <- p + geom_polygon(data = ell, aes(x=x,y=y,group = group), 
                   colour = colour,
                   alpha = 1,fill = NA,
                   linetype=linetype,
                   lwd =lwd)
  return(p)
}

#计算坐标轴标签
#calculate axis labels
pc1.pv <- paste0(round(pca.pv['PC1'],digits = 3) * 100, "%")
pc2.pv <- paste0(round(pca.pv['PC2'],digits = 3) * 100, "%")

#画出各个样本在二维空间的点
#draw the points of each sample in two-dimensional space
p <- ggplot(low_dim_df) + 
  geom_point(aes(x=PC1, y=PC2, color=group), size=2, #点的大小 size of the dot
             shape=20,#点的形状 shape of the dot
             alpha=0.5) +#设置点为半透明，出现叠加的效果 set the dot to be semi-transparent, resulting in an overlay effect.
  #如果使用默认的颜色，就在下面这行前面加个#
  #if you use the default colors, put a # in front of the following line
  scale_color_manual(values = mycol[1:length(unique(meta_df$group))]) +
  #还能调整整体的颜色亮度
  #it also adjusts the overall color brightness
  #scale_colour_hue(l=45) + 
  theme_bw() + #去除背景色 remove background color
  theme(panel.grid =element_blank()) + #去除网格线 remove gridlines
  
  #添加标签，同样可以加到方法一的同一位置
  #add labels, which can also be added to the same location as method one
  annotate("text",x=-8.5,y=-1.2,label = "BRCA",color = mycol[1]) +
  annotate("text",x=5,y=5.6,label = "LUCA",color = mycol[2]) +
  annotate("text",x=5,y=-2.5,label = "OV",color = mycol[3]) +
  
  #图例
  #legend
  guides(color=guide_legend(title = NULL)) +
  theme(legend.background = element_blank(), #移除整体边框 remove overall border
        #图例的左上角置于绘图区域的左上角
        #the upper left corner of the legend is placed in the upper left corner of the drawing area
        legend.position = c(0,1),legend.justification = c(0,1),
        legend.text = element_text(size=12)) + #字体大小 font size

  #调整坐标轴标签
  #adjust axis labels
  xlab(paste0("PC1 ( ", pc1.pv," variance )")) + 
  ylab(paste0("PC2 ( ", pc2.pv," variance )")) 
p
#画圈圈
#draw circles
p1 <- add_ellipase(p,ellipase_pro = 0.95,colour = "dimgrey",linetype=1,lwd=1)
p1
#保存为PDF文件
#save as PDF file
ggsave('PCA_DIY1.pdf',width = 5.5,height = 4)

#也可以多次叠加，画两个圆圈
#you can also stack it multiple times and draw two circles
p2 <- add_ellipase(p,ellipase_pro = 0.95,colour = "dimgrey",linetype=2,lwd=0.5)
p2 <- add_ellipase(p2,ellipase_pro = 0.98,colour = "dimgrey",linetype=2,lwd=0.5)
p2

#保存为PDF文件
#save as PDF file
ggsave('PCA_DIY2.pdf',width = 5.5,height = 4)
