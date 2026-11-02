# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:970-989
# sha256(func-block)=5e83de493cf5608512ffe610bf43136c587169b7b7cc3a7e41af8f5650195df1
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
meanp <- function(p) {
  keep <- (p >= 0) & (p <= 1)
  invalid <- sum(1L * keep) < 4
  if (invalid) {
    warning("Must have at least four valid p values")
    res <- list(z = NA_real_, p = NA_real_, validp = p[keep])
  } else {
    pi <- mean(p[keep])
    k <- length(p[keep])
    z <- (0.5 - pi) * sqrt(12 * k)
    if (k != length(p)) {
      warning("Some studies omitted")
    }
    res <- list(
      z = z, p = pnorm(z, lower.tail = FALSE),
      validp = p[keep]
    )
  }
  res
}
