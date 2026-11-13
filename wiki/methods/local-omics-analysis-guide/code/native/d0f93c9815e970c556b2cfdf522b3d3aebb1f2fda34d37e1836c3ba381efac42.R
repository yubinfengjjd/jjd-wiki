plot_guard <- function(plot_obj = NULL, plot_list = NULL, reason = "Unknown") {
  if (!is.null(plot_obj)) return(invisible(TRUE))
  if (is.null(plot_list) || length(plot_list) == 0) {
    stop(paste0("No plots generated: ", reason), call. = FALSE)
  }
  if (all(vapply(plot_list, is.null, logical(1)))) {
    stop(paste0("No plots generated: ", reason), call. = FALSE)
  }
  invisible(TRUE)
}
