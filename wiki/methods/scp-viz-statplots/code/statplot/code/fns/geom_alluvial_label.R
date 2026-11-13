# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:932-953
# sha256(func-block)=21042f0790e6bd460a4deb3d9c9a40b08dd61b6713ce36e6af905aed894820ff
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
geom_alluvial_label <- function(mapping = NULL,
                                data = NULL,
                                position = "identity",
                                na.rm = FALSE,
                                show.legend = NA,
                                space = 0,
                                width = .1,
                                inherit.aes = TRUE,
                                ...) {
  geom_sankey_label(
    mapping = mapping,
    data = data,
    position = position,
    na.rm = na.rm,
    show.legend = show.legend,
    space = space,
    width = width,
    type = "alluvial",
    inherit.aes = inherit.aes,
    ...
  )
}
