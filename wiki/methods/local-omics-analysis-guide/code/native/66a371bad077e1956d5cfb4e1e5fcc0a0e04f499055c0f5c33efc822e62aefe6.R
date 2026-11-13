center_focus_levels <- function(labels, scores) {
  labels <- as.character(labels)
  ord <- labels[order(as.numeric(scores), decreasing = TRUE, na.last = TRUE)]
  n <- length(ord)
  if (n <= 2) return(rev(ord))
  pos <- integer(0)
  center <- ceiling(n / 2)
  pos <- c(pos, center)
  step <- 1L
  while (length(pos) < n) {
    right <- center + step
    left <- center - step
    if (right <= n) pos <- c(pos, right)
    if (left >= 1) pos <- c(pos, left)
    step <- step + 1L
  }
  out <- character(n)
  out[pos[seq_len(n)]] <- ord
  out
}
