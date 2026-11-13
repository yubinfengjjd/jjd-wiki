wf_scale_fill_ref2_bubble <- function(limits = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver(), na.value = "#D9D9D9") {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package scales is required", call. = FALSE)
  ggplot2::scale_fill_gradientn(colours = wf_ref2_bubble_palette(), limits = limits, breaks = breaks, labels = labels, na.value = na.value, oob = scales::squish)
}
