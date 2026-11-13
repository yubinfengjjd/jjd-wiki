run_models_and_calculate_auc <- function(flist, df, response_variable) {
	n.model <- length(flist)
	aucDF <- data.frame(model = integer(), auc = numeric(), n.mRNA = integer(), stringsAsFactors = FALSE)
	
	for (i in 1:n.model) {
		display.progress(index = i, totalN = n.model)
		
		formula <- flist[[i]]
		model <- glm(formula = formula, data = df, family = "binomial", control = list(maxit = 50), na.action = na.exclude)
		predictions <- predict(model, newdata = df, type = "response")
		auc_value <- lares::quiet(auc(response = df[[response_variable]], predictor = predictions))
		
		aucDF <- rbind(aucDF, data.frame(
			model = i,
			auc = auc_value,
			n.mRNA = length(attr(terms(formula), "term.labels")),
			stringsAsFactors = FALSE
		))
	}
	return(aucDF)
}
