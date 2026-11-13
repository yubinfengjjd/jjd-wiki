# Concentric ring composition plot (one logical panel).
# Consumes a group/celltype/proportion table; does not read files or count cells.
# Adapted from SCP v0.5.6 CellStatPlot(plot_type = "ring") / StatPlot (GPL-3).

plot_ring <- function(
    df,
    group_col = "group",
    celltype_col = "celltype",
    proportion_col = "proportion",
    group_levels = NULL,
    celltype_levels = NULL,
    palette = NULL,
    ring_gap = 0.06,
    min_label_prop = 0.03,
    label_size = 3.2,
    group_label_size = 4,
    show_reference = TRUE,
    show_axis_titles = TRUE,
    clockwise = TRUE,
    border_color = "black",
    border_linewidth = 0.3,
    legend_title = "Cell type",
    base_size = 12
) {
  required <- c(group_col, celltype_col, proportion_col)
  missing <- setdiff(required, names(df))
  if (length(missing)) {
    stop("Missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  df <- data.frame(
    group = as.character(df[[group_col]]),
    celltype = as.character(df[[celltype_col]]),
    proportion = as.numeric(df[[proportion_col]]),
    stringsAsFactors = FALSE
  )
  if (anyNA(df$group) || anyNA(df$celltype) || anyNA(df$proportion)) {
    stop("group/celltype/proportion contain NA", call. = FALSE)
  }
  if (any(df$proportion < 0)) stop("proportion must be non-negative", call. = FALSE)
  if (is.null(group_levels)) group_levels <- unique(df$group)
  if (is.null(celltype_levels)) celltype_levels <- unique(df$celltype)
  group_levels <- as.character(group_levels)
  celltype_levels <- as.character(celltype_levels)
  if (!all(df$group %in% group_levels)) stop("group contains levels not in group_levels", call. = FALSE)
  if (!all(df$celltype %in% celltype_levels)) stop("celltype contains levels not in celltype_levels", call. = FALSE)
  sums <- tapply(df$proportion, df$group, sum)
  if (any(abs(sums - 1) > 1e-6)) {
    stop("proportion must sum to 1 within each group", call. = FALSE)
  }

  df$group <- factor(df$group, levels = group_levels)
  df$celltype <- factor(df$celltype, levels = celltype_levels)
  if (isTRUE(clockwise)) {
    df$celltype_draw <- factor(df$celltype, levels = rev(celltype_levels))
  } else {
    df$celltype_draw <- df$celltype
  }
  df <- df[order(df$group, df$celltype_draw), , drop = FALSE]
  df$start <- ave(df$proportion, df$group, FUN = function(x) c(0, head(cumsum(x), -1)))
  df$end <- ave(df$proportion, df$group, FUN = cumsum)
  df$ring <- as.numeric(df$group)
  df$r0 <- df$ring - 1 + ring_gap / 2
  df$r1 <- df$ring - ring_gap / 2
  df$mid <- (df$start + df$end) / 2 * 2 * pi
  df$lab_r <- (df$r0 + df$r1) / 2
  max_r <- max(df$r1)
  ref_r <- max_r + 0.22
  n_groups <- length(group_levels)
  n_celltypes <- length(celltype_levels)

  if (is.null(palette)) {
    palette <- c("#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99",
                 "#E31A1C", "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A",
                 "#FFFF99", "#B15928")
  }
  if (length(palette) < n_celltypes) {
    palette <- grDevices::colorRampPalette(palette)(n_celltypes)
  }
  palette <- palette[seq_len(n_celltypes)]

  p <- ggplot2::ggplot(df) +
    ggforce::geom_arc_bar(
      ggplot2::aes(x0 = 0, y0 = 0, r0 = r0, r = r1, start = start * 2 * pi,
                   end = end * 2 * pi, fill = celltype),
      color = border_color, linewidth = border_linewidth
    ) +
    ggplot2::geom_text(
      ggplot2::aes(
        x = lab_r * cos(mid), y = lab_r * sin(mid),
        label = ifelse(proportion >= min_label_prop,
                       paste0(round(proportion * 100, 1), "%"), "")
      ),
      size = label_size, color = "black"
    ) +
    ggplot2::annotate(
      "text", x = -max_r * 1.14, y = seq_along(group_levels) - 0.5,
      label = group_levels, hjust = 1, size = group_label_size
    ) +
    ggplot2::annotate(
      "segment", x = -max_r * 1.12, xend = -max_r * 1.02,
      y = seq_along(group_levels) - 0.5, yend = seq_along(group_levels) - 0.5,
      linewidth = 0.4
    ) +
    ggplot2::scale_fill_manual(values = palette, name = legend_title) +
    ggplot2::coord_fixed(clip = "off") +
    ggplot2::theme_void(base_size = base_size) +
    ggplot2::theme(
      panel.border = ggplot2::element_rect(fill = NA, colour = "black", linewidth = 0.8),
      legend.position = "right",
      plot.margin = ggplot2::margin(20, 20, 20, 90)
    )

  if (isTRUE(show_reference)) {
    ref_df <- data.frame(x0 = 0, y0 = 0, r = ref_r)
    p <- p +
      ggforce::geom_circle(
        data = ref_df,
        ggplot2::aes(x0 = x0, y0 = y0, r = r),
        inherit.aes = FALSE, linetype = "dashed", color = "grey70", linewidth = 0.4
      ) +
      ggplot2::annotate("text", x = 0, y = ref_r + 0.20, label = "0%/100%", size = 3.4) +
      ggplot2::annotate("text", x = ref_r + 0.20, y = 0, label = "25%", size = 3.4, hjust = 0) +
      ggplot2::annotate("text", x = 0, y = -ref_r - 0.32, label = "50%", size = 3.4) +
      ggplot2::annotate("text", x = -ref_r - 0.40, y = -0.15, label = "75%", size = 3.4, hjust = 1)
  }
  if (isTRUE(show_axis_titles)) {
    p <- p +
      ggplot2::annotate("text", x = -max_r * 1.90, y = max_r * 0.60,
                        label = "CellType", angle = 90, size = 4) +
      ggplot2::annotate("text", x = 0, y = -max_r - 0.90, label = "Percentage", size = 4)
  }
  attr(p, "ring_meta") <- list(
    n_groups = n_groups, n_celltypes = n_celltypes,
    max_r = max_r, min_label_prop = min_label_prop
  )
  p
}

ring_size_in <- function(n_groups, n_celltypes, base = 4.0,
                         per_group = 0.35, per_celltype = 0.08, minimum = 5.0) {
  max(minimum, base + per_group * n_groups + per_celltype * n_celltypes)
}
