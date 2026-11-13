get_expr_matrix <- function(sobj, assay = NULL, prefer = "data") {
  if (is.null(assay)) assay <- if ("Spatial" %in% Seurat::Assays(sobj)) "Spatial" else Seurat::DefaultAssay(sobj)
  mat <- tryCatch(suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, layer = prefer)), error = function(e) NULL)
  if (is.null(mat) || nrow(mat) == 0 || ncol(mat) == 0) {
    mat <- tryCatch(suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, slot = prefer)), error = function(e) NULL)
  }
  if (is.null(mat) || nrow(mat) == 0 || ncol(mat) == 0) {
    mat <- tryCatch(
      suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, layer = "counts")),
      error = function(e) suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, slot = "counts"))
    )
    mat <- log1p(mat)
  }
  mat
}
