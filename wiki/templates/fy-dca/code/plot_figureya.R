library(survival) # 生存分析 survival analysis
library(ggplotify) # 把基础图形转换为ggplot对象 ggplotify package converts basic graphics into ggplot objects
library(magick) # 图像处理 image processing
library(cowplot) # 图形组合 plot combination

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor prohibit the conversion of chr to factor

source("stdca.R") #stdca.R文件位于当前文件夹 stdca.R file is located in the current folder

pbc <- read.table("easy_input.txt")
pbc <- pbc[complete.cases(pbc),] #删掉缺失数据 delete missing data
#先把bili分为三类：低、中、高
#first, categorize bili into three groups: low, medium, and high
pbc$catbili <- cut(pbc$bili,breaks=c(-Inf, 2, 4, Inf),
                   labels=c("low","medium","high"))

#把status分为两类，原来的2为变成1，原来的1和0变成0
#split status into two categories, the original 2 to become 1, the original 1 and 0 to become 0
pbc$died <- pbc$status==2
pbc$status <- ifelse(pbc$died=="TRUE",1,0)

head(pbc)

Srv = Surv(pbc$time, pbc$died)

#此处选择5年的时间节点，输入文件的time列的单位是天，5年是1825天。
#下面每两行计算1种cox模型的系数，后面将画图对比
#这里模型的名字写为model1、model2，相应的图中也会显示这个名字。
#实际使用时，修改为你最终要呈现到图中的名字
#Here choose a 5 year timestep, the time column of the input file is in days, 5 years is 1825 days.
#Below, every two lines calculate the coefficients of one type of Cox model, followed by a comparison through plotting.
#Here the name of the model is written as model1, model2, and the corresponding graph will show this name.
#When you use them in practice, change them to the names you want to show in the graph.
coxmod1 = coxph(Srv ~ trt + age + sex + hepato + catbili + copper + stage, data=pbc)
pbc$model1 = c(1 - (summary(survfit(coxmod1, newdata=pbc), times=1825)$surv))

coxmod2 = coxph(Srv ~ ascites + spiders + edema + chol + albumin + alk.phos + ast + trig + platelet + protime, data=pbc)
pbc$model2 = c(1 - (summary(survfit(coxmod2,newdata=pbc), times=1825)$surv))

coxmod3 = coxph(Srv ~ trt + age + sex + hepato + catbili + copper + stage + ascites + spiders + edema + chol + albumin + alk.phos + ast + trig + platelet + protime, data=pbc)
pbc$model3 = c(1 - (summary(survfit(coxmod3,newdata=pbc), times=1825)$surv))

coxmod4 = coxph(Srv ~ stage, data=pbc)
pbc$model4 = c(1 - (summary(survfit(coxmod4,newdata=pbc), times=1825)$surv))

head(pbc)

mod1 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
                 predictors="model1", # 跟上一步模型的名字一致 same name as the model in the previous step
              cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="FALSE")

#mod2 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
#             predictors="model2", cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="FALSE")

#mod3 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
#             predictors="model3", cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="FALSE")

#mod4 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
#             predictors="model4", cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="FALSE")

pdf("net_benefit.pdf",width = 6,height = 6)
stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825,
      predictors=c("model1","model2","model3","model4"), # 跟前面模型的名字保持一致 consistent with the name of the previous model
      cmprsk=TRUE, smooth=TRUE, 
      xstop=0.5,intervention="FALSE")
dev.off()

mod1 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
      predictors="model1", cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="TRUE")

#mod2 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
#      predictors="model2", cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="TRUE")

#mod3 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
#      predictors="model3", cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="TRUE")

#mod4 <- stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825, 
#      predictors="model4", cmprsk=TRUE, smooth=TRUE, xstop=0.5,intervention="TRUE")

pdf("net_reduction.pdf",width = 6,height = 6)
stdca(data=pbc, outcome="status", ttoutcome="time", timepoint=1825,
      predictors=c("model1","model2","model3","model4"), 
      cmprsk=TRUE, smooth=TRUE, 
      xstop=0.5,intervention="TRUE")
dev.off()
