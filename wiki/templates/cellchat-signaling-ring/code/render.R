# Pathway-Directed Circular Cell-Cell Signaling Ring Renderer
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

nodes_file <- if (!is.null(spec$tables$nodes$filename)) spec$tables$nodes$filename else "ring_nodes.csv"
edges_file <- if (!is.null(spec$tables$edges$filename)) spec$tables$edges$filename else "ring_edges.csv"

node_raw <- readr::read_csv(file.path(data_dir, nodes_file), show_col_types = FALSE) %>%
  dplyr::mutate(node = as.character(node)) %>%
  dplyr::filter(!is.na(node), nzchar(node)) %>%
  dplyr::distinct(node, .keep_all = TRUE)

edge_raw <- readr::read_csv(file.path(data_dir, edges_file), show_col_types = FALSE) %>%
  dplyr::mutate(
    from = as.character(from),
    to = as.character(to),
    weight = as.numeric(weight)
  ) %>%
  dplyr::filter(!is.na(from), !is.na(to), is.finite(weight), weight > 0)

# Preserve all catalog nodes including isolated ones; append any edge-only node cleanly
extra_nodes <- setdiff(unique(c(edge_raw$from, edge_raw$to)), node_raw$node)
if (length(extra_nodes) > 0L) {
  node_raw <- dplyr::bind_rows(node_raw, data.frame(node = extra_nodes, stringsAsFactors = FALSE))
}
if (!"compartment" %in% names(node_raw)) node_raw$compartment <- "Cell"
if (!"is_hub" %in% names(node_raw)) node_raw$is_hub <- 0L
node_raw$compartment[is.na(node_raw$compartment) | !nzchar(node_raw$compartment)] <- "Cell"
node_raw$is_hub[is.na(node_raw$is_hub)] <- 0L

n <- nrow(node_raw)
if (!"color" %in% names(node_raw)) node_raw$color <- NA_character_
missing_col <- is.na(node_raw$color) | !nzchar(node_raw$color)
if (any(missing_col)) {
  auto_pal <- grDevices::colorRampPalette(RColorBrewer::brewer.pal(12, "Paired"))(n)
  node_raw$color[missing_col] <- auto_pal[missing_col]
}

hub_col <- if (!is.null(style$hub_label_color)) style$hub_label_color else "#D7191C"
def_col <- if (!is.null(style$default_label_color)) style$default_label_color else "#252229"
node_sz <- if (!is.null(style$node_size)) as.numeric(style$node_size) else 4.2
lbl_sz <- if (!is.null(style$label_size)) as.numeric(style$label_size) else max(1.6, min(3.0, 115 / max(n, 20)))

theta <- -2 * pi * (seq_len(n) - 1L) / n
left <- cos(theta) < 0
nodes <- data.frame(
  name = node_raw$node,
  x = cos(theta),
  y = sin(theta),
  tx = 1.105 * cos(theta),
  ty = 1.105 * sin(theta),
  align = ifelse(left, 1, 0),
  angle = theta * 180 / pi + ifelse(left, 180, 0),
  node_ink = node_raw$color,
  label_ink = ifelse(as.numeric(node_raw$is_hub) > 0, hub_col, def_col),
  stringsAsFactors = FALSE
)

pairs <- edge_raw %>%
  dplyr::group_by(from, to) %>%
  dplyr::summarise(weight = max(weight, na.rm = TRUE), .groups = "drop") %>%
  dplyr::arrange(weight)

ink_map <- setNames(nodes$node_ink, nodes$name)
curve_list <- lapply(seq_len(nrow(pairs)), function(i) {
  a <- as.numeric(nodes[match(pairs$from[i], nodes$name), c("x", "y")])
  b <- as.numeric(nodes[match(pairs$to[i], nodes$name), c("x", "y")])
  t <- seq(0, 1, length.out = 36)
  if (all(a == b)) {
    orth <- c(-a[2], a[1])
    p0 <- 0.99 * a - 0.035 * orth
    p3 <- 0.99 * a + 0.035 * orth
    p1 <- 0.68 * a - 0.22 * orth
    p2 <- 0.68 * a + 0.22 * orth
    xy <- outer((1 - t)^3, p0) + outer(3 * (1 - t)^2 * t, p1) + outer(3 * (1 - t) * t^2, p2) + outer(t^3, p3)
  } else {
    control <- 0.33 * (a + b)
    xy <- outer((1 - t)^2, a) + outer(2 * (1 - t) * t, control) + outer(t^2, b)
  }
  data.frame(x = xy[, 1], y = xy[, 2], id = i, ink = unname(ink_map[pairs$from[i]]), weight = pairs$weight[i])
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
  scale_linewidth_continuous(range = c(0.16, 1.45), guide = "none") +
  scale_alpha_continuous(range = c(0.22, 0.72), guide = "none") +
  coord_equal(xlim = c(-1.72, 1.72), ylim = c(-1.66, 1.66), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.margin = margin(8, 10, 8, 10))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 7.6
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 7.4
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
