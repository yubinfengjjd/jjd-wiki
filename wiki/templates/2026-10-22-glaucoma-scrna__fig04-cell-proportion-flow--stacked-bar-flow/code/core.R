# Cell-proportion stacked bars with flow ribbons between adjacent groups.
# Returns a ggplot object; does not read files or save.

plot_cellprop_flow <- function(
    data,
    x_col = "group",
    celltype_col = "celltype",
    prop_col = "proportion",
    x_levels = NULL,
    stack_levels = NULL,
    legend_levels = NULL,
    palette = NULL,
    normalize = TRUE,
    bar_width = 0.36,
    flow_alpha = 0.22,
    bar_alpha = 0.92,
    flow_n = 120,
    y_lab = "Cell proportion",
    legend_title = "Cell type",
    base_family = "sans"
) {
  required <- c(x_col, celltype_col, prop_col)
  if (!all(required %in% names(data))) {
    stop("Missing required columns: ",
         paste(setdiff(required, names(data)), collapse = ", "))
  }

  df <- data.frame(
    group = data[[x_col]],
    celltype = data[[celltype_col]],
    prop = as.numeric(data[[prop_col]]),
    stringsAsFactors = FALSE
  )

  if (is.null(x_levels)) x_levels <- unique(df$group)
  if (is.null(stack_levels)) stack_levels <- unique(df$celltype)
  if (is.null(legend_levels)) legend_levels <- rev(stack_levels)

  df <- df[!is.na(df$group) & !is.na(df$celltype) & !is.na(df$prop), , drop = FALSE]
  df$group <- factor(df$group, levels = x_levels)
  df$celltype <- factor(df$celltype, levels = stack_levels)

  if (isTRUE(normalize)) {
    df <- df |>
      dplyr::group_by(group) |>
      dplyr::mutate(prop = prop / sum(prop)) |>
      dplyr::ungroup()
  }

  pos_df <- df |>
    dplyr::arrange(group, celltype) |>
    dplyr::group_by(group) |>
    dplyr::mutate(
      ymax = cumsum(prop),
      ymin = ymax - prop,
      x = match(group, x_levels)
    ) |>
    dplyr::ungroup()

  flow_list <- list()
  idx <- 1
  for (ct in levels(pos_df$celltype)) {
    tmp <- pos_df[pos_df$celltype == ct, , drop = FALSE]
    tmp <- tmp[order(tmp$x), , drop = FALSE]
    if (nrow(tmp) >= 2) {
      for (i in seq_len(nrow(tmp) - 1)) {
        left <- tmp[i, ]
        right <- tmp[i + 1, ]
        x_seq <- seq(left$x + bar_width / 2, right$x - bar_width / 2, length.out = flow_n)
        flow_list[[idx]] <- data.frame(
          x = x_seq,
          ymin = seq(left$ymin, right$ymin, length.out = flow_n),
          ymax = seq(left$ymax, right$ymax, length.out = flow_n),
          celltype = as.character(ct),
          flow_id = paste0(ct, "_", i),
          stringsAsFactors = FALSE
        )
        idx <- idx + 1
      }
    }
  }
  flow_df <- dplyr::bind_rows(flow_list)

  if (is.null(palette)) {
    palette <- c(
      "#D96C86", "#F2A3A1", "#BDD6E8", "#8EA8D2", "#86C6BC",
      "#BCA7D8", "#DDD1EC", "#E64B35", "#4DBBD5"
    )
  }
  if (length(palette) < length(stack_levels)) {
    palette <- grDevices::hcl.colors(length(stack_levels), "Dark 3")
  }
  palette <- stats::setNames(palette[seq_along(stack_levels)], stack_levels)

  p <- ggplot2::ggplot() +
    ggplot2::geom_ribbon(
      data = flow_df,
      ggplot2::aes(x = x, ymin = ymin, ymax = ymax, group = flow_id, fill = celltype),
      alpha = flow_alpha, colour = NA
    ) +
    ggplot2::geom_rect(
      data = pos_df,
      ggplot2::aes(
        xmin = x - bar_width / 2, xmax = x + bar_width / 2,
        ymin = ymin, ymax = ymax, fill = celltype
      ),
      colour = NA, alpha = bar_alpha
    ) +
    ggplot2::scale_fill_manual(
      values = palette, breaks = legend_levels,
      name = legend_title, drop = FALSE
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq_along(x_levels), labels = x_levels,
      expand = ggplot2::expansion(mult = c(0.12, 0.12))
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, 1), breaks = c(0, 0.25, 0.50, 0.75, 1.00),
      labels = function(x) sprintf("%.2f", x),
      expand = c(0, 0)
    ) +
    ggplot2::labs(x = NULL, y = y_lab) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_classic(base_size = 12, base_family = base_family) +
    ggplot2::theme(
      axis.line = ggplot2::element_line(colour = "#4D4D4D", linewidth = 1.0),
      axis.ticks = ggplot2::element_line(colour = "#4D4D4D", linewidth = 1.0),
      axis.ticks.length = grid::unit(0.16, "cm"),
      axis.text = ggplot2::element_text(colour = "#333333", size = 11),
      axis.title.y = ggplot2::element_text(colour = "#333333", size = 13),
      axis.title.x = ggplot2::element_blank(),
      legend.position = "right",
      legend.title = ggplot2::element_text(size = 12, face = "bold"),
      legend.text = ggplot2::element_text(size = 10),
      legend.key.size = grid::unit(0.42, "cm"),
      legend.background = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = ggplot2::margin(8, 10, 8, 8)
    )

  p
}

`%||%` <- function(a, b) if (!is.null(a)) a else b

draw_cellprop_flow <- function(df, style = list()) {
  plot_cellprop_flow(
    data = df,
    x_levels = style$x_levels,
    stack_levels = style$stack_levels,
    legend_levels = style$legend_levels,
    palette = style$palette,
    normalize = style$normalize %||% TRUE,
    bar_width = style$bar_width %||% 0.36,
    flow_alpha = style$flow_alpha %||% 0.22,
    bar_alpha = style$bar_alpha %||% 0.92,
    flow_n = style$flow_n %||% 120,
    y_lab = style$y_lab %||% "Cell proportion",
    legend_title = style$legend_title %||% "Cell type",
    base_family = style$font_family %||% "sans"
  )
}
