library(ggplot2)
library(data.table)
library(aplot)
library(ggpubr)
library(dplyr)
Sys.setenv(LANGUAGE = "en") #显示英文报错信息 # error messages are displayed in English
options(stringsAsFactors = FALSE) #禁止chr转成factor # chr is not allowed to be converted to factor

# 加载模拟数据(因为是用ggplot做，所以多个组都可以)
# Load simulation data (because it is done with ggplot, so multiple groups are OK)
df <- read.table("easy_input.txt",sep = "\t",row.names = NULL,check.names = F,stringsAsFactors = F,header = T)
head(df)

# 计算p值
# 这里是多组，用kruskal.test函数，还可以改为aov
# 如果是两组，可以改为t.test，或wilcox.test
# Calculate the p-value
# Here are multiple groups, use the kruskal.test function, and you can change it to aov
# If there are two groups, you can change it to t.test, or wilcox.test
p.val <- kruskal.test(AUC ~ Subtype,
                      data = df)
p.lab <- paste0("P",
                ifelse(p.val$p.value < 0.001, " < 0.001",
                       paste0(" = ",round(p.val$p.value, 3)))) 
p.lab

# 设置颜色
# Set the color
green <- "#C7EAB2"
cyan <- "#5FC1C2"
blue <- "#1B90BE"

# 绘制上半部分密度图
# Draw the density map of the upper half
p_top <- ggplot(df, aes(x = AUC, color = Subtype, fill = Subtype)) +
  geom_density() +
  # 让箱子的所有位置都颜色统一，如例文所示
  # Make all positions of the box uniform in color, as shown in the example
  scale_color_manual(values = c(alpha(green,0.7),alpha(cyan,0.7),alpha(blue,0.7))) + # 设置透明色 # Set the transparent color
  scale_fill_manual(values = c(alpha(green,0.7),alpha(cyan,0.7),alpha(blue,0.7))) +
  theme_classic() + # 如果显示采用这一行 # Use this line if you want to display
   
  # 这里提取输入文件的第一列药物名称，写入x轴标签
  # Here extract the drug name in the first column of the input file and write it to the x-axis label
  xlab(paste0("Estimated AUC of ", unique(df$Drug))) + 
  # 第一列非必需，可以像下面这样直接写xlab
  # The first column is not required, you can write xlab directly like the following xlab("Estimated AUC of Cisplatin") +
  
  ylab(NULL) + 
  theme(legend.position = "none", 
        legend.title = element_blank(),
        axis.text.x = element_text(size = 12,color = "black"),
        axis.text.y = element_blank(), # 原文不显示纵轴的密度 # The original text does not show the density of the vertical axis
        #axis.text.y = element_text(size = 12,color = "black"), # 如果要显示采用这一行 # If you want to display ,youcan use this line
        axis.ticks.y = element_blank(),
        axis.line.y = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  geom_rug()
p_top

# 画box plot
# Draw a box plot
p_bot <- ggplot(df, aes(Subtype, AUC, fill = Subtype)) + 
  geom_boxplot(aes(col = Subtype)) + 
  scale_fill_manual(values = c(green, cyan, blue)) + 
  scale_color_manual(values = c(green, cyan, blue)) + 
  xlab(NULL) + ylab("Estimated AUC") + 
  theme_void() +
  theme(legend.position = "right",
        legend.title = element_blank(),
        axis.text.x = element_blank(), # 原文不显示箱线图的x轴 # The original text does not show the x-axis of the boxplot
        #axis.text.x = element_text(size = 12,color = "black"), # 如要显示箱线图x轴采用这一行 # If you want to display the boxplot x-axis, use this row
        axis.text.y = element_text(size = 11,color = "black"),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) + 
  annotate(geom="text",
           x = 1.5,
           hjust = 1,
           y = max(df$AUC),
           size = 4, angle = 270, fontface = "bold",
           label = p.lab) +
  coord_flip() # 翻转图像 # Flip the image

# 用白色标记箱子的基本统计量
# Mark the basic stats of the box in white
dat <- ggplot_build(p_bot)$data[[1]]
p_bot <- p_bot + geom_segment(data=dat, aes(x=xmin, xend=xmax, y=middle, yend=middle), color="white", inherit.aes = F)
p_bot

# 使用aplot拼图，底部箱型图稍微小一些 
# Use the aplot puzzle and make the bottom box plot slightly smaller
p <- p_top %>% insert_bottom(p_bot, height = 0.4)
pdf(file = "boxdensity.pdf", width = 6,height = 3)
p
invisible(dev.off())
