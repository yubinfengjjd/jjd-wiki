# Functional Gene & PROGENy Pathway Z-score Heatmap Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
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

fname <- if (!is.null(spec$tables$matrix$filename)) spec$tables$matrix$filename else "zscore_matrix.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE)
id_col <- colnames(raw)[1]
mat <- as.matrix(raw[, -1, drop = FALSE])
rownames(mat) <- as.character(raw[[id_col]])
storage.mode(mat) <- "numeric"

if (id_col == "canonical_subcluster" && isTRUE(style$transpose_subcluster_cols)) {
  mat <- t(mat)
}

z_cap <- if (is.null(style$z_cap)) 2.0 else as.numeric(style$z_cap)
if (isTRUE(style$cluster_rows) && nrow(mat) > 2) {
  row_ord <- rownames(mat)[hclust(dist(mat))$order]
} else {
  row_ord <- rev(rownames(mat))
}
if (isTRUE(style$cluster_cols) && ncol(mat) > 2) {
  col_ord <- colnames(mat)[hclust(dist(t(mat)))$order]
} else {
  col_ord <- colnames(mat)
}

long_df <- as.data.frame(mat) %>%
  tibble::rownames_to_column("row_id") %>%
  tidyr::pivot_longer(-row_id, names_to = "col_id", values_to = "z") %>%
  dplyr::mutate(
    row_id = factor(row_id, levels = row_ord),
    col_id = factor(col_id, levels = col_ord),
    z_clamped = pmax(pmin(as.numeric(z), z_cap), -z_cap)
  )

p <- ggplot(long_df, aes(x = col_id, y = row_id, fill = z_clamped)) +
  geom_tile(color = "white", linewidth = 0.35) +
  scale_fill_gradientn(
    colours = c("#264B96", "#6D94CE", "#F7F7F7", "#E67B67", "#B81D24"),
    limits = c(-z_cap, z_cap),
    name = "Z-scale"
  ) +
  scale_y_discrete(position = "right") +
  theme_minimal(base_size = 9) +
  theme(
    axis.title = element_blank(),
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 8.0, color = "#111111"),
    axis.text.y.right = element_text(size = 8.2, color = "#111111"),
    legend.position = "right",
    legend.key.width = unit(0.14, "in"),
    legend.key.height = unit(0.4, "in"),
    plot.margin = margin(6, 6, 6, 6)
  )

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(4.8, min(14, ncol(mat) * 0.36 + 2.4))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.6, min(12, nrow(mat) * 0.28 + 2.0))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
