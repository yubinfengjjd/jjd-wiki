# Modular hdWGCNA Co-expression Sphere Network Plot (reconstructed from tutorial spec)
# Supports arbitrary numbers of modules n, external gene_module.csv + edge_file.csv,
# and optional style JSON overrides.

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
script_dir <- if (length(script_arg) > 0) dirname(normalizePath(sub("^--file=", "", script_arg[1]))) else getwd()
entry_root <- if (basename(script_dir) == "code") dirname(script_dir) else script_dir

data_dir <- get_arg("--data", file.path(entry_root, "data"))
out_dir <- get_arg("--out", file.path(entry_root, "output"))
style_file <- get_arg("--style", NULL)

style <- list(
  width_in = 8.4,
  height_in = 8.0,
  dpi = 300,
  point_size = 1.95,
  point_alpha = 0.95,
  edge_color = "#a8a8a8",
  edge_alpha = 0.18,
  edge_width = 0.22,
  label_size = 3.15,
  wrap_width = 28,
  segment_color = "#2f2f2f",
  segment_size = 0.42,
  seed = 42,
  title = ""
)
if (!is.null(style_file) && file.exists(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  for (k in names(override)) {
    if (!is.null(override[[k]])) style[[k]] <- override[[k]]
  }
}

nodes_path <- file.path(data_dir, "gene_module.csv")
edges_path <- file.path(data_dir, "edge_file.csv")
if (!file.exists(nodes_path)) stop("Missing gene_module.csv in: ", data_dir)
if (!file.exists(edges_path)) stop("Missing edge_file.csv in: ", data_dir)

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
  stop("Nodes or edges are empty after filtering matching gene names.")
}

if (!"color" %in% names(nodes_df) || all(is.na(nodes_df$color) | !nzchar(nodes_df$color))) {
  mods <- unique(nodes_df$module)
  auto_pal <- grDevices::hcl.colors(max(3, length(mods)), palette = "Dark 3")[seq_along(mods)]
  nodes_df$color <- auto_pal[match(nodes_df$module, mods)]
}

if (!"annotation" %in% names(nodes_df)) {
  nodes_df$annotation <- ""
}

# Build igraph and assign balanced intra-/inter-module weights for dense spherical topology
mod_lookup <- setNames(nodes_df$module, nodes_df$gene_name)
same_mod <- mod_lookup[edges_df$from] == mod_lookup[edges_df$to]
base_tom <- if ("tom" %in% names(edges_df)) pmax(0.02, as.numeric(edges_df$tom)) else rep(0.1, nrow(edges_df))
edges_df$layout_weight <- ifelse(same_mod, 3.6 * (1 + base_tom), 1.05)

g <- igraph::graph_from_data_frame(edges_df[, c("from", "to", "layout_weight")], vertices = nodes_df, directed = FALSE)
g <- igraph::simplify(g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list(layout_weight = "max"))

set.seed(as.integer(style$seed))
coords <- igraph::layout_with_fr(g, weights = igraph::E(g)$layout_weight, niter = 1400)
coords[, 1] <- coords[, 1] - mean(coords[, 1])
coords[, 2] <- coords[, 2] - mean(coords[, 2])
rad <- sqrt(coords[, 1]^2 + coords[, 2]^2)
max_r <- max(rad, 1e-6)
coords <- coords / max_r
# Smooth spherical radial envelope keeping clusters contiguous inside unit disc
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

# Compute module centroids and outward radial label anchors (works cleanly for any module count n)
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
    n_genes = dplyr::n(),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    ann = ifelse(is.na(ann) | !nzchar(ann), "", ann),
    raw_label = ifelse(nzchar(ann), paste0(module, ":", ann), module),
    wrapped_label = stringr::str_wrap(raw_label, width = as.integer(style$wrap_width)),
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
w_in <- as.numeric(style$width_in)
h_in <- as.numeric(style$height_in)
if (n_mods > 18) {
  scale_bump <- sqrt(n_mods / 14)
  w_in <- max(w_in, 8.0 * scale_bump)
  h_in <- max(h_in, 7.5 * scale_bump)
}

p <- ggplot() +
  geom_segment(
    data = edge_plot_df,
    aes(x = x, y = y, xend = xend, yend = yend),
    color = style$edge_color,
    alpha = as.numeric(style$edge_alpha),
    linewidth = as.numeric(style$edge_width)
  ) +
  geom_point(
    data = node_plot_df,
    aes(x = x, y = y, color = module),
    size = as.numeric(style$point_size),
    alpha = as.numeric(style$point_alpha),
    show.legend = FALSE
  ) +
  scale_color_manual(values = mod_colors) +
  ggrepel::geom_text_repel(
    data = mod_summary,
    aes(x = cx, y = cy, label = wrapped_label),
    color = mod_summary$label_color,
    fontface = "bold",
    size = as.numeric(style$label_size),
    lineheight = 0.92,
    hjust = mod_summary$hjust_val,
    nudge_x = mod_summary$nudge_x,
    nudge_y = mod_summary$nudge_y,
    segment.color = style$segment_color,
    segment.size = as.numeric(style$segment_size),
    segment.alpha = 0.85,
    min.segment.length = 0,
    box.padding = 0.45,
    point.padding = 0.30,
    force = 3.5,
    force_pull = 0.35,
    max.iter = 5000,
    max.overlaps = Inf,
    seed = as.integer(style$seed)
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
out_png <- file.path(out_dir, "replica.png")
out_pdf <- file.path(out_dir, "replica.pdf")
out_svg <- file.path(out_dir, "replica.svg")

ggsave(out_png, p, width = w_in, height = h_in, dpi = as.numeric(style$dpi), bg = "#ffffff")
grDevices::cairo_pdf(out_pdf, width = w_in, height = h_in, bg = "#ffffff")
print(p)
grDevices::dev.off()

if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(out_svg, p, width = w_in, height = h_in, device = "svg", bg = "#ffffff")
} else {
  message("WARN: svglite not installed; falling back to grDevices::svg (text may be vector paths).")
  grDevices::svg(out_svg, width = w_in, height = h_in, bg = "#ffffff")
  print(p)
  grDevices::dev.off()
}
message(sprintf("Rendered %d nodes, %d edges, %d modules -> %s", nrow(node_plot_df), nrow(edge_plot_df), n_mods, out_dir))
