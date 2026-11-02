preprocess_data <- function(expFile){
	rt <- read.table(file.path("nor", expFile), sep = "\t", header = T, check.names = F)
	exp <- as.matrix(rt[, -1])
	rownames(exp) <- rt[, 1]
	return(exp)
}
