summary_breaks_paper <- function(x, n = 4L) {
  x <- x[is.finite(x) & x > 0]
  if (!length(x)) return(NULL)
  br <- unique(pretty(c(0, max(x, na.rm = TRUE)), n = n))
  br <- br[is.finite(br) & br > 0]
  if (length(br) < 3L && length(unique(x)) >= 3L) {
    br <- unique(as.numeric(stats::quantile(x, probs = seq(0.25, 1, length.out = min(4L, length(unique(x)))), na.rm = TRUE, names = FALSE, type = 7)))
  }
  if (length(br) > n) {
    idx <- unique(round(seq(1, length(br), length.out = n)))
    br <- br[idx]
  }
  signif(br, 2)
}
