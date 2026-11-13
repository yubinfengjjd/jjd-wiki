make_term2gene <- function(anno, id_col = "cpd_ID", path_col = "kegg_map") {
	stopifnot(all(c(id_col, path_col) %in% names(anno)))
	kmap_chr <- ifelse(is.na(anno[[path_col]]), "", anno[[path_col]])
	id_chr   <- ifelse(is.na(anno[[id_col]]),   "", anno[[id_col]])
	out <- vector("list", nrow(anno))
	for (i in seq_len(nrow(anno))) {
		kvec <- str_split(kmap_chr[i], "[,;|]+")[[1]] |> str_trim()
		cvec <- str_split(id_chr[i],    "[,;|]+")[[1]] |> str_trim()
		kvec <- kvec[kvec != "" & kvec != "-"]
		cvec <- cvec[cvec != "" & cvec != "-"]
		if (length(kvec) && length(cvec)) {
			out[[i]] <- expand.grid(
				PathwayID    = kvec,
				MetaboliteID = cvec,
				stringsAsFactors = FALSE
			)
		}
	}
	bind_rows(out) |> distinct()
}
