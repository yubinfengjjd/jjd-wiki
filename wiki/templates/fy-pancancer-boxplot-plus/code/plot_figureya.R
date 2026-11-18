Sys.setenv(LANGUAGE = "en") #显示英文报错信息 display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor prohibit the conversion of chr to factor

tcga_gtex <- read.csv("easy_input.csv", row.names = 1, header = T, as.is = F)
head(tcga_gtex)

library(ggpubr)

ylabname <- paste("TP53", "expression")
colnames(tcga_gtex) <- c("Tissues", "Groups", "Gene")

p1 <- ggboxplot(tcga_gtex, x = "Tissues", y = "Gene", fill = 'Groups',
                ylab = ylabname,
                color = "Groups", #两组用不同颜色 two groups use different colors
                palette = "jco", #配色方案 color scheme
                ggtheme = theme_minimal())
p1

# 画box的同时画散点
# draw the box while drawing the scatter points
p2 <- ggboxplot(tcga_gtex, x = "Tissues", y = "Gene", fill = 'Groups',
                ylab = ylabname,
                color = "Groups", 
                palette = "jco", 
                add = "jitter", #加散点 add scatter points
                #shape = "Groups", #两组散点用不同形状 two sets of scatter points use different shapes
                ggtheme = theme_minimal())
p2

# 标注p value
# mark p value
anno_df <- compare_means(Gene ~ Groups, group.by = "Tissues", data = tcga_gtex,
                         #这里是两组对比，用wilcox.test或t.test
                         #here are two sets of comparisons, using wilcox.test or t.test
                         method = "wilcox.test", 
                         #如果多组对比就用下面这行，kruskal.test或anova
                         #if you want to compare multiple groups, use the following line, kruskal.test or anova
                         #method = "kruskal.test", 
                         p.adjust.method = "holm") #
head(anno_df)

p3 <- p2 + 
  stat_pvalue_manual(anno_df, x = "Tissues", y.position = 15,
                     label = "p.signif", position = position_dodge(0.8))
p3
ggsave("pancancer_ggpubr.pdf", width = 14, height = 5)

library(ggplot2)

ylabname <- paste("TP53", "expression")
colnames(tcga_gtex) <- c("Tissues", "Groups", "Gene")

# 剔除没有normal sample的tissue
# exclude tissue without normal sample
tcga_gtex_MESO <- tcga_gtex[tcga_gtex$Tissues=="MESO",]
tcga_gtex_UVM <- tcga_gtex[tcga_gtex$Tissues=="UVM",]
tcga_gtex_withNormal <- tcga_gtex[tcga_gtex$Tissues != "MESO" & tcga_gtex$Tissues != "UVM",]

# 计算p value
# calculate p value
pvalues <- sapply(tcga_gtex_withNormal$Tissues, function(x) {
  res <- wilcox.test(as.numeric(Gene) ~ Groups, data = subset(tcga_gtex_withNormal, Tissues == x)) #两组，wilcox.test或t.test；多组，kruskal.test或aov(one-way ANOVA test) two groups, wilcox.test or t.test; multiple groups, kruskal.test or aov(one-way ANOVA test)
  res$p.value
})

pv <- data.frame(gene = tcga_gtex_withNormal$Tissues, pvalue = pvalues)
pv$sigcode <- cut(pv$pvalue, c(0,0.0001, 0.001, 0.01, 0.05, 1), 
                  labels=c('****','***', '**', '*', 'ns'))

# 画box plot
# draw box plot
p.box <- ggplot(tcga_gtex_withNormal, aes(x=Tissues, y=Gene, color=Groups, fill=Groups)) +
  geom_boxplot(alpha = .5) + #半透明 semi-transparent
  theme_classic() + #或theme_bw() or theme_bw()
  scale_fill_brewer(palette = "Set1") + #按类填充颜色 fill color by category
  scale_color_brewer(palette = "Set1") + #按类给边框着色 colorize borders by category

  theme(axis.text.x = element_text(colour="black", size = 11,
                                   #癌症名太挤，旋转45度
                                   #cancer name is too crowded, rotate 45 degrees
                                   angle = 45, hjust = .5, vjust = .5)) +
  geom_text(aes(x=gene, y=max(tcga_gtex_withNormal$Gene) * 1.1,
                         label = pv$sigcode),
                     data=pv, 
                     inherit.aes=F) +
  ylab(ylabname)
p.box
ggsave("pancancer_ggplot2box.pdf", width = 14, height = 5)

# 画带散点的box plot
# draw a box plot with scatter points
p.box.dot <- p.box + geom_point(shape = 21, size=.5, # 点的形状和大小 shape and size of points
             position = position_jitterdodge(), # 让点散开 let the points be scattered
             alpha = .5) #半透明 semi-transparent
p.box.dot
ggsave("pancancer_ggplot2boxDot.pdf", width = 14, height = 5)

# 把不带normal的tissue也画上
# draw the non-normal issue as well
p.box.dot + 
  # MESO
  geom_boxplot(alpha = .5, data = tcga_gtex_MESO,
                     mapping = aes(x=Tissues,y=Gene,fill=Groups)) +
  geom_point(data = tcga_gtex_MESO,
                     mapping = aes(x=Tissues,y=Gene,fill=Groups),
             shape = 21, size=.5, # 点的形状和大小 shape and size of points
             position = position_jitterdodge(), # 让点散开 let the points be scattered
             alpha = .5) + #半透明 semi-transparent
  # UVM
  geom_boxplot(alpha = .5, data = tcga_gtex_UVM,
                    mapping = aes(x=Tissues,y=Gene,fill=Groups)) +
  geom_point(data = tcga_gtex_UVM,
                    mapping = aes(x=Tissues,y=Gene,fill=Groups),
             shape = 21, size=.5, # 点的形状和大小 shape and size of points
             position = position_jitterdodge(), # 让点散开 let the points be scattered
             alpha = .5) + #半透明 semi-transparent
  theme_classic() + #或theme_bw() or theme_bw()
  theme(axis.text.x=element_text(colour="black", size = 11,
                                   angle = 45, hjust = .5, vjust = .5))
ggsave("pancancer_ggplot2boxDot_all.pdf", width = 14, height = 5)
