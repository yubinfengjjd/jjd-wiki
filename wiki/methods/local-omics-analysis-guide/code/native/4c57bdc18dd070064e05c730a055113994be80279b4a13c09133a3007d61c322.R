is_valid_combination <- function(method_str) {
	# 拆分组合方法（如 "Lasso+Stepglm" 拆分为 c("Lasso", "Stepglm")）
	components <- unlist(strsplit(method_str, "\\+"))
	
	# 检查每个子方法是否都存在于有效方法中
	all(components %in% names(preTrain.var_filtered))
}
