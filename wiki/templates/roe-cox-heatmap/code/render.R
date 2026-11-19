# Multi-Cohort Cox Risk Strip + Subtype/Tissue Ro/e Composite Heatmap
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
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

fname <- if (!is.null(spec$tables$roe_cox$filename)) spec$tables$roe_cox$filename else "roe_cox_input.csv"
df <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE)
df$canonical_subcluster <- factor(df$canonical_subcluster, levels = df$canonical_subcluster)

p_stars <- function(p) {
  ifelse(is.na(p), "", ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", ""))))
}

roe_cap <- if (is.null(style$roe_cap)) 2.2 else as.numeric(style$roe_cap)
txt_sz <- if (is.null(style$text_size)) 2.7 else as.numeric(style$text_size)

# Panel 1: Cox Risk/Protective Strip
cox_rows <- list()
if ("tcga_HR" %in% names(df)) {
  p_col <- if ("tcga_p_value" %in% names(df)) df$tcga_p_value else NA_real_
  cox_rows[[1]] <- data.frame(
    subcluster = df$canonical_subcluster,
    cohort = "TCGA cohort",
    status = ifelse(is.na(df$tcga_HR), "Not tested", ifelse(df$tcga_HR > 1, "Risk factor", "Protective factor")),
    sig = p_stars(as.numeric(p_col)),
    stringsAsFactors = FALSE
  )
}
if ("inhouse_HR" %in% names(df)) {
  p_col <- if ("inhouse_p_value" %in% names(df)) df$inhouse_p_value else NA_real_
  cox_rows[[length(cox_rows) + 1]] <- data.frame(
    subcluster = df$canonical_subcluster,
    cohort = "Inhouse cohort",
    status = ifelse(is.na(df$inhouse_HR), "Not tested", ifelse(df$inhouse_HR > 1, "Risk factor", "Protective factor")),
    sig = p_stars(as.numeric(p_col)),
    stringsAsFactors = FALSE
  )
}
cox_df <- dplyr::bind_rows(cox_rows)
cox_df$cohort <- factor(cox_df$cohort, levels = rev(unique(cox_df$cohort)))
cox_df$status <- factor(cox_df$status, levels = c("Risk factor", "Protective factor", "Not tested"))

p_cox <- ggplot(cox_df, aes(x = subcluster, y = cohort, fill = status)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = sig), color = "white", size = 3.6, fontface = "bold", vjust = 0.72) +
  scale_fill_manual(
    values = c("Risk factor" = "#C83E31", "Protective factor" = "#29699E", "Not tested" = "#E5E7EB"),
    drop = FALSE,
    name = NULL
  ) +
  scale_y_discrete(position = "right") +
  theme_minimal(base_size = 9) +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    axis.text.y.right = element_text(color = "#111111", size = 8.5),
    legend.position = "right",
    legend.key.size = unit(0.14, "in"),
    plot.margin = margin(10, 6, 1, 4)
  )

# Panel 2: Subtype Ro/e
sub_cols <- grep("^roe_subtype_", names(df), value = TRUE)
sub_df <- df %>%
  dplyr::select(canonical_subcluster, dplyr::all_of(sub_cols)) %>%
  tidyr::pivot_longer(-canonical_subcluster, names_to = "subtype", values_to = "roe") %>%
  dplyr::mutate(
    subtype = sub("^roe_subtype_", "", subtype),
    subtype = factor(subtype, levels = rev(unique(subtype))),
    roe_fill = pmin(as.numeric(roe), roe_cap),
    lbl = sprintf("%.1f", as.numeric(roe))
  )

p_sub <- ggplot(sub_df, aes(x = canonical_subcluster, y = subtype, fill = roe_fill)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = lbl, color = roe_fill > (roe_cap * 0.6)), size = txt_sz, show.legend = FALSE) +
  scale_color_manual(values = c("FALSE" = "#111111", "TRUE" = "white")) +
  scale_fill_gradientn(
    colours = c("#FFF7EC", "#FDD49E", "#FC8D59", "#D7301F", "#7F0000"),
    limits = c(0, roe_cap),
    name = "Ro/e (Subtype)"
  ) +
  scale_y_discrete(position = "right") +
  theme_minimal(base_size = 9) +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    axis.text.y.right = element_text(color = "#111111", size = 8.5),
    legend.position = "right",
    legend.key.width = unit(0.14, "in"),
    legend.key.height = unit(0.32, "in"),
    plot.margin = margin(2, 4, 1, 4)
  )

# Panel 3: Tissue Ro/e
tis_cols <- grep("^roe_tissue_", names(df), value = TRUE)
tis_df <- df %>%
  dplyr::select(canonical_subcluster, dplyr::all_of(tis_cols)) %>%
  tidyr::pivot_longer(-canonical_subcluster, names_to = "tissue", values_to = "roe") %>%
  dplyr::mutate(
    tissue = sub("^roe_tissue_", "", tissue),
    tissue = factor(tissue, levels = rev(unique(tissue))),
    roe_fill = pmin(as.numeric(roe), roe_cap),
    lbl = sprintf("%.1f", as.numeric(roe))
  )

p_tis <- ggplot(tis_df, aes(x = canonical_subcluster, y = tissue, fill = roe_fill)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = lbl, color = roe_fill > (roe_cap * 0.6)), size = txt_sz, show.legend = FALSE) +
  scale_color_manual(values = c("FALSE" = "#111111", "TRUE" = "white")) +
  scale_fill_gradientn(
    colours = c("#FCFBFD", "#DADAEB", "#9E9AC8", "#6A51A3", "#3F007D"),
    limits = c(0, roe_cap),
    name = "Ro/e (Tissue)"
  ) +
  scale_y_discrete(position = "right") +
  theme_minimal(base_size = 9) +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 8.0, color = "#111111"),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    axis.text.y.right = element_text(color = "#111111", size = 8.5),
    legend.position = "right",
    legend.key.width = unit(0.14, "in"),
    legend.key.height = unit(0.32, "in"),
    plot.margin = margin(2, 4, 4, 4)
  )

n_sub <- length(unique(sub_df$subtype))
n_tis <- length(unique(tis_df$tissue))
n_cols <- nrow(df)
w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(5.5, min(14, n_cols * 0.42 + 2.8))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(4.2, min(12, (2 + n_sub + n_tis) * 0.36 + 1.8))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

combined <- p_cox / p_sub / p_tis +
  patchwork::plot_layout(heights = c(length(levels(cox_df$cohort)), n_sub, n_tis), guides = "collect") +
  patchwork::plot_annotation(theme = theme(plot.margin = margin(12, 6, 4, 4)))

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
