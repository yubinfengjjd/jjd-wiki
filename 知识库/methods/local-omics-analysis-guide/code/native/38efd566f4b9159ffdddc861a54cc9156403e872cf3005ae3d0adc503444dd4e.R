fcolor <- function(x, p.col) {
	color <- ifelse(x > 0.8, p.col[1], 
									ifelse(x > 0.6, p.col[2], 
												 ifelse(x > 0.4, p.col[3], 
												 			 ifelse(x > 0.2, p.col[4], p.col[5]))))
	return(color)
}
