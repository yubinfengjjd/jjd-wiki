# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14710-14720
# sha256(func-block)=6405fffa6b1ba3ab24b6d7fa4156362cc94f7717808c17658691a74777a6ab4d
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
as_grob <- function(plot, ...) {
  if (inherits(plot, "gList")) {
    grobTree(plot)
  } else if (inherits(plot, "patchwork")) {
    patchworkGrob(plot, ...)
  } else if (inherits(plot, "ggplot")) {
    ggplotGrob(plot)
  } else {
    warning("Cannot convert object of class ", paste0(class(plot), collapse = ","), " into a grob.")
  }
}
