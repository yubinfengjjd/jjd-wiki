is_valid_combination <- function(method_str) {
	components <- unlist(strsplit(method_str, "\\+"))

	all(components %in% names(preTrain.var_filtered))
}
