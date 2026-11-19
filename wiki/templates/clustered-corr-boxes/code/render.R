# Symmetric Hierarchically Clustered Correlation Matrix with Diagonal Boxes & Staggered Leader Labels
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
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

fname <- if (!is.null(spec$tables$corr$filename)) spec$tables$corr$filename else "corr_matrix.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE)

# Support both tidy (row, col, r) and wide square matrix (first column = feature)
if (all(c("row", "col", "r") %in% names(raw))) {
  feats <- unique(c(as.character(raw$row), as.character(raw$col)))
  mat <- matrix(0, nrow = length(feats), ncol = length(feats), dimnames = list(feats, feats))
  diag(mat) <- 1
  idx <- cbind(match(as.character(raw$row), feats), match(as.character(raw$col), feats))
  mat[idx] <- as.numeric(raw$r)
  mat <- (mat + t(mat)) / 2
  diag(mat) <- 1
} else {
  feats <- as.character(raw[[1]])
  mat <- as.matrix(raw[, -1, drop = FALSE])
  mode(mat) <- "numeric"
  rownames(mat) <- feats
  if (ncol(mat) == nrow(mat)) {
    common <- intersect(feats, colnames(mat))
    if (length(common) == nrow(mat)) {
      mat <- mat[common, common, drop = FALSE]
      feats <- common
    }
  }
  mat <- (mat + t(mat)) / 2
  diag(mat) <- 1
}

n <- nrow(mat)
preserve_order <- if (is.null(style$preserve_order)) FALSE else isTRUE(style$preserve_order)
n_clusters <- if (is.null(style$n_clusters)) min(5L, max(1L, floor(n / 4))) else max(1L, min(n, as.integer(style$n_clusters)))
clust_method <- if (is.null(style$cluster_method)) "ward.D2" else as.character(style$cluster_method)

if (!preserve_order && n >= 3L) {
  dmat <- stats::as.dist(pmax(0, 1 - mat))
  hc <- stats::hclust(dmat, method = clust_method)
  ord <- hc$order
  mat <- mat[ord, ord, drop = FALSE]
  feats <- rownames(mat)
  grp <- stats::cutree(hc, k = n_clusters)[ord]
} else {
  grp <- rep(seq_len(n_clusters), each = ceiling(n / n_clusters))[seq_len(n)]
}

# Compute contiguous cluster run blocks along diagonal
rle_grp <- rle(as.integer(grp))
ends <- cumsum(rle_grp$lengths)
starts <- c(1L, head(ends, -1L) + 1L)
keep_boxes <- rle_grp$lengths >= 2L
bounds <- data.frame(
  start = starts[keep_boxes] - 0.5,
  end = ends[keep_boxes] + 0.5
)

heat <- expand.grid(y = seq_len(n), x = seq_len(n))
heat$value <- as.vector(mat)

pal <- unlist(style$palette)
if (length(pal) < 3L) pal <- c("#67001F", "#B2182B", "#F7F7F7", "#2166AC", "#053061")
box_col <- if (!is.null(style$box_color)) as.character(style$box_color) else "#202020"
box_lw <- if (!is.null(style$box_linewidth)) as.numeric(style$box_linewidth) else 0.55
lbl_sz <- if (!is.null(style$label_size)) as.numeric(style$label_size) else max(1.6, min(2.8, 72 / max(n, 15)))

odd_idx <- seq(1L, n, by = 2L)
even_idx <- seq(2L, n, by = 2L)
col1_x <- n + 1.4
col2_x <- n + max(7.5, n * 0.30)
max_x <- col2_x + max(6.5, max(nchar(feats)) * 0.48)

p <- ggplot(heat, aes(x = x, y = y)) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(
    colours = pal,
    limits = c(-1, 1),
    breaks = seq(-1, 1, 0.2),
    name = NULL
  ) +
  scale_y_reverse() +
  coord_fixed(xlim = c(0.5, max_x), ylim = c(0.5, n + 0.5), expand = FALSE, clip = "off") +
  guides(
    fill = guide_colourbar(
      barwidth = grid::unit(2.6, "mm"),
      barheight = grid::unit(58, "mm"),
      theme = theme(legend.text.position = "left")
    )
  ) +
  theme_void(base_size = 8) +
  theme(
    legend.position = "left",
    legend.text = element_text(size = 6.5, colour = "#222222"),
    legend.margin = margin(0, 2, 0, 0),
    plot.margin = margin(10, 8, 10, 8)
  )

if (nrow(bounds) > 0L) {
  p <- p + geom_rect(
    data = bounds,
    aes(xmin = start, xmax = end, ymin = start, ymax = end),
    inherit.aes = FALSE, fill = NA, colour = box_col, linewidth = box_lw
  )
}

if (length(odd_idx) > 0L) {
  p <- p +
    annotate("segment", x = n + 0.65, xend = col1_x - 0.15, y = odd_idx, yend = odd_idx,
             linetype = "dashed", linewidth = 0.22, colour = "#444444") +
    annotate("text", x = col1_x, y = odd_idx, label = feats[odd_idx], hjust = 0, size = lbl_sz, colour = "#111111")
}
if (length(even_idx) > 0L) {
  p <- p +
    annotate("segment", x = n + 0.65, xend = col2_x - 0.15, y = even_idx, yend = even_idx,
             linetype = "dashed", linewidth = 0.22, colour = "#444444") +
    annotate("text", x = col2_x, y = even_idx, label = feats[even_idx], hjust = 0, size = lbl_sz, colour = "#111111")
}

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 8.2
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 6.4
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
