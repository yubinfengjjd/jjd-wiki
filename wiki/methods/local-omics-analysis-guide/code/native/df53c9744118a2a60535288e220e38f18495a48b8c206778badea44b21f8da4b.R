find_cell_type <- function(gene) {
	cell_types <- names(small_marker_dict)[sapply(small_marker_dict, function(markers) gene %in% markers)]
	if (length(cell_types) > 0) {
		return(cell_types[1])
	} else {
		return("Unknown")
	}
}
