pick_ko_gene <- function(counts, candidates) {
  rn <- rownames(counts)
  rn_up <- toupper(rn)
  for (g in candidates) {
    g2 <- toupper(trimws(g))
    if (!nzchar(g2)) next
    hit <- which(rn_up == g2)
    if (length(hit)) return(rn[[hit[[1]]]])
  }
  # Last resort: choose a high-variance, reasonably expressed gene.
  m <- Matrix::rowMeans(counts)
  v <- Matrix::rowMeans(counts^2) - m^2
  ok <- which(m > stats::quantile(m, 0.5))
  if (!length(ok)) ok <- seq_len(nrow(counts))
  rn[[ok[[which.max(v[ok])]]]]
}
