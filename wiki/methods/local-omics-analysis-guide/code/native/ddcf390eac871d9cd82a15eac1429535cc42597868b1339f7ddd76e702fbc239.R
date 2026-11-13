wf_plot_scatter_ref1_style <- function(df, x, y, xlab = NULL, ylab = NULL, colour = NULL, colour_type = c("none", "discrete", "continuous"), palette = NULL, legend_title = NULL, point_size = 1.95, point_alpha = 0.6, add_lm = TRUE, add_stats = TRUE, fill_limits = NULL) {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package scales is required", call. = FALSE)
  colour_type <- match.arg(colour_type)
  if (colour_type == "none" || is.null(colour)) {
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]])) + geom_point(shape = 21, size = point_size, alpha = point_alpha, stroke = 0.32, fill = "#8FD0E0", colour = "#3E3E3E")
  } else if (colour_type == "discrete") {
    palette <- palette %||% wf_group_palette()
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]], fill = .data[[colour]])) + geom_point(shape = 21, size = point_size, alpha = point_alpha, stroke = 0.32, colour = "#3E3E3E") + scale_fill_manual(values = palette, name = legend_title %||% colour, drop = FALSE)
  } else {
    fill_limits <- fill_limits %||% wf_pretty_limits(df[[colour]], lower_q = 0.02, upper_q = 0.98, include_zero = FALSE)
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]], fill = .data[[colour]])) + geom_point(shape = 21, size = point_size, alpha = point_alpha, stroke = 0.32, colour = "#3E3E3E") + ggplot2::scale_fill_gradientn(colours = wf_scatter_ref1_palette(), limits = fill_limits, oob = scales::squish, name = legend_title %||% colour, breaks = wf_pretty_breaks(fill_limits, n = 4, include_zero = FALSE))
  }
  if (isTRUE(add_lm) && nrow(df) >= 3) p <- p + geom_smooth(method = "lm", se = FALSE, linewidth = 0.8, colour = "#4A4A4A")
  stats_label <- if (isTRUE(add_stats)) wf_scatter_stats_label(df, x, y) else NULL
  if (!is.null(stats_label)) {
    xrange <- range(df[[x]], na.rm = TRUE)
    yrange <- range(df[[y]], na.rm = TRUE)
    p <- p + annotate("text", x = xrange[1] + diff(xrange) * 0.03, y = yrange[2] - diff(yrange) * 0.03, label = stats_label, hjust = 0, vjust = 1, size = 3.5, fontface = "bold", colour = "#1F1F1F")
  }
  p + labs(x = xlab %||% x, y = ylab %||% y) + wf_theme_scatter_ref1() + guides(fill = if (colour_type == "continuous") guide_colorbar_paper(barheight_pt = 38, barwidth_pt = 7.5) else guide_legend_paper(override.aes = list(alpha = 1, size = 2.8)))
}
