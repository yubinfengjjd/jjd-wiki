get_spatial_xy <- function(sobj) {
  coords <- as.data.frame(Seurat::GetTissueCoordinates(sobj))
  cand <- list(c("imagerow", "imagecol"), c("row", "col"), c("x", "y"))
  for (nm in cand) {
    if (all(nm %in% colnames(coords))) {
      xy <- coords[, nm, drop = FALSE]
      colnames(xy) <- c("x", "y")
      rownames(xy) <- rownames(coords)
      return(xy)
    }
  }
  num_cols <- names(coords)[vapply(coords, is.numeric, logical(1))]
  if (length(num_cols) < 2) stop("No valid 2D spatial coordinates found.", call. = FALSE)
  xy <- coords[, num_cols[1:2], drop = FALSE]
  colnames(xy) <- c("x", "y")
  rownames(xy) <- rownames(coords)
  xy
}
