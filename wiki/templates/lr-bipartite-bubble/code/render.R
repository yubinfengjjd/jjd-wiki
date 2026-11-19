# Opposing-Axes Ligand-Receptor Bipartite Connector Bubble Plot
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

fname <- if (!is.null(spec$tables$pairs$filename)) spec$tables$pairs$filename else "lr_bipartite_pairs.csv"
df <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    ligand = as.character(ligand),
    receptor = as.character(receptor),
    ligand_expr = as.numeric(ligand_expr),
    ligand_pct = as.numeric(ligand_pct),
    receptor_expr = as.numeric(receptor_expr),
    receptor_pct = as.numeric(receptor_pct)
  )

lig_levels <- unique(df$ligand)
rec_levels <- unique(df$receptor)
df$x_lig <- seq(1, length(lig_levels), length.out = length(lig_levels))[match(df$ligand, lig_levels)]
df$x_rec <- seq(1, max(length(lig_levels), length(rec_levels)), length.out = length(rec_levels))[match(df$receptor, rec_levels)]

lig_pts <- df %>% dplyr::distinct(ligand, x_lig, ligand_expr, ligand_pct)
rec_pts <- df %>% dplyr::distinct(receptor, x_rec, receptor_expr, receptor_pct)

p <- ggplot() +
  geom_segment(data = df, aes(x = x_lig, y = 1.9, xend = x_rec, yend = 1.1),
               color = "#222222", linewidth = 0.65, alpha = 0.85) +
  geom_point(data = lig_pts, aes(x = x_lig, y = 2.02, size = ligand_pct, color = ligand_expr)) +
  scale_color_gradientn(colours = c("#FDE0DD", "#FB6A4A", "#CB181D"), name = "Average\nExpression") +
  geom_point(data = rec_pts, aes(x = x_rec, y = 0.98, size = receptor_pct), color = "#1B7837") +
  geom_text(data = lig_pts, aes(x = x_lig, y = 1.88, label = ligand), angle = 90, hjust = 1, vjust = 0.5, size = 2.7) +
  geom_text(data = rec_pts, aes(x = x_rec, y = 1.12, label = receptor), angle = 90, hjust = 0, vjust = 0.5, size = 2.7) +
  scale_size_continuous(range = c(2.5, 6.8), name = "Percent\nExpressed") +
  scale_y_continuous(breaks = c(0.98, 2.02), labels = c("Receptors", "Ligands"), limits = c(0.75, 2.25)) +
  theme_classic(base_size = 9.5) +
  theme(
    axis.title = element_blank(),
    axis.line.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(face = "bold", size = 9.5, color = "#111111"),
    legend.position = "right",
    plot.margin = margin(8, 8, 8, 8)
  )

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(5.8, min(12, max(length(lig_levels), length(rec_levels)) * 0.58 + 2.4))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 3.4
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
