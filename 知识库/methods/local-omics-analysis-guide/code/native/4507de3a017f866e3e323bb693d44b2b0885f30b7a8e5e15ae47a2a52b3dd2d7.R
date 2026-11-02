broad_class <- function(celltype) {
  ct <- as.character(celltype)
  if (ct %in% c("Epithelial")) return("Epithelial")
  if (ct %in% c("B_cells", "T_cells", "NKT_cells", "Plasma_cells", "Macrophage", "Mast_cells")) return("Immune")
  if (ct %in% c("Fibroblasts", "Endothelial", "SmoothMuscle")) return("Stromal")
  "Other"
}
