process_exprset <- function(expr, anno) {
	expr %>%
		tibble::rownames_to_column("probe_id") %>%
		dplyr::inner_join(anno, by = "probe_id") %>%
		dplyr::select(-probe_id) %>%
		dplyr::select(symbol, dplyr::everything()) %>%
		dplyr::mutate(rowMean = rowMeans(.[, -1])) %>%
		dplyr::arrange(dplyr::desc(rowMean)) %>%
		dplyr::distinct(symbol, .keep_all = TRUE) %>%
		dplyr::select(-rowMean) %>%
		tibble::column_to_rownames("symbol")
}
