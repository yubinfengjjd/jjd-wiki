# Multi-Gene Faceted Group Boxplot with Wilcoxon Brackets Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(jsonlite)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1L]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
tpl_root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[1L]))))

data_dir <- get_arg("--data")
out_dir <- get_arg("--out")
style_file <- get_arg("--style", NULL)
if (is.null(data_dir) || is.null(out_dir)) {
  stop("Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]")
}
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

spec <- jsonlite::fromJSON(file.path(tpl_root, "spec.json"), simplifyVector = FALSE)
style <- if (is.null(spec$style)) list() else spec$style
if (!is.null(style_file) && file.exists(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  for (k in names(override)) if (!is.null(override[[k]])) style[[k]] <- override[[k]]
}

fname <- if (!is.null(spec$tables$expr$filename)) spec$tables$expr$filename else "checkpoint_expr.csv"
raw <- utils::read.csv(file.path(data_dir, fname), check.names = FALSE, stringsAsFactors = FALSE)
raw$gene <- as.character(raw$gene)
raw$group <- as.character(raw$group)
raw$expression <- as.numeric(raw$expression)
raw <- raw[!is.na(raw$gene) & !is.na(raw$group) & is.finite(raw$expression), , drop = FALSE]

gene_levels <- unique(raw$gene)
group_levels <- unique(raw$group)
if (all(c("low", "high") %in% group_levels)) {
  group_levels <- c("low", "high", setdiff(group_levels, c("low", "high")))
}
raw$gene <- factor(raw$gene, levels = gene_levels)
raw$group <- factor(raw$group, levels = group_levels)

pal_vec <- unlist(style$group_colors)
if (length(pal_vec) < length(group_levels)) {
  pal_vec <- grDevices::colorRampPalette(c("#1D8A68", "#D05810", "#3B7EB6", "#8856A7"))(length(group_levels))
}
group_cols <- setNames(pal_vec[seq_along(group_levels)], group_levels)

cap_q <- if (is.null(style$cap_quantile)) 0.97 else as.numeric(style$cap_quantile)
cap_q <- max(0.5, min(1.0, cap_q))
show_outliers <- if (is.null(style$show_outliers)) TRUE else isTRUE(style$show_outliers)
show_bracket <- if (is.null(style$show_bracket)) FALSE else isTRUE(style$show_bracket)
y_trans <- if (is.null(style$y_transform)) "sqrt" else as.character(style$y_transform)

caps <- setNames(vapply(gene_levels, function(g) {
  as.numeric(stats::quantile(raw$expression[raw$gene == g], cap_q, na.rm = TRUE, names = FALSE))
}, numeric(1L)), gene_levels)

has_pre_p <- "pval" %in% names(raw) && any(is.finite(suppressWarnings(as.numeric(raw$pval))))

stat_rows <- lapply(gene_levels, function(g) {
  sub <- raw[raw$gene == g, , drop = FALSE]
  cap <- caps[[g]]
  pv <- NA_real_
  if (has_pre_p) {
    vals <- suppressWarnings(as.numeric(sub$pval))
    vals <- vals[is.finite(vals)]
    if (length(vals) > 0L) pv <- vals[1L]
  }
  if (is.na(pv) && length(group_levels) >= 2L) {
    a <- sub$expression[sub$group == group_levels[1L]]
    b <- sub$expression[sub$group == group_levels[2L]]
    if (length(a) >= 2L && length(b) >= 2L) {
      pv <- suppressWarnings(stats::wilcox.test(a, b, exact = FALSE)$p.value)
    }
  }
  stars <- if (is.na(pv)) "ns" else if (pv < 1e-4) "****" else if (pv < 1e-3) "***" else if (pv < 0.01) "**" else if (pv < 0.05) "*" else "ns"
  data.frame(gene = factor(g, levels = gene_levels), pval = pv, stars = stars, cap = cap, stringsAsFactors = FALSE)
})
pvals <- do.call(rbind, stat_rows)

box_list <- list()
out_list <- list()
for (g in gene_levels) {
  cap <- caps[[g]]
  for (gr in group_levels) {
    sub <- raw[raw$gene == g & raw$group == gr, , drop = FALSE]
    if (nrow(sub) == 0L) next
    x <- sub$expression
    hinges <- as.numeric(stats::quantile(x, c(0.25, 0.5, 0.75), names = FALSE))
    iqr <- hinges[3L] - hinges[1L]
    inlier <- x >= (hinges[1L] - 1.5 * iqr) & x <= (hinges[3L] + 1.5 * iqr)
    cap_eff <- max(cap, hinges[3L])
    ymax_val <- min(max(x[inlier]), cap_eff)
    box_list[[length(box_list) + 1L]] <- data.frame(
      gene = factor(g, levels = gene_levels),
      group = factor(gr, levels = group_levels),
      ymin = min(x[inlier]),
      lower = hinges[1L],
      middle = hinges[2L],
      upper = hinges[3L],
      ymax = ymax_val,
      stringsAsFactors = FALSE
    )
    if (show_outliers) {
      od <- sub[!inlier & x <= cap_eff, , drop = FALSE]
      if (nrow(od) > 0L) out_list[[length(out_list) + 1L]] <- od
    }
  }
}
boxes <- do.call(rbind, box_list)
outliers <- if (length(out_list) > 0L) do.call(rbind, out_list) else raw[0, , drop = FALSE]

top_by_gene <- tapply(boxes$ymax, boxes$gene, max, na.rm = TRUE)
pvals$top_y <- as.numeric(top_by_gene[as.character(pvals$gene)])
pvals$bracket_y <- pmax(pvals$cap, pvals$top_y) * 1.07
pvals$star_y <- pmax(pvals$cap, pvals$top_y) * 1.13

ncol_val <- if (is.null(style$ncol)) min(4L, length(gene_levels)) else as.integer(style$ncol)
nrow_val <- ceiling(length(gene_levels) / ncol_val)

p <- ggplot(boxes, aes(x = group, fill = group)) +
  geom_boxplot(
    aes(ymin = ymin, lower = lower, middle = middle, upper = upper, ymax = ymax),
    stat = "identity", width = 0.62, colour = "black", linewidth = 0.34
  )

if (show_outliers && nrow(outliers) > 0L) {
  p <- p + geom_point(data = outliers, aes(x = group, y = expression), inherit.aes = FALSE,
                      size = 0.55, alpha = 0.65, colour = "#1E1E1E")
}

if (show_bracket && length(group_levels) >= 2L) {
  p <- p +
    geom_segment(data = pvals, aes(x = 1.05, xend = 1.95, y = bracket_y, yend = bracket_y),
                 inherit.aes = FALSE, linewidth = 0.28, colour = "#333333") +
    geom_text(data = pvals, aes(x = 1.5, y = star_y * 1.04, label = stars),
              inherit.aes = FALSE, size = 2.6, colour = "#111111")
} else {
  p <- p + geom_text(data = pvals, aes(x = 1.5, y = star_y, label = stars),
                     inherit.aes = FALSE, size = 2.6, colour = "#111111")
}

p <- p +
  facet_wrap(~gene, ncol = ncol_val, scales = "free_y") +
  scale_fill_manual(values = group_cols, name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.06)), n.breaks = 4) +
  labs(x = NULL, y = "Expression") +
  theme_classic(base_size = 8.0) +
  theme(
    strip.background = element_blank(),
    strip.text = element_text(size = 8.0, face = "plain", colour = "#111111"),
    panel.border = element_rect(fill = NA, linewidth = 0.28, colour = "#757575"),
    axis.text = element_text(size = 6.8, colour = "#222222"),
    axis.ticks.length = grid::unit(0.7, "mm"),
    panel.spacing = grid::unit(2.0, "mm"),
    legend.position = "none",
    plot.margin = margin(6, 6, 6, 6)
  )

if (y_trans == "sqrt") {
  p <- p + coord_transform(y = "sqrt")
}

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(4.2, min(14, ncol_val * 1.85 + 0.6))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(2.8, min(12, nrow_val * 1.95 + 0.6))
dpi_val <- if (is.null(style$dpi)) 300L else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
