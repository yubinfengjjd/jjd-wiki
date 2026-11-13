pred_fun <- function(model, newdata) {
	prob_matrix <- predict(model, newdata = newdata, type = "prob")
	return(as.numeric(prob_matrix[, 2]))  # 二分类任务：返回正类概率
}
