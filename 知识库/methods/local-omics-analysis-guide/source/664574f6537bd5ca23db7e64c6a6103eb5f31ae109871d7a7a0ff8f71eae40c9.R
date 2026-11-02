find_repo_root <- function(start = getwd()) {
  cur <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    ok <- file.exists(file.path(cur, "scripts", "extract_style.py")) ||
      file.exists(file.path(cur, "code", "style", "FIGURE_SPEC_ST.yaml")) ||
      file.exists(file.path(cur, "code", "style", "FIGURE_SPEC.yaml")) ||
      file.exists(file.path(cur, "style", "FIGURE_SPEC_ST.yaml")) ||
      file.exists(file.path(cur, "style", "FIGURE_SPEC.yaml"))
    if (ok) return(cur)
    parent <- dirname(cur)
    if (identical(parent, cur)) break
    cur <- parent
  }
  normalizePath(start, winslash = "/", mustWork = FALSE)
}

get_style_spec_path <- function() {
  p <- Sys.getenv("UC20_FIGURE_SPEC", unset = "")
  if (nzchar(p) && file.exists(p)) return(normalizePath(p, winslash = "/", mustWork = FALSE))
  repo <- find_repo_root()
  cand <- c(
    file.path(repo, "code", "style", "FIGURE_SPEC_ST.yaml"),
    file.path(repo, "code", "style", "FIGURE_SPEC.yaml"),
    file.path(repo, "style", "FIGURE_SPEC_ST.yaml"),
    file.path(repo, "style", "FIGURE_SPEC.yaml")
  )
  for (x in cand) {
    if (file.exists(x)) return(normalizePath(x, winslash = "/", mustWork = FALSE))
  }
  NA_character_
}

read_figure_spec <- function(spec_path = NULL) {
  if (is.null(spec_path)) spec_path <- get_style_spec_path()
  if (is.na(spec_path) || !file.exists(spec_path)) {
    stop("FIGURE_SPEC not found; set UC20_FIGURE_SPEC or create style/FIGURE_SPEC_ST.yaml", call. = FALSE)
  }
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("R package 'yaml' is required", call. = FALSE)
  }
  spec <- yaml::read_yaml(spec_path)
  if (is.null(spec) || !is.list(spec)) stop("Failed to parse FIGURE_SPEC.yaml", call. = FALSE)
  spec
}

.spec_cache <- new.env(parent = emptyenv())
get_figure_spec <- function() {
  p <- get_style_spec_path()
  if (!exists("spec_path", envir = .spec_cache, inherits = FALSE) || !identical(get("spec_path", envir = .spec_cache), p)) {
    assign("spec", read_figure_spec(p), envir = .spec_cache)
    assign("spec_path", p, envir = .spec_cache)
  }
  get("spec", envir = .spec_cache)
}

.element_line_compat <- function(linewidth, colour = NULL, linetype = NULL) {
  fmls <- names(formals(ggplot2::element_line))
  if ("linewidth" %in% fmls) {
    return(ggplot2::element_line(linewidth = linewidth, colour = colour, linetype = linetype))
  }
  ggplot2::element_line(size = linewidth, colour = colour, linetype = linetype)
}

.element_rect_compat <- function(fill = NULL, colour = NULL, linewidth = NULL) {
  fmls <- names(formals(ggplot2::element_rect))
  if (!is.null(linewidth) && "linewidth" %in% fmls) {
    return(ggplot2::element_rect(fill = fill, colour = colour, linewidth = linewidth))
  }
  if (!is.null(linewidth) && "size" %in% fmls) {
    return(ggplot2::element_rect(fill = fill, colour = colour, size = linewidth))
  }
  ggplot2::element_rect(fill = fill, colour = colour)
}

.unit <- function(value, unit_name) {
  if (!requireNamespace("grid", quietly = TRUE)) stop("R package 'grid' is required", call. = FALSE)
  grid::unit(value, unit_name)
}

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) return(y)
  x
}

theme_paper <- function(base_size = 10.5, base_family = "Arial") {
  spec <- get_figure_spec()
  base_size <- spec$typography$base_size
  base_family <- spec$typography$font_family

  bg <- spec$canvas$background
  axis_lw <- spec$lines$axis_linewidth
  grid_lw <- spec$lines$grid_linewidth
  tick_len <- spec$lines$tick_length
  tick_dir <- spec$axes$tick_direction
  tick_len_signed <- if (!is.null(tick_dir) && tick_dir == "in") -tick_len else tick_len

  major_on <- isTRUE(spec$panel$grid_major)
  minor_on <- isTRUE(spec$panel$grid_minor)
  major_el <- if (major_on) .element_line_compat(linewidth = grid_lw, colour = "#DDDDDD") else ggplot2::element_blank()
  minor_el <- if (minor_on) .element_line_compat(linewidth = grid_lw * 0.7, colour = "#EEEEEE") else ggplot2::element_blank()

  remove_spines <- isTRUE(spec$axes$remove_top_right_spines)
  border_el <- if (remove_spines) ggplot2::element_blank() else .element_rect_compat(fill = NA, colour = "#000000", linewidth = axis_lw)

  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = .element_rect_compat(fill = bg, colour = NA),
      panel.background = .element_rect_compat(fill = bg, colour = NA),
      panel.border = border_el,
      panel.grid.major = major_el,
      panel.grid.minor = minor_el,
      axis.line = .element_line_compat(linewidth = axis_lw, colour = "#222222"),
      axis.title = ggplot2::element_text(size = spec$typography$axis_title_size, colour = "#222222"),
      axis.text = ggplot2::element_text(size = spec$typography$axis_text_size, colour = "#222222"),
      axis.ticks = .element_line_compat(linewidth = axis_lw, colour = "#222222"),
      axis.ticks.length = .unit(tick_len_signed, "pt"),
      legend.title = ggplot2::element_text(size = spec$typography$legend_text_size, face = "bold"),
      legend.text = ggplot2::element_text(size = spec$typography$legend_text_size),
      plot.title = ggplot2::element_text(face = "bold", hjust = 0, size = spec$typography$title_size),
      plot.subtitle = ggplot2::element_text(hjust = 0, colour = "#525252"),
      strip.background = .element_rect_compat(fill = "#F7F2EA", colour = NA),
      strip.text = ggplot2::element_text(face = "bold"),
      legend.position = spec$legend$position,
      legend.key.size = .unit(spec$legend$key_size, "pt"),
      legend.spacing = .unit(spec$legend$spacing, "pt"),
      legend.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      plot.title.position = "plot",
      plot.margin = ggplot2::margin(
        t = spec$panel$margin$t,
        r = spec$panel$margin$r,
        b = spec$panel$margin$b,
        l = spec$panel$margin$l,
        unit = spec$panel$margin$unit
      ),
      panel.spacing = .unit(spec$panel$panel_spacing, "pt")
    )
}

theme_spatial_paper <- function(base_size = 10.5, base_family = "Arial") {
  spec <- get_figure_spec()
  bg <- spec$spatial$panel_background %||% spec$canvas$background
  theme_paper(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = .element_rect_compat(fill = bg, colour = NA),
      panel.background = .element_rect_compat(fill = bg, colour = NA),
      plot.title = ggplot2::element_text(size = min(spec$typography$title_size %||% 11, 11), face = "bold", hjust = 0),
      legend.title = ggplot2::element_text(size = max(spec$typography$legend_text_size %||% 8.5, 9), face = "bold"),
      legend.text = ggplot2::element_text(size = max(spec$typography$legend_text_size %||% 8.5, 9))
    ) +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank()
    )
}

theme_heatmap_paper <- function(base_size = 10.5, base_family = "Arial") {
  theme_paper(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank()
    )
}

continuous_palette_paper <- function(palette = c("mako", "cividis", "viridis", "default")) {
  palette <- match.arg(palette)
  spec <- get_figure_spec()
  if (palette == "default") return(spec$palette$continuous_hex)
  if (!requireNamespace("viridisLite", quietly = TRUE)) {
    warning("Package 'viridisLite' not available; falling back to FIGURE_SPEC continuous palette.", call. = FALSE)
    return(spec$palette$continuous_hex)
  }
  if (identical(palette, "mako") && "mako" %in% getNamespaceExports("viridisLite")) {
    return(viridisLite::mako(8, begin = 0.06, end = 0.96))
  }
  option <- if (palette == "cividis") "C" else "D"
  viridisLite::viridis(8, option = option, begin = 0.06, end = 0.96)
}

guide_colorbar_paper <- function(barheight_pt = 42, barwidth_pt = 7.5, title.position = "top", ticks = TRUE) {
  ggplot2::guide_colorbar(
    barheight = .unit(barheight_pt, "pt"),
    barwidth = .unit(barwidth_pt, "pt"),
    title.position = title.position,
    ticks = ticks,
    ticks.colour = "#222222",
    frame.colour = "#222222"
  )
}

scale_continuous_paper <- function(limits = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver(), na.value = "#d9d9d9", palette = c("mako", "cividis", "viridis", "default")) {
  cols <- continuous_palette_paper(palette)
  ggplot2::scale_fill_gradientn(colours = cols, limits = limits, na.value = na.value, breaks = breaks, labels = labels)
}

scale_continuous_color_paper <- function(limits = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver(), na.value = "#d9d9d9", palette = c("mako", "cividis", "viridis", "default")) {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package 'scales' is required", call. = FALSE)
  cols <- continuous_palette_paper(palette)
  ggplot2::scale_colour_gradientn(colours = cols, limits = limits, na.value = na.value, oob = scales::squish, breaks = breaks, labels = labels)
}

scale_diverging_fill_paper <- function(limits = c(-1, 1), na.value = "#d9d9d9") {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package 'scales' is required", call. = FALSE)
  spec <- get_figure_spec()
  cols <- spec$palette$diverging_hex %||% rev(spec$palette$continuous_hex)
  ggplot2::scale_fill_gradientn(
    colours = cols,
    limits = limits,
    oob = scales::squish,
    na.value = na.value
  )
}

scale_diverging_color_paper <- function(limits = c(-1, 1), na.value = "#d9d9d9") {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package 'scales' is required", call. = FALSE)
  spec <- get_figure_spec()
  cols <- spec$palette$diverging_hex %||% rev(spec$palette$continuous_hex)
  ggplot2::scale_colour_gradientn(
    colours = cols,
    limits = limits,
    oob = scales::squish,
    na.value = na.value
  )
}

scale_sig_fill_paper <- function(limits = NULL, na.value = "#d9d9d9") {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package 'scales' is required", call. = FALSE)
  spec <- get_figure_spec()
  cols <- spec$palette$continuous_hex
  warm <- cols[seq_len(min(5, length(cols)))]
  ggplot2::scale_fill_gradientn(
    colours = warm,
    limits = limits,
    oob = scales::squish,
    na.value = na.value
  )
}

scale_discrete_fill_paper <- function(limits = NULL) {
  spec <- get_figure_spec()
  vals <- spec$palette$categorical_hex
  ggplot2::scale_fill_manual(values = vals, limits = limits, drop = FALSE)
}

scale_discrete_color_paper <- function(limits = NULL) {
  spec <- get_figure_spec()
  vals <- spec$palette$categorical_hex
  ggplot2::scale_colour_manual(values = vals, limits = limits, drop = FALSE)
}

label_wrap_paper <- function(width = 32) {
  force(width)
  function(x) vapply(as.character(x), function(val) paste(strwrap(val, width = width), collapse = "\n"), character(1))
}

parse_ratio_to_numeric <- function(x) {
  x <- as.character(x)
  out <- suppressWarnings(as.numeric(x))
  idx <- is.na(out) & grepl("/", x, fixed = TRUE)
  if (any(idx)) {
    out[idx] <- vapply(strsplit(x[idx], "/", fixed = TRUE), function(parts) {
      if (length(parts) != 2L) return(NA_real_)
      num <- suppressWarnings(as.numeric(parts[[1]]))
      den <- suppressWarnings(as.numeric(parts[[2]]))
      if (!is.finite(num) || !is.finite(den) || den == 0) return(NA_real_)
      num / den
    }, numeric(1))
  }
  out
}

# Keep bubble legends readable by collapsing continuous sizes into a few stable breaks.
summary_breaks_paper <- function(x, n = 4L) {
  x <- x[is.finite(x) & x > 0]
  if (!length(x)) return(NULL)
  br <- unique(pretty(c(0, max(x, na.rm = TRUE)), n = n))
  br <- br[is.finite(br) & br > 0]
  if (length(br) < 3L && length(unique(x)) >= 3L) {
    br <- unique(as.numeric(stats::quantile(x, probs = seq(0.25, 1, length.out = min(4L, length(unique(x)))), na.rm = TRUE, names = FALSE, type = 7)))
  }
  if (length(br) > n) {
    idx <- unique(round(seq(1, length(br), length.out = n)))
    br <- br[idx]
  }
  signif(br, 2)
}

guide_legend_paper <- function(title.position = "top", override.aes = list(), nrow = NULL) {
  ggplot2::guide_legend(
    title.position = title.position,
    nrow = nrow,
    byrow = !is.null(nrow),
    override.aes = override.aes,
    keyheight = .unit(10, "pt"),
    keywidth = .unit(10, "pt")
  )
}

scale_size_summary_paper <- function(values, name = ggplot2::waiver(), max_size = 8.6, n_breaks = 4L, limits = NULL, labels = ggplot2::waiver()) {
  finite_vals <- values[is.finite(values)]
  if (is.null(limits)) {
    upper <- if (length(finite_vals)) max(finite_vals, na.rm = TRUE) else 1
    if (!is.finite(upper) || upper <= 0) upper <- 1
    limits <- c(0, upper)
  }
  ggplot2::scale_size_area(
    max_size = max_size,
    breaks = summary_breaks_paper(finite_vals, n = n_breaks),
    limits = limits,
    labels = labels,
    name = name
  )
}

plot_guard <- function(plot_obj = NULL, plot_list = NULL, reason = "Unknown") {
  if (!is.null(plot_obj)) return(invisible(TRUE))
  if (is.null(plot_list) || length(plot_list) == 0) {
    stop(paste0("No plots generated: ", reason), call. = FALSE)
  }
  if (all(vapply(plot_list, is.null, logical(1)))) {
    stop(paste0("No plots generated: ", reason), call. = FALSE)
  }
  invisible(TRUE)
}

save_figure <- function(plot_obj, out_prefix, width = 7, height = 5, dpi = 600, bg = "white") {
  plot_guard(plot_obj = plot_obj, reason = paste0("save_figure failed for ", out_prefix))
  dir.create(dirname(out_prefix), recursive = TRUE, showWarnings = FALSE)

  pdf_file <- paste0(out_prefix, ".pdf")
  png_file <- paste0(out_prefix, ".png")

  pdf_dev <- if (isTRUE(capabilities("cairo"))) grDevices::cairo_pdf else grDevices::pdf
  if (identical(pdf_dev, grDevices::pdf)) {
    suppressWarnings(ggplot2::ggsave(
      filename = pdf_file,
      plot = plot_obj,
      device = pdf_dev,
      width = width,
      height = height,
      units = "in",
      dpi = 300,
      bg = bg,
      useDingbats = FALSE
    ))
  } else {
    suppressWarnings(ggplot2::ggsave(
      filename = pdf_file,
      plot = plot_obj,
      device = pdf_dev,
      width = width,
      height = height,
      units = "in",
      dpi = 300,
      bg = bg
    ))
  }

  suppressWarnings(ggplot2::ggsave(
    filename = png_file,
    plot = plot_obj,
    width = width,
    height = height,
    units = "in",
    dpi = dpi,
    bg = bg
  ))

  invisible(list(pdf = pdf_file, png = png_file))
}

save_panel_pdf <- function(plot_obj, out_file, width = NULL, height = NULL, bg = NULL) {
  plot_guard(plot_obj = plot_obj, reason = paste0("save_panel_pdf failed for ", out_file))
  spec <- get_figure_spec()
  if (is.null(width)) width <- spec$canvas$width
  if (is.null(height)) height <- spec$canvas$height
  if (is.null(bg)) bg <- spec$canvas$background
  dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
  pdf_dev <- grDevices::pdf
  if (isTRUE(spec$export$pdf_embed_fonts) && isTRUE(capabilities("cairo"))) {
    pdf_dev <- grDevices::cairo_pdf
  }
  if (identical(pdf_dev, grDevices::pdf)) {
    suppressWarnings(ggplot2::ggsave(
      filename = out_file,
      plot = plot_obj,
      device = pdf_dev,
      width = width,
      height = height,
      units = "in",
      dpi = 300,
      bg = bg,
      useDingbats = FALSE
    ))
  } else {
    suppressWarnings(ggplot2::ggsave(
      filename = out_file,
      plot = plot_obj,
      device = pdf_dev,
      width = width,
      height = height,
      units = "in",
      dpi = 300,
      bg = bg
    ))
  }
  invisible(out_file)
}

save_complexheatmap_pdf <- function(ht, out_file, width = NULL, height = NULL, bg = NULL) {
  if (!requireNamespace("ComplexHeatmap", quietly = TRUE)) stop("R package 'ComplexHeatmap' is required", call. = FALSE)
  if (!requireNamespace("grid", quietly = TRUE)) stop("R package 'grid' is required", call. = FALSE)
  spec <- get_figure_spec()
  if (is.null(width)) width <- spec$canvas$width
  if (is.null(height)) height <- spec$canvas$height
  if (is.null(bg)) bg <- spec$canvas$background

  dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
  pdf_dev <- grDevices::pdf
  if (isTRUE(spec$export$pdf_embed_fonts) && isTRUE(capabilities("cairo"))) {
    pdf_dev <- grDevices::cairo_pdf
  }
  pdf_dev(file = out_file, width = width, height = height, bg = bg)
  grid::grid.newpage()
  ComplexHeatmap::draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right")
  grDevices::dev.off()
  invisible(out_file)
}

complex_heatmap_defaults <- function(mat,
                                     title = NULL,
                                     legend_title = "Score",
                                     palette = c("continuous", "diverging"),
                                     limits = NULL,
                                     cluster_rows = TRUE,
                                     cluster_columns = TRUE,
                                     show_row_names = TRUE,
                                     show_column_names = TRUE,
                                     gap_mm = 0.9) {
  if (!requireNamespace("ComplexHeatmap", quietly = TRUE)) stop("R package 'ComplexHeatmap' is required", call. = FALSE)
  if (!requireNamespace("circlize", quietly = TRUE)) stop("R package 'circlize' is required", call. = FALSE)
  if (!requireNamespace("grid", quietly = TRUE)) stop("R package 'grid' is required", call. = FALSE)

  palette <- match.arg(palette)
  spec <- get_figure_spec()
  cols <- if (palette == "diverging") (spec$palette$diverging_hex %||% spec$palette$continuous_hex) else spec$palette$continuous_hex

  mat <- as.matrix(mat)
  if (!is.numeric(mat)) storage.mode(mat) <- "numeric"
  if (is.null(limits)) {
    if (palette == "diverging") {
      vmax <- suppressWarnings(max(abs(mat), na.rm = TRUE))
      if (!is.finite(vmax) || vmax <= 0) vmax <- 1
      rng <- c(-vmax, vmax)
    } else {
      rng <- range(mat, finite = TRUE, na.rm = TRUE)
    }
  } else {
    rng <- as.numeric(limits)
  }
  if (!all(is.finite(rng)) || length(rng) != 2 || rng[1] == rng[2]) rng <- if (palette == "diverging") c(-1, 1) else c(0, 1)

  brks <- seq(rng[1], rng[2], length.out = max(2, length(cols)))
  col_fun <- circlize::colorRamp2(brks, cols)

  row_sd <- suppressWarnings(apply(mat, 1, stats::sd, na.rm = TRUE))
  col_sd <- suppressWarnings(apply(mat, 2, stats::sd, na.rm = TRUE))
  cluster_rows <- isTRUE(cluster_rows) && nrow(mat) > 2 && any(is.finite(row_sd) & row_sd > 0)
  cluster_columns <- isTRUE(cluster_columns) && ncol(mat) > 2 && any(is.finite(col_sd) & col_sd > 0)

  ComplexHeatmap::Heatmap(
    mat,
    name = legend_title,
    col = col_fun,
    cluster_rows = cluster_rows,
    cluster_columns = cluster_columns,
    show_row_names = show_row_names,
    show_column_names = show_column_names,
    show_row_dend = FALSE,
    show_column_dend = FALSE,
    column_title = title %||% "",
    column_title_gp = grid::gpar(fontface = "bold", fontsize = spec$typography$title_size),
    row_names_gp = grid::gpar(fontsize = spec$typography$axis_text_size),
    column_names_gp = grid::gpar(fontsize = spec$typography$axis_text_size),
    column_names_rot = 45,
    column_names_centered = FALSE,
    row_names_max_width = grid::unit(52, "mm"),
    rect_gp = grid::gpar(col = "#E6E1D7", lwd = 0.45),
    border = FALSE,
    column_gap = grid::unit(max(gap_mm, 1.2), "mm"),
    row_gap = grid::unit(max(gap_mm, 1.0), "mm"),
    heatmap_legend_param = list(
      title_gp = grid::gpar(fontface = "bold", fontsize = spec$typography$legend_text_size),
      labels_gp = grid::gpar(fontsize = spec$typography$legend_text_size),
      legend_height = grid::unit(42, "mm"),
      border = NA
    )
  )
}

panel_output_root <- function(cfg, phase_id) {
  out_root <- NULL
  if (!is.null(cfg$output_dir) && !is.null(cfg$output_dir$panel_outputs)) {
    out_root <- cfg$output_dir$panel_outputs
  }
  if (is.null(out_root) || identical(out_root, "") || is.na(out_root)) {
    base <- cfg$base_dir
    if (is.null(base) || identical(base, "") || is.na(base)) {
      base <- getwd()
    }
    out_root <- file.path(base, "panel_outputs")
  }
  normalizePath(file.path(out_root, phase_id), winslash = "/", mustWork = FALSE)
}

panel_label <- function(...) {
  p <- patchwork::wrap_plots(...)
  p + patchwork::plot_annotation(tag_levels = "A", tag_suffix = ")")
}

qc_feature_labels <- function(feature_names, feature_labels = NULL) {
  out <- stats::setNames(as.list(feature_names), feature_names)
  if (!is.null(feature_labels)) {
    overlap <- intersect(feature_names, names(feature_labels))
    out[overlap] <- as.list(unname(feature_labels[overlap]))
  }
  out
}

qc_feature_param <- function(value, feature_names) {
  if (is.list(value) && !is.null(names(value))) {
    out <- stats::setNames(vector("list", length(feature_names)), feature_names)
    for (nm in intersect(feature_names, names(value))) out[[nm]] <- value[[nm]]
    return(out)
  }
  stats::setNames(rep(list(value), length(feature_names)), feature_names)
}

qc_panel_annotation <- function(title = NULL) {
  if (is.null(title) || !nzchar(title)) return(NULL)
  spec <- get_figure_spec()
  qc <- spec$qc %||% list()
  patchwork::plot_annotation(
    title = title,
    theme = ggplot2::theme(
      plot.title = ggplot2::element_text(
        size = qc$title_size %||% spec$typography$title_size,
        family = spec$typography$font_family,
        face = "bold",
        hjust = 0
      )
    )
  )
}

wrap_qc_panel <- function(plot_list, title = NULL, ncol = NULL) {
  plot_guard(plot_list = plot_list, reason = "QC panel assembly failed")
  if (is.null(ncol)) ncol <- length(plot_list)
  out <- patchwork::wrap_plots(plot_list, ncol = max(1, ncol))
  annot <- qc_panel_annotation(title)
  if (!is.null(annot)) out <- out + annot
  out
}
theme_qc_spatial_paper <- function(background = NULL) {
  spec <- get_figure_spec()
  qc <- spec$qc %||% list()
  bg <- background %||% qc$spatial_background %||% spec$spatial$panel_background %||% spec$canvas$background
  theme_spatial_paper() +
    ggplot2::theme(
      plot.background = .element_rect_compat(fill = bg, colour = NA),
      panel.background = .element_rect_compat(fill = bg, colour = NA),
      plot.title = ggplot2::element_text(size = qc$title_size %||% spec$typography$title_size, face = "bold", hjust = 0),
      legend.title = ggplot2::element_text(size = qc$legend_text_size %||% spec$typography$legend_text_size, face = "bold"),
      legend.text = ggplot2::element_text(size = qc$legend_text_size %||% spec$typography$legend_text_size),
      panel.spacing = .unit(max(spec$panel$panel_spacing, 5), "pt")
    )
}

theme_qc_violin_paper <- function(single_group = FALSE) {
  spec <- get_figure_spec()
  qc <- spec$qc %||% list()
  x_text_colour <- if (single_group) "#B0B0B0" else "#4A4A4A"
  theme_paper() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = qc$title_size %||% spec$typography$title_size, face = "bold", hjust = 0),
      axis.title = ggplot2::element_text(size = qc$axis_title_size %||% spec$typography$axis_title_size, colour = "#222222"),
      axis.text = ggplot2::element_text(size = qc$axis_text_size %||% spec$typography$axis_text_size, colour = "#333333"),
      axis.text.x = ggplot2::element_text(size = qc$axis_text_size %||% spec$typography$axis_text_size, colour = x_text_colour, face = if (single_group) "plain" else "bold"),
      axis.title.x = ggplot2::element_blank(),
      axis.ticks.x = if (single_group) ggplot2::element_blank() else .element_line_compat(linewidth = spec$lines$axis_linewidth, colour = "#222222"),
      legend.position = "none",
      panel.spacing = .unit(max(spec$panel$panel_spacing, 5), "pt")
    )
}

style_qc_violin <- function(plot_obj, y_label = NULL, title = NULL) {
  spec <- get_figure_spec()
  qc <- spec$qc %||% list()
  ident_vals <- as.character(plot_obj$data$ident %||% character())
  single_group <- length(unique(ident_vals)) <= 1
  id_levels <- unique(ident_vals)
  if (length(id_levels) == 0) id_levels <- ""

  violin_idx <- which(vapply(plot_obj$layers, function(layer) inherits(layer$geom, "GeomViolin"), logical(1)))
  point_idx <- which(vapply(plot_obj$layers, function(layer) inherits(layer$geom, "GeomPoint"), logical(1)))

  if (length(violin_idx) > 0) {
    for (idx in violin_idx) {
      plot_obj$layers[[idx]]$aes_params$alpha <- 0.96
      plot_obj$layers[[idx]]$aes_params$colour <- qc$violin_line %||% "#33424D"
      plot_obj$layers[[idx]]$aes_params$linewidth <- 0.35
    }
  }
  if (length(point_idx) > 0) {
    for (idx in point_idx) {
      plot_obj$layers[[idx]]$aes_params$alpha <- qc$violin_point_alpha %||% 0.18
      plot_obj$layers[[idx]]$aes_params$size <- qc$violin_point_size %||% 0.18
      plot_obj$layers[[idx]]$aes_params$colour <- qc$violin_point %||% "#202830"
      if (!is.null(plot_obj$layers[[idx]]$position) && !is.null(plot_obj$layers[[idx]]$position$width)) {
        plot_obj$layers[[idx]]$position$width <- 0.14
      }
    }
  }

  out <- plot_obj +
    ggplot2::scale_fill_manual(values = stats::setNames(rep(qc$violin_fill %||% "#6F8799", length(id_levels)), id_levels), guide = "none") +
    ggplot2::geom_boxplot(
      width = qc$violin_box_width %||% 0.16,
      outlier.shape = NA,
      fill = "#FFFFFFD9",
      colour = qc$violin_line %||% "#33424D",
      linewidth = 0.32
    ) +
    ggplot2::labs(
      x = NULL,
      y = y_label %||% plot_obj$labels$y %||% "",
      title = title %||% plot_obj$labels$title %||% ""
    ) +
    theme_qc_violin_paper(single_group = single_group)

  if (single_group) {
    out <- out + ggplot2::scale_x_discrete(labels = function(x) rep("", length(x)))
  }
  out
}

build_qc_violin_panel <- function(plot_list, feature_names, feature_labels = NULL, title = NULL, ncol = NULL) {
  label_map <- qc_feature_labels(feature_names, feature_labels)
  styled <- Map(
    f = function(plot_obj, feature_name) {
      style_qc_violin(
        plot_obj,
        y_label = label_map[[feature_name]],
        title = label_map[[feature_name]]
      )
    },
    plot_obj = plot_list,
    feature_name = feature_names
  )
  wrap_qc_panel(styled, title = title, ncol = ncol %||% length(feature_names))
}

plot_spatial_continuous_df <- function(df, title, legend_title = NULL, limits = NULL, palette = c("mako", "cividis", "viridis", "default"), theme_variant = c("default", "qc"), background = NULL, point_size = NULL, point_alpha = 0.96, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver()) {
  palette <- match.arg(palette)
  theme_variant <- match.arg(theme_variant)
  spec <- get_figure_spec()
  qc <- spec$qc %||% list()
  if (is.null(limits)) {
    rng <- stats::quantile(df$value, probs = c(0.03, 0.97), na.rm = TRUE, names = FALSE, type = 7)
    if (all(is.finite(rng)) && diff(rng) > 0) limits <- rng
  }
  if (is.null(point_size)) {
    point_size <- if (theme_variant == "qc") qc$spatial_spot_size_factor %||% 2.45 else 2.05
  }
  if (is.null(legend_barheight_pt)) {
    legend_barheight_pt <- if (theme_variant == "qc") qc$spatial_legend_barheight_pt %||% 34 else 34
  }
  if (is.null(legend_barwidth_pt)) {
    legend_barwidth_pt <- if (theme_variant == "qc") qc$spatial_legend_barwidth_pt %||% 7.5 else 8
  }
  base_theme <- if (theme_variant == "qc") theme_qc_spatial_paper(background = background) else theme_spatial_paper()
  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, colour = value)) +
    ggplot2::geom_point(size = point_size, alpha = point_alpha, stroke = 0, shape = 16) +
    ggplot2::scale_y_reverse() +
    ggplot2::coord_fixed() +
    scale_continuous_color_paper(limits = limits, palette = palette, breaks = breaks, labels = labels) +
    ggplot2::labs(title = title, colour = legend_title %||% "") +
    ggplot2::guides(colour = guide_colorbar_paper(barheight_pt = legend_barheight_pt, barwidth_pt = legend_barwidth_pt)) +
    base_theme
}

build_qc_spatial_panel <- function(df_list, feature_names, feature_labels = NULL, title = NULL, limits = NULL, palette = c("mako", "cividis", "viridis", "default"), background = NULL, point_size = NULL, point_alpha = 0.98, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, ncol = NULL) {
  if (is.null(names(df_list))) names(df_list) <- feature_names
  missing_features <- setdiff(feature_names, names(df_list))
  if (length(missing_features) > 0) {
    stop(sprintf("Missing QC spatial data for: %s", paste(missing_features, collapse = ", ")), call. = FALSE)
  }
  label_map <- qc_feature_labels(feature_names, feature_labels)
  limits_map <- qc_feature_param(limits, feature_names)
  plot_list <- lapply(feature_names, function(feature_name) {
    plot_spatial_continuous_df(
      df = df_list[[feature_name]],
      title = label_map[[feature_name]],
      legend_title = label_map[[feature_name]],
      limits = limits_map[[feature_name]],
      palette = palette,
      theme_variant = "qc",
      background = background,
      point_size = point_size,
      point_alpha = point_alpha,
      legend_barheight_pt = legend_barheight_pt,
      legend_barwidth_pt = legend_barwidth_pt
    )
  })
  names(plot_list) <- feature_names
  wrap_qc_panel(plot_list, title = title, ncol = ncol %||% length(feature_names))
}
spatial_defaults <- function(sobj, feature, limits = NULL, title = NULL, image.alpha = NULL, pt.size.factor = NULL, alpha = NULL, palette = c("default", "cividis", "viridis"), background = NULL, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, use_qc_theme = FALSE) {
  spec <- get_figure_spec()
  spatial <- spec$spatial %||% list()
  qc <- spec$qc %||% list()
  palette <- match.arg(palette)

  if (is.null(image.alpha)) image.alpha <- spatial$image_alpha %||% 0.0
  if (is.null(pt.size.factor)) {
    pt.size.factor <- if (isTRUE(use_qc_theme)) qc$spatial_spot_size_factor %||% spatial$spot_size_factor %||% 2.0 else spatial$spot_size_factor %||% 2.0
  }
  if (is.null(alpha)) {
    alpha <- if (isTRUE(use_qc_theme)) qc$spatial_alpha_range %||% spatial$alpha_range %||% c(0.60, 1.00) else spatial$alpha_range %||% c(0.60, 1.00)
  }
  if (!is.numeric(alpha) || length(alpha) != 2) alpha <- c(0.60, 1.00)
  if (is.null(legend_barheight_pt)) legend_barheight_pt <- if (isTRUE(use_qc_theme)) qc$spatial_legend_barheight_pt %||% 34 else 42
  if (is.null(legend_barwidth_pt)) legend_barwidth_pt <- if (isTRUE(use_qc_theme)) qc$spatial_legend_barwidth_pt %||% 7.5 else 7.5

  p <- suppressMessages(suppressWarnings(
    Seurat::SpatialFeaturePlot(
      sobj,
      features = feature,
      image.alpha = image.alpha,
      pt.size.factor = pt.size.factor,
      alpha = alpha,
      stroke = 0
    ) +
      ggplot2::guides(fill = guide_colorbar_paper(barheight_pt = legend_barheight_pt, barwidth_pt = legend_barwidth_pt)) +
      if (isTRUE(use_qc_theme)) theme_qc_spatial_paper(background = background) else theme_spatial_paper()
  ))
  if (!is.null(p$scales) && length(p$scales$scales) > 0) {
    p$scales$scales <- Filter(function(s) !("fill" %in% s$aesthetics), p$scales$scales)
  }
  p <- p + scale_continuous_paper(limits = limits, palette = palette)
  if (!is.null(title)) {
    p <- p + ggplot2::ggtitle(title)
  }
  p
}
