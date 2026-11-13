run_models_caret <- function(feature_combinations, data, response_var) {
	aucDF <- data.frame(model = integer(), auc = numeric(),
											n.mRNA = integer(), stringsAsFactors = FALSE)
	formula_list <- list()
	model_list <- list()

	cl <- makePSOCKcluster(detectCores() - 1)
	registerDoParallel(cl)
	on.exit(stopCluster(cl))

	for (i in 1:length(feature_combinations)) {
		if(exists("display.progress") && exists("n.model")) {
			display.progress(i, n.model)
		}

		current_features <- feature_combinations[[i]]
		formula <- as.formula(paste(response_var, "~", paste(current_features, collapse = " + ")))
		formula_list[[i]] <- formula

		tryCatch({
			set.seed(123)
			model <- train(
				formula,
				data = data,
				method = "glm",
				family = "binomial",
				trControl = ctrl,
				metric = "ROC"
			)

			auc_value <- max(model$results$ROC)
			model_list[[i]] <- model

			aucDF <- rbind(aucDF, data.frame(
				model = i,
				auc = auc_value,
				n.mRNA = length(current_features)
			))
		}, error = function(e) {
			message("\n模型 ", i, " 出错: ", e$message)
			model_list[[i]] <- NULL

			aucDF <- rbind(aucDF, data.frame(
				model = i,
				auc = NA,
				n.mRNA = length(current_features)
			))
		})
	}

	return(list(
		aucDF = aucDF,
		formula_list = formula_list,
		model_list = model_list
	))
}
