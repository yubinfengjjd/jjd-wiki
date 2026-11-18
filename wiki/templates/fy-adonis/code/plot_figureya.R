#肠道微生物数据，每行为一种肠道微生物，每一列为一个样本
#gut microbiota data, each row represents a type of gut microbe, and each column represents a sample
mydata <- read.table("easy_input_meta.txt",head=T,sep = "\t",row.names = 1)
mydata <- t(mydata) #转置
mydata[1:3,1:4]

#理化因子表格，每行为一个样本，每一列为一个因子，例如年龄、疾病、吸烟等
#physicochemical factor table, one sample per row, one factor per column, e.g., age, disease, smoking, etc.
myfactor <- read.table("easy_input_factors.txt",header = T,sep = "\t", row.names = 1)
head(myfactor)

#非必需，理化因子的分组信息，例如某几个因子都属于生活方式
#non-essential, grouping information of physicochemical factors, for example, certain factors all belong to lifestyle
gp <- read.table("easy_input_factor.group.txt",head=F,sep = "\t")
colnames(gp) <- c("factor","group")
head(gp)

# 进行adonis分析
# perform adonis analysis
library(vegan)
result <- adonis2(mydata ~ ., 
                  data = myfactor, 
                  by = "terms",        # 按项计算（与原始adonis相同）
                  permutations = 999,  # 置换次数，默认999
                  method = "bray",     # 距离方法，默认是"bray"（Bray-Curtis）
                  strata = NULL,       # 分层变量，如果需要分层置换检验
                  parallel = getOption("mc.cores") # 并行计算核心数
                  )

mytable <- as.data.frame(result)
mytable <- mytable[1:ncol(myfactor),]

# 是否进行p值校正并根据校正后p值挑选
# whether or not to perform p-value correction and select based on the corrected p-value
fdr <- T

if(fdr == T){
  # p.adjust
  mytable$fdr <- p.adjust(mytable$`Pr(>F)`, method = "fdr")
  # 根据fdr挑选理化因子
  # select physicochemical factors based on fdr
  choose <- mytable[mytable$fdr < 0.05,]
}else{
  choose <- mytable[mytable$`Pr(>F)` < 0.05,]
}

# 把计算结果保存到文件，可以像例文那样，作为文章的补充材料
# save the calculations to a file that can be used as additional material for the article, as in the example essay
write.csv(choose, "output_Adonis.csv", quote = F)

library(ggplot2)
#根据R2排序
#sort by R2
choose <- choose[order(choose$R2),]
choose$factor <- factor(row.names(choose),levels=row.names(choose))

#定义足够多的颜色，对应理化因子分组的数量
#define a sufficient number of colors corresponding to the number of physicochemical factor groupings
mycol <- c("#BD6263","#8EA325","#A9D179","#84CAC0","#F5AE6B","#BCB8D3","#4387B5")

#理化因子有无分组
#physical and chemical factors with or without grouping
group <- T #此处有分组信息 grouping information is available here

if (group == T) { 
  choose <- merge(choose,gp,by="factor")
  ggplot(choose,aes(x=factor, y=R2, fill = group)) + #按分组填充颜色 fill color by group
    geom_bar(stat = "identity",color = "black") + #bar有黑色边框 bar has a black border
    scale_x_discrete(expand = c(0,0)) + #上下不留空 do not leave it blank up and down
    scale_fill_manual(values = mycol) + #使用自定义的配色 use a custom color scheme
    
    labs(x="",y="Adnois R2") +
    coord_flip() + #坐标轴互换 coordinate-axis interchange
    
    theme_bw() + #去除背景色 remove background color
    theme(panel.grid =element_blank()) + #去除网格线 remove gridlines
    theme(panel.border = element_blank()) + #去除外层边框 remove outer border
    theme(axis.line = element_line(colour = "black")) +#沿坐标轴显示直线 display lines along the axes
    
    guides(fill = guide_legend(title = NULL)) 

} else {
  #不提供分组信息的情况
  #circumstances in which grouping information is not provided
  ggplot(choose,aes(x=factor,y=R2),fill = "black") + 
    geom_bar(stat = "identity",color = "black") + 
    scale_x_discrete(expand = c(0,0)) + 

    labs(x="", y="Adnois R2") +
    coord_flip() +
    theme_bw() +
    theme(panel.grid =element_blank()) + 
    theme(panel.border = element_blank()) + 
    theme(axis.line = element_line(colour = "black")) +
    
    guides(fill = guide_legend(title = NULL)) 
}

#保存到PDF文件
#save to PDF file
ggsave("adonis_barplot.pdf")
