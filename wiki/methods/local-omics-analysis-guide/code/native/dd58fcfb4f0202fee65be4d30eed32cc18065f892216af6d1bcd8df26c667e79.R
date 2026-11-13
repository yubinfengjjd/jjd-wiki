short_celltype_label <- function(x) {
  x <- gsub("_cells$", "", x)
  x <- gsub("_", " ", x)
  x <- gsub("^Fibroblasts$", "Fibro", x)
  x <- gsub("^Macrophage$", "Macroph.", x)
  x <- gsub("^Endothelial$", "Endo", x)
  x <- gsub("^SmoothMuscle$", "SMC", x)
  x <- gsub("^Plasma cells$", "Plasma", x)
  x
}
