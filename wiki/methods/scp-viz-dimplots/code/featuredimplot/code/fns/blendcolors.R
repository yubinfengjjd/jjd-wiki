# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:1026-1042
# sha256(func-block)=344e46aacfe3426ba52bd449050ee63fa56b8e2de3fbd31b9d24961ff4feea25
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
blendcolors <- function(colors, mode = c("blend", "average", "screen", "multiply")) {
  mode <- match.arg(mode)
  colors <- colors[!is.na(colors)]
  if (length(colors) == 0) {
    return(NA)
  }
  if (length(colors) == 1) {
    return(colors)
  }
  rgb <- as.list(as.data.frame(col2rgb(colors) / 255))
  Clist <- lapply(rgb, function(x) {
    list(x, 1)
  })
  blend_color <- BlendRGBList(Clist, mode = mode)
  blend_color <- rgb(blend_color[1], blend_color[2], blend_color[3])
  return(blend_color)
}
