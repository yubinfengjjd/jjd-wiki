# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:1000-1007
# sha256(func-block)=af768a5c9081a60a951706d3004acb943c07ce682009c1a259fe28b2967e506f
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
adjcolors <- function(colors, alpha) {
  color_df <- as.data.frame(col2rgb(colors) / 255)
  colors_out <- sapply(color_df, function(color) {
    color_rgb <- RGBA2RGB(list(color, alpha))
    return(rgb(color_rgb[1], color_rgb[2], color_rgb[3]))
  })
  return(colors_out)
}
