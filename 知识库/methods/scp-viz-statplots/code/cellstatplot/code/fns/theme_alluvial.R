# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:155-180
# sha256(func-block)=43707e8ac94c1619b1ada5581e4edbe4b6023f041b69749cd058c717a9a77153
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
theme_alluvial <-
  function(base_size = 11,
           base_family = "",
           base_line_size = base_size / 22,
           base_rect_size = base_size / 22) {{ ggplot2::theme_bw(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size
  ) %+replace%
    ggplot2::theme(
      panel.border = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      strip.background = ggplot2::element_rect(
        fill = "white",
        colour = "transparent",
        size = ggplot2::rel(2)
      ),
      complete = TRUE,
      axis.line.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank()
    ) }
  }
