fcex <- function(x) {
	x <- abs(x)
	cex <- ifelse(x < 0.1, p.cex[1], 
								ifelse(x < 0.2, p.cex[2], 
											 ifelse(x < 0.3, p.cex[3], 
											 			 ifelse(x < 0.4, p.cex[4], p.cex[5]))))
	return(cex)
}
