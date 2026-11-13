# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:731-752
# sha256(func-block)=4632db7b2eabb26a964eeca1377d28a5a372c893c039e2b91ea4bdc1fea02f50
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
zero_range <- function(x, tol = 1000 * .Machine$double.eps) {
  if (length(x) == 1) {
    return(TRUE)
  }
  if (length(x) != 2) {
    stop("x must be length 1 or 2")
  }
  if (any(is.na(x))) {
    return(NA)
  }
  if (x[1] == x[2]) {
    return(TRUE)
  }
  if (all(is.infinite(x))) {
    return(FALSE)
  }
  m <- min(abs(x))
  if (m == 0) {
    return(FALSE)
  }
  abs((x[1] - x[2]) / m) < tol
}
