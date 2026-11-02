# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:907-928
# sha256(func-block)=aa66fc4e42025e1352fd5b96155b44e50f8918f1ae5f660ecd2f546dd01947f4
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
geom_alluvial_text <- function(mapping = NULL,
                               data = NULL,
                               position = "identity",
                               na.rm = FALSE,
                               show.legend = NA,
                               space = 0,
                               width = .1,
                               inherit.aes = TRUE,
                               ...) {
  geom_sankey_text(
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
