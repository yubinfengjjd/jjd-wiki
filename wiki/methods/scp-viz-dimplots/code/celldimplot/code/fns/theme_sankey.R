# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:124-151
# sha256(func-block)=f6cce70651b113b4fa3941edcdcdcd784120c1316f4b825e6363defa52d99915
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
theme_sankey <- function(base_size = 11, base_family = "", base_line_size = base_size / 22, base_rect_size = base_size / 22) {{ ggplot2::theme_bw(
  base_size = base_size,
  base_family = base_family,
  base_line_size = base_line_size,
  base_rect_size = base_rect_size
) %+replace%
  ggplot2::theme(
    panel.border = ggplot2::element_blank(),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    axis.line = ggplot2::element_line(
      colour = "black",
      size = ggplot2::rel(1)
    ),
    legend.key = ggplot2::element_blank(),
    strip.background = ggplot2::element_rect(
      fill = "white",
      colour = "transparent",
      size = ggplot2::rel(2)
    ),
    complete = TRUE,
    axis.line.y = ggplot2::element_blank(),
    axis.line.x = ggplot2::element_blank(),
    axis.text.y = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    axis.ticks.x = ggplot2::element_blank()
  ) }
}
