library(rms) # 画calibration图 plot calibration curve
library(scales) # 颜色透明度 color transparency
library(ResourceSelection) # Hosmer-Lemeshow goodness of fit test

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 #Display English error message
options(stringsAsFactors = FALSE) #禁止chr转成factor #Disable conversion of chr to factor

dat <- read.table("easy_input.txt",sep = "\t",check.names = F,stringsAsFactors = F,header = T,row.names = 1)
head(dat)
summary(dat$MetaScore)
table(dat$MLL2)
table(dat$MetaStatus)

# 先构建逻辑回归，使用glm函数，为了做hoslem检验
# First build a logistic regression, using the glm function, in order to do the hoslem test
fullmodel_glm <- glm(MetaStatus ~ MetaScore + MLL2, 
                     data = dat, 
                     family = "binomial", 
                     control = list(maxit = 50))

# 做hosmer-lemeshow 检验来判断no departure from perfect ???t if p > 0.05
# Do Hosmer-Lemeshow test to determine no departure from perfect ???t if p > 0.05
p.hoslem <- hoslem.test(fullmodel_glm$y, fitted(fullmodel_glm), g=10)$p.value

# 再次构建逻辑回归，但是此时使用lrm函数，为了计算calibration
# Build the logistic regression again, but this time use the lrm function to calculate the calibration
full_lrm <- lrm(MetaStatus ~ MetaScore + MLL2,
                data = dat,
                x=TRUE,
                y=TRUE)  
# 取出calibration的结果
# Get the calibration result
full_calibrate <- calibrate(full_lrm, group=dat$MetaStatus) 

red <- "#FF0197"
blue <- "#0093FF"

pdf("calibration_for full model.pdf",width = 5,height = 5)

plot(full_calibrate[,"predy"], # predicted value
     full_calibrate[,"calibrated.corrected"], # actual rate
     lty=1,type="l",lwd = 2,
     col=alpha(red,0.6), # change colors
     xlab="Nomogram Predicted Probability", ylab="Actual LN Metastasis Rate" )

# 添加45°斜线作为标准
# Add 45° diagonal line as standard
abline(0,1, lwd = 1.5, lty = "longdash", col = blue)

legend("topleft", #图例的位置 #Legend position
       legend = c("Ideal","LNM-nomogram"), #图例文字 #Legend text
       col =c(blue,red), #图例线的颜色，与文字对应 #Legend line color, corresponding to the text
       lwd = 2,#图例中线的粗细 #Legend center line thickness
       lty = c("longdash","solid"),
       cex = 1,#图例字体大小 #Legend font size
       bty = "n")#不显示图例边框 #Do not display legend border

# 添加hosmer-lemeshow检验
# Add hosmer-lemeshow test
text(0,0,bquote("Hosmer-Lemeshow "~italic(P)~" = "~.(round(p.hoslem,3))),adj = 0)

invisible(dev.off())
