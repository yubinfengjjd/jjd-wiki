# Diffusion Map / Slingshot Trajectory & Dominant Multi-Module Overlay Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(jsonlite)
  library(scales)
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

cells_file <- if (!is.null(spec$tables$cells$filename)) spec$tables$cells$filename else "diffusion_trajectory_cells.csv"
cells <- readr::read_csv(file.path(data_dir, cells_file), show_col_types = FALSE) %>%
  dplyr::mutate(
    cell_id = as.character(cell_id),
    x = as.numeric(dim1),
    y = as.numeric(dim2),
    cluster = as.character(cluster)
  ) %>%
  dplyr::filter(!is.na(cell_id), is.finite(x), is.finite(y), !is.na(cluster))

scores_file <- if (!is.null(spec$tables$scores$filename)) spec$tables$scores$filename else "diffusion_module_scores.csv"
scores_path <- file.path(data_dir, scores_file)
has_scores <- file.exists(scores_path)

edges_file <- if (!is.null(spec$tables$edges$filename)) spec$tables$edges$filename else "trajectory_edges.csv"
edges_path <- file.path(data_dir, edges_file)
has_edges <- file.exists(edges_path)

color_mode <- if (is.null(style$color_mode)) "module_overlay" else as.character(style$color_mode)
if (color_mode == "module_overlay" && !has_scores) {
  color_mode <- if ("pseudotime" %in% names(cells) && any(is.finite(cells$pseudotime))) "pseudotime" else "cluster"
}
if (color_mode == "pseudotime" && (!"pseudotime" %in% names(cells) || !any(is.finite(cells$pseudotime)))) {
  color_mode <- "cluster"
}

dot_sz <- if (is.null(style$dot_size)) 0.95 else as.numeric(style$dot_size)
x_lbl <- if (is.null(style$x_label)) "DC_1" else as.character(style$x_label)
y_lbl <- if (is.null(style$y_label)) "DC_2" else as.character(style$y_label)
show_centroids <- if (is.null(style$show_centroids)) TRUE else isTRUE(style$show_centroids)
show_traj <- if (is.null(style$show_trajectory)) TRUE else isTRUE(style$show_trajectory)

scale01 <- function(v) {
  rng <- range(v[is.finite(v)])
  if (length(rng) < 2L || diff(rng) == 0) return(rep(0, length(v)))
  scales::squish((v - rng[1]) / diff(rng))
}

halo_text <- function(df, size = 2.6, colour = "#222222", offset = 0.015) {
  dirs <- seq(0, 2 * pi, length.out = 9)[1:8]
  outline <- do.call(rbind, lapply(dirs, function(a) {
    transform(df, x = x + offset * cos(a), y = y + offset * sin(a))
  }))
  list(
    geom_text(data = outline, aes(x = x, y = y, label = label), inherit.aes = FALSE,
              colour = "white", size = size, fontface = "bold"),
    geom_text(data = df, aes(x = x, y = y, label = label), inherit.aes = FALSE,
              colour = colour, size = size, fontface = "bold")
  )
}

add_l_arrows <- function(d, xl, yl) {
  dx <- diff(range(d$x)); dy <- diff(range(d$y))
  ox <- min(d$x) - 0.05 * dx
  oy <- min(d$y) - 0.06 * dy
  xend <- ox + 0.17 * max(dx, dy)
  yend <- oy + 0.17 * max(dx, dy)
  arr <- grid::arrow(length = grid::unit(1.25, "mm"), type = "open")
  list(
    annotate("segment", x = ox, xend = xend, y = oy, yend = oy, arrow = arr, linewidth = 0.40, colour = "#222222"),
    annotate("segment", x = ox, xend = ox, y = oy, yend = yend, arrow = arr, linewidth = 0.40, colour = "#222222"),
    annotate("text", x = (ox + xend) / 2, y = oy - 0.038 * dy, label = xl, size = 2.35, colour = "#222222"),
    annotate("text", x = ox - 0.038 * dx, y = (oy + yend) / 2, label = yl, angle = 90, size = 2.35, colour = "#222222")
  )
}

key_grobs <- list()

if (color_mode == "module_overlay") {
  sc <- readr::read_csv(scores_path, show_col_types = FALSE) %>%
    dplyr::mutate(cell_id = as.character(cell_id), module = as.character(module), score = as.numeric(score)) %>%
    dplyr::filter(!is.na(cell_id), !is.na(module), is.finite(score))
  mods <- unique(sc$module)
  mod_mat <- matrix(0, nrow = nrow(cells), ncol = length(mods), dimnames = list(cells$cell_id, mods))
  for (m in mods) {
    sub <- sc[sc$module == m, ]
    idx <- match(cells$cell_id, sub$cell_id)
    v <- rep(NA_real_, nrow(cells))
    v[!is.na(idx)] <- sub$score[idx[!is.na(idx)]]
    v[is.na(v)] <- min(v, na.rm = TRUE)
    mod_mat[, m] <- scale01(v)
  }
  dom <- max.col(mod_mat, ties.method = "first")
  peak_cols <- unlist(style$module_colors)
  if (length(peak_cols) < length(mods)) {
    peak_cols <- grDevices::colorRampPalette(c("#BF3347", "#328D40", "#397BB9", "#825097"))(length(mods))
  }
  ramps <- lapply(seq_along(mods), function(i) c("#F2EFF4", peak_cols[i]))
  cells$ink <- vapply(seq_len(nrow(cells)), function(i) {
    m_i <- dom[i]
    val <- mod_mat[i, m_i]
    grDevices::colorRampPalette(ramps[[m_i]])(256)[1L + round(scales::squish(val) * 255)]
  }, character(1))
  cells$ord_val <- apply(mod_mat, 1, max)
  cells <- cells[order(cells$ord_val), ]

  p <- ggplot(cells, aes(x = x, y = y, colour = ink)) +
    geom_point(size = dot_sz, stroke = 0, alpha = 0.94) +
    scale_colour_identity()

  for (i in seq_along(mods)) {
    ink_strip <- grDevices::colorRampPalette(ramps[[i]])(128)
    g <- grid::grobTree(
      grid::textGrob(mods[i], x = 0.45, y = 0.56, just = "right", gp = grid::gpar(fontsize = 6.5, fontface = "bold")),
      grid::rasterGrob(as.raster(matrix(ink_strip, nrow = 1)), x = 0.73, y = 0.56, width = 0.50, height = 0.28, interpolate = FALSE),
      grid::textGrob(c("0", "1"), x = c(0.49, 0.97), y = 0.18, gp = grid::gpar(fontsize = 5.6))
    )
    key_grobs[[i]] <- g
  }
} else if (color_mode == "pseudotime") {
  pt_pal <- unlist(style$pseudotime_palette)
  if (length(pt_pal) < 2L) pt_pal <- c("#2B5C8F", "#66C2A5", "#FFFFBF", "#FDAE61", "#D53E4F")
  cells <- cells[order(cells$pseudotime, na.last = FALSE), ]
  p <- ggplot(cells, aes(x = x, y = y, colour = pseudotime)) +
    geom_point(size = dot_sz, stroke = 0, alpha = 0.95) +
    scale_colour_gradientn(colours = pt_pal, name = "Pseudotime",
                           breaks = range(cells$pseudotime, na.rm = TRUE),
                           labels = c("Early", "Late")) +
    guides(colour = guide_colourbar(direction = "horizontal", barwidth = grid::unit(24, "mm"), barheight = grid::unit(2.2, "mm")))
} else {
  cls <- unique(cells$cluster)
  pal_cl <- setNames(grDevices::colorRampPalette(RColorBrewer::brewer.pal(min(12, max(3, length(cls))), "Paired"))(length(cls)), cls)
  p <- ggplot(cells, aes(x = x, y = y, colour = cluster)) +
    geom_point(size = dot_sz, stroke = 0, alpha = 0.94) +
    scale_colour_manual(values = pal_cl, name = NULL)
}

centers <- cells %>%
  dplyr::group_by(cluster) %>%
  dplyr::summarise(x = median(x), y = median(y), .groups = "drop")
centers$label <- as.character(seq_len(nrow(centers)))

if (show_traj && has_edges) {
  edges <- readr::read_csv(edges_path, show_col_types = FALSE) %>%
    dplyr::mutate(from_cluster = as.character(from_cluster), to_cluster = as.character(to_cluster))
  edges$x <- centers$x[match(edges$from_cluster, centers$cluster)]
  edges$y <- centers$y[match(edges$from_cluster, centers$cluster)]
  edges$xe <- centers$x[match(edges$to_cluster, centers$cluster)]
  edges$ye <- centers$y[match(edges$to_cluster, centers$cluster)]
  edges <- edges[complete.cases(edges[, c("x", "y", "xe", "ye")]), ]
  if (nrow(edges) > 0L) {
    p <- p + geom_curve(
      data = edges,
      aes(x = x, y = y, xend = xe, yend = ye),
      inherit.aes = FALSE,
      curvature = 0.18, linewidth = 0.48, linetype = "dashed",
      colour = "#2D2D2D",
      arrow = grid::arrow(length = grid::unit(1.4, "mm"), type = "closed")
    )
  }
}

dx <- diff(range(cells$x)); dy <- diff(range(cells$y))
if (show_centroids) {
  p <- p + halo_text(centers, size = 2.65, colour = "#1F1F1F", offset = 0.012 * max(dx, dy))
}

p <- p +
  add_l_arrows(cells, x_lbl, y_lbl) +
  coord_equal(clip = "off") +
  theme_void(base_size = 8.5) +
  theme(
    legend.position = if (color_mode == "module_overlay") "none" else "bottom",
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 7.5),
    plot.margin = margin(10, 12, if (length(key_grobs) > 0L) 26 else 14, 16)
  )

if (length(key_grobs) > 0L) {
  nk <- length(key_grobs)
  w_each <- min(0.24, 0.72 / nk)
  start_x <- 0.98 - nk * w_each
  for (i in seq_along(key_grobs)) {
    x0 <- start_x + (i - 1L) * w_each
    p <- p + inset_element(key_grobs[[i]], x0, 0.01, x0 + w_each - 0.008, 0.095, align_to = "full")
  }
}

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 6.4
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 5.8
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
