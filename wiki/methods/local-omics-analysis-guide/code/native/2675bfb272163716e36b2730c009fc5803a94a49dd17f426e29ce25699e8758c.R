extract_input <- function(seurat_obj, env, obj_names, cell_type_label) {
  if (!is.null(seurat_obj)) {
    obj_epi <- time_it("Subset Epithelial (Seurat)", function() extract_epithelial_from_seurat(seurat_obj, cell_type_label))
    assay <- if ("RNA" %in% Seurat::Assays(obj_epi)) "RNA" else Seurat::DefaultAssay(obj_epi)
    counts <- Seurat::GetAssayData(obj_epi, assay = assay, slot = "counts")
    counts <- as_dgC(counts)
    list(source = "Seurat", obj_epi = obj_epi, counts = counts)
  } else {
    mm <- pick_matrix(env, obj_names)
    if (is.null(mm$mat)) stop("No Seurat object and no matrix-like object found in loaded RData.")
    mat <- as_dgC(mm$mat)
    if (!guess_genes_by_cells(mat)) {
      log_msg("Matrix appears to be cells x genes; transposing to genes x cells.")
      mat <- Matrix::t(mat)
    }
    if (is.null(rownames(mat))) rownames(mat) <- paste0("G", seq_len(nrow(mat)))
    if (is.null(colnames(mat))) colnames(mat) <- paste0("C", seq_len(ncol(mat)))
    log_msg("Using matrix object: ", mm$name, " (", nrow(mat), " genes x ", ncol(mat), " cells)")
    list(source = "matrix", obj_epi = NULL, counts = mat)
  }
}
