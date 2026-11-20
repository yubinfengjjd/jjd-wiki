# Panel ID: fig06/H (Fig. 6 6H)
# Title: CAA_ST CCL14-CCR1 dual-channel concentric spatial co-expression map.
# Evidence tier: local_recompute
# Input tables: runs/step03_spatial/st_spots_fig6degh.csv
# Default dimensions: width = 4.2 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig06_h.R --paper-root <PAPER_ROOT> --out fig06_h.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig06_h.png', default_width = 4.2, default_height = 4.2)
st <- read_step("step03_spatial", "st_spots_fig6degh")
normalize_q <- function(x) {
  q <- unname(quantile(x, c(.05, .98), na.rm = TRUE))
  if (diff(q) < .Machine$double.eps) return(scale01(x))
  scales::squish(scales::rescale(x, from = q))
}
cc <- c("#F0EBEF", "#31A354")
cr <- c("#EFE9EE", "#DE2D26")
st$m1 <- normalize_q(st$CCL14)
st$m2 <- normalize_q(st$CCR1)
st$ccl14 <- wave_colour(st$m1, cc, c(0, 1))
st$ccr1 <- wave_colour(st$m2, cr, c(0, 1))
st <- st[order(st$m1 + st$m2), ]
coexpress <- ggplot(st, aes(imagecol, -imagerow)) +
  geom_point(colour = "#D8D0DC", size = .68, stroke = 0) +
  geom_point(aes(fill = ccl14, colour = ccr1), size = .64, shape = 21, stroke = .20, alpha = .89) +
  scale_fill_identity() + scale_colour_identity() + coord_equal() +
  labs(title = "CCL14-CCR1") + theme_umap_blank() +
  theme(plot.title = element_text(size = 6.8, face = "plain"),
        panel.border = element_rect(fill = NA, colour = "#BEB8BD", linewidth = .46))
channels <- wrap_plots(wrap_elements(full = wave_key(cc, "CCL14", "Min", "Max", TRUE)),
                       wrap_elements(full = wave_key(cr, "CCR1", "Min", "Max", TRUE)),
                       ncol = 1, heights = c(1, 1))
p <- panel_tag(wrap_plots(coexpress, channels, nrow = 1, widths = c(.72, .28)), "H")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
