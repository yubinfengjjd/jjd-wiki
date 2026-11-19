# Multi-Cluster Metabolic Pathway Lollipop / Dotchart Renderer
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

fname <- if (!is.null(spec$tables$metab$filename)) spec$tables$metab$filename else "metabolism_lollipop.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    pathway = as.character(pathway),
    cluster = as.character(cluster),
    neg_log10_p = as.numeric(neg_log10_p),
    score = as.numeric(score)
  ) %>%
  dplyr::filter(!is.na(pathway), !is.na(cluster), !is.na(neg_log10_p), !is.na(score))

top_n <- if (is.null(style$top_n)) 18L else as.integer(style$top_n)
top_paths <- raw %>%
  dplyr::group_by(pathway) %>%
  dplyr::summarise(max_p = max(neg_log10_p, na.rm = TRUE), .groups = "drop") %>%
  dplyr::slice_max(order_by = max_p, n = top_n, with_ties = FALSE) %>%
  dplyr::arrange(max_p) %>%
  dplyr::pull(pathway)

df <- raw %>% dplyr::filter(pathway %in% top_paths) %>%
  dplyr::mutate(pathway = factor(pathway, levels = top_paths))

bars_df <- df %>% dplyr::group_by(pathway) %>% dplyr::summarise(max_p = max(neg_log10_p, na.rm = TRUE), .groups = "drop")
cl_levels <- unique(df$cluster)
pal <- grDevices::hcl.colors(max(3, length(cl_levels)), palette = "Set 2")[seq_along(cl_levels)]
names(pal) <- cl_levels

p <- ggplot() +
  geom_segment(data = bars_df, aes(x = 0, xend = max_p, y = pathway, yend = pathway),
               color = "#DCDFE4", linewidth = 3.2) +
  geom_point(data = df, aes(x = neg_log10_p, y = pathway, color = cluster, size = score), alpha = 0.92) +
  scale_color_manual(values = pal, name = "celltype") +
  scale_size_continuous(range = c(1.8, 5.2), name = "Enrichment / logFC") +
  scale_x_continuous(expand = expansion(mult = c(0.01, 0.06))) +
  labs(title = "Top_Metabolic_pathway", x = "-Log (P value)", y = NULL) +
  theme_classic(base_size = 9.5) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5),
    axis.text.y = element_text(size = 8.4, color = "#111111"),
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank(),
    legend.position = "bottom",
    legend.box = "vertical",
    legend.text = element_text(size = 8.0),
    plot.margin = margin(8, 22, 6, 8)
  ) +
  guides(color = guide_legend(ncol = 3, override.aes = list(size = 3)))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 8.4
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(4.2, min(11, length(top_paths) * 0.27 + 2.0))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
