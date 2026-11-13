normalize_weight_table <- function(weight_mat) {
  rs <- rowSums(weight_mat, na.rm = TRUE)
  out <- weight_mat
  valid <- rs > 0
  out[valid, ] <- out[valid, , drop = FALSE] / rs[valid]
  out
}
