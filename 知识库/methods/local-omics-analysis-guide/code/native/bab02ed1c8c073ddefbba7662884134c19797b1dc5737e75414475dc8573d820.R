wf_order_discrete_levels <- function(values, palette_names = NULL) {
  values <- as.character(values)
  values <- values[!is.na(values) & nzchar(values)]
  present <- if (length(values) > 0) names(sort(table(values), decreasing = TRUE)) else character()
  if (is.null(palette_names)) return(present)
  c(present, setdiff(palette_names, present))
}
