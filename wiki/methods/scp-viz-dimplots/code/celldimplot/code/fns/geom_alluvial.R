# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:860-883
# sha256(func-block)=e21e60568bb1c3f601ddf34e8b61e2b9d641151442daa31083c23a0878625f98
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
geom_alluvial <- function(mapping = NULL,
                          data = NULL,
                          position = "identity",
                          na.rm = FALSE,
                          show.legend = NA,
                          space = 0,
                          width = .1,
                          smooth = 8,
                          inherit.aes = TRUE,
                          ...) {
  geom_sankey(
    mapping = mapping,
    data = data,
    position = position,
    na.rm = na.rm,
    show.legend = show.legend,
    space = space,
    width = width,
    smooth = smooth,
    type = "alluvial",
    inherit.aes = inherit.aes,
    ...
  )
}
