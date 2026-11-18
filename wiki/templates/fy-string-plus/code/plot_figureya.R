library(tidyr)                # 加载tidyr包｜Load tidyr package
library(scales)               # 加载scales包｜Load scales package
library(ggplot2)              # 加载绘图包｜Load plotting package
library(reshape2)             # 加载数据重塑包｜Load data reshaping package
library(igraph)               # 加载网络分析包｜Load network analysis package
library(magrittr)             # 加载管道操作包｜Load pipe operator package

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 #Display English error message
options(stringsAsFactors = FALSE) #禁止chr转成factor #Disable chr conversion to factor

mycircle <- function(coords, v=NULL, params) {
  vertex.color <- params("vertex", "color")
  if (length(vertex.color) != 1 && !is.null(v)) {
    vertex.color <- vertex.color[v]
  }
  vertex.size  <- 1/200 * params("vertex", "size")
  if (length(vertex.size) != 1 && !is.null(v)) {
    vertex.size <- vertex.size[v]
  }
  vertex.frame.color <- params("vertex", "frame.color")
  if (length(vertex.frame.color) != 1 && !is.null(v)) {
    vertex.frame.color <- vertex.frame.color[v]
  }
  vertex.frame.width <- params("vertex", "frame.width")
  if (length(vertex.frame.width) != 1 && !is.null(v)) {
    vertex.frame.width <- vertex.frame.width[v]
  }
  
  mapply(coords[,1], coords[,2], vertex.color, vertex.frame.color,
         vertex.size, vertex.frame.width,
         FUN=function(x, y, bg, fg, size, lwd) {
           symbols(x=x, y=y, bg=bg, fg=fg, lwd=lwd,
                   circles=size, lheight = 30, add=TRUE, inches=FALSE)
         })
}

# Define new vertex shape "fcircle" (filled circle with border)
add.vertex.shape("fcircle", clip=igraph.shape.noclip,
		 plot=mycircle, parameters=list(vertex.frame.color="white", # 或 "black"｜Or "black"
                                  vertex.frame.width=2)) # 边框宽度为2｜Border width = 2

# Give your focus official gene_symbol
sourceGene <- "FOXP3"

# Given name will be shown on the plot instead.
sourceName <- "FOXP3" 

# 读取相互作用关系和score
# Read the interaction relationship and score

links <- read.table("easy_input.txt", header = TRUE, sep = "\t")
colnames(links) <- c("source", "target", "Loc", "score")
# 把score归一化｜Rescale score
#links$score <- rescale(links$score, to = c(1, 10))

# 拆分Loc列｜Split Loc column
links <- separate_rows(links, Loc, sep = ", ")
head(links)
net <- graph_from_data_frame(links, directed = F)

n_loc <- length(unique(links$Loc))
pal_loc <- setNames(RColorBrewer::brewer.pal(n_loc, name = "Set1"), sort(unique(links$Loc)))

# see plot.igraph for more settings 
vertexes <- get.vertex.attribute(net, "name")
net %<>% 
  set.vertex.attribute("label", 
                       value = ifelse(vertexes == sourceGene, 
                                      sourceName, vertexes)) %<>%
  set.edge.attribute("color", 
                     value = pal_loc[links$Loc]) %<>%
  set.edge.attribute("weight", 
                     value = links$score)

set.seed(777)
lay <- layout_with_dh(net) #weight.node.dist = unique(links[,c("target","score")])$score) # weight here may be invalid!

# plot in SVG device, then you may use Adobe Illustrator 
# to fine tune the network map. 
# Such as adjust the text position to avoid overlapping.

pdf(file = "interaction.pdf", width = 6, height = 8)
plot(net, layout = lay, 
     vertex.shape = 'fcircle',
     vertex.size = ifelse(vertexes == sourceGene, 15, 3),
     vertex.color = "hotpink",
     vertex.frame.color = ggplot2::alpha("white", alpha = 0.5),
     vertex.frame.width = ifelse(vertexes == sourceGene, 30, 0.1),
     vertex.label.color = ifelse(vertexes == sourceGene, "black", "grey30"),
     vertex.label.family = "sans",
     vertex.label.cex = ifelse(vertexes == sourceGene, 0.9, 0.6),
     edge.curved = curve_multiple(net, start = 0.06))
     # fine tune "start" to get better visual effect. To shrink multiple edges using smaller value.
legend(-1, -1, legend= names(pal_loc),
       col= pal_loc, lty=1, cex=0.6,
       box.lty=1, box.lwd=1, box.col="black")
dev.off()
