wf_spatial_ref1_spec <- function() {
  spec <- get_figure_spec()
  ref1 <- spec$spatial_ref1 %||% list()
  list(
    background = ref1$panel_background %||% spec$spatial$panel_background %||% "#ECECE8",
    continuous_hex = ref1$continuous_hex %||% c("#2A3F9D", "#2C77C3", "#46B3B3", "#E9E4A5", "#F0A35A", "#D13E3E"),
    border_colour = ref1$border_colour %||% "#474747",
    point_size = as.numeric(ref1$point_size %||% 2.5),
    point_alpha = as.numeric(ref1$point_alpha %||% 1),
    stroke = as.numeric(ref1$stroke %||% 0.3),
    legend_barheight_pt = as.numeric(ref1$legend_barheight_pt %||% 44),
    legend_barwidth_pt = as.numeric(ref1$legend_barwidth_pt %||% 8.5)
  )
}
