source("crosslink.R") # From R package crosslink, https://github.com/zzwch/crosslink
source("layout.R") # From R package crosslink, https://github.com/zzwch/crosslink
source("transfromation.R") # From R package crosslink, https://github.com/zzwch/crosslink
source("utils.R") # From R package crosslink, https://github.com/zzwch/crosslink
source("crossplot.R") # From R package crosslink, https://github.com/zzwch/crosslink

library(dplyr) # 数据处理 data processing
library(ggplot2) # 画图 plot graph
library(scales) # 缩放 scale
Sys.setenv(LANGUAGE = "en") #显示英文报错信息 # error messages are displayed in English
options(stringsAsFactors = FALSE) #禁止chr转成factor # It is forbidden to convert chr into factor

# 载入节点信息
# Load node information
nodes <- read.csv("easy_input_nodes.csv", header = T)
head(nodes)

# 载入连线信息
# Load the connection information
edges <- read.csv("easy_input_edges.csv", header = T)
head(edges)

# 写入想画的type
# Write the type you want to draw
columns <- list(# 如果你只有两个type（或者只想画两列），就在list里写两行。# If you only have two types (or just want to draw two columns), write two lines in the list
  Gene = nodes$id[nodes$type == "Gene"],
  Drug = nodes$id[nodes$type == "Drug"],
  Target = nodes$id[nodes$type == "Tar"], 
  Pathway = nodes$id[nodes$type == "Path"]
)

columnCross2(edges, nodes, columns,
             height = 1, flank_mult = rep(0.1, length(columns)), segment_shrink = 0.1,
             linetype = "type", line_alpha = "alpha", line_color = "color", line_size = "size",
             pt_shape = "shape", pt_alpha = "alpha", 
             pt_color = "color", # 外圈颜色 # Outer ring color
             pt_fill = "color", # 填充颜色 # Fill color
             pt_size = "size", pt_stroke = 1)

ggsave(filename = "crosslink_file.pdf", width = 8, height = 5)

# 写入想画的type
# 如果你只有两个type（或者只想画两列），就在list里写两行。
# Write the type you want to draw
# If you only have two types (or just want to draw two columns), write two lines in the list.
columns <- list(
  Gene = nodes$id[nodes$type == "Gene"],
  Drug = nodes$id[nodes$type == "Drug"],
  Target = nodes$id[nodes$type == "Tar"], 
  Pathway = nodes$id[nodes$type == "Path"]
)

# 以连线类型和节点形状为例，说明定义外观的两种方式，定义其他外观的方法类似
# Take the line type and node shape as an example to illustrate the two ways to define appearances, and the methods for defining other appearances are similar
columnCross2(edges, nodes, columns,
             height = 1, flank_mult = rep(0.1, length(columns)), segment_shrink = 0.1,
             
             linetype = 1, # 默认值，所有连线都画成直线 # By default, all lines are drawn as straight lines
             line_alpha = "alpha", line_color = "color", line_size = "size" ,
             
             #pt_shape = 21, # 统一画成实心圆 # Draw a solid circle in unison
             # 或者Drug画成空心圆，其余画成实心圆 # Or the Drug is drawn as a hollow circle, and the rest is drawn as a solid circle
             pt_shape = c(rep(16, length(columns$Gene)), rep(1, length(columns$Drug)), rep(16, (length(columns$Target) + length(columns$Pathway)))), 
             
             pt_alpha = .8, # 统一设置透明度 # Set transparency uniformly
             pt_color = "color", pt_fill = "color", pt_size = "size", 
             pt_stroke = 3) # 让空心圆的边粗一些 # Make the edges of the hollow circle thicker

ggsave(filename = "crosslink_par.pdf", width = 8, height = 5)

# 载入节点信息
# Load node information
nodes <- read.csv("easy_input2_nodes.csv", header = T)
head(nodes)

# 载入连线信息
# Load connection information
edges <- read.csv("easy_input2_edges.csv", header = T)
head(edges)

# 这里把P和N都拆成两列，当然你也可以拆成更多列
# Split both P and N into two columns, but you can also split them into more columns
columns <- list(
  P1 = nodes$id[nodes$type == "P"][1:15],
  P2 = nodes$id[nodes$type == "P"][16:30],
  RBP = nodes$id[nodes$type == "RBP"],
  N1 = nodes$id[nodes$type == "N"][1:15], 
  N2 = nodes$id[nodes$type == "N"][16:30]
)
seq_len(length(columns))
# 以连线类型和节点形状为例，说明定义外观的两种方式，定义其他外观的方法类似
# Take the line type and node shape as an example to illustrate the two ways to define appearances, and the methods for defining other appearances are similar
columnCross2(edges, nodes, columns,
             height = 1, 
             
             # 默认值是1,2,3,4,5，每列之间是等距的
             # 我们想让两边的两列距离近些，就这样改
             # The default values are 1, 2, 3, 4, 5, and each column is equidistant
             # We want to make the two columns on both sides closer, so change it like this
             column_x = c(1, 1.5, 3, 4.5, 5), 
             
             # 默认值都是0.1
             # 我们想让中间RBP那列短一些，就这样改
             # The default value is 0.1
             # We want to make the middle RBP column shorter, so change it like this
             flank_mult = c(0.1, 0.1, 0.15, 0.1, 0.1), 
             
             segment_shrink = 0,
             line_alpha = .2, line_size = 1, line_color = "color",
             pt_shape = "shape",  pt_alpha = "alpha", pt_color = "color", pt_fill = "color", pt_size = "size", pt_stroke = 1)

ggsave(filename = "crosslink_multiCol.pdf", width = 6, height = 8)
