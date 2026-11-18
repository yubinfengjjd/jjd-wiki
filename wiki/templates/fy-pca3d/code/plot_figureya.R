library(rgl) # 3D绘图工具 The 3D plotting tool
Sys.setenv(LANGUAGE = "en") #显示英文报错信息 # Display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor # Disable conversion of chr to factor

## 读取基因表达矩阵 Read the gene expression matrix
#exp_data <- read.table("CGGA.mRNA_array_301_gene_level.20191128.txt", header=T, row.names=1, sep="\t")
# 为方便传输，只保留小数点后1位
# For ease of transmission, only one decimal place is retained
#write.csv(round(exp_data,1), "easy_input_expr_ori.csv", quote = F)
exp_data <- read.csv("easy_input_expr_all.csv", row.names = 1)
exp_data[1:3,1:3]

## 读取分组信息 Read group information
## 用到两列：CGGA_ID和Grade Use two columns: CGGA_ID and Grade
clinical_data <- read.table("CGGA.mRNA_array_301_clinical.20191128.txt", header=T, sep="\t")
clinical_data <- clinical_data[!is.na(clinical_data$Grade), ]
clinical_data[1,]
table(clinical_data$Grade)

# 获取LGG样本名称，Grade里的WHO II和WHO III定义为LGG
# Get the LGG sample name. WHO II and WHO III in Grade are defined as LGG.
lgg_sample <- as.character(subset(clinical_data, Grade %in% c("WHO II", "WHO III"))[, "CGGA_ID"])
lgg_sample <- lgg_sample[lgg_sample %in% colnames(exp_data)]
write.table(lgg_sample, "easy_input_group1.txt", quote = F, row.names = F)

# 获取GBM样本名称，Grade里的WHO IV定义为LGG
# Get the GBM sample name. WHO IV in Grade is defined as LGG.
gbm_sample <- as.character(subset(clinical_data, Grade %in% c("WHO IV"))[, "CGGA_ID"])
gbm_sample <- gbm_sample[gbm_sample %in% colnames(exp_data)]
write.table(gbm_sample, "easy_input_group2.txt", quote = F, row.names = F)

## 读取参与特定通路的基因 Read genes involved in a specific pathway
# 读取基因集合 # Read the gene collection
immune_response <- as.character(read.table("IMMUNE_RESPONSE_M19817.txt", skip=2)[, 1])
immune_system_process <- as.character(read.table("IMMUNE_SYSTEM_PROCESS_M13664.txt", skip=2)[, 1])
immune_genes <- unique(c(immune_response, immune_system_process))
immune_genes <- immune_genes[immune_genes %in% rownames(exp_data)]

# 获取感兴趣的基因表达谱 # Obtain gene expression profiles of interest
immune_data <- exp_data[immune_genes, c(lgg_sample, gbm_sample)]
immune_data[1:5, 1:5]
# 保存到文件 # Save to file
write.csv(immune_data, "easy_input_expr.csv", quote = F)

# 读取基因表达矩阵 # Read gene expression matrix
immune_data <- read.csv("easy_input_expr.csv", row.names = 1)
immune_data[1:3,1:3]
dim(immune_data)

# 做PCA # Perform PCA
pca <- prcomp(t(immune_data))

# 两个分组的sample ID
# Sample IDs for the two groups
lgg_sample <- read.table("easy_input_group1.txt", header = T)$x
gbm_sample <- read.table("easy_input_group2.txt", header = T)$x

# 准备颜色
# Prepare the colors
lgg_color <- rep("yellow", length(lgg_sample))
names(lgg_color) <- lgg_sample
gbm_color <- rep("red", length(gbm_sample))
names(gbm_color) <- gbm_sample
groups <- c(lgg_color, gbm_color)

# 3d PCA图
# 3D PCA plot
plot3d(pca$x[,1:3], # 取前三个主成分 # Take the first three principal components
       xlab="Comp.1", ylab="Comp.2", zlab="Comp.3", 
       col=groups, # 按groups填充颜色 # Fill color by group
       type="s", # 画球，'p' for points, 's' for spheres, 'l' for lines, 'h' for line segments 
# Draw spheres, 'p' for points, 's' for spheres, 'l' for lines, 'h' for line segments
       size=1, #球的大小 # Size of the spheres
       lwd=2, box=T)
# 保存(目前只能保存为png)
#rgl.snapshot("PCA.png")
# Save (Currently only saves to png)
#rgl.snapshot("PCA.png")

#手动调好3D图形位置，获得角度
# Manually adjust the 3D shape's position and obtain the angle
myMatrix <- par3d()
userMatrix <- myMatrix$userMatrix
windowRect <- myMatrix$windowRect
# 把角度保存到文件
# Save the angle to a file
#save(userMatrix, windowRect, file = "mypar3d.RData")

# 载入之前调好的角度
# Load the previously adjusted angle
(load("mypar3d.RData"))
head(userMatrix) # a 4 by 4 matrix describing user actions to display the scene.
head(windowRect) # integer. A vector of four values indicating the left, top, right and bottom of the displayed window (in pixels). Applies to the whole device.
par3d(userMatrix=userMatrix, windowRect=windowRect)
rglwidget()

# 保存(目前只能保存为png)
# Save (Currently only saves as PNG)
#rgl.snapshot("PCA.png")

legend3d("topright", # legend的位置 # Legend position
         legend = c("LGG (n=173)", "GBM (n=124)"), # 手写文字 # Handwritten text
         bty = "n", # 不带边框 # No border
         cex = 2, # 文字大小 # Text size
         pch = 16, # 圆形 # Circle
         col = c("yellow", "red")) # 颜色跟图中一致 # Colors consistent with the image
# 保存(目前只能保存为png) # Save (Currently only saves to PNG)
rgl.snapshot("PCA.png")
