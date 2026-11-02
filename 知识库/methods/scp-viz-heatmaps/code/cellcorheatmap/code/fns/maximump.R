# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:956-962
# sha256(func-block)=5cf7ccb9e24577f9a0ce943111421599635bfb87143ae283fab341f76d5f6da4
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
maximump <- function(p, alpha = 0.05, log.p = FALSE) {
  keep <- (p >= 0) & (p <= 1)
  validp <- p[keep]
  k <- length(validp)
  res <- wilkinsonp(p, r = k, alpha, log.p)
  res
}
