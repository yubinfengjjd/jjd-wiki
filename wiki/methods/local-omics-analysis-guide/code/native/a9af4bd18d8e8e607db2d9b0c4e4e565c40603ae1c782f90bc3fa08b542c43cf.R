guess_genes_by_cells <- function(mat) {
  nr <- nrow(mat)
  nc <- ncol(mat)
  if (nr >= nc) return(TRUE)
  if (nc >= 2000 && nr <= 1000) return(FALSE)
  FALSE
}
