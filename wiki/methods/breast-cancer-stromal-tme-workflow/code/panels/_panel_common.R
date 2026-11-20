# Shared bootstrap for Cai et al. (2026) standalone panel CLI scripts
# Parses --paper-root and --out, loads ../00c_style_and_manifold.R, and provides save_panel().

parse_panel_args <- function(default_out = "panel.png", default_width = 5.5, default_height = 4.5, default_dpi = 300L) {
  args <- commandArgs(trailingOnly = TRUE)
  get_arg <- function(flag, default = NULL) {
    idx <- match(flag, args)
    if (is.na(idx) || idx >= length(args)) default else args[idx + 1L]
  }
  paper_root <- get_arg("--paper-root", Sys.getenv("PAPER_ROOT", "."))
  out_path <- get_arg("--out", default_out)
  width <- as.numeric(get_arg("--width", default_width))
  height <- as.numeric(get_arg("--height", default_height))
  dpi <- as.integer(get_arg("--dpi", default_dpi))
  list(
    paper_root = normalizePath(paper_root, winslash = "/", mustWork = FALSE),
    out = out_path,
    width = width,
    height = height,
    dpi = dpi
  )
}

get_script_dir <- function() {
  script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(script_arg) != 1L) {
    stop("Run this panel script with Rscript --vanilla <panel-script.R> --paper-root <DIR> --out <OUT.png>")
  }
  dirname(normalizePath(sub("^--file=", "", script_arg), winslash = "/", mustWork = FALSE))
}

init_panel_env <- function(default_out = "panel.png", default_width = 5.5, default_height = 4.5, default_dpi = 300L) {
  scp_lib <- "E:/research-wiki-env/R-lib-scp/4.5"
  if (dir.exists(scp_lib)) {
    .libPaths(unique(c(.libPaths(), scp_lib)))
  }
  cfg <- parse_panel_args(default_out, default_width, default_height, default_dpi)
  Sys.setenv(PAPER_ROOT = cfg$paper_root)
  panel_dir <- get_script_dir()
  style_file <- file.path(dirname(panel_dir), "00c_style_and_manifold.R")
  if (!file.exists(style_file)) {
    stop("Cannot locate shared style helper: ", style_file)
  }
  source(style_file, local = .GlobalEnv)
  cfg
}

save_panel <- function(plot_obj, out_path, width = 5.5, height = 4.5, dpi = 300L) {
  out_dir <- dirname(out_path)
  if (nzchar(out_dir) && out_dir != ".") {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  }
  ext <- tolower(tools::file_ext(out_path))
  if (ext == "pdf") {
    ggplot2::ggsave(out_path, plot_obj, width = width, height = height, device = grDevices::cairo_pdf, bg = "white")
  } else if (ext == "svg") {
    ggplot2::ggsave(out_path, plot_obj, width = width, height = height, device = grDevices::svg, bg = "white")
  } else {
    ggplot2::ggsave(out_path, plot_obj, width = width, height = height, dpi = dpi, bg = "white")
  }
  if (!file.exists(out_path) || file.info(out_path)$size <= 0) {
    stop("Failed to write non-empty output: ", out_path)
  }
  message("Saved panel to ", out_path, " (", file.info(out_path)$size, " bytes)")
  invisible(out_path)
}

panel_legend_bar <- function(palette, label, labels = c("Min", "Max"), vertical = FALSE, compact = FALSE) {
  colours <- grDevices::colorRampPalette(palette)(128)
  raster <- if (vertical) as.raster(matrix(rev(colours), ncol = 1)) else as.raster(matrix(colours, nrow = 1))
  if (vertical) {
    grid::grobTree(
      grid::textGrob(label, x = .5, y = .98, gp = grid::gpar(fontsize = 5)),
      grid::rasterGrob(raster, x = .27, y = .43, width = .25, height = .59, interpolate = FALSE),
      grid::textGrob(labels[2], x = .43, y = .70, just = "left", gp = grid::gpar(fontsize = 5)),
      grid::textGrob(labels[1], x = .43, y = .14, just = "left", gp = grid::gpar(fontsize = 5))
    )
  } else {
    ends <- if (compact) c(.81, .985) else c(.49, .97)
    grid::grobTree(
      grid::textGrob(label, x = ends[1] - .025, y = .61, just = "right", gp = grid::gpar(fontsize = 5.8)),
      grid::rasterGrob(raster, x = mean(ends), y = .61, width = diff(ends), height = .23, interpolate = FALSE),
      grid::textGrob(labels, x = ends, y = .19, gp = grid::gpar(fontsize = 5))
    )
  }
}

panel_tile_colours <- function(values, palette, limits) {
  values <- pmax(0, pmin(1, (values - limits[1]) / diff(limits)))
  grDevices::colorRampPalette(palette)(256)[1 + round(values * 255)]
}

panel_spot_grid <- function(d, side = 95L, square = TRUE) {
  xy <- cbind(x = d$imagecol, y = -d$imagerow)
  margin <- diff(range(xy[, 1])) * .01
  ranges <- apply(xy, 2, range)
  steps <- ranges[2, ] - ranges[1, ]
  dims <- if (square) rep(side, 2) else pmax(2, round(side * steps / max(steps)))
  grid <- expand.grid(
    x = seq(ranges[1, 1] - margin, ranges[2, 1] + margin, length.out = dims[1]),
    y = seq(ranges[1, 2] - margin, ranges[2, 2] + margin, length.out = dims[2])
  )
  local <- RANN::nn2(xy, k = 2)
  spacing <- stats::median(local$nn.dists[, 2])
  near <- RANN::nn2(xy, as.matrix(grid), k = 6)
  w <- exp(-.5 * (near$nn.dists / (.73 * spacing))^2)
  list(grid = grid, index = near$nn.idx, weight = w, inside = near$nn.dists[, 1] <= 1.21 * spacing)
}

panel_quantile01 <- function(x, p = c(.05, .95)) {
  bounds <- stats::quantile(x, p, na.rm = TRUE, names = FALSE)
  if (diff(bounds) < .Machine$double.eps) return(scale01(x))
  scales::squish(scales::rescale(x, from = bounds))
}
