parse_ratio_to_numeric <- function(x) {
  x <- as.character(x)
  out <- suppressWarnings(as.numeric(x))
  idx <- is.na(out) & grepl("/", x, fixed = TRUE)
  if (any(idx)) {
    out[idx] <- vapply(strsplit(x[idx], "/", fixed = TRUE), function(parts) {
      if (length(parts) != 2L) return(NA_real_)
      num <- suppressWarnings(as.numeric(parts[[1]]))
      den <- suppressWarnings(as.numeric(parts[[2]]))
      if (!is.finite(num) || !is.finite(den) || den == 0) return(NA_real_)
      num / den
    }, numeric(1))
  }
  out
}
