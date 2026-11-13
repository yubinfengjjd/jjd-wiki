wf_spatial_backdrop_df <- function(obj) {
  coords <- get_spatial_xy(obj)
  coords$spot <- rownames(coords)
  coords
}
