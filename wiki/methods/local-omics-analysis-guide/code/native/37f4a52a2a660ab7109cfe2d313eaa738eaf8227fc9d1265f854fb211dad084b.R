split_id <- function(x) unique(trimws(unlist(strsplit(x, "[,;|\\s]+"))))
