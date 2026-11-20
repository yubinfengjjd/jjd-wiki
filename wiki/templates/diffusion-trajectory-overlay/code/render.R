# Diffusion Map / Slingshot Trajectory & Dominant Multi-Module Overlay Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(jsonlite)
  library(scales)
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

cells_file <- if (!is.null(spec$tables$cells$filename)) spec$tables$cells$filename else "diffusion_trajectory_cells.csv"
cells <- utils::read.csv(file.path(data_dir, cells_file), check.names = FALSE, stringsAsFactors = FALSE)
cells$cell_id <- as.character(cells$cell_id)
cells$x <- as.numeric(cells$dim1)
cells$y <- as.numeric(cells$dim2)
cells$cluster <- as.character(cells$cluster)
if ("pseudotime" %in% names(cells)) cells$pseudotime <- as.numeric(cells$pseudotime)
keep <- !is.na(cells$cell_id) & is.finite(cells$x) & is.finite(cells$y) & !is.na(cells$cluster)
cells <- cells[keep, , drop = FALSE]

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

dot_sz <- if (is.null(style$dot_size)) 1.05 else as.numeric(style$dot_size)
x_lbl <- if (is.null(style$x_label)) "DC_1" else as.character(style$x_label)
y_lbl <- if (is.null(style$y_label)) "DC_2" else as.character(style$y_label)
show_centroids <- if (is.null(style$show_centroids)) TRUE else isTRUE(style$show_centroids)
show_traj <- if (is.null(style$show_trajectory)) TRUE else isTRUE(style$show_trajectory)

scale01 <- function(v) {
  rng <- range(v[is.finite(v)])
  if (length(rng) < 2L || diff(rng) == 0) return(rep(0, length(v)))
  scales::squish((v - rng[1L]) / diff(rng))
}

halo_text <- function(df, size = 2.6, colour = "#222222", offset = 0.015) {
  dirs <- seq(0, 2 * pi, length.out = 9L)[1:8]
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
  ox <- min(d$x) - 0.055 * dx
  oy <- min(d$y) - 0.065 * dy
  xend <- ox + 0.16 * max(dx, dy)
  yend <- oy + 0.16 * max(dx, dy)
  arr <- grid::arrow(length = grid::unit(1.2, "mm"), type = "open")
  list(
    annotate("segment", x = ox, xend = xend, y = oy, yend = oy, arrow = arr, linewidth = 0.40, colour = "#222222"),
    annotate("segment", x = ox, xend = ox, y = oy, yend = yend, arrow = arr, linewidth = 0.40, colour = "#222222"),
    annotate("text", x = (ox + xend) / 2, y = oy - 0.038 * dy, label = xl, size = 2.3, colour = "#222222"),
    annotate("text", x = ox - 0.038 * dx, y = (oy + yend) / 2, label = yl, angle = 90, size = 2.3, colour = "#222222")
  )
}

key_grobs <- list()

if (color_mode == "module_overlay") {
  sc <- utils::read.csv(scores_path, check.names = FALSE, stringsAsFactors = FALSE)
  sc$cell_id <- as.character(sc$cell_id)
  sc$module <- as.character(sc$module)
  sc$score <- as.numeric(sc$score)
  sc <- sc[!is.na(sc$cell_id) & !is.na(sc$module) & is.finite(sc$score), , drop = FALSE]
  mods <- unique(sc$module)
  mod_mat <- matrix(0, nrow = nrow(cells), ncol = length(mods), dimnames = list(cells$cell_id, mods))
  for (m in mods) {
    sub <- sc[sc$module == m, , drop = FALSE]
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
  base_tints <- c("#F2EFF4", "#F3F6F1", "#EDF2FB", "#F3EEF7", "#FAF3E8", "#ECF6F3")
  ramps <- lapply(seq_along(mods), function(i) c(base_tints[(i - 1L) %% length(base_tints) + 1L], peak_cols[i]))
  cells$ink <- vapply(seq_len(nrow(cells)), function(i) {
    m_i <- dom[i]
    val <- mod_mat[i, m_i]
    grDevices::colorRampPalette(ramps[[m_i]])(256L)[1L + round(scales::squish(val) * 255)]
  }, character(1L))
  cells$ord_val <- apply(mod_mat, 1L, max)
  cells <- cells[order(cells$ord_val), , drop = FALSE]

  p <- ggplot(cells, aes(x = x, y = y, colour = ink)) +
    geom_point(size = dot_sz, stroke = 0, alpha = 0.94) +
    scale_colour_identity()

  for (i in seq_along(mods)) {
    ink_strip <- rev(grDevices::colorRampPalette(ramps[[i]])(128L))
    g <- grid::grobTree(
      grid::textGrob(mods[i], x = 0.50, y = 0.93, just = "center", gp = grid::gpar(fontsize = 6.5, fontface = "bold")),
      grid::rasterGrob(as.raster(matrix(ink_strip, ncol = 1L)), x = 0.30, y = 0.44, width = 0.24, height = 0.62, interpolate = FALSE),
      grid::textGrob(c("1", "0"), x = 0.50, y = c(0.73, 0.14), just = "left", gp = grid::gpar(fontsize = 5.8))
    )
    key_grobs[[i]] <- g
  }
} else if (color_mode == "pseudotime") {
  pt_pal <- unlist(style$pseudotime_palette)
  if (length(pt_pal) < 2L) pt_pal <- c("#2B5C8F", "#66C2A5", "#FFFFBF", "#FDAE61", "#D53E4F")
  cells <- cells[order(cells$pseudotime, na.last = FALSE), , drop = FALSE]
  p <- ggplot(cells, aes(x = x, y = y, colour = pseudotime)) +
    geom_point(size = dot_sz, stroke = 0, alpha = 0.95) +
    scale_colour_gradientn(colours = pt_pal, name = "Pseudotime",
                           breaks = range(cells$pseudotime, na.rm = TRUE),
                           labels = c("Early", "Late")) +
    guides(colour = guide_colourbar(direction = "horizontal", barwidth = grid::unit(24, "mm"), barheight = grid::unit(2.2, "mm")))
} else {
  cls <- unique(cells$cluster)
  pal_cl <- setNames(grDevices::colorRampPalette(RColorBrewer::brewer.pal(min(12L, max(3L, length(cls))), "Paired"))(length(cls)), cls)
  p <- ggplot(cells, aes(x = x, y = y, colour = cluster)) +
    geom_point(size = dot_sz, stroke = 0, alpha = 0.94) +
    scale_colour_manual(values = pal_cl, name = NULL)
}

cl_levels <- unique(cells$cluster)
centers <- do.call(rbind, lapply(seq_along(cl_levels), function(i) {
  s <- cells[cells$cluster == cl_levels[i], , drop = FALSE]
  data.frame(cluster = cl_levels[i], x = stats::median(s$x), y = stats::median(s$y),
             label = as.character(i), stringsAsFactors = FALSE)
}))

if (show_traj && has_edges) {
  edges <- utils::read.csv(edges_path, check.names = FALSE, stringsAsFactors = FALSE)
  edges$from_cluster <- as.character(edges$from_cluster)
  edges$to_cluster <- as.character(edges$to_cluster)
  edges$x <- centers$x[match(edges$from_cluster, centers$cluster)]
  edges$y <- centers$y[match(edges$from_cluster, centers$cluster)]
  edges$xe <- centers$x[match(edges$to_cluster, centers$cluster)]
  edges$ye <- centers$y[match(edges$to_cluster, centers$cluster)]
  edges <- edges[stats::complete.cases(edges[, c("x", "y", "xe", "ye")]), , drop = FALSE]
  if (nrow(edges) > 0L) {
    p <- p + geom_curve(
      data = edges,
      aes(x = x, y = y, xend = xe, yend = ye),
      inherit.aes = FALSE,
      curvature = 0.10, linewidth = 0.36, linetype = "dashed",
      colour = "#2D2D2D",
      arrow = grid::arrow(length = grid::unit(1.15, "mm"), type = "closed")
    )
  }
}

dx <- diff(range(cells$x)); dy <- diff(range(cells$y))
if (show_centroids) {
  p <- p + halo_text(centers, size = 2.55, colour = "#1F1F1F", offset = 0.008 * max(dx, dy))
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
  w_each <- min(0.16, 0.64 / nk)
  start_x <- 0.56 - (nk * w_each) / 2
  for (i in seq_along(key_grobs)) {
    x0 <- start_x + (i - 1L) * w_each
    p <- p + inset_element(key_grobs[[i]], x0, 0.015, x0 + w_each - 0.005, 0.21, align_to = "full")
  }
}

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 6.4
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 5.8
dpi_val <- if (is.null(style$dpi)) 300L else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
