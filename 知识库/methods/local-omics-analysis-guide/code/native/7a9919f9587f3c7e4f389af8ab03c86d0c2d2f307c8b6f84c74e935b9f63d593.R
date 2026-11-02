is_integerish <- function(x) {
  if (inherits(x, "dgCMatrix")) {
    if (!length(x@x)) return(TRUE)
    return(all(abs(x@x - round(x@x)) < 1e-8) && all(x@x >= 0))
  }
  all(abs(x - round(x)) < 1e-8) && all(x >= 0)
}
