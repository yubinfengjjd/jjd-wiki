# 设置knitr的全局代码块选项 / Set global chunk options for knitr

library(timeROC) # 时间依赖型ROC曲线分析 time-dependent ROC curve analysis
library(survival) # 生存分析 survival analysis
# 设置环境语言为英文，以便显示英文错误信息 - Set the environment language to English to display error messages in English
Sys.setenv(LANGUAGE = "en") 
# 禁止字符串自动转换为因子，避免数据类型意外转换 - Disable automatic conversion of strings to factors to avoid unexpected data type conversions
options(stringsAsFactors = FALSE) 

# 从CSV文件读取数据并设置第一列为行名 - Read data from a CSV file and set the first column as row names
tr <- read.csv("easy_input.csv", row.names = 1)

# 计算标记变量a的时间依赖型ROC曲线 - Calculate time-dependent ROC curve for marker a
# T: 生存时间 - Survival time
# delta: 事件状态（0= censored, 1= event） - Event status (0=censored, 1=event)
# marker: 预测标记变量 - Predictor marker
# other_markers: 调整的协变量矩阵 - Covariates matrix for adjustment
# cause: 关注的事件类型（竞争风险分析） - Event type of interest (for competing risks)
# weighting: 权重方法 - Weighting method
# times: 计算ROC的时间点 - Time points to calculate ROC
# iid: 是否返回个体水平估计 - Whether to return individual-level estimates
ROC.a <- timeROC(T=tr$time, 
                 delta=tr$status, marker=tr$a,
                 other_markers=as.matrix(tr[,c("age","sex")]),
                 cause=1,
                 weighting="marginal",
                 times=c(0,50,100,150,200,250,300,350,400),
                 iid=TRUE)

# ROC.b与其他两个的设置相比，marker设置不同，可以看到tr$b前后多一个负号("-")
# The marker setting for ROC.b is different from the others, with a negative sign before tr$b
# 原因在于该变量和结局事件的关系是该变量数值增大，结局事件发生率反而降低。
# This is because this variable has an inverse relationship with the outcome event (higher values indicate lower risk)

# 计算标记变量b的时间依赖型ROC曲线（取负值以反映负相关关系）
# Calculate time-dependent ROC curve for marker b (negated to reflect inverse relationship)
ROC.b <- timeROC(T= tr$time, delta= tr$status, marker=-tr$b,
               other_markers=as.matrix(tr[,c("age","sex")]),
               cause=1,weighting="marginal",
               times=c(0,50,100,150,200,250,300,350,400),
               iid=TRUE)

# 计算标记变量c的时间依赖型ROC曲线 - Calculate time-dependent ROC curve for marker c
ROC.c <- timeROC(T=tr$time, delta=tr$status,marker=tr$c,
               other_markers=as.matrix(tr[,c("age","sex")]),
               cause=1,weighting="marginal",
               times=c(0,50,100,150,200,250,300,350,400),
               iid=TRUE)

# 创建PDF文件用于保存ROC曲线图 - Create a PDF file to save the ROC curve plot
pdf("timeROC.pdf", 6, 5)  # 设置图形宽度为6英寸，高度为5英寸 - Set plot width to 6 inches and height to 5 inches

# 绘制标记变量a的时间依赖型AUC曲线 - Plot time-dependent AUC curve for marker a
plotAUCcurve(ROC.a, conf.int=FALSE, col="red")  # 不显示置信区间，曲线颜色为红色 - No confidence interval, curve color: red

# 在同一图上叠加绘制标记变量b的时间依赖型AUC曲线 - Add AUC curve for marker b to the same plot
plotAUCcurve(ROC.b, conf.int=FALSE, col="darkblue", add=TRUE)  # 曲线颜色为深蓝色 - Curve color: darkblue

# 在同一图上叠加绘制标记变量c的时间依赖型AUC曲线 - Add AUC curve for marker c to the same plot
plotAUCcurve(ROC.c, conf.int=FALSE, col="darkgreen", add=TRUE)  # 曲线颜色为深绿色 - Curve color: darkgreen

# 设置图例 - Add legend to the plot
legend("topright",  # 图例位置：右上角 - Legend position: top-right
       c("A model","B model","C model"),  # 图例标签 - Legend labels
       col=c("red","darkblue","darkgreen"),  # 对应曲线颜色 - Corresponding curve colors
       bty='n',  # 无边框 - No border
       lty=1,  # 线条类型为实线 - Line type: solid
       lwd=2,  # 线条宽度 - Line width
       cex=0.8)  # 字体大小 - Font size

dev.off()  # 关闭图形设备，保存PDF文件 - Close the graphics device and save the PDF
