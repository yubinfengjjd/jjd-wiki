generate_formulas <- function(candidate, response_variable) {
	flist <- list()
	for (i in 1:length(candidate)) {
		message("-- Generating ", i, " mRNA model...")
		tmp <- combn(candidate, m = i)
		for (j in 1:ncol(tmp)) {
			formula_str <- paste(response_variable, "~", paste(tmp[, j], collapse = " + "))
			flist <- append(flist, as.formula(formula_str))
		}
	}
	return(flist)
}
