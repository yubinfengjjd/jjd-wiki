detect_assay <- function(obj) {
  candidates <- unique(c("Spatial", Seurat::DefaultAssay(obj), Seurat::Assays(obj)))
  candidates <- candidates[!is.na(candidates) & nzchar(candidates)]
  for (assay in candidates) {
    dat <- tryCatch(get_expr_matrix(obj, assay = assay, prefer = "data"), error = function(e) NULL)
    if (!is.null(dat) && all(dim(dat) > 0)) return(assay)
  }
  stop("No assay with usable normalized data was detected.", call. = FALSE)
}
