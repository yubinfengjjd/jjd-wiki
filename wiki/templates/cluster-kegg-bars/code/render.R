# Multi-Subcluster Horizontal KEGG Enrichment Bar Grid Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(jsonlite)
  library(stringr)
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

fname <- if (!is.null(spec$tables$kegg$filename)) spec$tables$kegg$filename else "kegg_cluster_bars.csv"
raw <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    cluster = as.character(cluster),
    pathway = as.character(pathway),
    p_adjust = as.numeric(p_adjust),
    count = as.integer(round(as.numeric(count)))
  ) %>%
  dplyr::filter(!is.na(cluster), !is.na(pathway), is.finite(p_adjust), p_adjust >= 0, is.finite(count))

bar_fill <- if (!is.null(style$bar_fill)) as.character(style$bar_fill) else "#8E1D41"
top_n <- if (is.null(style$top_n)) 5L else as.integer(style$top_n)
ncol_val <- if (is.null(style$ncol)) 3L else as.integer(style$ncol)
wrap_w <- if (is.null(style$wrap_width)) 34L else as.integer(style$wrap_width)
base_sz <- if (is.null(style$base_size)) 7.5 else as.numeric(style$base_size)

clusters <- unique(raw$cluster)
ncol_eff <- min(ncol_val, max(1L, length(clusters)))
nrow_eff <- ceiling(length(clusters) / ncol_eff)

panels <- lapply(clusters, function(cl) {
  cur <- raw %>%
    dplyr::filter(cluster == cl) %>%
    dplyr::arrange(p_adjust, dplyr::desc(count), pathway) %>%
    dplyr::slice_head(n = top_n) %>%
    dplyr::mutate(
      score = -log10(pmax(p_adjust, .Machine$double.xmin)),
      path_fac = factor(pathway, levels = rev(pathway))
    )
  lbls <- setNames(stringr::str_wrap(cur$pathway, width = wrap_w), cur$pathway)

  ggplot(cur, aes(x = score, y = path_fac)) +
    geom_col(fill = bar_fill, width = 0.82) +
    geom_text(aes(label = count), hjust = -0.22, size = base_sz * 0.30, colour = "#2B2226") +
    scale_x_continuous(expand = expansion(mult = c(0.01, 0.22)), n.breaks = 4) +
    scale_y_discrete(labels = lbls, expand = expansion(add = 0.55)) +
    coord_cartesian(clip = "off") +
    labs(title = cl, x = "-log10(p.adjust)", y = NULL) +
    theme_bw(base_size = base_sz) +
    theme(
      plot.title = element_text(size = base_sz + 0.6, hjust = 0.5, face = "bold", margin = margin(b = 2)),
      axis.text.y = element_text(size = base_sz - 0.5, colour = "#242424", lineheight = 0.82),
      axis.text.x = element_text(size = base_sz - 0.7, colour = "#242424"),
      axis.title.x = element_text(size = base_sz - 0.4, margin = margin(t = 2)),
      axis.ticks.length = grid::unit(0.7, "mm"),
      panel.grid = element_blank(),
      panel.grid.major.x = element_line(colour = "#D8D5D9", linewidth = 0.3, linetype = "dashed"),
      panel.border = element_rect(colour = "#555155", linewidth = 0.4),
      plot.margin = margin(4, 8, 3, 4)
    )
})

combined <- patchwork::wrap_plots(panels, ncol = ncol_eff)

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else max(4.8, min(14, ncol_eff * 3.3))
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else max(3.2, min(14, nrow_eff * 2.15))
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
