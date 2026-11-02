wf_spatial_ref2_spec <- function() {
  spec <- get_figure_spec()
  ref2 <- spec$spatial_ref2 %||% list()
  list(
    background = ref2$panel_background %||% "#FFFFFF",
    border_colour = ref2$border_colour %||% "#5A5A5A",
    point_size = as.numeric(ref2$point_size %||% 2.45),
    point_alpha = as.numeric(ref2$point_alpha %||% 1),
    stroke = as.numeric(ref2$stroke %||% 0.3),
    legend_key_size_pt = as.numeric(ref2$legend_key_size_pt %||% 10),
    domain_label_fill = ref2$domain_label_fill %||% "#F6D98E",
    domain_label_colour = ref2$domain_label_colour %||% "#2F2F2F",
    domain_label_size = as.numeric(ref2$domain_label_size %||% 2.9)
  )
}
