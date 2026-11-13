# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7237-7245
# sha256(func-block)=82dd8427e19477300979e22f28e6101f3ca94193097a98a005ee367c3ef5e7d3
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
grid_draw <- function(groblist, x, y, width, height) {
  if (is.grob(groblist)) {
    groblist <- list(groblist)
  }
  for (i in seq_along(groblist)) {
    groblist[[i]]$vp <- viewport(x = x[i], y = y[i], width = width[i], height = height[i])
    grid.draw(groblist[[i]])
  }
}
