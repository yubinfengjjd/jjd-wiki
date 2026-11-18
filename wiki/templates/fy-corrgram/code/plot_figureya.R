# 设置knitr代码块的全局选项 / Set global options for knitr code chunks

# 读取CSV文件并将第一列作为行名
# Read a CSV file and set the first column as row names
df <- read.csv("easy_input.csv", row.names = 1)

# 显示数据框的前几行，用于快速查看数据结构
# Display the first few rows of the dataframe for a quick data structure overview
head(df)

# 设置绘图背景颜色为浅灰色（接近白色）
# Set the plotting background color to a light gray (near white)
par(bg = "#fdfdfd")

# 左下角面板函数：绘制散点图并添加线性拟合线
# Lower left panel function: Plot scatter points and add a linear regression line
panel.raters <- function (x, y, corr = NULL, ...) {
  if (!is.null(corr)) 
    return()
  plot.xy(xy.coords(x, y), type = "p", 
          pch = 20, # 点形状：实心圆 / Point shape: solid circle
          cex = .5, # 点大小：0.5倍默认大小 / Point size: 0.5x default
          ...)
  abline(lm(y ~ x), lwd = 2) # 添加线性回归拟合线，线宽为2 / Add linear regression line, line width 2
  box(col = "black", lwd = 2) # 添加黑色边框，线宽为2 / Add black border, line width 2
}

# 对角线面板函数：显示变量名称
# Diagonal panel function: Display variable names
textPanel <- function (x = 0.5, y = 0.5, txt, cex, font) {
  text(x, y, txt, cex = cex, font = font)
  box(col = "black", lwd = 2) # 添加黑色边框，线宽为2 / Add black border, line width 2
}

# 右上角面板函数：显示相关系数热图
# Upper right panel function: Display correlation coefficient heatmap
panel.fill.cor <- function (x, y, corr = NULL, ...) 
{
    # 计算Pearson相关系数并保留两位小数
    # Calculate Pearson correlation coefficient and round to two decimal places
    corr <- round(cor(x, y, use = "pairwise", method = "pearson"),2) # Can be changed to "kendall" or "spearman"
    
    # 自定义渐变色板：从深蓝色到白色再到深红色
    # Custom color palette: From dark blue to white to dark red
    ncol <- 14
    col.regions <- colorRampPalette(c('darkslateblue', 'navy', 'white', 'firebrick3', 'red'))
    pal <- col.regions(ncol)
    col.ind <- as.numeric(cut(corr, breaks = seq(from = -1, to = 1, length.out = ncol + 1), include.lowest = TRUE))
    
    # 绘制背景颜色块，颜色深浅表示相关强度
    # Draw background color block, intensity indicates correlation strength
    par(new=TRUE)
    plot(0, type='n', xlim=c(-1,1), ylim=c(-1,1), axes=FALSE, asp=1)
    usr <- par("usr")
    rect(usr[1], usr[3], usr[2], usr[4], col = pal[col.ind], 
        border = NA)
    
    # 在颜色块中央显示相关系数值
    # Display correlation coefficient value in the center of the color block
    text(0, 0, labels = corr, cex = 2.5, col = ifelse(corr > 0, "black", "white"))
    box(col = "black") # 添加黑色边框 / Add black border
}

# 创建PDF设备并保存相关矩阵图
# Create PDF device and save correlation matrix plot
pdf("corrgram.pdf",8,8)
pairs(df[1:5], 
      gap = .5, # 子图之间的间距 / Spacing between subplots
      text.panel = textPanel, # 对角线面板函数 / Diagonal panel function
      lower.panel = panel.raters, # 左下角面板函数 / Lower left panel function
      upper.panel = panel.fill.cor) # 右上角面板函数 / Upper right panel function

dev.off() # 关闭PDF设备 / Close PDF device
