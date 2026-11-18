# 设置knitr代码块的全局选项 / Set global options for knitr code chunks

# 从CSV文件读取数据，默认以逗号分隔，结果存储在dat2变量中
# Read data from a CSV file (default separator is comma) and store it in variable dat2
dat2 <- read.csv("easy_input.csv")

# 查看数据的基本结构和内容，显示数据集行数、列数和前几行信息
# View the basic structure and content of the data, showing the number of rows, columns, and the first few lines of the dataset
head(dat2)

### 用3-6列计算百分比 ###
# 计算ILC相关百分比，将结果存储在ILC变量中，并设置基因名称作为标识
# Calculate ILC-related percentage, store the result in variable ILC, and use gene names as identifiers
ILC <- (dat2$n_ILC/dat2$total_ILC)*100
names(ILC) <- dat2$Gene

# 计算IDC相关百分比，将结果存储在IDC变量中，并设置基因名称作为标识
# Calculate IDC-related percentage, store the result in variable IDC, and use gene names as identifiers
IDC <- (dat2$n_IDC/dat2$total_IDC)*100
names(IDC) <- dat2$Gene

### group列 ###
# 为每个分组的泡泡指定一种颜色
# Assign a unique color to each group of bubbles
# 预定义足够多的颜色
# Predefine a sufficient number of colors
mycol <- c("red","navy","forestgreen","black","#FB9A99","#33A02C","#E31A1C","#B15928","#6A3D9A","#CAB2D6","#A6CEE3","#1F78B4","#FDBF6F","#999999","#FF7F00")

# 将不显著的项定义为notsig组，用灰色表示
# Define non-significant items as the 'notsig' group and color them grey
dat2$group[dat2$pvalue > 0.001] <- "notsig"

# 获取所有唯一的分组名称
# Get all unique group names
cols.names <- unique(dat2$group)

# 创建颜色映射，不显著组使用灰色，其他组使用预定义颜色
# Create color mapping: non-significant group uses grey, others use predefined colors
cols.code <- c(mycol[1:(length(cols.names)-1)],"grey")
names(cols.code) <- cols.names

sizes <- -log10(dat2$pvalue)/5
sizes[sizes=="Inf"] <- 0
names(sizes) <- dat2$Gene

# 设置图形布局，一行两列，并调整边距为底部留出图例空间
# Set graphics layout to 1 row and 2 columns, adjust margins to leave space for legends at the bottom
par(mfrow=c(1,2),mar = par()$mar + c(3,0,0,3)) 

# 绘制局部散点图（放大视图）
# Plot the local scatter plot (zoomed-in view)
plot(ILC, IDC,
     col = cols.code[as.character(dat2$group)],  # 根据分组设置点的颜色 / Set point color by group
     xlim = c(0,15), ylim=c(0,15),              # 设置坐标轴范围，只显示局部数据 / Set axis limits to show局部data
     pch = 16,                                   # 使用实心圆点作为绘图符号 / Use filled circles as symbols
     ylab = "IDC (% altered samples)",          # Y轴标签 / Y-axis label
     xlab="ILC (% altered samples)",            # X轴标签 / X-axis label
     cex = sizes)                                # 根据p值设置点的大小 / Set point size by p-value

# 添加y=x参考线
# Add y=x reference line
abline(a = 0, b = 1, col = "gray60", lwd = 1, lty = 5)

# 在实心点外部绘制白色圆圈，增强视觉效果
# Draw white circles around the solid points for better visibility
points(ILC, IDC, pch = 1, col = "white", cex = sizes)

# 标记IDC百分比大于6的点
# Label points where IDC percentage > 6
up <- which(IDC > 6)
# 标记ILC百分比大于6的点
# Label points where ILC percentage > 6
down <- which(ILC > 6)

# 允许文本绘制在绘图区域外
# Allow text to be drawn outside the plotting region
par(xpd=TRUE)

# 在指定点的左侧添加基因名称标签
# Add gene name labels to the left of specified points
text(ILC[up], IDC[up], names(ILC[up]), pos=2) 

# 在指定点的右侧添加基因名称标签
# Add gene name labels to the right of specified points
text(ILC[down], IDC[down], names(ILC[down]), pos=4)

# 定义一个函数，用于给颜色添加透明度
# Define a function to add transparency (alpha) to colors
add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2, 
        function(x) 
          rgb(x[1], x[2], x[3], alpha=alpha))  
}

# 创建带有透明度的橙色，用于背景填充
# Create transparent orange color for background fill
gray.alpha <- add.alpha("orange", alpha=0.1)

# 绘制带有透明度的橙色背景，覆盖整个绘图区域
# Draw a transparent orange background covering the entire plot area
rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = gray.alpha)

# 在底部外部添加分组颜色图例
# Add legend for group colors outside the plot at the bottom
legend("bottom", 
       inset=c(0,-.5),  # 将图例放置在图的底部外部 / Position legend below the plot
       ncol = 3,        # 图例分3列显示 / Arrange legend items in 3 columns
       pch=16,          # 使用实心圆点作为图例符号 / Use filled circles as legend symbols
       col=cols.code,   # 设置图例颜色 / Set legend colors
       legend=cols.names,  # 设置图例标签 / Set legend labels
       bty="n")           # 不显示图例边框 / Omit legend box

### 绘制整体视图 ###
# Plot the overall view
plot(ILC, IDC,
     col = cols.code[as.character(dat2$group)],  # 根据分组设置点的颜色 / Color points by group
     xlim=c(0,70), ylim=c(0,70),                # 设置更大的坐标轴范围，显示整体数据 / Set wider axis limits
     ylab="",                                   # 暂时不设置Y轴标签 / Empty Y label (will be added later)
     xlab="ILC (% altered samples)",            # X轴标签 / X-axis label
     yaxt='n',                                  # 不显示左侧Y轴 / Suppress left Y-axis
     pch=16,                                    # 使用实心圆点作为绘图符号 / Use filled circles
     cex=sizes)                                 # 根据p值设置点的大小 / Scale points by p-value

# 在实心点外部绘制白色圆圈，增强视觉效果
# Draw white circles around the solid points for better visibility
points(ILC, IDC, pch=1, col = "white", cex=sizes)

# 在右侧绘制Y轴
# Draw the Y-axis on the right side
axis(side = 4)

# 在右侧添加Y轴标签，通过mgp参数调整标签位置
# Add Y-axis label on the right side, adjust position using mgp parameter
title(ylab="IDC (% altered samples)", 
      mgp=c(-20,1,0))  # Adjust according to the specific plot size

# 标记ILC或IDC百分比大于15的点
# Label points where ILC or IDC percentage > 15
w <- which(ILC > 15 | IDC > 15)

# 在指定点的上方添加基因名称标签
# Add gene name labels above the specified points
text(ILC[w], IDC[w], names(ILC[w]), pos=3)

# 添加点大小的图例，表示显著性水平
# Add legend for point size indicating significance level
u <- par("usr")  # 获取当前绘图区域的坐标范围 / Get current plot coordinates
f <- c(1,2.5,5,10,20)  # 定义显著性水平的参考值 / Define reference values for significance
s <- sqrt(f/3)  # 计算对应的点大小 / Calculate corresponding point sizes

# 在底部外部添加大小图例
# Add size legend outside the plot at the bottom
legend("bottom", 
       inset=c(0,-.5),  # 将图例放置在图的底部外部 / Position legend below the plot
       legend=rep("", length(f)),  # 空标签，仅显示符号 / Empty labels, show symbols only
       title = "Significance level [-log10(q)]",  # 图例标题 / Legend title
       pch=1,  # 使用空心圆圈作为图例符号 / Use open circles as symbols
       pt.cex=s,  # 设置符号大小 / Set symbol sizes
       bty='n',  # 不显示图例边框 / Omit legend box
       horiz = TRUE)  # 水平排列图例项 / Arrange items horizontally

# 恢复默认设置，禁止在绘图区域外绘制内容
# Reset to default, disable drawing outside the plot region
par(xpd = F)

# 添加y=x参考线（虚线）
# Add y=x reference line (dashed)
abline(a = 0, b = 1, col = "gray60", lwd = 1, lty=2)

# 在整体图中标记局部区域的位置，使用与局部图相同的背景颜色
# Mark the location of the zoomed-in region in the overall plot with the same background color
rect(par("usr")[1]/4.6, par("usr")[3]/4.6, par("usr")[2]/4.6, par("usr")[4]/4.6, col = gray.alpha, border=TRUE)

# 保存当前图形状态，以便后续使用
# Save the current plot for later use
recordedplot1 <- recordPlot()

# 将图形保存为PDF文件
# Save the plot to a PDF file
pdf("baseZoom.pdf",10,5.5)
recordedplot1
dev.off()
