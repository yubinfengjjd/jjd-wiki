compute_nhood <- function(coords, comp, k) {
  nn <- FNN::get.knn(as.matrix(coords), k = k)$nn.index
  out <- matrix(NA_real_, nrow = nrow(comp), ncol = ncol(comp), dimnames = list(rownames(comp), colnames(comp)))
  for (i in seq_len(nrow(comp))) out[i, ] <- colMeans(comp[nn[i, ], , drop = FALSE], na.rm = TRUE)
  out
}
