# Marker feature UMAP grid: gray background, expression gradient, target-group
# contour, short axes and per-panel colorbars. Returns a patchwork object.
# It does not read files, run analysis, or save output.

plot_feature_umap_grid <- function(
    coords,
    expr_long,
    genes,
    gene_to_group,
    ncol = 3,
    x_col = "umap_1",
    y_col = "umap_2",
    cell_col = "cell_id",
    group_col = "group",
    feature_col = "feature",
    value_col = "value",
    exp_palette = c("#74B8AF", "#CFE0C7", "#F1E8AE"),
    bg_color = "#CFCFCF",
    pt_size_bg = 0.24,
    pt_size_fg = 0.30,
    alpha_bg = 0.32,
    alpha_fg = 0.96,
    min_cutoff = "q05",
    max_cutoff = "q98",
    title_size = 13.5,
    legend_text_size = 7,
    xpad_ratio = 0.018,
    ypad_ratio = 0.018,
    panel_margin = 7,
    family = "sans",
    return_list = FALSE
) {
  required_coords <- c(x_col, y_col, cell_col, group_col)
  required_expr <- c(cell_col, feature_col, value_col)
  if (!all(required_coords %in% names(coords))) {
    stop("Missing coordinate columns: ",
         paste(setdiff(required_coords, names(coords)), collapse = ", "))
  }
  if (!all(required_expr %in% names(expr_long))) {
    stop("Missing expression columns: ",
         paste(setdiff(required_expr, names(expr_long)), collapse = ", "))
  }
  if (any(is.na(coords[[x_col]])) || any(is.na(coords[[y_col]]))) {
    stop("UMAP coordinates contain NA; remove or impute before plotting.")
  }

  x_range <- range(coords[[x_col]], na.rm = TRUE)
  y_range <- range(coords[[y_col]], na.rm = TRUE)
  x_span <- diff(x_range)
  y_span <- diff(y_range)
  x_pad <- x_span * xpad_ratio
  y_pad <- y_span * ypad_ratio
  x_lim <- c(x_range[1] - x_pad, x_range[2] + x_pad)
  y_lim <- c(y_range[1] - y_pad, y_range[2] + y_pad)
  axis_len_x <- x_span * 0.12
  axis_len_y <- y_span * 0.12
  axis_x0 <- x_lim[1] + x_pad
  axis_y0 <- y_lim[1] + y_pad

  parse_cutoff <- function(x, values) {
    if (is.numeric(x)) return(x)
    if (is.character(x) && grepl("^q[0-9]+$", x)) {
      q <- as.numeric(sub("^q", "", x)) / 100
      return(as.numeric(stats::quantile(values, probs = q, na.rm = TRUE)))
    }
    stop("cutoff must be numeric or character like 'q05', 'q95'")
  }

  make_one_panel <- function(gene) {
    sub <- expr_long[expr_long[[feature_col]] == gene, c(cell_col, value_col), drop = FALSE]
    df <- coords
    df$value <- sub[[value_col]][match(df[[cell_col]], sub[[cell_col]])]
    df_bg <- df
    df_fg <- df[!is.na(df$value) & df$value > 0, , drop = FALSE]

    if (nrow(df_fg) == 0) {
      p <- ggplot2::ggplot() +
        ggplot2::geom_point(
          data = df_bg,
          ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]]),
          color = bg_color, size = pt_size_bg, alpha = alpha_bg, stroke = 0
        ) +
        ggplot2::coord_cartesian(
          xlim = x_lim, ylim = y_lim, expand = FALSE, clip = "off"
        ) +
        ggplot2::labs(title = gene) +
        ggplot2::theme_void(base_family = family) +
        ggplot2::theme(
          plot.title = ggplot2::element_text(
            face = "italic", size = title_size, hjust = 0.5,
            margin = ggplot2::margin(b = 2), family = family
          ),
          plot.margin = ggplot2::margin(panel_margin, panel_margin,
                                        panel_margin, panel_margin)
        )
      return(p)
    }

    min_val <- parse_cutoff(min_cutoff, df_fg$value)
    max_val <- parse_cutoff(max_cutoff, df_fg$value)
    if (isTRUE(min_val >= max_val)) {
      min_val <- min(df_fg$value, na.rm = TRUE)
      max_val <- max(df_fg$value, na.rm = TRUE)
    }
    df_fg$value_plot <- pmin(pmax(df_fg$value, min_val), max_val)
    df_fg <- df_fg[order(df_fg$value_plot), , drop = FALSE]

    brks <- pretty(c(min_val, max_val), n = 4)
    brks <- brks[brks >= min_val & brks <= max_val]

    p <- ggplot2::ggplot() +
      ggplot2::geom_point(
        data = df_bg,
        ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]]),
        color = bg_color, size = pt_size_bg, alpha = alpha_bg, stroke = 0
      ) +
      ggplot2::geom_point(
        data = df_fg,
        ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]], colour = value_plot),
        size = pt_size_fg, alpha = alpha_fg, stroke = 0
      ) +
      ggplot2::scale_colour_gradientn(
        colours = exp_palette,
        limits = c(min_val, max_val),
        breaks = brks,
        labels = function(x) format(round(x, 0), trim = TRUE, scientific = FALSE),
        oob = scales::squish,
        guide = ggplot2::guide_colorbar(
          title = NULL, frame.colour = NA, ticks.colour = NA,
          barheight = grid::unit(1.6, "cm"),
          barwidth = grid::unit(0.20, "cm")
        )
      ) +
      ggplot2::coord_cartesian(
        xlim = x_lim, ylim = y_lim, expand = FALSE, clip = "off"
      ) +
      ggplot2::labs(title = gene) +
      ggplot2::theme_void(base_family = family) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(
          face = "italic", size = title_size, hjust = 0.5,
          margin = ggplot2::margin(b = 2), family = family
        ),
        legend.position = "right",
        legend.text = ggplot2::element_text(size = legend_text_size, colour = "black"),
        legend.key.height = grid::unit(0.35, "cm"),
        legend.key.width = grid::unit(0.22, "cm"),
        plot.background = ggplot2::element_rect(fill = "white", colour = NA),
        panel.background = ggplot2::element_rect(fill = "white", colour = NA),
        plot.margin = ggplot2::margin(panel_margin, panel_margin,
                                      panel_margin, panel_margin)
      )

    target <- unname(gene_to_group[[gene]])
    if (!is.null(target) && !is.na(target) && target %in% df_bg[[group_col]]) {
      df_contour <- df_bg[df_bg[[group_col]] == target, , drop = FALSE]
      if (nrow(df_contour) > 2) {
        p <- p + ggunchull::stat_unchull(
          data = df_contour,
          ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]]),
          colour = "#A0A0A0", fill = "#D8D8D8", alpha = 0.25,
          linewidth = 0.22, delta = 0.45, linetype = "dashed",
          inherit.aes = FALSE
        )
      }
    }

    p <- p +
      ggplot2::annotate(
        "segment",
        x = axis_x0, xend = axis_x0 + axis_len_x,
        y = axis_y0, yend = axis_y0,
        linewidth = 0.4, color = "black",
        arrow = grid::arrow(length = grid::unit(0.10, "cm"), type = "closed")
      ) +
      ggplot2::annotate(
        "segment",
        x = axis_x0, xend = axis_x0,
        y = axis_y0, yend = axis_y0 + axis_len_y,
        linewidth = 0.4, color = "black",
        arrow = grid::arrow(length = grid::unit(0.10, "cm"), type = "closed")
      ) +
      ggplot2::annotate(
        "text",
        x = axis_x0 + axis_len_x * 0.55,
        y = axis_y0 - y_span * 0.040,
        label = "UMAP_1", size = 2.8, fontface = "italic", family = family
      ) +
      ggplot2::annotate(
        "text",
        x = axis_x0 - x_span * 0.040,
        y = axis_y0 + axis_len_y * 0.55,
        label = "UMAP_2", size = 2.8, fontface = "italic",
        family = family, angle = 90
      )

    p
  }

  plots <- lapply(genes, make_one_panel)
  if (isTRUE(return_list)) {
    return(plots)
  }
  patchwork::wrap_plots(plotlist = plots, ncol = ncol, byrow = TRUE)
}
