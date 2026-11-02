.element_line_compat <- function(linewidth, colour = NULL, linetype = NULL) {
  fmls <- names(formals(ggplot2::element_line))
  if ("linewidth" %in% fmls) {
    return(ggplot2::element_line(linewidth = linewidth, colour = colour, linetype = linetype))
  }
  ggplot2::element_line(size = linewidth, colour = colour, linetype = linetype)
}
