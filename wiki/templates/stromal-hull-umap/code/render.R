# Subcluster UMAP with Numbered Centroids, Smooth Dashed Functional Hulls & Multi-Column Dot Legend Renderer
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
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

fname <- if (!is.null(spec$tables$cells$filename)) spec$tables$cells$filename else "stromal_umap_cells.csv"
df <- utils::read.csv(file.path(data_dir, fname), check.names = FALSE, stringsAsFactors = FALSE)
df$cell_id <- as.character(df$cell_id)
df$x <- as.numeric(df$umap_1)
df$y <- as.numeric(df$umap_2)
df$subcluster <- as.character(df$subcluster)
keep <- !is.na(df$cell_id) & is.finite(df$x) & is.finite(df$y) & !is.na(df$subcluster)
df <- df[keep, , drop = FALSE]

has_fg <- "functional_group" %in% names(df) && any(!is.na(df$functional_group) & nzchar(as.character(df$functional_group)))
df$functional_group <- if (has_fg) as.character(df$functional_group) else df$subcluster

has_comp <- "compartment" %in% names(df) && any(!is.na(df$compartment) & nzchar(as.character(df$compartment)))
df$compartment <- if (has_comp) as.character(df$compartment) else "Cells"
compartments <- unique(df$compartment)

# Known Cai 2026 canonical 36-subcluster palette with fallback for user labels
known_pal <- c(
  C1_mFib_ACTA2="#A3C9DC", C2_ifnFib_HSPA6="#327EB0", C3_lpFib_PLA2G2A="#81B992",
  C4_iFib_BNC2="#6BB458", C5_iFib_CXCL8="#7DA545", C6_iFib_NFKB1="#F2AA56",
  C7_lpFib_APOD="#EF7E1E", C8_iFib_CCL19="#F1958A", C9_mFib_COL12A1="#DA3539",
  C10_lpFib_ABCA8="#9578B2", C11_tFib_ENO1="#937694", C12_apFib_CD74="#ECDE86",
  C13_lpFib_LUM="#AA5829", C14_tFib_A2M="#4867A0",
  C1_ArtEC_SEMA3G="#3A97C2", C2_ArtEC_DLL4="#B9719F", C3_CapEC_CD36="#AA95BE",
  C4_TipEC_PGF="#D19570", C5_VenEC_HIF1A="#517188", C6_VenEC_CD74="#4B6C8B",
  C7_tEC_DOCK4="#A58882", "C8_emtEC_CD24+"="#8D6798", C9_emtEC_COL1A1="#6E6370",
  C10_nEC_IL6="#C88B68", C11_nEC_HMOX1="#D55635", C12_LEC_CCL21="#B14E53",
  C1_SMC_MYL9="#AA5244", C2_SMC_FN1="#B7987C", C3_SMC_MYH11="#DECCD8",
  C4_tPC_COL3A1="#D39CBB", C5_tPC_CCL19="#C9B2C5", C6_tPC_CD74="#E0B483",
  C7_tPC_SEPT7="#A66155", C8_tPC_PRKG1="#D19855", C9_nPC_CXCL8="#60A274",
  C10_nPC_GJA5="#C7D4A6"
)

subclusters <- unique(df$subcluster)
pal <- setNames(rep(NA_character_, length(subclusters)), subclusters)
matched_k <- subclusters %in% names(known_pal)
pal[matched_k] <- known_pal[subclusters[matched_k]]
if (any(!matched_k)) {
  unmatched <- subclusters[!matched_k]
  base_ext <- grDevices::colorRampPalette(c(
    RColorBrewer::brewer.pal(12, "Paired"),
    RColorBrewer::brewer.pal(8, "Set2")
  ))(length(unmatched))
  pal[!matched_k] <- base_ext
}

hull_col <- if (!is.null(style$hull_color)) as.character(style$hull_color) else "#D63A2F"
hull_lw <- if (!is.null(style$hull_linewidth)) as.numeric(style$hull_linewidth) else 0.36
dot_sz <- if (!is.null(style$dot_size)) as.numeric(style$dot_size) else 0.85
leg_cols <- if (is.null(style$legend_cols)) 4L else as.integer(style$legend_cols)
show_hulls <- if (is.null(style$show_hulls)) TRUE else isTRUE(style$show_hulls)
show_centroids <- if (is.null(style$show_centroids)) TRUE else isTRUE(style$show_centroids)

halo_text <- function(d, size = 2.6, colour = "#222222", offset = 0.8) {
  dirs <- seq(0, 2 * pi, length.out = 9L)[1:8]
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

build_comp_plot <- function(sub_df, comp_title, show_title = TRUE) {
  comp_subs <- unique(sub_df$subcluster)
  set.seed(42)
  df_plot <- sub_df[sample.int(nrow(sub_df)), , drop = FALSE]
  dx <- diff(range(sub_df$x)); dy <- diff(range(sub_df$y))
  span <- max(dx, dy, 1e-4)

  p <- ggplot(df_plot, aes(x = x, y = y, colour = subcluster)) +
    geom_point(size = dot_sz * 1.42, stroke = 0, alpha = 0.94) +
    scale_colour_manual(values = pal[comp_subs], guide = "none") +
    coord_equal(clip = "off") +
    theme_void(base_size = 8.5) +
    theme(plot.margin = margin(4, 6, 4, 6))
  if (show_title) {
    p <- p + labs(title = comp_title) +
      theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 9.5, margin = margin(b = 2)))
  }

  if (show_hulls && has_fg) {
    fgs <- unique(sub_df$functional_group)
    comp_mid <- colMeans(sub_df[, c("x", "y"), drop = FALSE])
    hull_list <- list()
    fg_lbls <- list()
    for (i in seq_along(fgs)) {
      fg <- fgs[i]
      pts <- sub_df[sub_df$functional_group == fg, c("x", "y"), drop = FALSE]
      if (nrow(pts) < 6L) next
      mid <- colMeans(pts)
      dist <- sqrt(rowSums(sweep(as.matrix(pts), 2L, mid)^2))
      pts <- pts[dist <= stats::quantile(dist, 0.96, names = FALSE), , drop = FALSE]
      if (nrow(pts) < 4L) next
      h <- grDevices::chull(pts)
      scaled <- 1.075 * sweep(as.matrix(pts[h, , drop = FALSE]), 2L, mid)
      scaled <- sweep(scaled, 2L, mid, "+")
      closed <- rbind(scaled, scaled[1L, ])
      bx <- stats::spline(seq_len(nrow(closed)), closed[, 1L], n = 120L, method = "periodic")$y
      by <- stats::spline(seq_len(nrow(closed)), closed[, 2L], n = 120L, method = "periodic")$y
      hull_list[[length(hull_list) + 1L]] <- data.frame(x = bx, y = by, grp = i)
      # Place functional label outward along radial direction from compartment center
      vec <- mid - comp_mid
      vnorm <- sqrt(sum(vec^2))
      if (vnorm < 1e-4) {
        lx <- mid[1L]; ly <- max(by) + 0.02 * span
      } else {
        uvec <- vec / vnorm
        proj <- (bx - mid[1L]) * uvec[1L] + (by - mid[2L]) * uvec[2L]
        idx_out <- which.max(proj)
        lx <- bx[idx_out] + 0.022 * span * uvec[1L]
        ly <- by[idx_out] + 0.022 * span * uvec[2L]
      }
      fg_lbls[[length(fg_lbls) + 1L]] <- data.frame(x = lx, y = ly, label = fg)
    }
    if (length(hull_list) > 0L) {
      hulls <- do.call(rbind, hull_list)
      fg_df <- do.call(rbind, fg_lbls)
      p <- p +
        geom_polygon(data = hulls, aes(x = x, y = y, group = grp), inherit.aes = FALSE,
                     colour = hull_col, fill = NA, linetype = "dashed", linewidth = hull_lw) +
        halo_text(fg_df, size = 2.55, colour = hull_col, offset = 0.005 * span)
    }
  }

  if (show_centroids) {
    cent <- do.call(rbind, lapply(seq_along(comp_subs), function(i) {
      s <- sub_df[sub_df$subcluster == comp_subs[i], , drop = FALSE]
      data.frame(x = stats::median(s$x), y = stats::median(s$y), label = as.character(i), stringsAsFactors = FALSE)
    }))
    p <- p + halo_text(cent, size = 2.75, colour = "#222222", offset = 0.005 * span)
  }
  p
}

if (length(compartments) > 1L) {
  comp_plots <- lapply(compartments, function(cp) {
    build_comp_plot(df[df$compartment == cp, , drop = FALSE], cp, show_title = TRUE)
  })
  top_p <- patchwork::wrap_plots(comp_plots, nrow = 1L)
} else {
  top_p <- build_comp_plot(df, compartments[1L], show_title = FALSE)
}

# Build multi-column dot legend grouped by compartment (or functional_group)
item_rows <- list()
grp_col <- if (length(compartments) > 1L) "compartment" else "functional_group"
for (grp_val in unique(df[[grp_col]])) {
  item_rows[[length(item_rows) + 1L]] <- data.frame(label = grp_val, ink = NA_character_, is_hdr = TRUE, stringsAsFactors = FALSE)
  subs <- unique(df$subcluster[df[[grp_col]] == grp_val])
  for (sb in subs) {
    item_rows[[length(item_rows) + 1L]] <- data.frame(label = sb, ink = unname(pal[sb]), is_hdr = FALSE, stringsAsFactors = FALSE)
  }
}
leg_df <- do.call(rbind, item_rows)
n_items <- nrow(leg_df)
n_rows <- ceiling(n_items / leg_cols)
leg_df$col <- (seq_len(n_items) - 1L) %/% n_rows
leg_df$row <- n_rows - (seq_len(n_items) - 1L) %% n_rows

leg_p <- ggplot(leg_df, aes(x = col, y = row)) +
  geom_point(data = leg_df[!leg_df$is_hdr, , drop = FALSE], aes(colour = ink), size = 3.0) +
  geom_text(aes(x = col + ifelse(is_hdr, 0.0, 0.07), label = label,
                fontface = ifelse(is_hdr, "bold", "plain")),
            hjust = 0, size = 2.95, colour = "#1F1F1F") +
  scale_colour_identity() +
  coord_cartesian(xlim = c(-0.08, leg_cols - 0.04), ylim = c(0.4, n_rows + 0.6), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.margin = margin(2, 8, 4, 10))

leg_h_frac <- min(0.40, max(0.18, n_rows * 0.032))
combined <- patchwork::wrap_plots(top_p, leg_p, ncol = 1L, heights = c(1 - leg_h_frac, leg_h_frac))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 9.6
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 6.2
dpi_val <- if (is.null(style$dpi)) 300L else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
