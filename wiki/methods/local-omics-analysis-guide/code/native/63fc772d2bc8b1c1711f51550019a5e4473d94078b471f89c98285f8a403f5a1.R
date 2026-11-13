select_hvgs <- function(counts, target) {
  target <- as.integer(max(2000L, min(7500L, target)))
  target <- min(target, nrow(counts))
  lib <- Matrix::colSums(counts)
  sf <- stats::median(lib)
  norm <- t(t(counts) / pmax(lib, 1) * sf)
  norm <- log1p(norm * 1e4)
  m <- Matrix::rowMeans(norm)
  v <- Matrix::rowMeans(norm^2) - m^2
  score <- v / (m + 1e-6)
  ord <- order(score, decreasing = TRUE)
  rownames(counts)[ord[seq_len(target)]]
}
