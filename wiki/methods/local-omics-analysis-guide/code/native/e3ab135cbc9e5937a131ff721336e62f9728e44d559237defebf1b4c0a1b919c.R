.unit <- function(value, unit_name) {
  if (!requireNamespace("grid", quietly = TRUE)) stop("R package 'grid' is required", call. = FALSE)
  grid::unit(value, unit_name)
}
