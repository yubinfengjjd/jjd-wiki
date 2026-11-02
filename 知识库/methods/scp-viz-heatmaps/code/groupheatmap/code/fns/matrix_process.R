# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7208-7226
# sha256(func-block)=bd1f5eae1533749df598bc025855c8d551add8ab5e3e43352ff56f6b95e5046f
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
matrix_process <- function(matrix, method = c("raw", "zscore", "fc", "log2fc", "log1p"), ...) {
  if (is.function(method)) {
    matrix_processed <- method(matrix, ...)
  } else if (method == "raw") {
    matrix_processed <- matrix
  } else if (method == "fc") {
    matrix_processed <- fc_matrix(matrix)
  } else if (method == "zscore") {
    matrix_processed <- zscore_matrix(matrix, ...)
  } else if (method == "log2fc") {
    matrix_processed <- log2fc_matrix(matrix)
  } else if (method == "log1p") {
    matrix_processed <- log1p_matrix(matrix)
  }
  if (!identical(dim(matrix_processed), dim(matrix))) {
    stop("The dimensions of the matrix are changed after processing")
  }
  return(matrix_processed)
}
