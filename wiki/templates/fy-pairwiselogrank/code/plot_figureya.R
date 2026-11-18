library(survival) # 生存分析 survival analysis
library(survminer) # 生存曲线绘制 survival curve plotting
library(RColorBrewer) # 颜色调色板 color palettes
library(tibble) # 数据框增强 enhanced data frames
library(ggpp) # ggplot2扩展 ggplot2 extensions

# 显示英文报错信息
# Show English error messages
Sys.setenv(LANGUAGE = "en")

# 禁止chr转成factor
# Prevent character-to-factor conversion
options(stringsAsFactors = FALSE) 

# 加载示例数据
# Load example data
dat <- read.table("easy_input.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)

# 仿照原文将PAM50分型按照ABCDE标记
# Label PAM50 subtypes as A-E following the paper
dat$group <- sapply(dat$PAM50,function(x) {
  switch(x, 
         "Basal"  = "A", 
         "Her2"   = "B", 
         "LumA"   = "C", 
         "LumB"   = "D", 
         "Normal" = "E")}) 

# 将生存时间转换为月份
# Convert survival time to months
dat$OS.time <- dat$OS.time * 12 

# 生存分析
# Survival analysis
fitd <- survdiff(Surv(OS.time, OS) ~ group,
                 data      = dat,
                 na.action = na.exclude)
p.val <- 1 - pchisq(fitd$chisq, length(fitd$n) - 1)

# 拟合生存曲线
# Fit survival curves
fit <- survfit(Surv(OS.time, OS)~ group,
               data      = dat,
               type      = "kaplan-meier",
               error     = "greenwood",
               conf.type = "plain",
               na.action = na.exclude)

# 配对生存分析
# Pairwise survival analysis
ps <- pairwise_survdiff(Surv(OS.time, OS)~ group,
                        data            = dat,
                        p.adjust.method = "none") 

# 设置颜色
# Set colors
mycol <- brewer.pal(n = 10, "Paired")[c(2,4,6,8,10)]

# 绘制基础图形
# Draw the basic graphics

## 隐藏类标记
## Remove "group=" prefix
names(fit$strata) <- gsub("group=", "", names(fit$strata))

## 生存曲线图
## Survival curve plot
p <- ggsurvplot(fit               = fit,
                # 不绘制置信区间 
                # No confidence intervals
                conf.int          = FALSE, 
                # 生存风险表 
                #Show risk table
                risk.table        = TRUE, 
                risk.table.col    = "strata",
                # KM曲线颜色
                # KM curve colors
                palette           = mycol, 
                data              = dat,
                # 时间轴，一般考虑5年（原文）或者10年长度
                # Time axis (5-10 year range)
                xlim              = c(0,120), 
                size              = 1,
                # 时间轴的刻度（每年）
                # Tick marks (annual)
                break.time.by     = 12, 
                legend.title      = "",
                xlab              = "Time (months)",
                ylab              = "Overall survival",
                risk.table.y.text = FALSE,
                # 风险表的高度
                # Risk table height
                tables.height     = 0.3) 
p

## 添加overall p value
## Add overall p-value
p.lab <- paste0("log-rank test P",
                ifelse(p.val < 0.001, " < 0.001", 
                       paste0(" = ",round(p.val, 3))))

p$plot <- p$plot + annotate("text",
                            x = 0, y = 0.55, 
                            hjust = 0,
                            fontface = 4,
                            label = p.lab)
p

## 添加配对表格
## Add pairwise comparison table
addTab <- as.data.frame(as.matrix(ifelse(round(ps$p.value, 3) < 0.001, "<0.001",
                                         round(ps$p.value, 3))))
addTab[is.na(addTab)] <- "-"
df <- tibble(x = 0, y = 0, tb = list(addTab))
p$plot <- p$plot + 
  geom_table(data = df, 
             aes(x = x, y = y, label = tb), 
             table.rownames = TRUE)
p

# 输出图像
# Save plot
pdf.options(reset = TRUE, onefile = FALSE)
pdf("km curve with pairwise logrank test.pdf", width = 4.5, height = 6)
print(p)
dev.off()
