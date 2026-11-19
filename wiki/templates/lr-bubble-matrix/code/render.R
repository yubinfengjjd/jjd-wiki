# Ligand-Receptor Communication Probability Bubble Matrix Renderer
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

fname <- if (!is.null(spec$tables$lr$filename)) spec$tables$lr$filename else "lr_bubble_matrix.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE)

if (!"pair_label" %in% names(raw)) {
  if (all(c("source", "target") %in% names(raw))) {
    raw$pair_label <- paste0(raw$source, "->", raw$target)
  } else {
    stop("Need either pair_label or source+target columns")
  }
}
if (!"interaction" %in% names(raw)) {
  if ("interaction_name" %in% names(raw)) {
    raw$interaction <- raw$interaction_name
  } else if (all(c("ligand", "receptor") %in% names(raw))) {
    raw$interaction <- paste0(raw$ligand, "_", raw$receptor)
  }
}
if (!"pval" %in% names(raw)) raw$pval <- 0.01

df <- raw %>%
  dplyr::mutate(
    pair_label = as.character(pair_label),
    interaction = as.character(interaction),
    prob = as.numeric(prob),
    pval = as.numeric(pval)
  ) %>%
  dplyr::filter(!is.na(pair_label), !is.na(interaction), !is.na(prob)) %>%
  dplyr::group_by(pair_label, interaction) %>%
  dplyr::summarise(prob = max(prob, na.rm = TRUE), pval = min(pval, na.rm = TRUE), .groups = "drop")

max_int <- if (is.null(style$max_interactions)) 18L else as.integer(style$max_interactions)
max_pairs <- if (is.null(style$max_pairs)) 22L else as.integer(style$max_pairs)

top_ints <- df %>% dplyr::group_by(interaction) %>% dplyr::summarise(m = max(prob), .groups = "drop") %>%
  dplyr::slice_max(order_by = m, n = max_int, with_ties = FALSE) %>% dplyr::pull(interaction)
top_pairs <- df %>% dplyr::group_by(pair_label) %>% dplyr::summarise(m = max(prob), .groups = "drop") %>%
  dplyr::slice_max(order_by = m, n = max_pairs, with_ties = FALSE) %>% dplyr::pull(pair_label)

df <- df %>%
  dplyr::filter(interaction %in% top_ints, pair_label %in% top_pairs) %>%
  dplyr::mutate(
    interaction = factor(interaction, levels = rev(top_ints)),
    pair_label = factor(pair_label, levels = top_pairs)
  )

p <- ggplot(df, aes(x = interaction, y = pair_label)) +
  geom_point(aes(size = prob, fill = prob), shape = 21, color = "#1A1A1A", stroke = 0.45) +
  scale_fill_gradientn(
    colours = c("#E8F5E9", "#8CC084", "#4D8B9B", "#6D3B96", "#4A146E"),
    name = "Communication\nProbability"
  ) +
  scale_size_continuous(range = c(2.0, 6.2), name = "prob") +
  theme_bw(base_size = 9) +
  theme(
    axis.title = element_blank(),
    panel.grid.major = element_line(color = "#ECECEC", linewidth = 0.35),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 8.0, color = "#111111"),
    axis.text.y = element_text(size = 8.0, color = "#111111"),
    legend.position = "bottom",
    legend.box = "horizontal",
    plot.margin = margin(6, 8, 6, 8)
  )

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(5.2, min(14, length(top_ints) * 0.36 + 3.0))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(4.2, min(12, length(top_pairs) * 0.28 + 2.2))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
