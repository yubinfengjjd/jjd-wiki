as_dgC <- function(x) {
  if (inherits(x, "dgCMatrix")) return(x)
  if (is.data.frame(x)) x <- as.matrix(x)
  if (!is.matrix(x)) stop("Unsupported matrix type: ", paste(class(x), collapse = "/"))
  Matrix::Matrix(x, sparse = TRUE)
}
