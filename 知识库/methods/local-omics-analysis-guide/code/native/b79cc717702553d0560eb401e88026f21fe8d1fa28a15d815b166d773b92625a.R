find_celltype_column <- function(meta, target_label) {
  cols <- colnames(meta)
  priority <- c("celltype", "cell_type", "CellType", "annotation", "major_celltype", "major", "celltype_major",
                "celltypes", "cell.types", "cell_type1", "celltype1")
  cols2 <- unique(c(intersect(priority, cols), cols))

  best <- NULL
  best_n <- -1L
  for (col in cols2) {
    v <- meta[[col]]
    if (is.list(v) || is.matrix(v)) next
    if (is.numeric(v)) next
    v <- as.character(v)
    n <- sum(grepl(target_label, v, ignore.case = TRUE), na.rm = TRUE)
    if (n > best_n) {
      best <- col
      best_n <- n
    }
  }
  list(col = best, n_match = best_n)
}
