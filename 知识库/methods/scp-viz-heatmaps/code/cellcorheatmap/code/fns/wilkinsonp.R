# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:923-954
# sha256(func-block)=cd12f1b5393ba41461104c1b507b570d1c956b56c61c50008219e5ea949ec371
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
wilkinsonp <- function(p, r = 1, alpha = 0.05, log.p = FALSE) {
  alpha <- ifelse(alpha > 1, alpha / 100, alpha)
  stopifnot(alpha > 0, alpha < 1)
  alpha <- ifelse(alpha > 0.5, 1 - alpha, alpha)
  keep <- (p >= 0) & (p <= 1)
  invalid <- sum(1L * keep) < 2
  if (invalid) {
    warning("Must have at least two valid p values")
    res <- list(
      p = NA_real_, pr = NA_real_, r = r, critp = NA_real_,
      alpha = alpha, validp = p[keep]
    )
  } else {
    pi <- p[keep]
    k <- length(pi)
    if (k != length(p)) {
      warning("Some studies omitted")
    }
    if ((r < 1) | (r > k)) {
      r <- 1
      warning("Illegal r set to 1")
    }
    pi <- sort(pi)
    pr <- pi[r]
    res <- list(
      p = pbeta(pr, r, k + 1 - r, log.p = log.p),
      pr = pr, r = r, critp = qbeta(alpha, r, k + 1 - r),
      alpha = alpha, validp = pi
    )
  }
  res
}
