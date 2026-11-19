# Paired Tissue Composition Stacked Ratio Bar + Sample Proportion Boxplot Renderer
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

fname <- if (!is.null(spec$tables$prop$filename)) spec$tables$prop$filename else "tissue_ratio_prop.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    cluster = as.character(cluster),
    tissue = as.character(tissue),
    sample_id = as.character(sample_id),
    proportion = as.numeric(proportion)
  ) %>%
  dplyr::filter(!is.na(cluster), !is.na(tissue), !is.na(sample_id), is.finite(proportion))

if (max(raw$proportion, na.rm = TRUE) > 1.5) {
  raw$proportion <- raw$proportion / 100
}

clusters <- rev(unique(raw$cluster))
tissues <- unique(raw$tissue)
preferred_tissues <- c("ANT", "Normal", "T", "Tumor", "LM", "Lymphnode")
ordered_t <- c(intersect(preferred_tissues, tissues), setdiff(tissues, preferred_tissues))
tissues <- ordered_t

raw$group <- match(raw$cluster, clusters)
raw$tissue_fac <- factor(raw$tissue, levels = tissues)
n_cl <- length(clusters)
n_tis <- length(tissues)

pal_vec <- unlist(style$tissue_colors)
if (length(pal_vec) < n_tis) {
  pal_vec <- grDevices::colorRampPalette(c("#2B9E77", "#D95F02", "#7570B3", "#E7298A"))(n_tis)
}
ink <- setNames(pal_vec[seq_len(n_tis)], tissues)

# Left stacked tissue ratio bars
if ("n_cells" %in% names(raw) && any(is.finite(suppressWarnings(as.numeric(raw$n_cells))))) {
  raw$n_cells <- suppressWarnings(as.numeric(raw$n_cells))
  pooled <- raw %>%
    dplyr::group_by(group, cluster, tissue_fac) %>%
    dplyr::summarise(val = sum(n_cells, na.rm = TRUE), .groups = "drop")
} else {
  pooled <- raw %>%
    dplyr::group_by(group, cluster, tissue_fac) %>%
    dplyr::summarise(val = mean(proportion, na.rm = TRUE), .groups = "drop")
}

bars <- do.call(rbind, lapply(split(pooled, pooled$group), function(d) {
  d <- d[order(d$tissue_fac), ]
  tot <- sum(d$val, na.rm = TRUE)
  if (tot <= 0) tot <- 1
  d$x1 <- cumsum(d$val) / tot
  d$x0 <- c(0, head(d$x1, -1L))
  d
}))

# Right sample proportion boxplots + jitter
max_prop <- max(0.30, ceiling(max(raw$proportion, na.rm = TRUE) * 10) / 10)
box_start <- 1.12
box_span <- 1.56
raw$x <- box_start + box_span * (raw$proportion / max_prop)
offsets <- seq(-0.24, 0.24, length.out = max(1L, n_tis))
if (n_tis == 1L) offsets <- 0
offset_map <- setNames(offsets, tissues)
raw$y <- raw$group + unname(offset_map[as.character(raw$tissue_fac)])

# Significance (first two tissues, BH-adjusted or precomputed)
paired_flag <- if (is.null(style$paired_test)) TRUE else isTRUE(style$paired_test)
has_pre_p <- "pval" %in% names(raw) && any(is.finite(suppressWarnings(as.numeric(raw$pval))))

p_vals <- vapply(clusters, function(cl) {
  sub <- raw[raw$cluster == cl, ]
  if (has_pre_p) {
    v <- suppressWarnings(as.numeric(sub$pval))
    v <- v[is.finite(v)]
    if (length(v) > 0L) return(v[1L])
  }
  if (n_tis < 2L) return(NA_real_)
  a <- sub[sub$tissue == tissues[1L], c("sample_id", "proportion")]
  b <- sub[sub$tissue == tissues[2L], c("sample_id", "proportion")]
  if (paired_flag) {
    j <- merge(a, b, by = "sample_id")
    if (nrow(j) >= 3L) {
      if (all(j$proportion.x == j$proportion.y)) return(1.0)
      return(suppressWarnings(wilcox.test(j$proportion.x, j$proportion.y, paired = TRUE, exact = FALSE)$p.value))
    }
  }
  if (nrow(a) >= 3L && nrow(b) >= 3L) {
    return(suppressWarnings(wilcox.test(a$proportion, b$proportion, exact = FALSE)$p.value))
  }
  NA_real_
}, numeric(1))

p_adj <- p.adjust(p_vals, method = "BH")
sig_labels <- ifelse(is.na(p_adj), "ns",
                     ifelse(p_adj < 1e-4, "****",
                            ifelse(p_adj < 1e-3, "***",
                                   ifelse(p_adj < 0.01, "**",
                                          ifelse(p_adj < 0.05, "*", "ns")))))

show_ylab <- if (is.null(style$show_ylabels)) TRUE else isTRUE(style$show_ylabels)
box_w <- min(0.20, 0.56 / max(1L, n_tis))

p <- ggplot() +
  geom_rect(data = bars, aes(xmin = x0, xmax = x1, ymin = group - 0.37, ymax = group + 0.37, fill = tissue_fac),
            colour = "white", linewidth = 0.16) +
  geom_boxplot(data = raw, aes(x = x, y = y, colour = tissue_fac, group = interaction(group, tissue_fac)),
               orientation = "y", width = box_w, linewidth = 0.28, outlier.shape = NA, fill = NA) +
  geom_point(data = raw, aes(x = x, y = y, colour = tissue_fac), size = 0.85, stroke = 0,
             position = position_jitter(width = 0, height = 0.032, seed = 42)) +
  annotate("text", x = box_start + box_span + 0.14, y = seq_len(n_cl), label = sig_labels,
           colour = "#443E44", size = 2.45, hjust = 0.5) +
  annotate("segment", x = 1.055, xend = 1.055, y = 0.52, yend = n_cl + 0.48,
           colour = "#777777", linewidth = 0.32) +
  scale_fill_manual(values = ink, name = NULL) +
  scale_colour_manual(values = ink, guide = "none") +
  scale_x_continuous(
    breaks = c(0, 0.5, 1, box_start, box_start + 0.5 * box_span, box_start + box_span),
    labels = c("0", "0.5", "1", "0", as.character(round(max_prop * 50)), as.character(round(max_prop * 100)))
  ) +
  scale_y_continuous(
    breaks = if (show_ylab) seq_len(n_cl) else NULL,
    labels = if (show_ylab) clusters else NULL
  ) +
  labs(caption = paste0("Ratio (stacked)          % Cells (", tissues[1], " vs ", tissues[min(2L, n_tis)], " BH-adjusted)")) +
  coord_cartesian(xlim = c(-0.02, box_start + box_span + 0.28), ylim = c(0.45, n_cl + 0.55), expand = FALSE, clip = "off") +
  theme_classic(base_size = 8.0) +
  guides(fill = guide_legend(nrow = 1, override.aes = list(colour = NA))) +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_text(size = 7.0, colour = "#222222"),
    axis.text.y = element_text(size = 7.4, colour = "#111111"),
    axis.ticks.length = grid::unit(0.85, "mm"),
    legend.position = "top",
    legend.text = element_text(size = 7.5),
    legend.key.height = grid::unit(2.6, "mm"),
    legend.key.width = grid::unit(3.6, "mm"),
    plot.caption = element_text(size = 7.0, hjust = 0.5, margin = margin(t = 4), colour = "#333333"),
    plot.margin = margin(6, 10, 6, 8)
  )

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 6.2
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.6, min(11, n_cl * 0.34 + 1.4))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
