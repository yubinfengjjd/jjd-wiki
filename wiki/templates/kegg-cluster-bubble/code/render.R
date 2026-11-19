# Multi-Cluster KEGG Pathway Bubble Matrix Renderer
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

fname <- if (!is.null(spec$tables$kegg$filename)) spec$tables$kegg$filename else "kegg_cluster_bubble.csv"
df <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    pathway = as.character(pathway),
    cluster = as.character(cluster),
    count = as.numeric(count),
    logp = as.numeric(logp)
  ) %>%
  dplyr::filter(!is.na(pathway), !is.na(cluster), !is.na(count), !is.na(logp))

cl_ord <- unique(df$cluster)
pw_ord <- df %>% dplyr::group_by(pathway) %>% dplyr::summarise(first_cl = match(cluster[1], cl_ord), .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(first_cl)) %>% dplyr::pull(pathway)

df <- df %>% dplyr::mutate(
  cluster = factor(cluster, levels = cl_ord),
  pathway = factor(pathway, levels = pw_ord)
)

p <- ggplot(df, aes(x = cluster, y = pathway)) +
  geom_point(aes(size = count, color = logp), alpha = 0.92) +
  scale_color_gradientn(colours = c("#F4A582", "#DF65B0", "#88419D", "#4D004B"), name = "logp") +
  scale_size_continuous(range = c(2.0, 5.8), name = "Count") +
  theme_bw(base_size = 8.5) +
  theme(
    axis.title = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#EAEAEA", linewidth = 0.3),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7.8, color = "#111111"),
    axis.text.y = element_text(size = 7.2, color = "#111111"),
    legend.position = "right",
    plot.margin = margin(6, 6, 6, 8)
  )

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(6.4, min(13, length(cl_ord) * 0.42 + 4.4))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(5.0, min(13, length(pw_ord) * 0.20 + 1.8))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
