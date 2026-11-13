estimate_density <- function(net) {
  if (is.null(net) || is.null(dim(net))) return(NA_real_)
  if (inherits(net, "dgCMatrix")) {
    nnz0 <- length(net@x)
    p <- nrow(net)
    denom <- max(1, p * p - p)
    return(nnz0 / denom)
  }
  p <- nrow(net)
  denom <- max(1, p * p - p)
  sum(net != 0) / denom
}
