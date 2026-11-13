write_lines_safe <- function(path, x) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  writeLines(x, con = path, useBytes = TRUE)
}
