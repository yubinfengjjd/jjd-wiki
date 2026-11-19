# Multi-Source Study Workflow & Cohort Schematic Renderer
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

steps_file <- if (!is.null(spec$tables$steps$filename)) spec$tables$steps$filename else "workflow_steps.csv"
cohorts_file <- if (!is.null(spec$tables$cohorts$filename)) spec$tables$cohorts$filename else "workflow_cohorts.csv"

steps <- readr::read_csv(file.path(data_dir, steps_file), show_col_types = FALSE) %>%
  dplyr::mutate(
    branch = as.character(branch),
    step_order = as.numeric(step_order),
    label = gsub("\\\\n", "\n", as.character(label))
  ) %>%
  dplyr::arrange(branch, step_order)

if (!"arrow_style" %in% names(steps)) steps$arrow_style <- "solid"
if (!"box_fill" %in% names(steps)) steps$box_fill <- NA_character_

cohorts <- readr::read_csv(file.path(data_dir, cohorts_file), show_col_types = FALSE) %>%
  dplyr::mutate(
    branch = as.character(branch),
    cohort = as.character(cohort),
    n_samples = as.numeric(n_samples)
  )
if (!"origin" %in% names(cohorts)) cohorts$origin <- "public"

branches <- unique(c(steps$branch, cohorts$branch))
nb <- length(branches)
branch_y <- setNames(seq(from = 30, to = if (nb == 1) 30 else 11, length.out = nb), branches)

default_fills <- c("#D6B7CF", "#BBBBBB", "#C2CBD8", "#A6BAD0", "#CBE0D2")
inhouse_col <- if (!is.null(style$inhouse_color)) style$inhouse_color else "#4FB3C8"
public_col <- if (!is.null(style$public_color)) style$public_color else "#B5B2AF"
tissue_fill <- if (!is.null(style$tissue_fill)) style$tissue_fill else "#F6E5BB"
tissue_border <- if (!is.null(style$tissue_border)) style$tissue_border else "#B18470"
nodule_fill <- if (!is.null(style$nodule_fill)) style$nodule_fill else "#AB5141"
nodule_border <- if (!is.null(style$nodule_border)) style$nodule_border else "#982723"
show_pie <- if (is.null(style$show_source_pie)) TRUE else isTRUE(style$show_source_pie)

# Stylized tissue / sample collection icon on left
tissue_shape <- data.frame(
  x = c(2, 12, 13, 18, 21.5, 20.5, 18.5, 17, 12.5, 9, 7, 5),
  y = c(33, 33, 26, 22, 16, 12, 9, 6.5, 7.5, 5, 14, 25)
)
mass_shape <- data.frame(
  x = c(3.3, 5.1, 6.8, 7.8, 7.2, 8.6, 8, 6.5, 5.6),
  y = c(32.8, 32.8, 23, 16, 11, 5.5, 4.8, 12.5, 21.8)
)
nodule_shape <- data.frame(
  x = c(13.9, 16.1, 17.7, 17, 15.2, 13.2, 12.3),
  y = c(19.6, 19, 16.5, 14.6, 13.9, 15, 17.8)
)

p <- ggplot() +
  geom_polygon(data = tissue_shape, aes(x, y), fill = tissue_fill, colour = tissue_border, linewidth = 0.55) +
  geom_polygon(data = mass_shape, aes(x, y), fill = "#AA7875", colour = "#9E6664", linewidth = 0.28) +
  geom_polygon(data = nodule_shape, aes(x, y), fill = nodule_fill, colour = nodule_border, linewidth = 0.50) +
  annotate("curve", x = c(13.5, 14, 15.8, 16.4, 15, 16.4), y = c(16, 17, 17, 16.9, 15.6, 15.8),
           xend = c(10.7, 10.8, 15, 19.5, 18.5, 20.5), yend = c(13, 24.8, 23.5, 21, 11.5, 17),
           curvature = 0.32, colour = c("#AB241D", "#487F57", "#487F57", "#AB241D", "#AB241D", "#AB241D"),
           linewidth = 0.58)

if (show_pie) {
  total_n <- sum(cohorts$n_samples, na.rm = TRUE)
  in_n <- sum(cohorts$n_samples[tolower(cohorts$origin) == "in-house"], na.rm = TRUE)
  frac <- if (total_n > 0) in_n / total_n else 0.2
  if (frac > 0 && frac < 1) {
    th1 <- seq(0, frac * 2 * pi, length.out = 60)
    th2 <- seq(frac * 2 * pi, 2 * pi, length.out = 120)
    p <- p +
      geom_polygon(data = data.frame(x = 15.2 + c(0, 4.8 * sin(th2)), y = 5.4 + c(0, 4.8 * cos(th2))),
                   aes(x, y), fill = public_col, colour = "#65615C", linewidth = 0.22) +
      geom_polygon(data = data.frame(x = 15.2 + c(0, 4.8 * sin(th1)), y = 5.4 + c(0, 4.8 * cos(th1))),
                   aes(x, y), fill = inhouse_col, colour = "#65615C", linewidth = 0.22) +
      annotate("text", x = c(19.5, 9.8), y = c(9.4, 3.0),
               label = c(sprintf("In-house\n%.1f%%", 100 * frac), "Public data"),
               size = 2.4, hjust = c(0, 1), fontface = "bold", colour = "#222222")
  }
}

# Middle workflow branches
max_steps <- max(as.integer(tapply(steps$step_order, steps$branch, length)), 1L)
x_start <- 26.0
x_end <- 62.5
step_xs <- if (max_steps == 1L) (x_start + x_end) / 2 else seq(x_start, x_end, length.out = max_steps)

for (b in branches) {
  yb <- branch_y[[b]]
  sb <- steps[steps$branch == b, ]
  sb <- sb[order(sb$step_order), ]
  k <- nrow(sb)
  if (k == 0) next
  xs <- if (k == 1L) step_xs[1] else seq(x_start, x_end, length.out = k)
  bw <- min(3.4, (x_end - x_start) / max(k, 2) * 0.42)
  bh <- 3.6
  # Connector from origin tissue
  lt0 <- ifelse(tolower(sb$arrow_style[1]) == "dashed", "dashed", "solid")
  p <- p + annotate("segment", x = 21.0, y = yb, xend = xs[1] - bw - 0.5, yend = yb,
                    colour = ifelse(lt0 == "dashed", "#888888", "#181818"),
                    linetype = lt0, linewidth = 0.48,
                    arrow = grid::arrow(type = "closed", length = grid::unit(1.4, "mm")))
  for (j in seq_len(k)) {
    fill_j <- if (!is.na(sb$box_fill[j]) && nzchar(sb$box_fill[j])) sb$box_fill[j] else default_fills[(j - 1L) %% length(default_fills) + 1L]
    p <- p +
      annotate("rect", xmin = xs[j] - bw, xmax = xs[j] + bw, ymin = yb - bh, ymax = yb + bh,
               fill = fill_j, colour = "#5E5B63", linewidth = 0.32) +
      annotate("text", x = xs[j], y = yb - bh - 2.4, label = sb$label[j],
               size = 2.35, fontface = "bold", lineheight = 0.92, colour = "#1F1F1F")
    if (j > 1L) {
      lt <- ifelse(!is.na(sb$arrow_style[j]) && tolower(sb$arrow_style[j]) == "dashed", "dashed", "solid")
      p <- p + annotate("segment", x = xs[j - 1L] + bw + 0.4, y = yb, xend = xs[j] - bw - 0.4, yend = yb,
                        colour = ifelse(lt == "dashed", "#888888", "#181818"),
                        linetype = lt, linewidth = 0.48,
                        arrow = grid::arrow(type = "closed", length = grid::unit(1.4, "mm")))
    }
  }
}

# Right cohort summary dashed panels
panel_xmin <- 68.5
panel_xmax <- 97.5
box_h <- if (nb == 1) 24 else 14.2
for (i in seq_along(branches)) {
  b <- branches[i]
  yb <- branch_y[[b]]
  cb <- cohorts[cohorts$branch == b, ]
  ymin_b <- yb - box_h * 0.52
  ymax_b <- yb + box_h * 0.52
  in_tot <- sum(cb$n_samples[tolower(cb$origin) == "in-house"], na.rm = TRUE)
  pub_tot <- sum(cb$n_samples[tolower(cb$origin) != "in-house"], na.rm = TRUE)
  sub_txt <- sprintf("in-house (%d), public (%d)", in_tot, pub_tot)

  p <- p +
    annotate("rect", xmin = panel_xmin, xmax = panel_xmax, ymin = ymin_b, ymax = ymax_b,
             colour = "#9A9A9A", fill = "#FAFAFA", linetype = "dashed", linewidth = 0.35) +
    annotate("text", x = (panel_xmin + panel_xmax) / 2, y = ymax_b + 1.6,
             label = b, fontface = "bold", size = 3.2, colour = "#181818") +
    annotate("text", x = (panel_xmin + panel_xmax) / 2, y = ymax_b - 2.1,
             label = sub_txt, fontface = "bold", size = 2.4, colour = "#555555")
  if (nrow(cb) > 0) {
    nc <- nrow(cb)
    cols_n <- if (nc > 4) 2L else 1L
    rows_n <- ceiling(nc / cols_n)
    xs_c <- if (cols_n == 1L) rep((panel_xmin + panel_xmax) / 2, nc) else {
      ifelse(seq_len(nc) <= rows_n, panel_xmin + 7.2, panel_xmin + 21.3)
    }
    ys_c <- numeric(nc)
    for (col_i in seq_len(cols_n)) {
      idx <- which(if (cols_n == 1L) rep(TRUE, nc) else if (col_i == 1L) seq_len(nc) <= rows_n else seq_len(nc) > rows_n)
      ys_c[idx] <- seq(ymax_b - 4.7, ymin_b + 2.0, length.out = length(idx))
      if (length(idx) == 1L) ys_c[idx] <- (ymax_b - 4.2 + ymin_b + 1.8) / 2
    }
    lbls <- sprintf("%s (%d)", cb$cohort, cb$n_samples)
    cols_lbl <- ifelse(tolower(cb$origin) == "in-house", "#1B6B7A", "#242424")
    p <- p + annotate("text", x = xs_c, y = ys_c, label = lbls, size = 2.65, fontface = "bold", colour = cols_lbl)
  }
}

p <- p +
  coord_cartesian(xlim = c(0.5, 99.0), ylim = c(0.5, 39.5), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.margin = margin(6, 8, 6, 8))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 9.8
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 4.2
dpi_val <- if (is.null(style$dpi)) 300 else as.integer(style$dpi)

ggsave(file.path(out_dir, "figure.png"), p, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), p, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), p, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
