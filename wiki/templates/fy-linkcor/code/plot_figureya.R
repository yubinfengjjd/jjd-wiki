library(data.table) # 读取大数据集 for reading large datasets
library(GSVA) # 计算通路富集得分 for calculating pathway enrichment scores
library(ggplot2) # 画图 for plotting
library(ggcor) # 相关性图 for correlation plots by Yuhui Li
Sys.setenv(LANGUAGE = "en") #显示英文报错信息
options(stringsAsFactors = FALSE) #禁止chr转成factor

# 读取gmt文件为列表形式，满足pathifier的输入要求
# Read gmt file as list format to meet pathifier input requirements

gmt2list <- function(annofile){
  if (!file.exists(annofile)) {
    stop("There is no such gmt file.")
  }
  
  if (tools::file_ext(annofile) == "xz") {
    annofile <- xzfile(annofile)
    x <- scan(annofile, what="", sep="\n", quiet=TRUE)
    close(annofile)
  } else if (tools::file_ext(annofile) == "gmt") {
    x <- scan(annofile, what="", sep="\n", quiet=TRUE)
  } else {
    stop ("Only gmt and gmt.xz are accepted for gmt2list")
  }
  
  y <- strsplit(x, "\t")
  names(y) <- sapply(y, `[[`, 1)
  
  annoList <- lapply(y, `[`, c(-1,-2))
  return(annoList)
}

# load TCGA-BLCA FPKM
expr <- read.table("tcga_blca_fpkm.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)
tumsam <- colnames(expr)[substr(colnames(expr),11,13) == "01A"] # 取出肿瘤样本
# load immunotherapy-predicted pathways
immPath <- read.table("immunotherapy predicted pathways.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)
immPath.list <- list()
for (i in rownames(immPath)) {
  tmp <- immPath[i,"Genes"]
  tmp <- toupper(unlist(strsplit(tmp,", ",fixed = T)))
  tmp <- gsub(" ","",tmp)
  immPath.list[[i]] <- tmp
}

# load bladder cancer related signatures
blcaPath <- read.table("bladder cancer signature.txt",sep = "\t",row.names = 1,check.names = F,stringsAsFactors = F,header = T)
blcaPath.list <- list()
for (i in rownames(blcaPath)) {
  tmp <- blcaPath[i,"Genes"]
  tmp <- toupper(unlist(strsplit(tmp,", ",fixed = T)))
  tmp <- gsub(" ","",tmp)
  blcaPath.list[[i]] <- tmp
}

# 计算immunotherapy-predicted pathways的富集得分
# Calculate enrichment scores for immunotherapy-predicted pathways
immPath.param <- GSVA::ssgseaParam(
  as.matrix(log2(expr[,tumsam] + 1)),
  immPath.list
)
immPath.score <- GSVA::gsva(immPath.param, verbose = FALSE)
# 保存到文件，便于套用 Save to file for easy reuse
write.table(immPath.score, "easy_input_immPath.txt", sep = "\t", row.names = TRUE, col.names = NA, quote = FALSE)

# 计算膀胱癌相关签名的富集得分
# Calculate enrichment scores for bladder cancer related signatures
blcaPath.param <- GSVA::ssgseaParam(
  as.matrix(log2(expr[,tumsam] + 1)),
  blcaPath.list
)
blcaPath.score <- GSVA::gsva(blcaPath.param, verbose = FALSE)
# 保存到文件，便于套用 Save to file for easy reuse
write.table(blcaPath.score, "easy_input_blcaPath.txt", sep = "\t", row.names = TRUE, col.names = NA, quote = FALSE)


# 加载单个基因的表达量，也就是"1对多"的"1"
# Load expression of a single gene, which is the "1" in "1-to-many"
siglec15 <- read.csv("easy_input_gene.csv", row.names = 1, check.names = F)

# 加载第一组富集得分 Load first set of enrichment scores
immPath.score <- read.table("easy_input_immPath.txt", check.names = F)
# 跟目标基因SIGLEC15的表达量合并 Merge with target gene SIGLEC15 expression
immPath.score <- rbind.data.frame(immPath.score,
                                  siglec15)

# 加载第二组富集得分 Load second set of enrichment scores
blcaPath.score <- read.table("easy_input_blcaPath.txt", check.names = F)
# 跟目标基因SIGLEC15的表达量合并 Merge with target gene SIGLEC15 expression
blcaPath.score <- rbind.data.frame(blcaPath.score,
                                   siglec15)

# 循环计算相关性并绘制左下角｜Loop to calculate correlations and plot bottom left
immCorSiglec15 <- NULL
for (i in rownames(immPath.score)) {
  # 确保数据是数值型 Ensure data is numeric
  x_data <- as.numeric(immPath.score[i,])
  y_data <- as.numeric(siglec15)

  cr <- cor.test(x_data, y_data, method = "pearson")
  immCorSiglec15 <- rbind.data.frame(immCorSiglec15,
                                     data.frame(gene = "Siglec15",
                                                path = i,
                                                r = cr$estimate,
                                                p = cr$p.value,
                                                stringsAsFactors = F),
                                     stringsAsFactors = F)
}
immCorSiglec15$sign <- ifelse(immCorSiglec15$r > 0,"pos","neg")
immCorSiglec15$absR <- abs(immCorSiglec15$r)
immCorSiglec15$rSeg <- as.character(cut(immCorSiglec15$absR,c(0,0.25,0.5,0.75,1),labels = c("0.25","0.50","0.75","1.00"),include.lowest = T))
immCorSiglec15$pSeg <- as.character(cut(-log10(immCorSiglec15$p),c(0,2,5,10,Inf),labels = c("ns (p≥0.01)","<0.01 (2≤-log10p<5)","<0.001 (5≤-log10p<10)","<1e-10 (-log10p≥10)"),include.lowest = T))
immCorSiglec15[nrow(immCorSiglec15),"pSeg"] <- "Not Applicable"

immCorSiglec15$rSeg <- factor(immCorSiglec15$rSeg, levels = c("0.25","0.50","0.75","1.00"))
immCorSiglec15$pSeg <- factor(immCorSiglec15$pSeg, levels = c("<1e-10 (-log10p≥10)","<0.001 (5≤-log10p<10)","<0.01 (2≤-log10p<5)","Not Applicable","ns (p≥0.01)"))
immCorSiglec15$sign <- factor(immCorSiglec15$sign, levels = c("pos","neg"))

p1 <- quickcor(t(immPath.score), 
         type = "lower",
         show.diag = TRUE) + 
  geom_colour() +
  add_link(df = immCorSiglec15, 
           mapping = aes(colour = pSeg, size = rSeg, linetype = sign),
           spec.key = "gene",
           env.key = "path",
           diag.label = FALSE) +
  scale_size_manual(values = c(0.5, 1, 1.5, 2)) +
  scale_color_manual(values = c("#19A078","#DA6003","#7570B4","#E8288E","#65A818")) +
  scale_fill_gradient2(low = "#9483E1",mid = "white",high = "#E11953",midpoint=0) +
  remove_axis("x")
p1
ggsave(filename = "ggcor plot in bottom left.pdf", width = 10,height = 8)

# 循环计算相关性并绘制右上角｜Loop to calculate correlations and plot top right
blcaCorSiglec15 <- NULL
for (i in rownames(blcaPath.score)) {
  # 确保数据是数值型｜Ensure data is numeric
  x_data <- as.numeric(blcaPath.score[i,])
  y_data <- as.numeric(siglec15)
  
  cr <- cor.test(x_data, y_data, method = "pearson")
  blcaCorSiglec15 <- rbind.data.frame(blcaCorSiglec15,
                                     data.frame(gene = "Siglec15",
                                                path = i,
                                                r = cr$estimate,
                                                p = cr$p.value,
                                                stringsAsFactors = F),
                                     stringsAsFactors = F)
}
blcaCorSiglec15$sign <- ifelse(blcaCorSiglec15$r > 0,"pos","neg")
blcaCorSiglec15$absR <- abs(blcaCorSiglec15$r)
blcaCorSiglec15$rSeg <- as.character(cut(blcaCorSiglec15$absR,c(0,0.25,0.5,0.75,1),labels = c("0.25","0.50","0.75","1.00"),include.lowest = T))
blcaCorSiglec15$pSeg <- as.character(cut(-log10(blcaCorSiglec15$p),c(0,2,5,10,Inf),labels = c("ns (p≥0.01)","<0.01 (2≤-log10p<5)","<0.001 (5≤-log10p<10)","<1e-10 (-log10p≥10)"),include.lowest = T))
blcaCorSiglec15[nrow(blcaCorSiglec15),"pSeg"] <- "Not Applicable"

blcaCorSiglec15$rSeg <- factor(blcaCorSiglec15$rSeg, levels = c("0.25","0.50","0.75","1.00"))
blcaCorSiglec15$pSeg <- factor(blcaCorSiglec15$pSeg, levels = c("<1e-10 (-log10p≥10)","<0.001 (5≤-log10p<10)","<0.01 (2≤-log10p<5)","Not Applicable","ns (p≥0.01)"))
blcaCorSiglec15$sign <- factor(blcaCorSiglec15$sign, levels = c("pos","neg"))

p2 <- quickcor(t(blcaPath.score), 
         type = "upper",
         show.diag = TRUE) + 
  geom_colour() +
  add_link(df = blcaCorSiglec15, 
           mapping = aes(colour = pSeg, size = rSeg, linetype = sign),
           spec.key = "gene",
           env.key = "path",
           diag.label = FALSE) +
  scale_size_manual(values = c(0.5, 1, 1.5, 2)) +
  scale_color_manual(values = c("#19A078","#DA6003","#7570B4","#E8288E","#65A818")) +
  scale_fill_gradient2(low = "#9483E1",mid = "white",high = "#E11953",midpoint=0) +
  remove_axis("x")
p2
ggsave(filename = "ggcor plot in top right.pdf", width = 10,height = 8)
