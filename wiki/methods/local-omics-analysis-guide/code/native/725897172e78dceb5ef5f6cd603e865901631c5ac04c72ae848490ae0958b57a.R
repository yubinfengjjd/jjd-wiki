gini_index <- function(x) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  if (length(x) == 0L) return(NA_real_)
  x <- x - min(x)
  total <- sum(x)
  if (!is.finite(total) || total <= 0) return(0)
  x <- sort(x)
  n <- length(x)
  (2 * sum(seq_len(n) * x) / (n * total)) - (n + 1) / n
}
