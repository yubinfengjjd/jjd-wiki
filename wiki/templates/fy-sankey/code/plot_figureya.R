library(ggalluvial) # 画桑基图 draw sankey
library(dplyr) # 数据处理 data processing

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor prohibit the conversion of chr to factor

df <- read.table("easy_input.txt",sep = "\t",row.names = 1,header = T)
head(df)

#定义足够多的颜色，后面从这里选颜色
#define enough colors to pick colors from later
mycol <- rep(c("#223D6C","#D20A13","#FFD121","#088247","#11AA4D","#58CDD9","#7A142C","#5D90BA","#029149","#431A3D","#91612D","#6E568C","#E0367A","#D8D155","#64495D","#7CC767"),2)

#格式转换
#format conversion
UCB_lodes <- to_lodes_form(df[,1:ncol(df)],
                           key = "Gene",
                           axes = 1:ncol(df),
                           id = "Cohort")
dim(UCB_lodes)
head(UCB_lodes)
tail(UCB_lodes)

ggplot(UCB_lodes,
       aes(x = Gene, stratum = stratum, alluvium = Cohort,
           fill = stratum, label = stratum)) +
  scale_x_discrete(expand = c(0, 0)) + 
  geom_flow(width = 1/8) + #线跟方块间空隙的宽窄 the width of the gap between the line and the square
  geom_stratum(alpha = .9,width = 1/10) + #方块的透明度、宽度 transparency, width of the square
  geom_text(stat = "stratum", size = 3, color="black") + #文字大小、颜色 text size, color
  
  #不喜欢默认的配色方案，用前面自己写的配色方案
  #If you don't like the default color scheme, use the one you created earlier
  scale_fill_manual(values = mycol) +

  xlab("") + ylab("") +
  theme_bw() + #去除背景色 remove background color
  theme(panel.grid =element_blank()) + #去除网格线 remove gridlines
  theme(panel.border = element_blank()) + #去除外层边框 remove outer border
  theme(axis.line = element_blank(),axis.ticks = element_blank(),axis.text = element_blank()) + #去掉坐标轴 remove the axes
  ggtitle("")+
  guides(fill = FALSE) 

ggsave("sankey_stratum_3.pdf")

UCB_lodes <- to_lodes_form(df[,c(1,3)],
                           key = "Gene",
                           axes = 1:2,
                           id = "Cohort")
dim(UCB_lodes)

ggplot(UCB_lodes,
       aes(x = Gene, stratum = stratum, alluvium = Cohort,
           fill = stratum, label = stratum)) +
  scale_x_discrete(expand = c(0, 0)) + 
  
  #用aes.flow参数控制线从哪边来，颜色就跟哪边一致。
  #默认是forward，此处用backward。
  #use the aes.flow parameter to control the side from which the line originates, and the color will correspond to that side.
  #default is forward, use backward here.
  geom_flow(width = 1/8,aes.flow = "backward") +
  
  coord_flip() + #旋转90度 rotate 90 degrees
  geom_stratum(alpha = .9,width = 1/10) +
  geom_text(stat = "stratum", size = 3,color="black") +

  #如果分组少，可以用scale_fill_brewer。修改type和palette两个参数选择配色方案，更多配色方案参考下图，分别对应type参数的“Seq”、“qual”、“Div”
  #If there are fewer groups, you can use scale_fill_brewer. Adjust the type and palette parameters to choose the color scheme., and refer to the following figure for more color schemes, corresponding to the type parameter's "Seq", "Qual", "Div" respectively.
  #scale_fill_brewer(type = "Div", palette = "BrBG") +
  
  #如果分组太多，就要用前面自己写的配色方案
  #If there are too many groups, you have to use the color scheme you wrote earlier on your own
  scale_fill_manual(values = mycol) +

  xlab("") + ylab("") +
  theme_bw() + 
  theme(panel.grid =element_blank()) + 
  theme(panel.border = element_blank()) + 
  theme(axis.line.x = element_blank(),axis.ticks = element_blank(),axis.text.x = element_blank()) + #显示分组名字 show group name
  ggtitle("") +
  guides(fill = FALSE) 

ggsave("sankey_stratum_2.pdf")

subdf <- df

# 计算频率
# calculate frequency
subdf <- subdf %>% 
  group_by(gene, mutation, subtype) %>% #如果有更多列，就在括号里继续添加列名 If there are more columns, continue adding column names in parentheses
  tally(name = "Freq") %>% 
  as.data.frame()
head(subdf)

ggplot(as.data.frame(subdf),
       aes(y = Freq,
           axis1 = gene, 
           axis2 = mutation, 
           axis3 = subtype)) + #这里画三列，如果有更多列，就继续添加，例如axis4 = 列名 Here draw three columns, if there are more columns, continue to add, for example axis4 = column name
  scale_fill_manual(values = mycol) + 
  ggalluvial::geom_flow(stat = "alluvium",width = 1/8,aes(fill = gene)) +
  geom_stratum(width = 1/8, reverse = T) +
  geom_text(stat = "stratum", size = 3, aes(label = after_stat(stratum)),
            reverse = T) +
  scale_x_continuous(breaks = 1:3, labels = c("gene", "mutation", "subtype")) +
  
  theme(legend.position = "bottom", #底部画图例 draw legend at bottom
        legend.title = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(size = 12, face = "bold", color = "black")) +
  
  xlab("") + ylab("") +
  theme_bw() + #去除背景色 remove background color
  theme(panel.grid =element_blank()) + #去除网格线 remove gridlines
  theme(panel.border = element_blank()) + #去除外层边框 remove outer border
  theme(axis.line = element_blank(),axis.ticks = element_blank(), #不画xy轴 do not draw the xy-axis
        axis.text.y = element_blank()) + # 只保留x轴label keep only the x-axis label
  ggtitle("")
ggsave("sankey_alluvium.pdf")
