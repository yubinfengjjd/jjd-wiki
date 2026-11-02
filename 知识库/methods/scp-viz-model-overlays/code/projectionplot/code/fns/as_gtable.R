# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14724-14741
# sha256(func-block)=a86e41fb168520c07396c33b4a8ab168cc974299275488c855022fd780bb3601
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
as_gtable <- function(plot, ...) {
  if (inherits(plot, "gtable")) {
    return(plot)
  }
  if (inherits(plot, "grob")) {
    u <- unit(1, "null")
    gt <- gtable_col(NULL, list(plot), u, u)
    gt$layout$clip <- "inherit"
    return(gt)
  } else {
    grob <- as_grob(plot, ...)
    if (inherits(grob, "gtable")) {
      return(grob)
    } else {
      return(as_gtable(grob, ...))
    }
  }
}
