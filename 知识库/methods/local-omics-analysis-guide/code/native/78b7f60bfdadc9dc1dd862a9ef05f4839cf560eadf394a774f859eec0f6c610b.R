wf_scale01 <- function(x, lower_q = 0.01, upper_q = 0.99) {
  rng <- stats::quantile(x, probs = c(lower_q, upper_q), na.rm = TRUE, names = FALSE, type = 7)
  if (!all(is.finite(rng)) || diff(rng) <= 0) return(rep(0, length(x)))
  x <- pmin(pmax(x, rng[1]), rng[2])
  (x - rng[1]) / (rng[2] - rng[1])
}
