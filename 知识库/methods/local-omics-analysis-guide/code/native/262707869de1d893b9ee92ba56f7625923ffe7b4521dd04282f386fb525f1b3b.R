bin_by_quantile <- function(x, n = 5L) {
  x <- as.numeric(x)
  probs <- seq(0, 1, length.out = n + 1L)
  br <- as.numeric(stats::quantile(x, probs = probs, na.rm = TRUE, type = 7))
  br <- unique(br)
  if (length(br) < 3L) {
    return(factor(rep("Bin 1", length(x)), levels = "Bin 1"))
  }
  labs <- paste0("Bin ", seq_len(length(br) - 1L))
  cut(x, breaks = br, include.lowest = TRUE, labels = labs, right = TRUE)
}
