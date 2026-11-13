label_wrap_paper <- function(width = 32) {
  force(width)
  function(x) vapply(as.character(x), function(val) paste(strwrap(val, width = width), collapse = "\n"), character(1))
}
