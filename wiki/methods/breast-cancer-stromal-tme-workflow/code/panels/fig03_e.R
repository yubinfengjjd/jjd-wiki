# Panel ID: fig03/E (Fig. 3 3E)
# Title: CAA_ST C10_lpFib_ABCA8 / T-cell joint-high zone and LGALS3/HAVCR2/CD86/CTLA4 spatial co-localization.
# Evidence tier: proxy
# Input tables: runs/step03_spatial/st_spots_fig3be.csv, data_small/CAA_ST-umap.qs, data_small/st/caa_st_scored.qs
# Default dimensions: width = 5.8 in, height = 3.6 in
# Usage: Rscript --vanilla code/panels/fig03_e.R --paper-root <PAPER_ROOT> --out fig03_e.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig03_e.png', default_width = 5.8, default_height = 3.6)
st <- read_step("step03_spatial", "st_spots_fig3be")
spatial_expression <- function(d, candidates) {
  for (path in c("data_small/CAA_ST-umap.qs", "data_small/st/caa_st_scored.qs")) {
    object <- qs::qread(file.path(paper_dir, path), nthreads = 1)
    assay <- object[["Spatial"]]
    available <- intersect(candidates, rownames(assay))
    if (length(available)) {
      gene <- available[1]
      layer <- SeuratObject::LayerData(assay, layer = "data", features = gene)
      if (is.null(layer) || !gene %in% rownames(layer)) {
        counts <- SeuratObject::LayerData(assay, layer = "counts")
        layer <- log1p(counts[gene, , drop = FALSE] / rep(Matrix::colSums(counts), each = 1) * 1e4)
      }
      idx <- match(d$spot, colnames(layer))
      return(list(gene = gene, expression = as.numeric(layer[gene, idx])))
    }
    rm(object, assay); invisible(gc())
  }
  list(gene = "LGALS9", expression = rep(NA_real_, nrow(d)))
}
galectin <- spatial_expression(st, c("LGALS9", "LGALS3"))
st$galectin <- galectin$expression
sampled <- panel_spot_grid(st, side = 148L, square = FALSE)
joint_bg <- transform(sampled$grid, ink = ifelse(sampled$inside, "#D9C6D2", "transparent"))
joint_high <- st[st$spatial_zone_fig3e == "ABCA8_lpFib_Tcell_joint_high", ]
joint <- ggplot() +
  geom_raster(data = joint_bg, aes(x, y, fill = ink)) +
  scale_fill_identity() +
  geom_point(data = st, aes(imagecol, -imagerow), colour = "#CDB4C5", size = .68, stroke = 0) +
  geom_point(data = joint_high, aes(imagecol, -imagerow), colour = "#D7191C", size = .9, stroke = 0) +
  coord_equal() +
  labs(title = "C10_lpFib_ABCA8 / T cell", subtitle = "Joint high in red") +
  theme_umap_blank() +
  theme(legend.position = "none", plot.subtitle = element_text(size = 6, hjust = .5),
        panel.border = element_rect(fill = NA, colour = "#C6BFC3", linewidth = .45))
E_fields <- c("galectin", "HAVCR2", "CD86", "CTLA4")
E_titles <- c(if (galectin$gene == "LGALS3") "LGALS9/3 (LGALS3)" else "LGALS9/3", E_fields[-1])
E_small <- wrap_plots(lapply(seq_along(E_fields), function(i) {
  gene <- E_fields[i]
  area <- st[order(st[[gene]], na.last = FALSE), ]
  upper <- quantile(area[[gene]], .97, na.rm = TRUE, names = FALSE)
  if (upper <= min(area[[gene]], na.rm = TRUE)) upper <- max(area[[gene]], na.rm = TRUE)
  spatial_panel(area, gene, expression_cols, E_titles[i], size = .94, frame = FALSE, fixed = FALSE,
                normalise = FALSE, limits = c(0, upper)) +
    theme(aspect.ratio = 1, plot.title = element_text(size = 7.4, face = "plain"),
          panel.border = element_rect(fill = NA, colour = "black", linewidth = .6))
}), ncol = 2)
grob_palette <- as.raster(matrix(grDevices::colorRampPalette(expression_cols)(128), nrow = 1))
bar_grob <- grid::grobTree(
  grid::textGrob("Expression", x = .75, y = .63, just = "right", gp = grid::gpar(fontsize = 6.1)),
  grid::rasterGrob(grob_palette, x = .868, y = .65, width = .205, height = .25, interpolate = FALSE),
  grid::textGrob(c("Min", "Max"), x = c(.766, .971), y = .24, gp = grid::gpar(fontsize = 5))
)
p <- panel_tag(wrap_plots(wrap_plots(joint, E_small, nrow = 1, widths = c(.47, .53)),
                          wrap_elements(full = bar_grob), ncol = 1, heights = c(.91, .09)), "E")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
