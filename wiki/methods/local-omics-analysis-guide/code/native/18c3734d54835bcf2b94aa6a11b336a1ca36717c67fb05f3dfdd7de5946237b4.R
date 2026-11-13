safe_md5 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  as.character(tools::md5sum(path))
}
