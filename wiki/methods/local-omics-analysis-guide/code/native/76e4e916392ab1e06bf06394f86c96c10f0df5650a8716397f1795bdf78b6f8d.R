create_optimized_corr_plot <- function(immune_matrix) {
	# 计算基因与免疫特征的相关性
	geneCor <- data.frame()
	for(cell in colnames(immune_matrix)) {
		for(gene in colnames(data)) {
			x <- as.numeric(immune_matrix[, cell])
			y <- as.numeric(data[, gene])
			corT <- cor.test(x, y, method = "spearman")
			geneCor <- rbind(geneCor, cbind(spec = gene, env = cell, 
																			r = corT$estimate, p = corT$p.value))
		}
	}
	
	# 处理相关性数据
	geneCor$r <- as.numeric(geneCor$r)
	geneCor$p <- as.numeric(geneCor$p)
	geneCor$pd <- ifelse(geneCor$p < 0.05, 
											 ifelse(geneCor$r > 0, "Positive", "Negative"), 
											 "Not")
	geneCor$r_abs <- abs(geneCor$r)
	geneCor <- geneCor %>% 
		mutate(rd = cut(r_abs, breaks = c(-Inf, 0.2, 0.4, 0.6, Inf),
										labels = c("< 0.2", "0.2 - 0.4", "0.4 - 0.6", ">= 0.6")))
	return(geneCor)
}
