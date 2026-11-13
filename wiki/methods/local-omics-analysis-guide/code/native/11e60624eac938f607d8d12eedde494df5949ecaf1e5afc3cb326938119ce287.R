compute_meanExpr <- function(seurat_epi, counts_mat) {
  if (!is.null(seurat_epi)) {
    assay <- if ("RNA" %in% Seurat::Assays(seurat_epi)) "RNA" else Seurat::DefaultAssay(seurat_epi)
    data_mat <- Seurat::GetAssayData(seurat_epi, assay = assay, slot = "data")
    if (!inherits(data_mat, "dgCMatrix")) data_mat <- as_dgC(data_mat)
    if (!length(data_mat@x)) {
      seurat_epi <- Seurat::NormalizeData(seurat_epi, verbose = FALSE)
      data_mat <- Seurat::GetAssayData(seurat_epi, assay = assay, slot = "data")
      if (!inherits(data_mat, "dgCMatrix")) data_mat <- as_dgC(data_mat)
    }
    data_mat <- data_mat[rownames(counts_mat), colnames(counts_mat), drop = FALSE]
    Matrix::rowMeans(data_mat)
  } else {
    lib <- Matrix::colSums(counts_mat)
    sf <- stats::median(lib)
    norm <- t(t(counts_mat) / pmax(lib, 1) * sf)
    norm <- log1p(norm * 1e4)
    Matrix::rowMeans(norm)
  }
}
