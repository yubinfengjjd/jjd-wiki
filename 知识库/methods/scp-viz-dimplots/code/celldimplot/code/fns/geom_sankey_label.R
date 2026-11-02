# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:768-801
# sha256(func-block)=bdce47d7c41fe19e066970fcfe1d62e8f944dc87213e3b3d105c41957ba45c35
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
geom_sankey_label <- function(mapping = NULL,
                              data = NULL,
                              position = "identity",
                              na.rm = FALSE,
                              show.legend = NA,
                              space = NULL,
                              type = "sankey",
                              width = .1,
                              inherit.aes = TRUE,
                              ...) {
  # Prepare aesthics for label
  label.aes <- list(...)

  list(
    label = ggplot2::layer(
      stat = StatSankeyText,
      data = data,
      mapping = mapping,
      geom = "label",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(
        list(
          na.rm = na.rm,
          width = width,
          space = space,
          type = type,
          label.aes
        )
      )
    )
  )
}
