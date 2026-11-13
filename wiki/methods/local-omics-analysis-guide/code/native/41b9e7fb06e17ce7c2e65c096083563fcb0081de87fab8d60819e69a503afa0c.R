.element_rect_compat <- function(fill = NULL, colour = NULL, linewidth = NULL) {
  fmls <- names(formals(ggplot2::element_rect))
  if (!is.null(linewidth) && "linewidth" %in% fmls) {
    return(ggplot2::element_rect(fill = fill, colour = colour, linewidth = linewidth))
  }
  if (!is.null(linewidth) && "size" %in% fmls) {
    return(ggplot2::element_rect(fill = fill, colour = colour, size = linewidth))
  }
  ggplot2::element_rect(fill = fill, colour = colour)
}
