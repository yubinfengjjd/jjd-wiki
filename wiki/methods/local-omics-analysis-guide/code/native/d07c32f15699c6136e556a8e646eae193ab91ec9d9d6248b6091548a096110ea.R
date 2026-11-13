write_json_safe <- function(path, x) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  jsonlite::write_json(x, path = path, pretty = TRUE, auto_unbox = TRUE)
}
