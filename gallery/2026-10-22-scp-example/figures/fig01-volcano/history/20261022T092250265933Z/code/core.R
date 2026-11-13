# Volcano plotting core (one logical panel).
# Consumes a DE result table; does not read files or run DE tests.
# Adapted from SCP v0.5.6 VolcanoPlot (GPL-3); see original_code/volcano.R.

plot_volcano <- function(
    df,
    group = NULL,
    x_metric = c("diff_pct", "avg_log2FC"),
    log2fc_cutoff = 0,
    padj_cutoff = 0.05,
    direction = c("both", "up", "down"),
    nlabel = 8,
    features_label = NULL,
    cap_quantiles = c(0.01, 0.99),
    color_limits = c(-5, 5),
    palette = c("#053061", "#2166AC", "#F7F7F7", "#B2182B", "#67001F"),
    pt_size = 1,
    pt_alpha = 1,
    highlight_color = "black",
    highlight_size = 1.5,
    label_size = 4,
    label_fg = "black",
    label_bg = "white",
    label_bg_r = 0.1,
    base_size = 12,
    aspect_ratio = NULL
) {
  x_metric <- match.arg(x_metric)
  direction <- match.arg(direction)
  required <- c("gene", "group1", "avg_log2FC", "pct.1", "pct.2", "p_val_adj")
  missing <- setdiff(required, names(df))
  if (length(missing)) {
    stop("Missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (is.null(group)) {
    groups <- unique(as.character(df$group1))
    if (length(groups) != 1) {
      stop("Select one group1 for a single-panel volcano; found: ",
           paste(groups, collapse = ", "), call. = FALSE)
    }
    group <- groups[[1]]
  }
  df <- df[as.character(df$group1) == group, , drop = FALSE]
  if (!nrow(df)) stop("No rows for group1 = ", group, call. = FALSE)
  if (anyNA(df$avg_log2FC) || anyNA(df$pct.1) || anyNA(df$pct.2) ||
      anyNA(df$p_val_adj)) {
    stop("DE table contains NA in required numeric columns", call. = FALSE)
  }

  df$diff_pct <- df$pct.1 - df$pct.2
  df$neglog10padj <- -log10(df$p_val_adj)
  df$is_de <- FALSE
  up <- df$avg_log2FC > log2fc_cutoff & df$p_val_adj < padj_cutoff
  down <- df$avg_log2FC < -log2fc_cutoff & df$p_val_adj < padj_cutoff
  if (direction %in% c("both", "up")) df$is_de[up] <- TRUE
  if (direction %in% c("both", "down")) df$is_de[down] <- TRUE

  finite <- df$avg_log2FC[is.finite(df$avg_log2FC)]
  if (!length(finite)) stop("No finite avg_log2FC values", call. = FALSE)
  q <- stats::quantile(finite, cap_quantiles, names = FALSE, na.rm = TRUE)
  x_upper <- q[2]
  x_lower <- q[1]
  if (!(x_upper > 0)) x_upper <- max(finite[finite > 0], 0)
  if (!(x_lower < 0)) x_lower <- min(finite[finite < 0], 0)
  if (x_upper > 0 && x_lower < 0) {
    value_range <- min(abs(c(x_upper, x_lower)))
    x_upper <- value_range
    x_lower <- -value_range
  }

  df$border <- FALSE
  df$display_log2fc <- df$avg_log2FC
  hi <- df$display_log2fc > x_upper
  lo <- df$display_log2fc < x_lower
  df$border[hi | lo] <- TRUE
  df$display_log2fc[hi] <- x_upper
  df$display_log2fc[lo] <- x_lower

  if (x_metric == "diff_pct") {
    df$x <- df$diff_pct
    df$y <- df$neglog10padj
    df$y[df$display_log2fc < 0] <- -df$y[df$display_log2fc < 0]
    df <- df[order(abs(df$display_log2fc), decreasing = FALSE, na.last = FALSE), , drop = FALSE]
    color_by <- "display_log2fc"
    color_title <- "log2FC"
  } else {
    df$x <- df$display_log2fc
    df$y <- df$neglog10padj
    df$y[df$diff_pct < 0] <- -df$y[df$diff_pct < 0]
    df <- df[order(abs(df$diff_pct), decreasing = FALSE, na.last = FALSE), , drop = FALSE]
    color_by <- "diff_pct"
    color_title <- "diff_pct"
  }
  df$distance <- df$x^2 + df$y^2

  df$label <- FALSE
  if (is.null(features_label)) {
    pos <- which(df$y >= 0)
    neg <- which(df$y < 0)
    if (length(pos)) df$label[pos[head(order(df$distance[pos], decreasing = TRUE), nlabel)]] <- TRUE
    if (length(neg)) df$label[neg[head(order(df$distance[neg], decreasing = TRUE), nlabel)]] <- TRUE
  } else {
    df$label[df$gene %in% features_label] <- TRUE
  }

  jitter <- ggplot2::position_jitter(width = 0.2, height = 0.2, seed = 11)
  x_nudge <- diff(range(df$x, na.rm = TRUE)) * 0.05
  if (!is.finite(x_nudge) || x_nudge == 0) x_nudge <- 0.02

  p <- ggplot2::ggplot() +
    ggplot2::geom_point(
      data = df[!df$is_de & !df$border, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, color = .data[[color_by]]),
      size = pt_size, alpha = pt_alpha
    ) +
    ggplot2::geom_point(
      data = df[!df$is_de & df$border, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, color = .data[[color_by]]),
      size = pt_size, alpha = pt_alpha, position = jitter
    ) +
    ggplot2::geom_point(
      data = df[df$is_de & !df$border, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y),
      color = highlight_color, size = highlight_size
    ) +
    ggplot2::geom_point(
      data = df[df$is_de & df$border, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y),
      color = highlight_color, size = highlight_size, position = jitter
    ) +
    ggplot2::geom_point(
      data = df[df$is_de & !df$border, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, color = .data[[color_by]]),
      size = pt_size, alpha = pt_alpha
    ) +
    ggplot2::geom_point(
      data = df[df$is_de & df$border, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, color = .data[[color_by]]),
      size = pt_size, alpha = pt_alpha, position = jitter
    ) +
    ggplot2::geom_hline(yintercept = 0, color = "black", linewidth = 0.4) +
    ggplot2::geom_vline(xintercept = 0, color = "grey", linetype = 2, linewidth = 0.4) +
    ggrepel::geom_text_repel(
      data = df[df$label, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$gene),
      min.segment.length = 0, max.overlaps = 100,
      segment.colour = "grey40", color = label_fg,
      bg.color = label_bg, bg.r = label_bg_r,
      size = label_size, force = 20,
      nudge_x = ifelse(df$y[df$label] >= 0, -x_nudge, x_nudge)
    ) +
    ggplot2::labs(
      x = if (x_metric == "diff_pct") "diff_pct" else "avg_log2FC",
      y = "-log10(p-adjust)",
      title = group,
      color = color_title
    ) +
    ggplot2::scale_color_gradientn(
      colors = palette,
      limits = color_limits,
      oob = scales::squish,
      guide = ggplot2::guide_colorbar(
        frame.colour = "black", ticks.colour = "black", title.hjust = 0
      )
    ) +
    ggplot2::scale_y_continuous(labels = abs) +
    ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(fill = NA, colour = "black", linewidth = 1),
      plot.title = ggplot2::element_text(hjust = 0.5, size = base_size * 1.15),
      axis.title = ggplot2::element_text(size = base_size * 1.05),
      axis.text = ggplot2::element_text(size = base_size, colour = "black"),
      legend.title = ggplot2::element_text(size = base_size),
      legend.text = ggplot2::element_text(size = base_size * 0.9),
      legend.key = ggplot2::element_rect(fill = "transparent", colour = "transparent"),
      aspect.ratio = aspect_ratio
    )
  p
}
