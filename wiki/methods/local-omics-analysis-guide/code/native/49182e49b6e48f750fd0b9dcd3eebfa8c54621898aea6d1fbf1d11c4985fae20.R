split_one <- function(s) {
	if (length(s) == 0 || all(is.na(s))) return(character(0))
	x <- trimws(unlist(strsplit(s, "\\s*[\\|,;]+\\s*")))
	x <- x[!is.na(x) & x != "" & x != "-"]
	unique(x)
}
