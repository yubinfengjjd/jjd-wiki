# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:691-744
# sha256(func-block)=3863422c80a0859858a467fae2fce6c4623a2a2bab6b553b409a665d6191bb0d
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
geom_sankey <- function(mapping = NULL,
                        data = NULL,
                        position = "identity",
                        na.rm = FALSE,
                        show.legend = NA,
                        space = NULL,
                        type = "sankey",
                        width = .1,
                        smooth = 8,
                        inherit.aes = TRUE,
                        ...) {
  params_list <- prepare_params(...)

  list(
    flow = ggplot2::layer(
      stat = StatSankeyFlow,
      data = data,
      mapping = mapping,
      geom = "polygon",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(
        list(
          na.rm = na.rm,
          width = width,
          space = space,
          smooth = smooth,
          type = type,
          params_list[[1]]
        )
      )
    ),
    node = ggplot2::layer(
      stat = StatSankeyNode,
      data = data,
      mapping = mapping,
      geom = ggplot2::GeomRect,
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(
        list(
          na.rm = na.rm,
          width = width,
          space = space,
          smooth = smooth,
          type = type,
          params_list[[2]]
        )
      )
    )
  )
}
