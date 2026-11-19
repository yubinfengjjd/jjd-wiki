# Cell-Cell Interaction Count Marginal Barplot + Matrix Heatmap Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
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

fname <- if (!is.null(spec$tables$counts$filename)) spec$tables$counts$filename else "interaction_counts.csv"
df <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    SOURCE = as.character(SOURCE),
    TARGET = as.character(TARGET),
    count = as.numeric(count)
  )

src_totals <- df %>% dplyr::group_by(SOURCE) %>% dplyr::summarise(tot = sum(count, na.rm = TRUE), .groups = "drop") %>% dplyr::arrange(dplyr::desc(tot))
tgt_totals <- df %>% dplyr::group_by(TARGET) %>% dplyr::summarise(tot = sum(count, na.rm = TRUE), .groups = "drop") %>% dplyr::arrange(tot)

df$SOURCE <- factor(df$SOURCE, levels = src_totals$SOURCE)
df$TARGET <- factor(df$TARGET, levels = tgt_totals$TARGET)
src_totals$SOURCE <- factor(src_totals$SOURCE, levels = src_totals$SOURCE)
tgt_totals$TARGET <- factor(tgt_totals$TARGET, levels = tgt_totals$TARGET)

p_top <- ggplot(src_totals, aes(x = SOURCE, y = tot / 1000)) +
  geom_col(fill = "#5B6478", width = 0.72) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(y = expression(interactions %*% 10^3)) +
  theme_classic(base_size = 8.5) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    plot.margin = margin(4, 2, 0, 6)
  )

p_heat <- ggplot(df, aes(x = SOURCE, y = TARGET, fill = count)) +
  geom_tile(color = "white", linewidth = 0.25) +
  scale_fill_gradientn(
    colours = c("#F7F5EE", "#CFD7E8", "#7B8CC4", "#3E4C8A", "#9E3B33"),
    name = "interactions"
  ) +
  theme_minimal(base_size = 8.5) +
  theme(
    axis.title = element_blank(),
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7.2, color = "#111111"),
    axis.text.y = element_blank(),
    legend.position = "bottom",
    legend.key.width = unit(0.45, "in"),
    legend.key.height = unit(0.11, "in"),
    plot.margin = margin(1, 2, 4, 6)
  )

p_right <- ggplot(tgt_totals, aes(x = tot / 1000, y = TARGET)) +
  geom_col(fill = "#5B6478", width = 0.72) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.08))) +
  scale_y_discrete(position = "right") +
  labs(title = "Total number of\ninteractions ×10³", x = NULL, y = NULL) +
  theme_classic(base_size = 8.5) +
  theme(
    plot.title = element_text(size = 8.5, face = "bold", hjust = 0),
    axis.text.y.right = element_text(size = 7.5, color = "#111111"),
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank(),
    plot.margin = margin(1, 6, 4, 0)
  )

layout_mat <- "
A#
BC
"
combined <- patchwork::wrap_plots(A = p_top, B = p_heat, C = p_right, design = layout_mat) +
  patchwork::plot_layout(widths = c(4.6, 1.3), heights = c(1.0, 3.8))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(6.8, min(14, nrow(src_totals) * 0.24 + 2.8))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(5.2, min(12, nrow(tgt_totals) * 0.24 + 2.4))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
