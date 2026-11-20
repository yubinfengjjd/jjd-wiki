# Panel ID: fig02/J (Fig. 2 2J)
# Title: Zenodo CAA_ST single-slide 14-Fib signature weighting proxy (raw scores and relative weights).
# Evidence tier: proxy
# Input tables: runs/step03_spatial/st_spots_fig2j.csv
# Default dimensions: width = 6.8 in, height = 5.2 in
# Usage: Rscript --vanilla code/panels/fig02_j.R --paper-root <PAPER_ROOT> --out fig02_j.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_j.png', default_width = 6.8, default_height = 5.2)
st <- read_step("step03_spatial", "st_spots_fig2j")
st_fields <- paste0("score_", names(fib_legacy))
sp_palette <- c("#7B84B8", "#A5A6C5", "#E8A64B")
stopifnot(all(st_fields %in% names(st)))
mat <- as.matrix(st[, st_fields])
shifted <- apply(mat, 2, function(value) pmax(0, value - quantile(value, .05, na.rm = TRUE)))
weighted <- st
weighted[, st_fields] <- shifted / pmax(rowSums(shifted), .Machine$double.eps)
sp_grid <- function(d) {
  wrap_plots(lapply(seq_along(st_fields), function(i) {
    spatial_panel(d, st_fields[i], sp_palette, names(fib_cols)[i], size = .44, fixed = FALSE) +
      theme(plot.title = element_text(size = 4.6, face = "plain", hjust = .5, margin = margin(0, 0, 1, 0)),
            panel.spacing = grid::unit(1.5, "pt"), plot.margin = margin(.75, .75, .75, .75))
  }), ncol = 7)
}
label_grob <- function(value) wrap_elements(full = grid::textGrob(value, x = .062, just = "left", gp = grid::gpar(fontsize = 6, col = "#333333")))
p <- panel_tag(wrap_plots(
  label_grob("CAA_ST  |  Fib signature scores"),
  sp_grid(st),
  label_grob("CAA_ST  |  Relative signature weights (same section)"),
  sp_grid(weighted),
  wrap_elements(full = panel_legend_bar(sp_palette, "Cell density proxy", compact = TRUE)),
  ncol = 1, heights = c(.059, .421, .047, .421, .052)
), "J")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
