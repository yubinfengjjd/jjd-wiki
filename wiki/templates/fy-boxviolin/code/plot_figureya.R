library(ggplot2)
library(ggpubr)

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 # Display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor # Disable conversion of chr to factor

tmp <- read.csv("easy_input.csv", row.names = NULL, check.names = F, header = T, stringsAsFactors = F)
head(tmp)
table(tmp$DNAmAge)

p <- wilcox.test(tmp[which(tmp$DNAmAge == "DNAmAge-ACC"),"est.ic50"],tmp[which(tmp$DNAmAge == "DNAmAge-DCC"),"est.ic50"])$p.value

# 设置颜色
# Set colors
jco <- c("#2874C5","#EABF00")

ggplot(data = tmp,aes(x = DNAmAge, y = est.ic50, fill = DNAmAge))+
  scale_fill_manual(values = jco[2:1]) + 
  geom_violin(alpha=0.4, position = position_dodge(width = .75),
              size=0.8, color="black") + # 边框线黑色 # border line black
  geom_boxplot(notch = TRUE, outlier.size = -1, 
               color="black", lwd=0.8, alpha = 0.7)+ # 背景色透明化 # background color transparent
  geom_point(shape = 21, size=2, 
             position = position_jitterdodge(), 
             color="black", alpha=1)+ # 边框线黑色 # border line black
  theme_classic() +
  ylab(expression("Estimated IC"[50]~" for Paclitaxel")) +
  xlab("")  +
  annotate(geom="text", cex=6,
           x=1.5, y=-1, # 根据自己的数据调节p value的位置 # Adjust the position of the p value based on your own data
           label=paste0("P ", ifelse(p<0.001, "< 0.001", paste0("= ",round(p,3)))), # 添加P值 # Add the P value
           color="black") + 
  theme(#panel.border = element_rect(colour = "black", fill=NA, size=0.2), # 原图有框 # The original image has a frame
        axis.ticks = element_line(size=0.2,color="black"),
        axis.ticks.length = unit(0.2,"cm"),
        legend.position = "none",
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10))

# 保存图像 # Save the image
ggsave("boxViolin.pdf", width = 4.5, height = 4)

tmp <- read.csv("easy_input_multi.csv", row.names = NULL, check.names = F, header = T, stringsAsFactors = F)
head(tmp)
table(tmp$TGFBcluster)

# 设置组间对比，排列组合
# Set up intergroup comparisons and permutations
my_comparisons <- list( c("Red-TGFB", "Pink-TGFB"), 
                        c("Red-TGFB", "Grey-TGFB"), 
                        c("Red-TGFB", "Blue-TGFB"), 
                        c("Pink-TGFB","Grey-TGFB"),
                        c("Pink-TGFB","Blue-TGFB"),
                        c("Grey-TGFB","Blue-TGFB"))

#set color
blue   <- "#5bc0eb"
grey   <- "#8693ab"
darkred   <- "#F2042C"
lightred  <- "#FF7FBF"

ggplot(data = tmp,aes(x = TGFBcluster, #分组列名 #Group column name
                      y = Enrichscore, #连续变量列名 #Continuous variable column name
                      fill = TGFBcluster))+ #按分组填充颜色 #Fill by group
  scale_fill_manual(values = c(blue, grey, lightred, darkred)) + #用自定义颜色填充 #Fill with custom color
  geom_violin(alpha = 0.4, position = position_dodge(width = .75), 
              size = 0.8, color="black") +
  geom_boxplot(notch = TRUE, outlier.size = -1, 
               color="black", lwd=0.8, alpha = 0.7) +
  geom_point(shape = 21, size=2, # 点的性状和大小 # Point characteristics and size
             position = position_jitterdodge(), # 让点散开 # Spread out the points
             color="black", alpha = 1) +
  theme_classic() + 
  ylab("Enrichment score") +
  xlab("TGFB cluster") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
        #panel.border = element_rect(colour = "black", fill=NA, size=0.2),
        axis.ticks = element_line(size=0.2, color="black"),
        axis.ticks.length = unit(0.2, "cm"),
        legend.position = "none",
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 10)) +

  # 如果不要组间比较就注释掉下面这行 
  # Comment out the following line if you don't want between-group comparisons. 
  stat_compare_means(comparisons = my_comparisons) + 
  stat_compare_means(method = "kruskal.test", label.y = min(tmp$Enrichscore))
p

ggsave("boxViolin_multipleGroups.pdf", width = 6, height = 6)
