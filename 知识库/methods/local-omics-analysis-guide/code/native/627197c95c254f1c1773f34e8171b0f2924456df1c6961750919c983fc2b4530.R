wf_pretty_limits <- function(x, lower_q = 0.02, upper_q = 0.98, include_zero = TRUE, n = 4) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  if (!length(x)) return(c(0, 1))
  rng <- stats::quantile(x, probs = c(lower_q, upper_q), na.rm = TRUE, names = FALSE, type = 7)
  if (!all(is.finite(rng)) || diff(rng) <= 0) rng <- range(x, na.rm = TRUE)
  if (isTRUE(include_zero) && rng[1] >= 0) rng[1] <- 0
  brks <- pretty(rng, n = n)
  brks <- brks[is.finite(brks)]
  if (isTRUE(include_zero) && rng[1] >= 0) brks <- sort(unique(c(0, brks)))
  keep <- brks >= min(rng) & brks <= max(rng)
  if (sum(keep) >= 2) brks <- brks[keep]
  lims <- range(brks, finite = TRUE)
  if (!all(is.finite(lims)) || diff(lims) <= 0) lims <- range(rng, finite = TRUE)
  if (isTRUE(include_zero) && lims[1] > 0) lims[1] <- 0
  lims
}
