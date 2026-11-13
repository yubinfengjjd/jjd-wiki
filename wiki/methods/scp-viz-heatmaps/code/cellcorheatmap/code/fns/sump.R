# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:992-1024
# sha256(func-block)=3fe0f09bbd7443b270a12a5da26c071dccbe706694b0ca6a068bafbd6ad7b82b
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
sump <- function(p) {
  keep <- (p >= 0) & (p <= 1)
  invalid <- sum(1L * keep) < 2
  if (invalid) {
    warning("Must have at least two valid p values")
    res <- list(p = NA_real_, conservativep = NA_real_, validp = p[keep])
  } else {
    sigmap <- sum(p[keep])
    k <- length(p[keep])
    conservativep <- exp(k * log(sigmap) - lgamma(k + 1))
    nterm <- floor(sigmap) + 1
    denom <- lfactorial(k)
    psum <- 0
    terms <- vector("numeric", nterm)
    for (i in 1:nterm) {
      terms[i] <- lchoose(k, i - 1) + k * log(sigmap -
        i + 1) - denom
      pm <- 2 * (i %% 2) - 1
      psum <- psum + pm * exp(terms[i])
    }
    if (k != length(p)) {
      warning("Some studies omitted")
    }
    if (sigmap > 20) {
      warning("Likely to be unreliable, check with another method")
    }
    res <- list(
      p = psum, conservativep = conservativep,
      validp = p[keep]
    )
  }
  res
}
