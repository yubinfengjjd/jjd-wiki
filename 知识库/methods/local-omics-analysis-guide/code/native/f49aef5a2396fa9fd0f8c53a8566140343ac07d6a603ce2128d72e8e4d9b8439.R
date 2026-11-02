wf_md5 <- function(path) if (file.exists(path)) as.character(tools::md5sum(path)) else NA_character_
