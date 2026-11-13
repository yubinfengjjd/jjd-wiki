write_text <- function(text, path) {
  writeLines(text, path, useBytes = TRUE)
  invisible(path)
}
