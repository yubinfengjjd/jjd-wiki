library(survival) # 生存分析 survival analysis
library(survminer) # 生存曲线绘制 survival curve plotting
Sys.setenv(LANGUAGE = "en") #显示英文报错信息 display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor prohibit the conversion of chr to factor

df <- read.csv("easy_input.csv",row.names = 1)
head(df)

df$bestA <- cut(df[,3],breaks=c(-Inf,766.37, Inf), #其中766.37要改成你的基因A的高低分界值 among them, 766.37 should be changed to the high and low boundary value of your gene A
                   labels=c("0","1"))
df$bestB <- cut(df[,4],breaks=c(-Inf,880.23, Inf), #其中880.23要改成你的基因B的高低分界值 among them, 880.23 should be changed to the high and low boundary value of your gene B
                   labels=c("0","1"))
df$bestGroup <- paste0(df$bestA,df$bestB)
#按照两个基因表达量高低的排列组合分成4组
#divided into 4 groups according to the arrangement of high and low expression of the two genes
df$bestGroup <- ifelse(df$bestGroup=='00','1',ifelse(df$bestGroup=='10','2',ifelse(df$bestGroup=="01","3","4")))
head(df)

df$group <- df$bestGroup


#定义结局变量，生存时间和结局
#define ending variables, survival times and endings
y <- Surv(df$futime, df$fustat==1)

#logrank检验两两比较的结果
#logrank test for two-by-two comparisons
comp <- pairwise_survdiff(Surv(futime,fustat) ~ group, data = df)
pvalue <- as.vector(unlist(comp$p.value))

#将p value和两两比较的组别生成两列的数据集
#generate a two-column dataset of p values and two-by-two comparison groups
name <- array(dim=c(3,3))
for(i in 1:3){
  for(j in 2:4){
    name[i,j-1] = print(paste(i,j,sep = " vs "))
  }
}
pvalue_name <- as.vector(t(name))
logrank <- data.frame(pvalue_name,pvalue)
logrank

#挑选p value小于0.05的记录
#select records with p value less than 0.05
logrank_sig <- subset(logrank, pvalue < 0.05)
#如果p值太小，就写“<0.0001”，否则保留小数点后4位
#if the p-value is too small, write “<0.0001”, otherwise keep 4 decimal places
logrank_sig$pvalue <- lapply(logrank_sig$pvalue,function(i)
  ifelse (i<0.0001,"<0.0001",round(i, 4)))
logrank_sig

#进行COX回归，导出每组对应的HR值，并将1赋值给对照组
#perform COX regression, derive the corresponding HR values for each group, and assign 1 to the control group
coxph.fit <- coxph(y ~ as.factor(group), data = df) 
hr <- round(coef(summary(coxph.fit))[,2],3)
HR <- c(1,as.vector(unlist(hr)))

#KM曲线的绘制
#KM curve plotting
kmfit <- survfit(y~df$group,)

#写legend
#write legend
A = c("Low; ", "High;", "Low; ", "High;")
B = c("Low; ", "Low; ", "High;", "High;")
Group = c(1,2,3,4)
text.legend1 <- paste0(colnames(df)[3], " = ", A, colnames(df)[4], " = ", B, " Group = ", Group, ", HR = ", HR)
text.legend2 <- paste0(logrank_sig$pvalue_name," : ",logrank_sig$pvalue)

#自定义足够你用的颜色
#customize enough colors for you
mycol <- c("#223D6C","#D20A13","#FFD121","#088247","#11AA4D","#58CDD9","#7A142C","#5D90BA","#431A3D","#91612D","#6E568C","#E0367A","#D8D155","#64495D","#7CC767")

#画图，并保存到pdf文件
#draw and save to a pdf file
pdf("nSurv.pdf",width = 7,height = 6)
par(xpd = T, 
    mar = par()$mar + c(0,0,0,5)#,#在右侧给图例留出空间 leave space for the legend on the right side
    #cex.axis=0.8, cex.lab=1, cex.main=1, cex.sub=1 #修改字体大小 modify font size
    )
plot(kmfit, 
     col= mycol, 
     lwd = 1.4,#线的粗细 thickness of line
     #pch = "o", #如果你也想让观测点的形状是o，就运行这行 if you also want the observation point to be shaped like an o, run this line
     xlab="Months from diagnosis", 
     ylab="Survival Distribution Function", 
     mark.time=TRUE)
legend("bottomleft", lty=c("solid","solid","solid","solid"),
       col=mycol, 
       legend=text.legend1, 
       bty="n", 
       lwd = 2,
       cex=0.8)
legend("topright", 
       inset=c(-0.3,0), #图例画到图外面 legend is drawn to the outside of the figure
       legend=c("Pairwise comparison",text.legend2), 
       bty="n", 
       cex=0.8)
dev.off()
