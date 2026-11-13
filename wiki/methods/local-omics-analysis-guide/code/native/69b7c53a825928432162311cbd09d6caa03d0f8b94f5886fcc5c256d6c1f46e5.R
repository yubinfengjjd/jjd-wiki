render_spatial_pathway_literal <- function(pathway_literal) {
  stem <- wf_sanitize_stem(paste0('aggregate_spatial_', pathway_literal))
  pdf_path <- file.path(dir_map$pathway, paste0(stem, '.pdf'))
  png_path <- file.path(dir_map$pathway, paste0(stem, '.png'))

  grDevices::pdf(pdf_path, width = 9.2, height = 7.1, onefile = TRUE)
  par(mar = c(0.6, 0.6, 2.2, 0.6), xpd = NA)
  netVisual_aggregate(
    cellchat,
    signaling = pathway_literal,
    layout = 'spatial',
    edge.width.max = 2.2,
    vertex.size.max = 3.2,
    vertex.label.cex = 1.45,
    alpha.image = 0.16
  )
  grDevices::dev.off()

  grDevices::png(png_path, width = 9.2, height = 7.1, units = 'in', res = 320, bg = 'white')
  par(mar = c(0.6, 0.6, 2.2, 0.6), xpd = NA)
  netVisual_aggregate(
    cellchat,
    signaling = pathway_literal,
    layout = 'spatial',
    edge.width.max = 2.2,
    vertex.size.max = 3.2,
    vertex.label.cex = 1.45,
    alpha.image = 0.16
  )
  grDevices::dev.off()
}
