library(circlize)        # 用于绘制环形图 # For creating circular plots
library(gridBase)        # 提供基础图形功能 # Provides basic graphic functions
library(grid)            # 用于图形布局 # For graphical layout
library(ComplexHeatmap)  # 用于绘制复杂热图 # For creating complex heatmaps
library(SimDesign)       # 提供模拟设计和分析功能 # Provides simulation design and analysis functions 

Sys.setenv(LANGUAGE = "en") # 显示英文报错信息 # Messages are displayed in English
options(stringsAsFactors = FALSE) # 禁止字符型数据自动转换为因子型 # Prevent automatic conversion of character data to factors

# 加载亚型数据并依次排序
# Load the subtype data and sort them in turn
subt <- read.table("easy_input.txt", sep = "\t", row.names = 1, check.names = F, stringsAsFactors = F, header = T)
head(subt)

# 亚型依次排序
# Isotypes are sorted in order
subt <- subt[order(subt$TCGA_subtype, 
                   subt$Moffitt_subtype, 
                   subt$`Bailey subtype`, 
                   subt$`Collisson subtype`), ]

# 设置各个亚型的颜色
# Set the color of each subtype
subtype1.col <- c("#9AAF57", "#6AA1AB", "#E1B52E", "#81552E")
subtype2.col <- c("#717579", "#DFE8EE")
subtype3.col <- c("#9B1C1F", "#8F7999", "black", "#9FC6EC")
subtype4.col <- c("#6978BC", "#F7F07C", "#D3BDDC")

# 映射各亚型各水平的颜色
# Map the colors of each subtype and each level
col_subt1 <- c("Cholesterogenic" = subtype1.col[1],
               "Glycolytic" = subtype1.col[2],
               "Quiescent" = subtype1.col[3],
               "Mixed" = subtype1.col[4])
col_subt2 <- c("Basal-like" = subtype2.col[1], 
               "Classical" = subtype2.col[2])
col_subt3 <- c("Squamous" = subtype3.col[1], 
               "Immunogenic" = subtype3.col[2], 
               "Progenitor" = subtype3.col[3], 
               "ADEX" = subtype3.col[4])
col_subt4 <- c("Quasi-mesenchymal" = subtype4.col[1],
               "Exocrine-like" = subtype4.col[2],
               "Classical" = subtype4.col[3])

# 创建图例
# Create a legend
lgd_subt1 <- Legend(title = "TCGA subtype", # 图例title # Legend title
                    at = names(col_subt1), # 图例的水平 # The level of the legend
                    legend_gp = gpar(fill = col_subt1)) # 图例所填充的颜色 # The color of the legend filled
lgd_subt2 <- Legend(title = "Moffitt subtype", 
                    at = names(col_subt2), 
                    legend_gp = gpar(fill = col_subt2))
lgd_subt3 <- Legend(title = "Bailey subtype", 
                    at = names(col_subt3), 
                    legend_gp = gpar(fill = col_subt3))
lgd_subt4 <- Legend(title = "Collisson subtype", 
                    at = names(col_subt4), 
                    legend_gp = gpar(fill = col_subt4))

# 自定义函数，正式合并图像和图例
# Custom functions to formally merge images and legends
circlize_plot = function() {
  circos.heatmap(subt$TCGA_subtype, 
                 split = factor(subt$TCGA_subtype,levels = c("Cholesterogenic", "Glycolytic", "Quiescent", "Mixed")), # 按照亚型因子顺序排列 # Listed in order of subtype factor
                 col = col_subt1, 
                 track.height = 0.14,
                 show.sector.labels = TRUE) # 显示区块名 # Displays the block name
  circos.heatmap(subt$Moffitt_subtype, 
                 split = factor(subt$Moffitt_subtype, levels = c("Basal-like", "Classical")), 
                 col = col_subt2, 
                 track.height = 0.14)
  circos.heatmap(subt$`Bailey subtype`, 
                 split = factor(subt$`Bailey subtype`, levels = c("Squamous", "Immunogenic", "Progenitor", "ADEX")), 
                 col = col_subt3, 
                 track.height = 0.14)
  circos.heatmap(subt$`Collisson subtype`, 
                 split = factor(subt$`Collisson subtype`, levels = c("Quasi-mesenchymal", "Exocrine-like", "Classical")), 
                 col = col_subt4, 
                 track.height = 0.14)
  # 注意：circos.clear() 在函数外部调用，确保每次绘图前状态是干净的
  # Note: circos.clear() is called outside the function to ensure the state is clean before each plot
}

## 开始画图 ## Start drawing
plot.new() # 请从这句开始到你想修改/理解的那行代码，整段运行 # Please start with this sentence and run the whole line of code you want to modify/understand
circle_size = unit(0.8, "snpc") # snpc会设置一个正方形的区域 # SNPC will set a square area
pushViewport(viewport(x = 0, y = 0.5, 
                      width = circle_size, 
                      height = circle_size,
                      just = c("left", "center")))
par(omi = gridOMI(), new = TRUE)
circos.clear() # 确保 circlize 状态是干净的 # Ensure circlize state is clean
suppressMessages(suppressWarnings(circlize_plot()))

# 添加正中心的文字
# Add text in the center
text(0, 0, "PDAC\nsamples", cex = 0.9) # 添加正中心的文字 # Add text in the center
upViewport()

# 画图例
# Draw a legend
lgd_list <- packLegend(lgd_subt1, 
                       lgd_subt2, 
                       lgd_subt3, 
                       lgd_subt4, 
                       max_height = unit(0.9*dev.size()[2], "inch"))
draw(lgd_list, x = circle_size, just = "left")

# 直接保存图像到本地
# Save images directly to your local computer
dev.copy2pdf(file = "subtype circos plot.pdf")
