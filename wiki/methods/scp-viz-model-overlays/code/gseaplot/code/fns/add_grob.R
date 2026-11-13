# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14755-14794
# sha256(func-block)=24f01a9a68b616f3d194c88ca821eae6655b691d833502b1b4e3fbac1b9c6c21
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
add_grob <- function(gtable, grob, position = c("top", "bottom", "left", "right", "none"), space = NULL, clip = "on") {
  position <- match.arg(position)
  if (position == "none" || is.null(grob)) {
    return(gtable)
  }

  if (is.null(space)) {
    if (is.gtable(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- sum(grob$heights)
      } else {
        space <- sum(grob$widths)
      }
    } else if (is.grob(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- grobHeight(grob)
      } else {
        space <- grobWidth(grob)
      }
    }
  }

  if (position == "top") {
    gtable <- gtable_add_rows(gtable, space, 0)
    gtable <- gtable_add_grob(gtable, grob, t = 1, l = mean(gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]), clip = clip)
  }
  if (position == "bottom") {
    gtable <- gtable_add_rows(gtable, space, -1)
    gtable <- gtable_add_grob(gtable, grob, t = dim(gtable)[1], l = mean(gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]), clip = clip)
  }
  if (position == "left") {
    gtable <- gtable_add_cols(gtable, space, 0)
    gtable <- gtable_add_grob(gtable, grob, t = mean(gtable$layout[grep("panel", gtable$layout$name), "t"]), l = 1, clip = clip)
  }
  if (position == "right") {
    gtable <- gtable_add_cols(gtable, space, -1)
    gtable <- gtable_add_grob(gtable, grob, t = mean(gtable$layout[grep("panel", gtable$layout$name), "t"]), l = dim(gtable)[2], clip = clip)
  }
  return(gtable)
}
