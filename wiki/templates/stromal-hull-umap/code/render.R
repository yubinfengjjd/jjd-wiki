# Subcluster UMAP with Numbered Centroids, Smooth Dashed Functional Hulls & Multi-Column Dot Legend Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(jsonlite)
  library(RColorBrewer)
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

fname <- if (!is.null(spec$tables$cells$filename)) spec$tables$cells$filename else "stromal_umap_cells.csv"
df <- readr::read_csv(file.path(data_dir, fname), show_col_types = FALSE) %>%
  dplyr::mutate(
    cell_id = as.character(cell_id),
    x = as.numeric(umap_1),
    y = as.numeric(umap_2),
    subcluster = as.character(subcluster)
  ) %>%
  dplyr::filter(!is.na(cell_id), is.finite(x), is.finite(y), !is.na(subcluster))

has_fg <- "functional_group" %in% names(df) && any(!is.na(df$functional_group) & nzchar(as.character(df$functional_group)))
if (has_fg) {
  df$functional_group <- as.character(df$functional_group)
} else {
  df$functional_group <- df$subcluster
}

subclusters <- unique(df$subcluster)
n_sub <- length(subclusters)

base_pal <- c("#A3C9DC", "#327EB0", "#81B992", "#6BB458", "#7DA545", "#F2AA56", "#EF7E1E",
              "#F1958A", "#DA3539", "#9578B2", "#937694", "#ECDE86", "#AA5829", "#4867A0")
if (n_sub > length(base_pal)) {
  base_pal <- grDevices::colorRampPalette(c(base_pal, RColorBrewer::brewer.pal(12, "Paired")))(n_sub)
}
pal <- setNames(base_pal[seq_len(n_sub)], subclusters)

hull_col <- if (!is.null(style$hull_color)) as.character(style$hull_color) else "#D63A2F"
hull_lw <- if (!is.null(style$hull_linewidth)) as.numeric(style$hull_linewidth) else 0.48
dot_sz <- if (!is.null(style$dot_size)) as.numeric(style$dot_size) else 0.85
leg_cols <- if (is.null(style$legend_cols)) 3L else as.integer(style$legend_cols)
show_hulls <- if (is.null(style$show_hulls)) TRUE else isTRUE(style$show_hulls)
show_centroids <- if (is.null(style$show_centroids)) TRUE else isTRUE(style$show_centroids)

halo_text <- function(d, size = 2.6, colour = "#222222", offset = 0.12) {
  dirs <- seq(0, 2 * pi, length.out = 9)[1:8]
  outline <- do.call(rbind, lapply(dirs, function(angle) {
    transform(d, x = x + offset * cos(angle), y = y + offset * sin(angle))
  }))
  list(
    geom_text(data = outline, aes(x = x, y = y, label = label), inherit.aes = FALSE,
              colour = "white", size = size, fontface = "bold"),
    geom_text(data = d, aes(x = x, y = y, label = label), inherit.aes = FALSE,
              colour = colour, size = size, fontface = "bold")
  )
}

add_l_arrows <- function(d, xl = "UMAP_1", yl = "UMAP_2") {
  dx <- diff(range(d$x)); dy <- diff(range(d$y))
  ox <- min(d$x) - 0.04 * dx
  oy <- min(d$y) - 0.05 * dy
  span <- 0.17 * max(dx, dy)
  arr <- grid::arrow(length = grid::unit(1.2, "mm"), type = "open")
  list(
    annotate("segment", x = ox, xend = ox + span, y = oy, yend = oy, arrow = arr, linewidth = 0.40, colour = "#222222"),
    annotate("segment", x = ox, xend = ox, y = oy, yend = oy + span, arrow = arr, linewidth = 0.40, colour = "#222222"),
    annotate("text", x = ox + span / 2, y = oy - 0.036 * dy, label = xl, size = 2.35, colour = "#222222"),
    annotate("text", x = ox - 0.036 * dx, y = oy + span / 2, label = yl, angle = 90, size = 2.35, colour = "#222222")
  )
}

# Shuffle draw order so dense clusters blend cleanly
set.seed(42)
df_plot <- df[sample.int(nrow(df)), ]
dx <- diff(range(df$x)); dy <- diff(range(df$y))
span <- max(dx, dy, 1e-4)

p <- ggplot(df_plot, aes(x = x, y = y, colour = subcluster)) +
  geom_point(size = dot_sz * 1.45, stroke = 0, alpha = 0.94) +
  scale_colour_manual(values = pal, guide = "none") +
  coord_equal(clip = "off") +
  theme_void(base_size = 8.5) +
  theme(plot.margin = margin(8, 12, 12, 16))

if (show_hulls && has_fg) {
  fgs <- unique(df$functional_group)
  hull_list <- list()
  fg_lbls <- list()
  for (i in seq_along(fgs)) {
    fg <- fgs[i]
    pts <- df[df$functional_group == fg, c("x", "y")]
    if (nrow(pts) < 6L) next
    mid <- colMeans(pts)
    dist <- sqrt(rowSums(sweep(as.matrix(pts), 2, mid)^2))
    pts <- pts[dist <= stats::quantile(dist, 0.94, names = FALSE), ]
    if (nrow(pts) < 4L) next
    h <- grDevices::chull(pts)
    scaled <- 1.08 * sweep(as.matrix(pts[h, ]), 2, mid)
    scaled <- sweep(scaled, 2, mid, "+")
    closed <- rbind(scaled, scaled[1L, ])
    bx <- stats::spline(seq_len(nrow(closed)), closed[, 1L], n = 120, method = "periodic")$y
    by <- stats::spline(seq_len(nrow(closed)), closed[, 2L], n = 120, method = "periodic")$y
    hull_list[[length(hull_list) + 1L]] <- data.frame(x = bx, y = by, grp = i)
    top_idx <- which.max(by)
    fg_lbls[[length(fg_lbls) + 1L]] <- data.frame(x = bx[top_idx], y = by[top_idx] + 0.025 * span, label = fg)
  }
  if (length(hull_list) > 0L) {
    hulls <- do.call(rbind, hull_list)
    fg_df <- do.call(rbind, fg_lbls)
    p <- p +
      geom_polygon(data = hulls, aes(x = x, y = y, group = grp), inherit.aes = FALSE,
                   colour = hull_col, fill = NA, linetype = "dashed", linewidth = hull_lw) +
      halo_text(fg_df, size = 2.7, colour = hull_col, offset = 0.009 * span)
  }
}

if (show_centroids) {
  cent <- df %>%
    dplyr::group_by(subcluster) %>%
    dplyr::summarise(x = stats::median(x), y = stats::median(y), .groups = "drop")
  cent$label <- as.character(match(cent$subcluster, subclusters))
  p <- p + halo_text(cent, size = 2.85, colour = "#222222", offset = 0.008 * span)
}

p <- p + add_l_arrows(df, "UMAP_1", "UMAP_2")

# Multi-column colored-dot legend grouped by functional_group (when available)
if (has_fg) {
  item_rows <- list()
  fg_map <- df %>% dplyr::distinct(functional_group, subcluster)
  for (fg in unique(df$functional_group)) {
    item_rows[[length(item_rows) + 1L]] <- data.frame(label = fg, ink = NA_character_, is_hdr = TRUE, stringsAsFactors = FALSE)
    subs <- intersect(subclusters, fg_map$subcluster[fg_map$functional_group == fg])
    for (sb in subs) {
      idx_num <- match(sb, subclusters)
      item_rows[[length(item_rows) + 1L]] <- data.frame(
        label = paste0(idx_num, ": ", sb),
        ink = unname(pal[sb]),
        is_hdr = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  leg_df <- do.call(rbind, item_rows)
} else {
  leg_df <- data.frame(
    label = paste0(seq_along(subclusters), ": ", subclusters),
    ink = unname(pal[subclusters]),
    is_hdr = FALSE,
    stringsAsFactors = FALSE
  )
}

n_items <- nrow(leg_df)
n_rows <- ceiling(n_items / leg_cols)
leg_df$col <- (seq_len(n_items) - 1L) %/% n_rows
leg_df$row <- n_rows - (seq_len(n_items) - 1L) %% n_rows

leg_p <- ggplot(leg_df, aes(x = col, y = row)) +
  geom_point(data = leg_df[!leg_df$is_hdr, ], aes(colour = ink), size = 2.8) +
  geom_text(aes(x = col + ifelse(is_hdr, 0.0, 0.07), label = label,
                fontface = ifelse(is_hdr, "bold", "plain")),
            hjust = 0, size = 2.75, colour = "#1F1F1F") +
  scale_colour_identity() +
  coord_cartesian(xlim = c(-0.08, leg_cols - 0.02), ylim = c(0.4, n_rows + 0.6), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.margin = margin(2, 8, 6, 12))

leg_h_frac <- min(0.42, max(0.18, n_rows * 0.036))
combined <- patchwork::wrap_plots(p, leg_p, ncol = 1, heights = c(1 - leg_h_frac, leg_h_frac))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 6.6
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 7.6
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
