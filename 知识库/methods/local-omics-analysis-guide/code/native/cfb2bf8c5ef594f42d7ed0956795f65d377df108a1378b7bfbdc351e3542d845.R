wf_spatial_df <- function(obj, values, source = c("meta", "expr"), assay = NULL, layer = "data") {
  source <- match.arg(source)
  coords <- get_spatial_xy(obj)
  coords$spot <- rownames(coords)
  coords$value <- if (source == "meta") obj@meta.data[coords$spot, values, drop = TRUE] else as.numeric(get_expr_matrix(obj, assay = assay, prefer = layer)[values, coords$spot])
  coords
}
