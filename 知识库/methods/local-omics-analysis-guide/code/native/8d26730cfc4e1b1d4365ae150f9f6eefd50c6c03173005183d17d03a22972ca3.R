scale_size_summary_paper <- function(values, name = ggplot2::waiver(), max_size = 8.6, n_breaks = 4L, limits = NULL, labels = ggplot2::waiver()) {
  finite_vals <- values[is.finite(values)]
  if (is.null(limits)) {
    upper <- if (length(finite_vals)) max(finite_vals, na.rm = TRUE) else 1
    if (!is.finite(upper) || upper <= 0) upper <- 1
    limits <- c(0, upper)
  }
  ggplot2::scale_size_area(
    max_size = max_size,
    breaks = summary_breaks_paper(finite_vals, n = n_breaks),
    limits = limits,
    labels = labels,
    name = name
  )
}
