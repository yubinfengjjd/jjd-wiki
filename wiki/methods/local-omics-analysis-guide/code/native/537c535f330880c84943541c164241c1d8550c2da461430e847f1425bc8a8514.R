.rename_last_col <- function(obj, new_name) {
  colnames(obj@meta.data)[ncol(obj@meta.data)] <- new_name
  obj
}
