# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:976-1004
# sha256(func-block)=2e24cb93beb46fb2c3e01a87e4ab0034066b4056a1122d71011423f2cb9fac53
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
geom_sankey_bump <- function(mapping = NULL,
                             data = NULL,
                             position = "identity",
                             na.rm = FALSE,
                             show.legend = NA,
                             smooth = 8,
                             type = "sankey",
                             inherit.aes = TRUE,
                             ...) {
  params_list <- prepare_params(...)

  list(
    flow = ggplot2::layer(
      stat = StatSankeyBumpFlow,
      data = data,
      mapping = mapping,
      geom = "polygon",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(list(
        na.rm = na.rm,
        type = type,
        smooth = smooth,
        params_list[[1]]
      ))
    )
  )
}
