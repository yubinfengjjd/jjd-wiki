# Pseudotime Multi-Branch Gene Expression Curve Grid Renderer
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

fname <- if (!is.null(spec$tables$curves$filename)) spec$tables$curves$filename else "pseudotime_branch_genes.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE)
if (!"branch" %in% names(raw) && "terminal_cluster" %in% names(raw)) {
  raw$branch <- raw$terminal_cluster
}
df <- raw %>%
  dplyr::mutate(
    gene = factor(as.character(gene), levels = unique(as.character(gene))),
    branch = as.character(branch),
    pseudotime_norm = as.numeric(pseudotime_norm),
    smoothed_expr = as.numeric(smoothed_expr)
  ) %>%
  dplyr::filter(!is.na(gene), !is.na(branch), !is.na(pseudotime_norm), !is.na(smoothed_expr))

br_levels <- unique(df$branch)
pal <- c("#529E73", "#66A61E", "#7570B3", "#E7298A", "#D95F02")[seq_len(min(5, length(br_levels)))]
if (length(br_levels) > 5) {
  pal <- c("#529E73", grDevices::hcl.colors(length(br_levels) - 1, palette = "Dark 3"))
}
names(pal) <- br_levels

ncol_val <- if (is.null(style$ncol)) 2L else as.integer(style$ncol)
nrow_val <- ceiling(length(levels(df$gene)) / ncol_val)

p <- ggplot(df, aes(x = pseudotime_norm, y = smoothed_expr, color = branch)) +
  geom_line(linewidth = 0.85, alpha = 0.9) +
  scale_color_manual(values = pal, name = "Lineage") +
  facet_wrap(~gene, ncol = ncol_val, scales = "free_y") +
  labs(x = "Pseudotime", y = NULL) +
  theme_classic(base_size = 9.2) +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.6),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold", size = 9.5),
    legend.position = "bottom",
    plot.margin = margin(6, 8, 6, 8)
  )

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(4.8, ncol_val * 2.7)
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.6, nrow_val * 1.6 + 1.0)
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
