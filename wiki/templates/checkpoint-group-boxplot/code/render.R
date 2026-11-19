# Multi-Gene Faceted Group Boxplot with Wilcoxon Brackets Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(jsonlite)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
tpl_root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[1]))))

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
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    gene = as.character(gene),
    group = as.character(group),
    expression = as.numeric(expression)
  ) %>%
  dplyr::filter(!is.na(gene), !is.na(group), is.finite(expression))

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
show_bracket <- if (is.null(style$show_bracket)) TRUE else isTRUE(style$show_bracket)
y_trans <- if (is.null(style$y_transform)) "sqrt" else as.character(style$y_transform)

display_limits <- raw %>%
  dplyr::group_by(gene) %>%
  dplyr::summarise(cap = as.numeric(quantile(expression, cap_q, na.rm = TRUE, names = FALSE)), .groups = "drop")

has_pre_p <- "pval" %in% names(raw) && any(is.finite(suppressWarnings(as.numeric(raw$pval))))

stat_rows <- lapply(gene_levels, function(g) {
  sub <- raw[raw$gene == g, ]
  cap <- display_limits$cap[match(g, display_limits$gene)]
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
      pv <- suppressWarnings(wilcox.test(a, b, exact = FALSE)$p.value)
    }
  }
  stars <- if (is.na(pv)) "ns" else if (pv < 1e-4) "****" else if (pv < 1e-3) "***" else if (pv < 0.01) "**" else if (pv < 0.05) "*" else "ns"
  data.frame(gene = factor(g, levels = gene_levels), pval = pv, stars = stars, cap = cap, stringsAsFactors = FALSE)
})
pvals <- do.call(rbind, stat_rows)

box_list <- list()
out_list <- list()
for (g in gene_levels) {
  cap <- display_limits$cap[match(g, display_limits$gene)]
  for (gr in group_levels) {
    sub <- raw[raw$gene == g & raw$group == gr, ]
    if (nrow(sub) == 0L) next
    x <- sub$expression
    hinges <- as.numeric(quantile(x, c(0.25, 0.5, 0.75), names = FALSE))
    iqr <- hinges[3] - hinges[1]
    inlier <- x >= (hinges[1] - 1.5 * iqr) & x <= (hinges[3] + 1.5 * iqr)
    cap_eff <- max(cap, hinges[3])
    ymax_val <- min(max(x[inlier]), cap_eff)
    box_list[[length(box_list) + 1L]] <- data.frame(
      gene = factor(g, levels = gene_levels),
      group = factor(gr, levels = group_levels),
      ymin = min(x[inlier]),
      lower = hinges[1],
      middle = hinges[2],
      upper = hinges[3],
      ymax = ymax_val,
      stringsAsFactors = FALSE
    )
    if (show_outliers) {
      od <- sub[!inlier & x <= cap_eff, ]
      if (nrow(od) > 0L) out_list[[length(out_list) + 1L]] <- od
    }
  }
}
boxes <- do.call(rbind, box_list)
outliers <- if (length(out_list) > 0L) do.call(rbind, out_list) else raw[0, ]

gene_max <- boxes %>%
  dplyr::group_by(gene) %>%
  dplyr::summarise(top_y = max(ymax, na.rm = TRUE), .groups = "drop")
pvals <- pvals %>%
  dplyr::left_join(gene_max, by = "gene") %>%
  dplyr::mutate(
    bracket_y = pmax(cap, top_y) * 1.07 + 0.03,
    star_y = pmax(cap, top_y) * 1.15 + 0.05
  )

ncol_val <- if (is.null(style$ncol)) min(4L, length(gene_levels)) else as.integer(style$ncol)
nrow_val <- ceiling(length(gene_levels) / ncol_val)

p <- ggplot(boxes, aes(x = group, fill = group)) +
  geom_boxplot(
    aes(ymin = ymin, lower = lower, middle = middle, upper = upper, ymax = ymax),
    stat = "identity", width = 0.62, colour = "black", linewidth = 0.36
  )

if (show_outliers && nrow(outliers) > 0L) {
  p <- p + geom_point(data = outliers, aes(x = group, y = expression), inherit.aes = FALSE,
                      size = 0.65, alpha = 0.65, colour = "#222222")
}

if (show_bracket && length(group_levels) >= 2L) {
  p <- p +
    geom_segment(data = pvals, aes(x = 1, xend = 2, y = bracket_y, yend = bracket_y),
                 inherit.aes = FALSE, linewidth = 0.32, colour = "#333333") +
    geom_text(data = pvals, aes(x = 1.5, y = star_y, label = stars),
              inherit.aes = FALSE, size = 2.9, colour = "#111111")
} else {
  p <- p + geom_text(data = pvals, aes(x = 1.5, y = star_y, label = stars),
                     inherit.aes = FALSE, size = 2.9, colour = "#111111")
}

p <- p +
  facet_wrap(~gene, ncol = ncol_val, scales = "free_y") +
  scale_fill_manual(values = group_cols, name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0.03, 0.10)), n.breaks = 4) +
  labs(x = NULL, y = "Expression") +
  theme_classic(base_size = 8.5) +
  theme(
    strip.background = element_blank(),
    strip.text = element_text(size = 8.5, face = "bold", colour = "#111111"),
    panel.border = element_rect(fill = NA, linewidth = 0.35, colour = "#757575"),
    axis.text = element_text(size = 7.5, colour = "#222222"),
    axis.ticks.length = grid::unit(0.8, "mm"),
    panel.spacing = grid::unit(2.4, "mm"),
    legend.position = "none",
    plot.margin = margin(6, 6, 6, 6)
  )

if (y_trans == "sqrt") {
  p <- p + coord_transform(y = "sqrt")
}

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(4.2, min(14, ncol_val * 1.85 + 0.6))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(2.8, min(12, nrow_val * 1.95 + 0.6))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
