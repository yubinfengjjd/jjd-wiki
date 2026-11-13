# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:805-838
# sha256(func-block)=5fce08c1cc2ce1e87a076ad9cb05679dd448c74b99ce53685d1718915c17093a
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
geom_sankey_text <- function(mapping = NULL,
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
      geom = "text",
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
