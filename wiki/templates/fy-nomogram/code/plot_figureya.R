library(survival) # 生存分析 survival analysis
library(regplot) # 新型nomogram new nomogram
library(rms) # 经典nomogram classic nomogram
library(nomogramEx) # 输出nomogram公式 output nomogram formula
Sys.setenv(LANGUAGE = "en") #显示英文报错信息 display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor prohibit the conversion of chr to factor

# 加载修改后的 regplot 函数，使其支持非交互式环境生成 PDF
# Load modified regplot function to support non-interactive PDF generation
source("regplot_functions_modified.R")
source("regplot_modified.R")
# 如果需要使用原版 regplot，请注释掉上面两行代码
# If you need to use the original regplot, please comment out the above two lines of

pbc <- read.table("easy_input.txt")

pbc$catbili <- cut(pbc$bili, breaks = c(-Inf, 2, 4, Inf),
                   labels=c("low", "medium", "high"))
pbc$died <- pbc$status == 2

head(pbc)

dd <- datadist(pbc)
options(datadist="dd")
options(na.action="na.delete")
summary(pbc$time)
coxpbc <- cph(formula = Surv(time,died) ~  age + catbili + sex + copper + stage + trt ,data=pbc,x=T,y=T,surv = T,na.action=na.delete)  #,time.inc =2920

print(coxpbc)
surv <- Survival(coxpbc) 
surv3 <- function(x) surv(1825,x)
surv4 <- function(x) surv(2920,x)

x <- nomogram(coxpbc,fun = list(surv3,surv4),lp=T,
            funlabel = c('5-year survival Probability','8-year survival Probability'),
            maxscale = 100,fun.at = c(0.95,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1))

pdf("nomogram_classical.pdf",width = 12,height = 10)
plot(x, lplabel="Linear Predictor",
     xfrac=.35,varname.label=TRUE, varname.label.sep="=", ia.space=.2, 
     tck=NA, tcl=-0.20, lmgp=0.3,
     points.label='Points', total.points.label='Total Points',
     total.sep.page=FALSE, 
     cap.labels=FALSE,cex.var = 1.6,cex.axis = 1.05,lwd=5,
     label.every = 1,col.grid = gray(c(0.8, 0.95)))
dev.off()

#print(x)
nomogramEx(nomo=x,np=2,digit = 9)

pbccox <- coxph(formula = Surv(time,died) ~  age + catbili + sex +
                   copper + stage + trt , data = pbc)

# 生成 Cox 回归 nomogram PDF
# Generate Cox regression nomogram PDF
pdf("nomogram_regplot_cox.pdf", width = 12, height = 8)
regplot(pbccox,
        observation=pbc[2,], #对观测2的六个指标在列线图上进行计分展示，也可以不展示 the six indicators for Observation 2 can be scored and displayed on the nomogram, or they may not be displayed.
        points = TRUE, #如果为FALSE，则显示每个βx贡献的回归分数。否则，贡献将以 0-100 的"点数"刻度表示 If FALSE the regression scores of each βx contribution are shown. Otherwise contributions are represented by a 0-100 "points" scale.
        plots = c("density", #可选"no plot" "density" "boxes" "ecdf" "bars" "boxplot" "violin" "bean" "spikes" optional "no plot" "density" "boxes" "ecdf" "bars" "boxplot" "violin" "bean" "spikes"
                  "boxes"), #可选"no plot" "boxes" "bars" "spikes" optional "no plot" "boxes" "bars" "spikes"
        failtime = c(1095,1825), #预测3年和5年的死亡风险，此处单位是day predict the risk of death over 3 and 5 years, with the unit being days.
        subticks = TRUE,
        clickable = FALSE, # 非交互式环境必须设置为 FALSE / Must be FALSE in non-interactive environment
        prfail = TRUE, #cox回归中需要TRUE TRUE is required in cox regression
        showP = T, #是否展示统计学差异 whether to demonstrate statistical differences
        droplines = F,#观测2示例计分是否画线 Observation 2 example scoring whether or not to draw a line
        rank="range", #rank="range "表示βx的范围，rank="sd "表示βx的标准差 rank="range" is by the range of the βx's, and rank="sd" is by the standard deviation of the βx's.
        interval="confidence") #展示观测的可信区间 demonstrate confidence intervals for observations
dev.off()

## 绘制逻辑回归图，显示几率表和置信区间
## Plot a logistic regression, showing odds scale and confidence interval
pbcglm <- glm(died ~  age + catbili + sex + copper, family = "binomial", data=pbc )

# 生成逻辑回归 nomogram PDF
# Generate logistic regression nomogram PDF
pdf("nomogram_regplot_glm.pdf", width = 10, height = 8)
regplot(pbcglm,
        observation=pbc[1,],
        points = TRUE,
        subticks = TRUE,
        clickable = FALSE, # 非交互式环境必须设置为 FALSE / Must be FALSE in non-interactive environment
        odds = TRUE,
        interval = "confidence")
dev.off()

set.seed(123)  # 设置随机种子以确保结果可重复 / Set seed for reproducibility
f5 <- cph(formula = Surv(time,died) ~  age + catbili + sex + copper +stage + trt,data=pbc,x=T,y=T,surv = T,na.action=na.delete,time.inc = 1825) 

#参数m=50表示每组50个样本进行重复计算
#the parameter m=50 means 50 samples in each group for repeated calculations
cal5 <- calibrate(f5, cmethod="KM", method="boot",u=1825,m=50,B=1000) 

pdf("calibration_5y.pdf",width = 8,height = 8)
plot(cal5,
     lwd = 2,#error bar的粗细 thickness of the error bar
     lty = 1,#error bar的类型，可以是0-6 type of the error bar, which can be 0-6.
     errbar.col = c("#2166AC"),#error bar的颜色 color of the error bar
     xlim = c(0,1),ylim= c(0,1),
     xlab = "Nomogram-prediced OS (%)",ylab = "Observed OS (%)",
     cex.lab=1.2, cex.axis=1, cex.main=1.2, cex.sub=0.6) #字的大小 font size
lines(cal5[,c('mean.predicted',"KM")], 
      type = 'b', #连线的类型，可以是"p","b","o" type of line, which can be “p”, “b”, “o”.
      lwd = 2, #连线的粗细 thickness of the line
      pch = 16, #点的形状，可以是0-20 shape of the point, which can be 0-20
      col = c("#2166AC")) #连线的颜色 color of the line
mtext("")
box(lwd = 1) #边框粗细 border thickness
abline(0,1,lty = 3, #对角线为虚线 diagonal lines are dashed
       lwd = 2, #对角线的粗细 diagonal thickness
       col = c("#224444")#对角线的颜色 diagonal color
       ) 
dev.off()

set.seed(123)  # 设置随机种子以确保结果可重复 / Set seed for reproducibility
f8 <- cph(formula = Surv(time,died) ~  age + catbili + sex + copper +stage + trt,data=pbc,x=T,y=T,surv = T,na.action=na.delete,time.inc = 2920) 
cal8 <- calibrate(f8, cmethod="KM", method="boot",u=2920,m=50,B=1000)

pdf("calibration_8y.pdf",width = 8,height = 8)
plot(cal8,
     lwd = 2,
     lty = 1,
     errbar.col = c("#B2182B"),
     xlim = c(0,1),ylim= c(0,1),
     xlab = "Nomogram-prediced OS (%)",ylab = "Observed OS (%)",
     col = c("#B2182B"),
     cex.lab=1.2,cex.axis=1, cex.main=1.2, cex.sub=0.6)
lines(cal8[,c('mean.predicted',"KM")],
      type= 'b',
      lwd = 2,
      col = c("#B2182B"),
      pch = 16)
mtext("")
box(lwd = 1)
abline(0,1,lty= 3,
       lwd = 2,
       col =c("#224444"))
dev.off()

pdf("calibration_compare.pdf",width = 8,height = 8)
plot(cal5,lwd = 2,lty = 0,errbar.col = c("#2166AC"),
     bty = "l", #只画左边和下边框 draw only the left and lower borders
     xlim = c(0,1),ylim= c(0,1),
     xlab = "Nomogram-prediced OS (%)",ylab = "Observed OS (%)",
     col = c("#2166AC"),
     cex.lab=1.2,cex.axis=1, cex.main=1.2, cex.sub=0.6)
lines(cal5[,c('mean.predicted',"KM")],
      type = 'b', lwd = 1, col = c("#2166AC"), pch = 16)
mtext("")

plot(cal8,lwd = 2,lty = 0,errbar.col = c("#B2182B"),
     xlim = c(0,1),ylim= c(0,1),col = c("#B2182B"),add = T)
lines(cal8[,c('mean.predicted',"KM")],
      type = 'b', lwd = 1, col = c("#B2182B"), pch = 16)

abline(0,1, lwd = 2, lty = 3, col = c("#224444"))

legend("topleft", #图例的位置 location of the legend
       legend = c("5-year","8-year"), #图例文字 legend text
       col =c("#2166AC","#B2182B"), #图例线的颜色，与文字对应 color of the legend line, corresponding to the text
       lwd = 2,#图例中线的粗细 thickness of lines in the legend
       cex = 1.2,#图例字体大小 legend font size
       bty = "n")#不显示图例边框 legend border not displayed
dev.off()
