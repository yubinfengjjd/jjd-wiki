# Combined Two-Panel Composite Assembly: Panel A (Sphere Network) + Panel B (Module GO Enrichment Bars)
# Usage: Rscript compose_ab.R

suppressPackageStartupMessages({
  library(ggplot2)
  library(igraph)
  library(ggrepel)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(stringr)
})

post_dir <- normalizePath("E:/research-wiki/gallery/2026-11-19-hdwgcna-network")
out_dir <- file.path(post_dir, "composite")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# --- Panel A: Co-expression Sphere Network ---
nodes_df <- readr::read_csv(file.path(post_dir, "figures/fig01/data/gene_module.csv"), show_col_types = FALSE) %>%
  dplyr::mutate(gene_name = as.character(gene_name), module = as.character(module)) %>%
  dplyr::distinct(gene_name, .keep_all = TRUE)
edges_df <- readr::read_csv(file.path(post_dir, "figures/fig01/data/edge_file.csv"), show_col_types = FALSE) %>%
  dplyr::mutate(from = as.character(from), to = as.character(to)) %>%
  dplyr::filter(from %in% nodes_df$gene_name, to %in% nodes_df$gene_name, from != to)

mod_lookup <- setNames(nodes_df$module, nodes_df$gene_name)
same_mod <- mod_lookup[edges_df$from] == mod_lookup[edges_df$to]
edges_df$layout_weight <- ifelse(same_mod, 3.6 * (1 + pmax(0.02, as.numeric(edges_df$tom))), 1.05)

g <- igraph::graph_from_data_frame(edges_df[, c("from", "to", "layout_weight")], vertices = nodes_df, directed = FALSE)
g <- igraph::simplify(g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list(layout_weight = "max"))
set.seed(42)
coords <- igraph::layout_with_fr(g, weights = igraph::E(g)$layout_weight, niter = 1400)
coords[, 1] <- coords[, 1] - mean(coords[, 1])
coords[, 2] <- coords[, 2] - mean(coords[, 2])
rad <- sqrt(coords[, 1]^2 + coords[, 2]^2)
max_r <- max(rad, 1e-6)
coords <- coords / max_r
r_new <- rad / max_r
coords <- coords * ifelse(r_new > 0, (r_new^0.80) / r_new, 1)

node_plot_df <- nodes_df %>%
  dplyr::mutate(
    x = coords[match(gene_name, igraph::V(g)$name), 1],
    y = coords[match(gene_name, igraph::V(g)$name), 2]
  )
xy_map <- setNames(seq_len(nrow(node_plot_df)), node_plot_df$gene_name)
edge_plot_df <- edges_df %>%
  dplyr::mutate(
    x = node_plot_df$x[xy_map[from]],
    y = node_plot_df$y[xy_map[from]],
    xend = node_plot_df$x[xy_map[to]],
    yend = node_plot_df$y[xy_map[to]]
  )

darken_bright <- function(hex) {
  rgb_m <- grDevices::col2rgb(hex) / 255
  lum <- 0.299 * rgb_m[1, ] + 0.587 * rgb_m[2, ] + 0.114 * rgb_m[3, ]
  ifelse(lum > 0.74, grDevices::rgb(rgb_m[1, ] * 0.80, rgb_m[2, ] * 0.80, rgb_m[3, ] * 0.72), hex)
}

mod_summary <- node_plot_df %>%
  dplyr::group_by(module) %>%
  dplyr::summarise(
    cx = stats::median(x),
    cy = stats::median(y),
    color = dplyr::first(color),
    ann = dplyr::first(na.omit(annotation[nzchar(annotation)])),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    raw_label = paste0(module, ":", ann),
    wrapped_label = stringr::str_wrap(raw_label, width = 26),
    label_color = darken_bright(color),
    ang = atan2(cy, cx),
    r_anchor = ifelse(sqrt(cx^2 + cy^2) > 0.65, 1.13, 1.20),
    tx = r_anchor * cos(ang),
    ty = r_anchor * sin(ang),
    nudge_x = tx - cx,
    nudge_y = ty - cy,
    hjust_val = ifelse(cos(ang) > 0.28, 0, ifelse(cos(ang) < -0.28, 1, 0.5))
  )
mod_colors <- setNames(mod_summary$color, mod_summary$module)

p_a <- ggplot() +
  geom_segment(
    data = edge_plot_df,
    aes(x = x, y = y, xend = xend, yend = yend),
    color = "#a8a8a8", alpha = 0.18, linewidth = 0.20
  ) +
  geom_point(
    data = node_plot_df,
    aes(x = x, y = y, color = module),
    size = 1.75, alpha = 0.95, show.legend = FALSE
  ) +
  scale_color_manual(values = mod_colors) +
  ggrepel::geom_text_repel(
    data = mod_summary,
    aes(x = cx, y = cy, label = wrapped_label),
    color = mod_summary$label_color,
    fontface = "bold", size = 3.0, lineheight = 0.90,
    hjust = mod_summary$hjust_val,
    nudge_x = mod_summary$nudge_x, nudge_y = mod_summary$nudge_y,
    segment.color = "#2f2f2f", segment.size = 0.40, segment.alpha = 0.85,
    min.segment.length = 0, box.padding = 0.42, point.padding = 0.28,
    force = 3.4, force_pull = 0.35, max.iter = 5000, max.overlaps = Inf, seed = 42
  ) +
  coord_equal(xlim = c(-1.62, 1.62), ylim = c(-1.42, 1.42), clip = "off") +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "#ffffff", color = NA),
    panel.background = element_rect(fill = "#ffffff", color = NA),
    plot.margin = margin(6, 4, 6, 4)
  )

# --- Panel B: 7x2 Module Enrichment Horizontal Bars ---
df_b <- readr::read_csv(file.path(post_dir, "figures/fig02/data/enrich_plot_dat.csv"), show_col_types = FALSE) %>%
  dplyr::mutate(module = as.character(module), Term = as.character(Term), log10p = as.numeric(log10p))

mod_levels <- unique(df_b$module)
n_mods <- length(mod_levels)
ncol_val <- 2L
nrow_val <- ceiling(n_mods / ncol_val)
max_x <- max(8.5, max(df_b$log10p, na.rm = TRUE) * 1.06)
x_ticks <- c(0, 2, 4, 6, 8)
truncate_term <- function(s) ifelse(nchar(s) > 42, paste0(substr(s, 1, 41), "..."), s)
strip_text_color <- function(hex) {
  rgb_m <- grDevices::col2rgb(hex) / 255
  lum <- 0.299 * rgb_m[1, 1] + 0.587 * rgb_m[2, 1] + 0.114 * rgb_m[3, 1]
  if (lum < 0.42) "#ffffff" else "#111111"
}

b_plots <- vector("list", n_mods)
for (idx in seq_len(n_mods)) {
  mod <- mod_levels[idx]
  sub <- df_b %>%
    dplyr::filter(module == mod) %>%
    dplyr::arrange(log10p) %>%
    dplyr::mutate(Term_disp = truncate_term(Term), Term_f = factor(Term_disp, levels = unique(Term_disp)))
  col_hex <- sub$color[1]
  row_idx <- ceiling(idx / ncol_val)
  is_bottom <- (row_idx == nrow_val) || (idx + ncol_val > n_mods)
  b_plots[[idx]] <- ggplot(sub, aes(x = log10p, y = Term_f)) +
    geom_col(fill = col_hex, alpha = 0.52, width = 0.72) +
    geom_text(aes(x = max_x * 0.03, label = Term_disp), hjust = 0, size = 2.05, color = "#111111") +
    facet_wrap(~module, ncol = 1) +
    scale_x_continuous(limits = c(0, max_x), breaks = x_ticks, expand = c(0, 0)) +
    labs(x = NULL, y = NULL) +
    theme_classic(base_size = 8) +
    theme(
      strip.background = element_rect(fill = col_hex, color = "#222222", linewidth = 0.45),
      strip.text = element_text(color = strip_text_color(col_hex), face = "bold", size = 7.2, margin = margin(t = 1.6, b = 1.6)),
      axis.line.y = element_line(color = "#222222", linewidth = 0.4),
      axis.line.x = if (is_bottom) element_line(color = "#222222", linewidth = 0.4) else element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.x = if (is_bottom) element_line(color = "#222222", linewidth = 0.35) else element_blank(),
      axis.text.x = if (is_bottom) element_text(size = 7.0, color = "#111111") else element_blank(),
      panel.background = element_rect(fill = "#ffffff", color = NA),
      plot.background = element_rect(fill = "#ffffff", color = NA),
      plot.margin = margin(1.5, 3, if (is_bottom) 1.5 else 2, 3)
    )
}
p_b <- patchwork::wrap_plots(b_plots, ncol = ncol_val) +
  labs(caption = "-log10(P-value)") +
  theme(plot.caption = element_text(hjust = 0.5, size = 9, color = "#111111"))

# Side-by-side composite matching full_original.png (1080 x 725 -> aspect ~1.49)
composite <- (p_a | p_b) + patchwork::plot_layout(widths = c(1.75, 1.0))

w_in <- 13.4
h_in <- 9.0
ggsave(file.path(out_dir, "composite.png"), composite, width = w_in, height = h_in, dpi = 300, bg = "#ffffff")
grDevices::cairo_pdf(file.path(out_dir, "composite.pdf"), width = w_in, height = h_in, bg = "#ffffff")
print(composite)
grDevices::dev.off()
grDevices::svg(file.path(out_dir, "composite.svg"), width = w_in, height = h_in, bg = "#ffffff")
print(composite)
grDevices::dev.off()
message("Rendered composite Panel A + Panel B -> ", out_dir)
