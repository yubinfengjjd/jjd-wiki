# Pathway-Directed Circular Cell-Cell Signaling Ring Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(jsonlite)
  library(RColorBrewer)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1L]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
tpl_root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[1L]))))

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

nodes_file <- if (!is.null(spec$tables$nodes$filename)) spec$tables$nodes$filename else "ring_nodes.csv"
edges_file <- if (!is.null(spec$tables$edges$filename)) spec$tables$edges$filename else "ring_edges.csv"

node_raw <- utils::read.csv(file.path(data_dir, nodes_file), check.names = FALSE, stringsAsFactors = FALSE)
node_raw$node <- as.character(node_raw$node)
node_raw <- node_raw[!is.na(node_raw$node) & nzchar(node_raw$node), , drop = FALSE]
node_raw <- node_raw[!duplicated(node_raw$node), , drop = FALSE]

edge_raw <- utils::read.csv(file.path(data_dir, edges_file), check.names = FALSE, stringsAsFactors = FALSE)
edge_raw$from <- as.character(edge_raw$from)
edge_raw$to <- as.character(edge_raw$to)
edge_raw$weight <- as.numeric(edge_raw$weight)
edge_raw <- edge_raw[!is.na(edge_raw$from) & !is.na(edge_raw$to) & is.finite(edge_raw$weight) & edge_raw$weight > 0, , drop = FALSE]

# Preserve all catalog nodes including isolated ones; append any edge-only node cleanly
extra_nodes <- setdiff(unique(c(edge_raw$from, edge_raw$to)), node_raw$node)
if (length(extra_nodes) > 0L) {
  add_df <- data.frame(node = extra_nodes, stringsAsFactors = FALSE)
  for (col in setdiff(names(node_raw), "node")) add_df[[col]] <- NA
  node_raw <- rbind(node_raw, add_df[, names(node_raw), drop = FALSE])
}
if (!"compartment" %in% names(node_raw)) node_raw$compartment <- "Cell"
if (!"is_hub" %in% names(node_raw)) node_raw$is_hub <- 0L
node_raw$compartment[is.na(node_raw$compartment) | !nzchar(node_raw$compartment)] <- "Cell"
node_raw$is_hub[is.na(node_raw$is_hub)] <- 0L

n <- nrow(node_raw)
if (!"color" %in% names(node_raw)) node_raw$color <- NA_character_
missing_col <- is.na(node_raw$color) | !nzchar(node_raw$color)
if (any(missing_col)) {
  auto_pal <- grDevices::colorRampPalette(RColorBrewer::brewer.pal(12L, "Paired"))(n)
  node_raw$color[missing_col] <- auto_pal[missing_col]
}

hub_col <- if (!is.null(style$hub_label_color)) style$hub_label_color else "#D7191C"
def_col <- if (!is.null(style$default_label_color)) style$default_label_color else "#252229"
node_sz <- if (!is.null(style$node_size)) as.numeric(style$node_size) else 4.48
lbl_sz <- if (!is.null(style$label_size)) as.numeric(style$label_size) else max(1.6, min(3.0, 115 / max(n, 20)))

theta <- -2 * pi * (seq_len(n) - 1L) / n
left <- cos(theta) < 0
nodes <- data.frame(
  name = node_raw$node,
  x = cos(theta),
  y = sin(theta),
  tx = 1.106 * cos(theta),
  ty = 1.106 * sin(theta),
  align = ifelse(left, 1, 0),
  angle = theta * 180 / pi + ifelse(left, 180, 0),
  node_ink = node_raw$color,
  label_ink = ifelse(as.numeric(node_raw$is_hub) > 0, hub_col, def_col),
  stringsAsFactors = FALSE
)

pairs <- aggregate(weight ~ from + to, edge_raw, max)
pairs <- pairs[order(pairs$weight), , drop = FALSE]

ink_map <- setNames(nodes$node_ink, nodes$name)
curve_list <- lapply(seq_len(nrow(pairs)), function(i) {
  a <- as.numeric(nodes[match(pairs$from[i], nodes$name), c("x", "y")])
  b <- as.numeric(nodes[match(pairs$to[i], nodes$name), c("x", "y")])
  t <- seq(0, 1, length.out = 36L)
  if (all(a == b)) {
    orth <- c(-a[2L], a[1L])
    p0 <- 0.99 * a - 0.035 * orth
    p3 <- 0.99 * a + 0.035 * orth
    p1 <- 0.69 * a - 0.22 * orth
    p2 <- 0.69 * a + 0.22 * orth
    xy <- outer((1 - t)^3, p0) + outer(3 * (1 - t)^2 * t, p1) + outer(3 * (1 - t) * t^2, p2) + outer(t^3, p3)
  } else {
    control <- 0.33 * (a + b)
    xy <- outer((1 - t)^2, a) + outer(2 * (1 - t) * t, control) + outer(t^2, b)
  }
  data.frame(x = xy[, 1L], y = xy[, 2L], id = i, ink = unname(ink_map[pairs$from[i]]), weight = pairs$weight[i])
})
curves <- if (length(curve_list) > 0L) do.call(rbind, curve_list) else data.frame(x = numeric(), y = numeric(), id = integer(), ink = character(), weight = numeric())

p <- ggplot() +
  geom_path(data = curves, aes(x = x, y = y, group = id, colour = ink, linewidth = weight, alpha = weight),
            lineend = "round") +
  geom_point(data = nodes, aes(x = x, y = y, fill = node_ink), shape = 21, colour = "white",
             size = node_sz, stroke = 0.28) +
  geom_text(data = nodes, aes(x = tx, y = ty, angle = angle, hjust = align, label = name, colour = label_ink),
            size = lbl_sz) +
  scale_colour_identity() +
  scale_fill_identity() +
  scale_linewidth_continuous(range = c(0.13, 1.33), guide = "none") +
  scale_alpha_continuous(range = c(0.20, 0.67), guide = "none") +
  coord_equal(xlim = c(-1.70, 1.70), ylim = c(-1.59, 1.59), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.margin = margin(5, 9, 3, 9))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 7.2
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 7.0
dpi_val <- if (is.null(style$dpi)) 300L else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
