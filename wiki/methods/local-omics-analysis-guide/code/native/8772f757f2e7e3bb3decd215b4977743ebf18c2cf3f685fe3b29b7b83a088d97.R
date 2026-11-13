wf_read_gmt <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  out <- lapply(lines, function(x) {
    parts <- strsplit(x, "\t", fixed = TRUE)[[1]]
    stats::setNames(list(unique(parts[-c(1, 2)])), parts[1])
  })
  unlist(out, recursive = FALSE)
}
