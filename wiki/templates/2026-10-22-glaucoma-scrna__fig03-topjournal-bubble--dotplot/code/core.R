# Top-journal bubble dot plot: group x feature, color = relative expression,
# size = percentage expressed, bottom color chips for groups.
# Returns a ggplot object; does not read files or save.

plot_dotplot_bubble <- function(
    df,
    x_col = "group",
    y_col = "feature",
    expr_col = "avg_expression",
    pct_col = "pct_expressed",
    x_levels = NULL,
    y_levels = NULL,
    x_colors = NULL,
    expr_palette = c("#083B6F", "#3B8FC2", "#D9EEF4", "#F6F3EA", "#F07C56", "#8A001F"),
    expr_limits = c(0, 1),
    expr_breaks = c(0, 0.25, 0.50, 0.75, 1.00),
    size_limits = c(0, 100),
    size_breaks = c(25, 50, 75),
    size_range = c(1.2, 7.0),
    panel_fill = "#F2F2F2",
    plot_width = 6,
    plot_height = 12,
    italic_y = TRUE,
    base_family = "sans"
) {
  required <- c(x_col, y_col, expr_col, pct_col)
  if (!all(required %in% names(df))) {
    stop("Missing required columns: ",
         paste(setdiff(required, names(df)), collapse = ", "))
  }

  dat <- data.frame(
    x_value = as.character(df[[x_col]]),
    y_value = as.character(df[[y_col]]),
    expr_value = as.numeric(df[[expr_col]]),
    pct_value = as.numeric(df[[pct_col]]),
    stringsAsFactors = FALSE
  )
  dat$expr_value <- pmax(expr_limits[1], pmin(expr_limits[2], dat$expr_value))
  dat$pct_value <- pmax(size_limits[1], pmin(size_limits[2], dat$pct_value))

  if (is.null(x_levels)) x_levels <- unique(dat$x_value)
  if (is.null(y_levels)) y_levels <- unique(dat$y_value)
  x_levels <- as.character(x_levels)
  y_levels <- as.character(y_levels)
  dat <- dat[dat$x_value %in% x_levels & dat$y_value %in% y_levels, , drop = FALSE]
  dat$x_value <- factor(dat$x_value, levels = x_levels)
  dat$y_value <- factor(dat$y_value, levels = y_levels)
  dat$x <- as.numeric(dat$x_value)
  dat$y <- length(y_levels) - as.numeric(dat$y_value) + 1

  if (is.null(x_colors)) {
    x_colors <- c(
      "#F2A000", "#37B7AE", "#13A25B", "#F0DB35", "#1C9AD6",
      "#D65F00", "#AEB0B4", "#C98CB7", "#E64B35", "#4DBBD5",
      "#00A087", "#3C5488", "#F39B7F", "#7876B1", "#EE4C97",
      "#7E6148", "#20854E", "#FFDC91", "#BC80BD", "#8DD3C7"
    )
  }
  if (length(x_colors) < length(x_levels)) {
    x_colors <- grDevices::hcl.colors(length(x_levels), "Dark 3")
  }
  x_colors <- stats::setNames(x_colors[seq_along(x_levels)], x_levels)

  anno_df <- data.frame(
    x = seq_along(x_levels),
    y = -0.85,
    anno = factor(x_levels, levels = x_levels)
  )

  p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(
      ggplot2::aes(size = pct_value, colour = expr_value), alpha = 0.98
    ) +
    ggplot2::geom_point(
      data = anno_df,
      ggplot2::aes(x = x, y = y, fill = anno),
      inherit.aes = FALSE, shape = 21, size = 4.8, stroke = 0
    ) +
    ggplot2::scale_fill_manual(values = x_colors, guide = "none") +
    ggplot2::scale_colour_gradientn(
      colours = expr_palette,
      limits = expr_limits,
      breaks = expr_breaks,
      labels = sprintf("%.2f", expr_breaks),
      oob = scales::squish,
      name = "Relative\nExpression"
    ) +
    ggplot2::scale_size_continuous(
      range = size_range,
      limits = size_limits,
      breaks = size_breaks,
      name = "Percentage\nExpressed"
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq_along(x_levels),
      labels = x_levels,
      limits = c(0.5, length(x_levels) + 0.5),
      expand = ggplot2::expansion(mult = 0)
    ) +
    ggplot2::scale_y_continuous(
      breaks = seq_along(y_levels),
      labels = rev(y_levels),
      limits = c(-1.35, length(y_levels) + 0.6),
      expand = ggplot2::expansion(mult = 0)
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::guides(
      colour = ggplot2::guide_colourbar(
        title.position = "top", title.hjust = 0,
        barheight = grid::unit(3.0, "cm"),
        barwidth = grid::unit(0.45, "cm"),
        ticks.colour = "black", frame.colour = NA
      ),
      size = ggplot2::guide_legend(
        title.position = "top", title.hjust = 0,
        override.aes = list(colour = "black", alpha = 1),
        label.position = "right"
      )
    ) +
    ggplot2::theme_classic(base_size = 10, base_family = base_family) +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = panel_fill, colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      panel.border = ggplot2::element_rect(fill = NA, colour = "black", linewidth = 1.5),
      axis.line = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(
        angle = 90, vjust = 0.5, hjust = 1, colour = "black", size = 9.5,
        margin = ggplot2::margin(t = 3)
      ),
      axis.text.y = ggplot2::element_text(
        colour = "black", size = 9.2,
        face = if (isTRUE(italic_y)) "italic" else "plain",
        margin = ggplot2::margin(r = 3)
      ),
      axis.ticks = ggplot2::element_line(colour = "black", linewidth = 0.55),
      axis.ticks.length = grid::unit(2.3, "pt"),
      legend.position = "right",
      legend.box = "vertical",
      legend.box.spacing = grid::unit(1.2, "cm"),
      legend.title = ggplot2::element_text(size = 10.5, colour = "black", lineheight = 0.9),
      legend.text = ggplot2::element_text(size = 8.7, colour = "black"),
      legend.key = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(8, 22, 8, 8)
    )

  p
}

`%||%` <- function(a, b) if (!is.null(a)) a else b

draw_dotplot_bubble <- function(df, style = list()) {
  x_levels <- style$x_levels %||% unique(as.character(df$group))
  if (!is.null(style$y_levels)) {
    y_levels <- style$y_levels
  } else {
    features <- unique(as.character(df$feature))
    if ("target_group" %in% names(df)) {
      target <- df$target_group[match(features, df$feature)]
      target_pos <- match(target, x_levels)
      y_levels <- features[order(target_pos, seq_along(features), na.last = TRUE)]
    } else {
      y_levels <- features
    }
  }
  plot_dotplot_bubble(
    df,
    x_levels = x_levels,
    y_levels = y_levels,
    x_colors = style$x_colors,
    expr_palette = style$expr_palette %||% c(
      "#083B6F", "#3B8FC2", "#D9EEF4", "#F6F3EA", "#F07C56", "#8A001F"
    ),
    expr_limits = style$expr_limits %||% c(0, 1),
    expr_breaks = style$expr_breaks %||% c(0, 0.25, 0.5, 0.75, 1),
    size_limits = style$size_limits %||% c(0, 100),
    size_breaks = style$size_breaks %||% c(25, 50, 75),
    size_range = style$size_range %||% c(1.2, 7.0),
    panel_fill = style$panel_fill %||% "#F2F2F2",
    plot_width = style$width_in %||% 6,
    plot_height = style$height_in %||% 12,
    italic_y = style$italic_y %||% TRUE,
    base_family = style$font_family %||% "sans"
  )
}
