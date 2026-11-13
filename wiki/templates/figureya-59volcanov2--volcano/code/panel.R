# Bulk DE volcano with tiered colours/sizes, functionized from FigureYa59volcanoV2.
# Plots logFC and P values given upstream (e.g. limma topTable); no test is recomputed.
# "advanced" = upstream tiered mode, "classic" = red/blue/grey. Optional highlighted genes are
# circled and labelled, coloured by their gene set; one colour per set, no silent recycling.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

UPSTREAM_SET_COLORS <- c("darkgreen", "chocolate4", "blueviolet", "#223D6C", "#D20A13", "#088247",
                         "#58CDD9", "#7A142C", "#5D90BA", "#431A3D", "#91612D", "#6E568C",
                         "#E0367A", "#D8D155", "#64495D", "#7CC767")

volcano_prepare <- function(df) {
  required <- c("gene", "log2fc", "pvalue")
  missing <- setdiff(required, names(df))
  if (length(missing)) stop("Missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  if (anyNA(df$gene) || any(!nzchar(as.character(df$gene)))) stop("gene cannot be missing", call. = FALSE)
  if (anyDuplicated(df$gene)) stop("gene must be unique", call. = FALSE)
  for (column in c("log2fc", "pvalue")) {
    if (!is.numeric(df[[column]]) || any(!is.finite(df[[column]]))) {
      stop(column, " must be finite numbers", call. = FALSE)
    }
  }
  if (any(df$pvalue <= 0 | df$pvalue > 1)) stop("pvalue must be in (0, 1]", call. = FALSE)
  df
}

plot_panel <- function(tables, style) {
  if (!"de" %in% names(tables)) stop("Missing table: de", call. = FALSE)
  x <- volcano_prepare(as.data.frame(tables$de))
  mode <- get_style(style, "mode", "advanced")
  fc1 <- get_style(style, "logfc_cut", 1.5)
  p1 <- get_style(style, "p_cut", 0.05)
  fc2 <- get_style(style, "logfc_cut2", 2.5)
  p2 <- get_style(style, "p_cut2", 1e-4)
  fc3 <- get_style(style, "logfc_cut3", 5)
  p3 <- get_style(style, "p_cut3", 1e-5)
  if (identical(mode, "classic")) {
    cols <- ifelse(x$pvalue < p1 & x$log2fc > fc1, "red",
                   ifelse(x$pvalue < p1 & x$log2fc < -fc1, "blue", "grey"))
    size <- ifelse(x$pvalue < p1 & abs(x$log2fc) > fc1, 4, 2)
  } else if (identical(mode, "advanced")) {
    cols <- rep("grey", nrow(x))
    cols[x$pvalue < p1 & x$log2fc > fc1] <- "#FB9A99"
    cols[x$pvalue < p2 & x$log2fc > fc2] <- "#ED4F4F"
    cols[x$pvalue < p1 & x$log2fc < -fc1] <- "#B2DF8A"
    cols[x$pvalue < p2 & x$log2fc < -fc2] <- "#329E3F"
    cols <- grDevices::adjustcolor(cols, alpha.f = 0.5)
    size <- rep(1, nrow(x))
    size[x$pvalue < p1 & abs(x$log2fc) > fc1] <- 2
    size[x$pvalue < p2 & abs(x$log2fc) > fc2] <- 4
    size[x$pvalue < p3 & abs(x$log2fc) > fc3] <- 6
  } else {
    stop("style.mode must be 'advanced' or 'classic'", call. = FALSE)
  }
  x$color_transparent <- cols
  x$size <- size
  x$nlp <- -log10(x$pvalue)
  limit <- get_style(style, "x_limit", NULL)
  if (is.null(limit)) limit <- ceiling(max(abs(x$log2fc))) + 1
  breaks <- sort(unique(c(-fc1, 0, fc1, pretty(c(-limit, limit)))))
  breaks <- breaks[abs(breaks) <= limit]
  ymax <- max(x$nlp) * 1.1
  p <- ggplot2::ggplot(x, ggplot2::aes(log2fc, nlp)) +
    ggplot2::geom_point(alpha = 0.6, size = x$size, colour = x$color_transparent) +
    ggplot2::labs(x = bquote(~Log[2] ~ "(fold change)"), y = bquote(~-Log[10] ~ italic("P-value")),
                  title = get_style(style, "title", "")) +
    ggplot2::scale_x_continuous(breaks = breaks, labels = breaks, limits = c(-limit, limit)) +
    ggplot2::ylim(c(0, ymax)) +
    ggplot2::geom_vline(xintercept = c(-fc1, fc1), color = "grey40", linetype = "longdash", lwd = 0.5) +
    ggplot2::geom_hline(yintercept = -log10(p1), color = "grey40", linetype = "longdash", lwd = 0.5) +
    ggplot2::theme_bw(base_size = get_style(style, "base_size", 12)) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
  if (identical(mode, "advanced")) {
    p <- p +
      ggplot2::geom_vline(xintercept = c(-fc2, fc2), color = "grey40", linetype = "longdash", lwd = 0.5) +
      ggplot2::geom_hline(yintercept = -log10(p2), color = "grey40", linetype = "longdash", lwd = 0.5)
  }
  n_sets <- 0L
  hl <- tables$highlight
  if (!is.null(hl) && nrow(hl)) {
    if (!all(c("gene", "set") %in% names(hl))) stop("highlight needs columns gene, set", call. = FALSE)
    unknown <- setdiff(hl$gene, x$gene)
    policy <- get_style(style, "missing_highlight", "error")
    if (length(unknown) && identical(policy, "drop")) {
      warning("Highlighted genes not in de table, dropped: ", paste(unknown, collapse = ", "), call. = FALSE)
      hl <- hl[!hl$gene %in% unknown, , drop = FALSE]
    } else if (length(unknown)) {
      stop("Highlighted genes not in de table: ", paste(unknown, collapse = ", "),
           " (set style.missing_highlight = \"drop\" to drop them, as upstream merge() does)", call. = FALSE)
    }
    dropped <- unknown
    sel <- merge(hl[, c("gene", "set")], x, by = "gene")
    sets <- unique(as.character(hl$set))
    n_sets <- length(sets)
    palette <- unlist(get_style(style, "set_colors", NULL))
    if (is.null(palette)) palette <- UPSTREAM_SET_COLORS
    if (length(palette) < n_sets) {
      stop("style.set_colors has ", length(palette), " colours for ", n_sets, " sets", call. = FALSE)
    }
    palette <- stats::setNames(palette[seq_len(n_sets)], sets)
    sel$set <- factor(sel$set, levels = sets)
    label_size <- get_style(style, "label_size", 5)
    p <- p +
      ggplot2::geom_point(data = sel, alpha = 1, size = 4.6, shape = 1, stroke = 1, color = "black") +
      ggrepel::geom_text_repel(data = sel, ggplot2::aes(label = gene, color = set), show.legend = FALSE,
                               size = label_size, box.padding = grid::unit(0.35, "lines"),
                               point.padding = grid::unit(0.3, "lines"),
                               seed = get_style(style, "seed", 1)) +
      ggplot2::scale_color_manual(values = palette)
    legend <- gridExtra::tableGrob(sets, rows = rep("", n_sets), cols = "",
                                   theme = gridExtra::ttheme_minimal(base_colour = unname(palette)))
    p <- p + ggplot2::annotation_custom(legend, ymin = ymax - 0.18 * ymax * max(1, n_sets / 4), ymax = ymax,
                                        xmin = -limit, xmax = -limit + 0.25 * limit)
  }
  attr(p, "n_sets") <- n_sets
  attr(p, "dropped_highlight") <- if (exists("dropped")) dropped else character()
  attr(p, "n_genes") <- nrow(x)
  p
}

figure_size <- function(tables, style, p) {
  sizing <- get_style(style, "sizing", list())
  if (identical(get_style(sizing, "mode", "adaptive"), "fixed")) {
    width <- get_style(style, "width_in", 6)
    height <- get_style(style, "height_in", 5)
  } else {
    # scatter: size does not grow with gene count; only a long set legend adds height
    width <- get_style(sizing, "base_width_in", 6)
    height <- get_style(sizing, "base_height_in", 5) +
      get_style(sizing, "per_set_in", 0.25) * max(0, attr(p, "n_sets") - 8)
  }
  list(mode = get_style(sizing, "mode", "adaptive"), profile = "volcano", n_genes = attr(p, "n_genes"),
       n_sets = attr(p, "n_sets"), dropped_highlight = I(attr(p, "dropped_highlight")), width_in = width, height_in = height)
}

draw_figure <- function(p) {
  print(p)
  invisible(p)
}

draw <- function(fig, rect, tables, style) {
  draw_figure(plot_panel(tables, style))
}
