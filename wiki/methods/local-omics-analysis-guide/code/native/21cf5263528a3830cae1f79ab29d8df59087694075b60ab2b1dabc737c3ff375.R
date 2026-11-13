process_alignment <- function(geo_cli_name, expr_name) {
	# 获取数据对象
	geo_cli <- get(geo_cli_name)
	expr <- get(expr_name)
	
	# 获取有效样本交集
	common_samples <- intersect(geo_cli$geo_accession, colnames(expr))
	
	# 样本对齐检查
	if(length(common_samples) == 0) {
		stop(paste0("No common samples between ", geo_cli_name, " and ", expr_name))
	}
	
	# 调整样本顺序
	expr <- expr[, common_samples]
	geo_cli <- geo_cli[geo_cli$geo_accession%in%common_samples, ]
	assign(expr_name, expr, envir = .GlobalEnv)
	assign(geo_cli_name, geo_cli, envir = .GlobalEnv)
	# 生成检查报告
	cat(paste0(
		"Processed ", expr_name, ":\n",
		"  Original columns: ", length(colnames(expr)), "\n",
		"  Matched samples: ", length(common_samples), "\n"
	))
}
