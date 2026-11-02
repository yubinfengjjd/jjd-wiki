# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14743-14751
# sha256(func-block)=513f9f0a4f2aa0318ed4104c775088baae54decfa0ce357825c6d9623c3517a4
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
get_legend <- function(plot) {
  plot <- as_gtable(plot)
  grob_names <- plot$layout$name
  grobs <- plot$grobs
  grobIndex <- which(grepl("guide-box", grob_names))
  grobIndex <- grobIndex[1]
  matched_grobs <- grobs[[grobIndex]]
  return(matched_grobs)
}
