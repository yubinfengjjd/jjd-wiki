# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:831-841
# sha256(func-block)=5d6a39950391b3c400ac76e5803eb34abd229efc2636af13f1b26a6e1bc06cd1
# verbatim copy; read-only provenance
as_matrix <- function(x) {
  if (!inherits(matrix, "dgCMatrix")) {
    return(as.matrix(x))
  } else {
    row_pos <- x@i
    col_pos <- findInterval(seq_along(x@x) - 1, x@p[-1])
    out <- asMatrix(rp = row_pos, cp = col_pos, z = x@x, nrows = x@Dim[1], ncols = x@Dim[2])
    attr(out, "dimnames") <- list(x@Dimnames[[1]], x@Dimnames[[2]])
    return(out)
  }
}
