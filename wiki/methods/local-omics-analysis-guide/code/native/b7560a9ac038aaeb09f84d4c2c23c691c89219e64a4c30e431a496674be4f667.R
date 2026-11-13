find_cell_type <- function(gene) {
	# 遍历small_marker_dict，检查基因是否在列表中
	cell_types <- names(small_marker_dict)[sapply(small_marker_dict, function(markers) gene %in% markers)]
	# 如果找到对应的细胞类型，返回类型名称，否则返回"Unknown"
	if (length(cell_types) > 0) {
		return(cell_types[1])  # 只返回第一个匹配的细胞类型
	} else {
		return("Unknown")
	}
}
