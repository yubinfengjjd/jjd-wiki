extract_epithelial_from_seurat <- function(obj, target_label) {
  meta <- obj@meta.data
  hit <- find_celltype_column(meta, target_label)
  if (is.null(hit$col) || hit$n_match <= 0) {
    stop("Could not find meta.data column containing label: ", target_label,
         ". Available meta.data columns: ", paste(colnames(meta), collapse = ", "))
  }
  col <- hit$col
  v <- as.character(meta[[col]])
  keep <- grepl(target_label, v, ignore.case = TRUE)
  cells <- rownames(meta)[keep]
  if (!length(cells)) stop("Matched column but got 0 cells for label: ", target_label)
  log_msg("Celltype column selected: ", col, " | matched ", sum(keep), " cells")
  subset(obj, cells = cells)
}
