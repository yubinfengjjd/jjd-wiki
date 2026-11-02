generate_combinations <- function(predictors) {
	n <- length(predictors)
	all_combinations <- unlist(
		lapply(1:n, function(k) combn(predictors, k, simplify = FALSE)),
		recursive = FALSE
	)
	return(all_combinations)
}
