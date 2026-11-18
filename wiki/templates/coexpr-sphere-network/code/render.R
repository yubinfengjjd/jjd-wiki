# Co-expression Module Sphere Network Renderer (hdWGCNA / WGCNA)
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(igraph)
  library(ggrepel)
  library(dplyr)
  library(readr)
  library(stringr)
  library(jsonlite)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1]
}

script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- dirname(normalizePath(sub("^--file=", "", script_arg[1])))
tpl_root <- dirname(script_dir)

data_dir <- get_arg("--data")
out_dir <- get_arg("--out")
style_file <- get_arg("--style", NULL)
if (is.null(data_dir) || is.null(out_dir)) {
  stop("Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]")
}
if (!dir.exists(data_dir)) stop("Data directory not found: ", data_dir)

spec <- jsonlite::fromJSON(file.path(tpl_root, "spec.json"), simplifyVector = FALSE)
style <- if (is.null(spec$style)) list() else spec$style
if (!is.null(style_file) && file.exists(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  for (k in names(override)) {
    if (!is.null(override[[k]])) style[[k]] <- override[[k]]
  }
}

nodes_fname <- if (!is.null(spec$tables$nodes$filename)) spec$tables$nodes$filename else "gene_module.csv"
edges_fname <- if (!is.null(spec$tables$edges$filename)) spec$tables$edges$filename else "edge_file.csv"
nodes_path <- file.path(data_dir, nodes_fname)
edges_path <- file.path(data_dir, edges_fname)
if (!file.exists(nodes_path)) stop("Missing nodes file: ", nodes_path)
if (!file.exists(edges_path)) stop("Missing edges file: ", edges_path)

nodes_df <- readr::read_csv(nodes_path, show_col_types = FALSE) %>%
  dplyr::mutate(
    gene_name = as.character(gene_name),
    module = as.character(module)
  ) %>%
  dplyr::filter(!is.na(gene_name), nzchar(gene_name), !is.na(module), nzchar(module)) %>%
  dplyr::distinct(gene_name, .keep_all = TRUE)

edges_df <- readr::read_csv(edges_path, show_col_types = FALSE) %>%
  dplyr::mutate(from = as.character(from), to = as.character(to)) %>%
  dplyr::filter(from %in% nodes_df$gene_name, to %in% nodes_df$gene_name, from != to)

if (nrow(nodes_df) == 0 || nrow(edges_df) == 0) {
  stop("Nodes or edges are empty after matching gene names.")
}

if (!"color" %in% names(nodes_df) || all(is.na(nodes_df$color) | !nzchar(nodes_df$color))) {
  mods <- unique(nodes_df$module)
  auto_pal <- grDevices::hcl.colors(max(3, length(mods)), palette = "Dark 3")[seq_along(mods)]
  nodes_df$color <- auto_pal[match(nodes_df$module, mods)]
}
if (!"annotation" %in% names(nodes_df)) {
  nodes_df$annotation <- ""
}

mod_lookup <- setNames(nodes_df$module, nodes_df$gene_name)
same_mod <- mod_lookup[edges_df$from] == mod_lookup[edges_df$to]
base_tom <- if ("tom" %in% names(edges_df)) pmax(0.02, as.numeric(edges_df$tom)) else rep(0.1, nrow(edges_df))
edges_df$layout_weight <- ifelse(same_mod, 3.6 * (1 + base_tom), 1.05)

g <- igraph::graph_from_data_frame(edges_df[, c("from", "to", "layout_weight")], vertices = nodes_df, directed = FALSE)
g <- igraph::simplify(g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list(layout_weight = "max"))

seed_val <- if (is.null(style$seed)) 42 else as.integer(style$seed)
set.seed(seed_val)
coords <- igraph::layout_with_fr(g, weights = igraph::E(g)$layout_weight, niter = 1400)
coords[, 1] <- coords[, 1] - mean(coords[, 1])
coords[, 2] <- coords[, 2] - mean(coords[, 2])
rad <- sqrt(coords[, 1]^2 + coords[, 2]^2)
max_r <- max(rad, 1e-6)
coords <- coords / max_r
r_new <- rad / max_r
scale_fac <- ifelse(r_new > 0, (r_new^0.80) / r_new, 1)
coords <- coords * scale_fac

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

wrap_w <- if (is.null(style$wrap_width)) 28 else as.integer(style$wrap_width)
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
    ann = ifelse(is.na(ann) | !nzchar(ann), "", ann),
    raw_label = ifelse(nzchar(ann), paste0(module, ":", ann), module),
    wrapped_label = stringr::str_wrap(raw_label, width = wrap_w),
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
n_mods <- nrow(mod_summary)
w_in <- if (is.null(style$width_in)) 8.4 else as.numeric(style$width_in)
h_in <- if (is.null(style$height_in)) 8.0 else as.numeric(style$height_in)
if (n_mods > 18) {
  scale_bump <- sqrt(n_mods / 14)
  w_in <- max(w_in, 8.0 * scale_bump)
  h_in <- max(h_in, 7.5 * scale_bump)
}

p <- ggplot() +
  geom_segment(
    data = edge_plot_df,
    aes(x = x, y = y, xend = xend, yend = yend),
    color = if (is.null(style$edge_color)) "#a8a8a8" else style$edge_color,
    alpha = if (is.null(style$edge_alpha)) 0.18 else as.numeric(style$edge_alpha),
    linewidth = if (is.null(style$edge_width)) 0.22 else as.numeric(style$edge_width)
  ) +
  geom_point(
    data = node_plot_df,
    aes(x = x, y = y, color = module),
    size = if (is.null(style$point_size)) 1.95 else as.numeric(style$point_size),
    alpha = if (is.null(style$point_alpha)) 0.95 else as.numeric(style$point_alpha),
    show.legend = FALSE
  ) +
  scale_color_manual(values = mod_colors) +
  ggrepel::geom_text_repel(
    data = mod_summary,
    aes(x = cx, y = cy, label = wrapped_label),
    color = mod_summary$label_color,
    fontface = "bold",
    size = if (is.null(style$label_size)) 3.15 else as.numeric(style$label_size),
    lineheight = 0.92,
    hjust = mod_summary$hjust_val,
    nudge_x = mod_summary$nudge_x,
    nudge_y = mod_summary$nudge_y,
    segment.color = if (is.null(style$segment_color)) "#2f2f2f" else style$segment_color,
    segment.size = if (is.null(style$segment_size)) 0.42 else as.numeric(style$segment_size),
    segment.alpha = 0.85,
    min.segment.length = 0,
    box.padding = 0.45,
    point.padding = 0.30,
    force = 3.5,
    force_pull = 0.35,
    max.iter = 5000,
    max.overlaps = Inf,
    seed = seed_val
  ) +
  coord_equal(xlim = c(-1.62, 1.62), ylim = c(-1.42, 1.42), clip = "off") +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "#ffffff", color = NA),
    panel.background = element_rect(fill = "#ffffff", color = NA),
    plot.margin = margin(10, 14, 10, 14)
  )

if (!is.null(style$title) && nzchar(trimws(style$title))) {
  p <- p + labs(title = style$title) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 13, margin = margin(b = 6)))
}

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dpi <- if (is.null(style$dpi)) 300 else as.numeric(style$dpi)
ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi, bg = "#ffffff")
grDevices::cairo_pdf(file.path(out_dir, "figure.pdf"), width = w_in, height = h_in, bg = "#ffffff")
print(p)
grDevices::dev.off()
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = "svg", bg = "#ffffff")
} else {
  grDevices::svg(file.path(out_dir, "figure.svg"), width = w_in, height = h_in, bg = "#ffffff")
  print(p)
  grDevices::dev.off()
}
