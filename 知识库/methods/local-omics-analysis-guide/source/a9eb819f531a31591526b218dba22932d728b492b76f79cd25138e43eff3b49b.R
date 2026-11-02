suppressPackageStartupMessages({
  library(yaml)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(patchwork)
  library(Seurat)
  library(Matrix)
  library(ggsci)
})

source(file.path("code", "R", "plot_helpers.R"))

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0 || all(is.na(x))) y else x

wf_find_root <- function(start = getwd()) {
  cur <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    if (file.exists(file.path(cur, "code", "config.yml")) && dir.exists(file.path(cur, "workflow"))) return(cur)
    parent <- dirname(cur)
    if (identical(parent, cur)) break
    cur <- parent
  }
  stop("Cannot locate ST_FROM_RAW_2026-03-06 root.", call. = FALSE)
}

wf_load_config <- function() {
  root <- wf_find_root()
  cfg <- yaml::read_yaml(file.path(root, "code", "config.yml"))
  cfg$project_root <- root
  cfg$base_dir <- root
  cfg$output$local_root <- file.path(root, cfg$output$local_root %||% "local_outputs")
  rel_abs <- function(path) {
    if (is.null(path) || identical(path, "")) return(path)
    if (grepl("^[A-Za-z]:[/\\\\]|^/", path)) return(normalizePath(path, winslash = "/", mustWork = FALSE))
    normalizePath(file.path(root, path), winslash = "/", mustWork = FALSE)
  }
  cfg$input$st_raw_dirs <- lapply(cfg$input$st_raw_dirs, rel_abs)
  cfg$input$scrna_reference_rds <- rel_abs(cfg$input$scrna_reference_rds)
  cfg$input$ptm_gene_sets <- rel_abs(cfg$input$ptm_gene_sets)
  cfg$input$reference_paths <- lapply(cfg$input$reference_paths, rel_abs)
  cfg$deps$local_lib <- rel_abs(cfg$deps$local_lib)
  cfg$deps$spacexr_source <- rel_abs(cfg$deps$spacexr_source)
  if (!is.null(cfg$deps$celltrek_source)) cfg$deps$celltrek_source <- rel_abs(cfg$deps$celltrek_source)
  cfg$plot$bubble_reference_paths <- vapply(cfg$plot$bubble_reference_paths, rel_abs, character(1))
  cfg
}

wf_set_seed <- function(cfg) set.seed(cfg$analysis$seeds$global %||% 1L)
wf_local_root <- function(cfg) cfg$output$local_root
wf_step_root <- function(cfg, step_id, label) file.path(wf_local_root(cfg), sprintf("%s.%s", step_id, label))

get_expr_matrix <- function(sobj, assay = NULL, prefer = "data") {
  if (is.null(assay)) assay <- if ("Spatial" %in% Seurat::Assays(sobj)) "Spatial" else Seurat::DefaultAssay(sobj)
  mat <- tryCatch(suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, layer = prefer)), error = function(e) NULL)
  if (is.null(mat) || nrow(mat) == 0 || ncol(mat) == 0) {
    mat <- tryCatch(suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, slot = prefer)), error = function(e) NULL)
  }
  if (is.null(mat) || nrow(mat) == 0 || ncol(mat) == 0) {
    mat <- tryCatch(
      suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, layer = "counts")),
      error = function(e) suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, slot = "counts"))
    )
    mat <- log1p(mat)
  }
  mat
}

get_spatial_xy <- function(sobj) {
  coords <- as.data.frame(Seurat::GetTissueCoordinates(sobj))
  cand <- list(c("imagerow", "imagecol"), c("row", "col"), c("x", "y"))
  for (nm in cand) {
    if (all(nm %in% colnames(coords))) {
      xy <- coords[, nm, drop = FALSE]
      colnames(xy) <- c("x", "y")
      rownames(xy) <- rownames(coords)
      return(xy)
    }
  }
  num_cols <- names(coords)[vapply(coords, is.numeric, logical(1))]
  if (length(num_cols) < 2) stop("No valid 2D spatial coordinates found.", call. = FALSE)
  xy <- coords[, num_cols[1:2], drop = FALSE]
  colnames(xy) <- c("x", "y")
  rownames(xy) <- rownames(coords)
  xy
}

wf_step_dirs <- function(cfg, step_id, label, script_basename = NULL) {
  root <- wf_step_root(cfg, step_id, label)
  code_dir <- file.path(root, "code")
  result_dir <- file.path(root, "result")
  polished_dir <- file.path(result_dir, "polished")
  out <- list(
    root = root,
    code = code_dir,
    result = result_dir,
    pdf = file.path(result_dir, "pdf"),
    tables = file.path(result_dir, "tables"),
    rds = file.path(result_dir, "rds"),
    logs = file.path(result_dir, "logs"),
    polished = polished_dir,
    pdf_single_panel = file.path(polished_dir, "pdf_single_panel"),
    png_single_panel = file.path(polished_dir, "png_single_panel"),
    manifest = file.path(result_dir, "manifest.csv")
  )
  for (x in out[c("root", "code", "result", "pdf", "tables", "rds", "logs", "polished", "pdf_single_panel", "png_single_panel")]) dir.create(x, recursive = TRUE, showWarnings = FALSE)
  if (!is.null(script_basename)) {
    src <- file.path(cfg$project_root, "workflow", script_basename)
    if (file.exists(src)) file.copy(src, file.path(code_dir, script_basename), overwrite = TRUE)
  }
  snap_files <- c(
    file.path(cfg$project_root, "code", "config.yml"),
    file.path(cfg$project_root, "code", "style", "FIGURE_SPEC_ST.yaml"),
    file.path(cfg$project_root, "code", "R", "plot_helpers.R"),
    file.path(cfg$project_root, "code", "R", "workflow_helpers.R")
  )
  for (f in snap_files[file.exists(snap_files)]) file.copy(f, file.path(code_dir, basename(f)), overwrite = TRUE)
  out
}

wf_reset_local_outputs <- function(cfg) {
  root <- wf_local_root(cfg)
  if (dir.exists(root)) unlink(root, recursive = TRUE, force = TRUE)
  dir.create(root, recursive = TRUE, showWarnings = FALSE)
}

wf_manifest_init <- function() tibble::tibble(path = character(), kind = character(), paper_level = character(), note = character())
wf_manifest_add <- function(manifest, path, kind, paper_level = "reject", note = "") bind_rows(manifest, tibble(path = normalizePath(path, winslash = "/", mustWork = FALSE), kind = kind, paper_level = paper_level, note = note))
wf_manifest_write <- function(step_dirs, manifest) { readr::write_csv(manifest, step_dirs$manifest); invisible(step_dirs$manifest) }

wf_copy_pdf_png <- function(plot, step_dirs, stem, width = 7, height = 5, paper_level = "reject", note = "", manifest = wf_manifest_init()) {
  spec <- get_figure_spec()
  png_dpi <- switch(
    paper_level,
    main_text = spec$export$main_text_png_dpi %||% 600,
    supplementary = spec$export$supplementary_png_dpi %||% spec$export$png_dpi %||% 300,
    spec$export$png_dpi %||% 300
  )
  out_prefix <- file.path(step_dirs$pdf, stem)
  files <- save_figure(plot, out_prefix = out_prefix, width = width, height = height, dpi = png_dpi, bg = spec$canvas$background %||% "white")
  manifest <- wf_manifest_add(manifest, files$pdf, "pdf", paper_level = paper_level, note = note)
  wf_manifest_add(manifest, files$png, "png", "reject", note)
}

wf_sanitize_stem <- function(x) gsub("[^A-Za-z0-9._-]+", "_", x)
wf_export_spatial_composites <- function(cfg) isTRUE(cfg$plot$export_spatial_composites)

wf_copy_single_panel_pdf_png <- function(plot, step_dirs, stem, width = 7, height = 5, paper_level = "reject", note = "", manifest = wf_manifest_init(), bg = NULL) {
  spec <- get_figure_spec()
  png_dpi <- switch(
    paper_level,
    main_text = spec$export$main_text_png_dpi %||% 600,
    supplementary = spec$export$supplementary_png_dpi %||% spec$export$png_dpi %||% 300,
    spec$export$png_dpi %||% 300
  )
  stem <- wf_sanitize_stem(stem)
  pdf_file <- file.path(step_dirs$pdf_single_panel, paste0(stem, ".pdf"))
  png_file <- file.path(step_dirs$png_single_panel, paste0(stem, ".png"))
  bg <- bg %||% (spec$canvas$background %||% "white")
  save_panel_pdf(plot, out_file = pdf_file, width = width, height = height, bg = bg)
  suppressWarnings(ggplot2::ggsave(
    filename = png_file,
    plot = plot,
    width = width,
    height = height,
    units = "in",
    dpi = png_dpi,
    bg = bg
  ))
  manifest <- wf_manifest_add(manifest, pdf_file, "pdf", paper_level = paper_level, note = note)
  wf_manifest_add(manifest, png_file, "png", "reject", note)
}

wf_project_palette <- function(n, palette_name = "npg") {
  vals <- switch(
    palette_name,
    d3 = ggsci::pal_d3("category20")(max(n, 3)),
    aaas = ggsci::pal_aaas("default")(max(n, 3)),
    lancet = ggsci::pal_lancet("lanonc")(max(n, 3)),
    npg = ggsci::pal_npg("nrc")(max(n, 10)),
    ggsci::pal_npg("nrc")(max(n, 10))
  )
  if (length(vals) < n) vals <- rep(vals, length.out = n)
  vals[seq_len(n)]
}

wf_named_palette <- function(labels, palette_name = "npg") setNames(wf_project_palette(length(labels), palette_name = palette_name), labels)
wf_group_palette <- function() c(High = "#D98563", Low = "#8EB9BC")
wf_display_label <- function(x) gsub("_", " ", as.character(x))
wf_sample_label <- function(sample_id) gsub("^GSM[0-9]+_", "", as.character(sample_id))
wf_order_discrete_levels <- function(values, palette_names = NULL) {
  values <- as.character(values)
  values <- values[!is.na(values) & nzchar(values)]
  present <- if (length(values) > 0) names(sort(table(values), decreasing = TRUE)) else character()
  if (is.null(palette_names)) return(present)
  c(present, setdiff(palette_names, present))
}
wf_spatial_celltype_palette <- function(labels) {
  canonical <- c(
    Epithelial = "#E8C27E",
    Fibroblasts = "#F2C2C8",
    Endothelial = "#A8D88F",
    SmoothMuscle = "#8FA1C7",
    Macrophage = "#F2B25B",
    Mast_cells = "#D95B54",
    T_cells = "#4F97D3",
    NKT_cells = "#56AE6C",
    B_cells = "#F4D9A6",
    Plasma_cells = "#B89AD9"
  )
  labels <- as.character(labels)
  out <- rep(NA_character_, length(labels))
  for (i in seq_along(labels)) {
    hit <- names(canonical)[tolower(names(canonical)) == tolower(labels[[i]])]
    if (length(hit) > 0) out[[i]] <- canonical[[hit[[1]]]]
  }
  if (anyNA(out)) {
    fallback <- wf_project_palette(sum(is.na(out)), palette_name = "d3")
    out[is.na(out)] <- fallback
  }
  setNames(out, labels)
}
wf_spatial_domain_palette <- function(labels) {
  base_cols <- c("#E8C27E", "#F1463A", "#F3BDC3", "#47A447", "#A8D88F", "#2C7FB8", "#C7D7B5", "#D5A16D")
  setNames(rep(base_cols, length.out = length(labels)), labels)
}
wf_scale01 <- function(x, lower_q = 0.01, upper_q = 0.99) {
  rng <- stats::quantile(x, probs = c(lower_q, upper_q), na.rm = TRUE, names = FALSE, type = 7)
  if (!all(is.finite(rng)) || diff(rng) <= 0) return(rep(0, length(x)))
  x <- pmin(pmax(x, rng[1]), rng[2])
  (x - rng[1]) / (rng[2] - rng[1])
}

wf_pretty_limits <- function(x, lower_q = 0.02, upper_q = 0.98, include_zero = TRUE, n = 4) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  if (!length(x)) return(c(0, 1))
  rng <- stats::quantile(x, probs = c(lower_q, upper_q), na.rm = TRUE, names = FALSE, type = 7)
  if (!all(is.finite(rng)) || diff(rng) <= 0) rng <- range(x, na.rm = TRUE)
  if (isTRUE(include_zero) && rng[1] >= 0) rng[1] <- 0
  brks <- pretty(rng, n = n)
  brks <- brks[is.finite(brks)]
  if (isTRUE(include_zero) && rng[1] >= 0) brks <- sort(unique(c(0, brks)))
  keep <- brks >= min(rng) & brks <= max(rng)
  if (sum(keep) >= 2) brks <- brks[keep]
  lims <- range(brks, finite = TRUE)
  if (!all(is.finite(lims)) || diff(lims) <= 0) lims <- range(rng, finite = TRUE)
  if (isTRUE(include_zero) && lims[1] > 0) lims[1] <- 0
  lims
}

wf_pretty_breaks <- function(limits, n = 4, include_zero = TRUE) {
  limits <- as.numeric(limits)
  if (length(limits) != 2 || !all(is.finite(limits)) || diff(limits) <= 0) return(c(0, 1))
  brks <- pretty(limits, n = n)
  brks <- brks[is.finite(brks) & brks >= limits[1] & brks <= limits[2]]
  if (isTRUE(include_zero) && limits[1] >= 0) brks <- sort(unique(c(0, brks)))
  if (length(brks) < 3) brks <- seq(limits[1], limits[2], length.out = 4)
  unique(brks)
}

wf_read_gmt <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  out <- lapply(lines, function(x) {
    parts <- strsplit(x, "\t", fixed = TRUE)[[1]]
    stats::setNames(list(unique(parts[-c(1, 2)])), parts[1])
  })
  unlist(out, recursive = FALSE)
}

wf_spatial_df <- function(obj, values, source = c("meta", "expr"), assay = NULL, layer = "data") {
  source <- match.arg(source)
  coords <- get_spatial_xy(obj)
  coords$spot <- rownames(coords)
  coords$value <- if (source == "meta") obj@meta.data[coords$spot, values, drop = TRUE] else as.numeric(get_expr_matrix(obj, assay = assay, prefer = layer)[values, coords$spot])
  coords
}

wf_spatial_backdrop_df <- function(obj) {
  coords <- get_spatial_xy(obj)
  coords$spot <- rownames(coords)
  coords
}

wf_spatial_ref1_spec <- function() {
  spec <- get_figure_spec()
  ref1 <- spec$spatial_ref1 %||% list()
  list(
    background = ref1$panel_background %||% "#FFFFFF",
    continuous_hex = ref1$continuous_hex %||% c("#2A3F9D", "#2C77C3", "#46B3B3", "#E9E4A5", "#F0A35A", "#D13E3E"),
    border_colour = ref1$border_colour %||% "#474747",
    point_size = as.numeric(ref1$point_size %||% 2.5),
    point_alpha = as.numeric(ref1$point_alpha %||% 1),
    stroke = as.numeric(ref1$stroke %||% 0.3),
    legend_barheight_pt = as.numeric(ref1$legend_barheight_pt %||% 44),
    legend_barwidth_pt = as.numeric(ref1$legend_barwidth_pt %||% 8.5)
  )
}

wf_spatial_ref2_spec <- function() {
  spec <- get_figure_spec()
  ref2 <- spec$spatial_ref2 %||% list()
  list(
    background = ref2$panel_background %||% "#FFFFFF",
    border_colour = ref2$border_colour %||% "#5A5A5A",
    point_size = as.numeric(ref2$point_size %||% 2.45),
    point_alpha = as.numeric(ref2$point_alpha %||% 1),
    stroke = as.numeric(ref2$stroke %||% 0.3),
    legend_key_size_pt = as.numeric(ref2$legend_key_size_pt %||% 10),
    domain_label_fill = ref2$domain_label_fill %||% "#F6D98E",
    domain_label_colour = ref2$domain_label_colour %||% "#2F2F2F",
    domain_label_size = as.numeric(ref2$domain_label_size %||% 2.9)
  )
}

wf_plot_spatial_feature_ref1_style <- function(df, feature_name = NULL, legend_title = NULL, limits = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver(), point_size = NULL, point_alpha = NULL, background = NULL, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, backdrop_df = NULL, backdrop_size = NULL, backdrop_fill = "#F3F3F3", backdrop_colour = "#D9D9D9", backdrop_alpha = 1) {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package scales is required", call. = FALSE)
  ref1 <- wf_spatial_ref1_spec()
  feature_label <- legend_title %||% feature_name %||% "Feature"
  if (is.null(limits)) {
    limits <- wf_pretty_limits(df$value, lower_q = 0.02, upper_q = 0.98, include_zero = all(df$value >= 0, na.rm = TRUE))
  }
  if (inherits(breaks, "waiver")) {
    breaks <- wf_pretty_breaks(limits, n = 4, include_zero = all(limits >= 0))
  }
  point_size <- point_size %||% ref1$point_size
  point_alpha <- point_alpha %||% ref1$point_alpha
  background <- background %||% ref1$background
  legend_barheight_pt <- legend_barheight_pt %||% ref1$legend_barheight_pt
  legend_barwidth_pt <- legend_barwidth_pt %||% ref1$legend_barwidth_pt
  backdrop_size <- backdrop_size %||% max(point_size * 0.96, 1.7)

  p <- ggplot()
  if (!is.null(backdrop_df) && nrow(backdrop_df) > 0) {
    p <- p +
      ggplot2::geom_point(data = backdrop_df, ggplot2::aes(x = x, y = y), inherit.aes = FALSE, shape = 21, size = backdrop_size, alpha = backdrop_alpha, stroke = max(ref1$stroke * 0.7, 0.18), fill = backdrop_fill, colour = backdrop_colour)
  }

  p +
    geom_point(data = df, aes(x = x, y = y, fill = value), shape = 21, size = point_size, alpha = point_alpha, stroke = ref1$stroke, colour = ref1$border_colour) +
    scale_x_continuous(expand = ggplot2::expansion(mult = 0.02)) +
    scale_y_reverse(expand = ggplot2::expansion(mult = 0.02)) +
    coord_fixed() +
    ggplot2::scale_fill_gradientn(colours = ref1$continuous_hex, limits = limits, oob = scales::squish, na.value = "#D9D9D9", breaks = breaks, labels = labels) +
    labs(fill = feature_label) +
    guides(fill = guide_colorbar_paper(barheight_pt = legend_barheight_pt, barwidth_pt = legend_barwidth_pt, title.position = "top", ticks = TRUE)) +
    theme_spatial_paper() +
    ggplot2::theme(plot.title = ggplot2::element_blank(), plot.subtitle = ggplot2::element_blank(), plot.background = ggplot2::element_rect(fill = background, colour = NA), panel.background = ggplot2::element_rect(fill = background, colour = NA), panel.border = ggplot2::element_blank(), legend.position = "right", legend.title = ggplot2::element_text(size = 8.8, face = "bold", margin = ggplot2::margin(b = 3)), legend.text = ggplot2::element_text(size = 8.2), legend.box.margin = ggplot2::margin(0, 0, 0, 2), plot.margin = ggplot2::margin(5, 6, 5, 6))
}

wf_plot_spatial_structure_ref2_style <- function(df, feature_name = NULL, palette, legend_title = NULL, point_size = NULL, point_alpha = NULL, legend_levels = NULL, add_domain_labels = FALSE, label_map = NULL, backdrop_df = NULL, backdrop_size = NULL, backdrop_fill = "#F3F3F3", backdrop_colour = "#D9D9D9", backdrop_alpha = 1) {
  ref2 <- wf_spatial_ref2_spec()
  legend_levels <- legend_levels %||% wf_order_discrete_levels(df$value, names(palette))
  df$value <- factor(as.character(df$value), levels = legend_levels)
  point_size <- point_size %||% ref2$point_size
  point_alpha <- point_alpha %||% ref2$point_alpha
  backdrop_size <- backdrop_size %||% max(point_size * 0.94, 1.7)

  p <- ggplot()
  if (!is.null(backdrop_df) && nrow(backdrop_df) > 0) {
    p <- p +
      ggplot2::geom_point(data = backdrop_df, ggplot2::aes(x = x, y = y), inherit.aes = FALSE, shape = 21, size = backdrop_size, alpha = backdrop_alpha, stroke = max(ref2$stroke * 0.7, 0.18), fill = backdrop_fill, colour = backdrop_colour)
  }

  p <- p +
    geom_point(data = df, aes(x = x, y = y, fill = value), shape = 21, size = point_size, alpha = point_alpha, stroke = ref2$stroke, colour = ref2$border_colour) +
    scale_x_continuous(expand = ggplot2::expansion(mult = 0.02)) +
    scale_y_reverse(expand = ggplot2::expansion(mult = 0.02)) +
    coord_fixed() +
    scale_fill_manual(values = palette[legend_levels], breaks = legend_levels, drop = FALSE, na.value = "#D9D9D9") +
    labs(fill = legend_title %||% "") +
    guides(fill = guide_legend(override.aes = list(shape = 21, size = max(point_size, 3.6), alpha = 1, colour = ref2$border_colour, stroke = ref2$stroke), byrow = TRUE)) +
    theme_spatial_paper() +
    ggplot2::theme(plot.title = ggplot2::element_blank(), plot.subtitle = ggplot2::element_blank(), plot.background = ggplot2::element_rect(fill = ref2$background, colour = NA), panel.background = ggplot2::element_rect(fill = ref2$background, colour = NA), panel.border = ggplot2::element_blank(), legend.position = "right", legend.title = ggplot2::element_text(size = 8.8, face = "bold", margin = ggplot2::margin(b = 4)), legend.text = ggplot2::element_text(size = 8.1), legend.key.height = grid::unit(ref2$legend_key_size_pt, "pt"), legend.spacing.y = grid::unit(1.5, "pt"), legend.box.margin = ggplot2::margin(0, 0, 0, 2), plot.margin = ggplot2::margin(5, 6, 5, 6))

  if (isTRUE(add_domain_labels)) {
    label_map <- label_map %||% stats::setNames(as.character(seq_along(legend_levels) - 1L), legend_levels)
    centroids <- df %>% dplyr::filter(!is.na(value)) %>% dplyr::group_by(value) %>% dplyr::summarise(x = stats::median(x, na.rm = TRUE), y = stats::median(y, na.rm = TRUE), .groups = "drop")
    centroids$label <- unname(label_map[as.character(centroids$value)])
    centroids <- centroids[!is.na(centroids$label) & nzchar(centroids$label), , drop = FALSE]
    if (nrow(centroids) > 0) {
      p <- p + ggplot2::geom_label(data = centroids, ggplot2::aes(x = x, y = y, label = label), inherit.aes = FALSE, size = ref2$domain_label_size, fontface = "bold", label.size = 0.18, label.padding = grid::unit(0.09, "lines"), fill = ref2$domain_label_fill, colour = ref2$domain_label_colour)
    }
  }
  p
}

wf_scatter_ref1_palette <- function() c("#9EDCE7", "#63C0D2", "#8962C8", "#5C2D90")
wf_ref2_bubble_palette <- function() c("#1F5C99", "#78B5D8", "#F3EDE3", "#E07A58", "#8D1730")

wf_format_p_value <- function(p) {
  if (!is.finite(p)) return("P = NA")
  if (p < 0.001) return("P < 0.001")
  paste0("P = ", formatC(p, format = "f", digits = 3))
}

wf_scatter_stats_label <- function(df, x, y, method = "spearman") {
  vals <- df[, c(x, y), drop = FALSE]
  vals <- vals[stats::complete.cases(vals), , drop = FALSE]
  if (nrow(vals) < 3) return(NULL)
  tst <- suppressWarnings(tryCatch(stats::cor.test(vals[[x]], vals[[y]], method = method), error = function(e) NULL))
  if (is.null(tst)) return(NULL)
  paste(c("Spearman", paste0("R = ", formatC(unname(tst$estimate), format = "f", digits = 3)), wf_format_p_value(tst$p.value)), collapse = "\n")
}

wf_theme_scatter_ref1 <- function() {
  theme_paper() + ggplot2::theme(plot.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA), panel.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA), panel.grid.major = ggplot2::element_blank(), panel.grid.minor = ggplot2::element_blank(), panel.border = ggplot2::element_blank(), axis.line = .element_line_compat(linewidth = 0.6, colour = "#1F1F1F"), axis.title = ggplot2::element_text(size = 10.2, face = "bold", colour = "#1F1F1F"), axis.text = ggplot2::element_text(size = 8.7, colour = "#1F1F1F"), legend.position = "right", legend.title = ggplot2::element_text(size = 8.6, face = "bold"), legend.text = ggplot2::element_text(size = 8.2), plot.title = ggplot2::element_blank(), plot.subtitle = ggplot2::element_blank(), plot.margin = ggplot2::margin(5, 6, 5, 6))
}

wf_with_subplot_title <- function(plot_obj, title, size = 9.2, hjust = 0.5) {
  if (is.null(title) || !nzchar(title)) return(plot_obj)
  plot_obj +
    labs(title = title) +
    theme(
      plot.title = element_text(size = size, face = "bold", hjust = hjust, colour = "#1F1F1F"),
      plot.title.position = "plot",
      plot.margin = margin(5, 6, 5, 6)
    )
}

wf_wrap_grouped_panel <- function(plot_list, ncol = NULL, panel_background = "#FFFFFF", guides = "collect") {
  plot_guard(plot_list = plot_list, reason = "Grouped panel assembly failed")
  if (is.null(ncol)) {
    ncol <- if (length(plot_list) <= 2) length(plot_list) else ceiling(sqrt(length(plot_list)))
  }
  patchwork::wrap_plots(plot_list, ncol = max(1L, ncol), guides = guides) &
    theme(
      legend.position = "right",
      legend.justification = "center",
      legend.box.margin = margin(0, 0, 0, 2),
      panel.spacing = grid::unit(6, "pt"),
      plot.background = element_rect(fill = panel_background, colour = NA),
      panel.background = element_rect(fill = panel_background, colour = NA),
      plot.margin = margin(5, 6, 5, 6)
    )
}

wf_plot_scatter_ref1_style <- function(df, x, y, xlab = NULL, ylab = NULL, colour = NULL, colour_type = c("none", "discrete", "continuous"), palette = NULL, legend_title = NULL, point_size = 1.95, point_alpha = 0.6, add_lm = TRUE, add_stats = TRUE, fill_limits = NULL) {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package scales is required", call. = FALSE)
  colour_type <- match.arg(colour_type)
  if (colour_type == "none" || is.null(colour)) {
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]])) + geom_point(shape = 21, size = point_size, alpha = point_alpha, stroke = 0.32, fill = "#8FD0E0", colour = "#3E3E3E")
  } else if (colour_type == "discrete") {
    palette <- palette %||% wf_group_palette()
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]], fill = .data[[colour]])) + geom_point(shape = 21, size = point_size, alpha = point_alpha, stroke = 0.32, colour = "#3E3E3E") + scale_fill_manual(values = palette, name = legend_title %||% colour, drop = FALSE)
  } else {
    fill_limits <- fill_limits %||% wf_pretty_limits(df[[colour]], lower_q = 0.02, upper_q = 0.98, include_zero = FALSE)
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]], fill = .data[[colour]])) + geom_point(shape = 21, size = point_size, alpha = point_alpha, stroke = 0.32, colour = "#3E3E3E") + ggplot2::scale_fill_gradientn(colours = wf_scatter_ref1_palette(), limits = fill_limits, oob = scales::squish, name = legend_title %||% colour, breaks = wf_pretty_breaks(fill_limits, n = 4, include_zero = FALSE))
  }
  if (isTRUE(add_lm) && nrow(df) >= 3) p <- p + geom_smooth(method = "lm", se = FALSE, linewidth = 0.8, colour = "#4A4A4A")
  stats_label <- if (isTRUE(add_stats)) wf_scatter_stats_label(df, x, y) else NULL
  if (!is.null(stats_label)) {
    xrange <- range(df[[x]], na.rm = TRUE)
    yrange <- range(df[[y]], na.rm = TRUE)
    p <- p + annotate("text", x = xrange[1] + diff(xrange) * 0.03, y = yrange[2] - diff(yrange) * 0.03, label = stats_label, hjust = 0, vjust = 1, size = 3.5, fontface = "bold", colour = "#1F1F1F")
  }
  p + labs(x = xlab %||% x, y = ylab %||% y) + wf_theme_scatter_ref1() + guides(fill = if (colour_type == "continuous") guide_colorbar_paper(barheight_pt = 38, barwidth_pt = 7.5) else guide_legend_paper(override.aes = list(alpha = 1, size = 2.8)))
}

wf_theme_bubble_ref2 <- function() {
  theme_paper() + ggplot2::theme(plot.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA), panel.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA), strip.background = .element_rect_compat(fill = "#FFFFFF", colour = NA), panel.border = .element_rect_compat(fill = NA, colour = "#6A6A6A", linewidth = 0.35), panel.grid.major.x = .element_line_compat(linewidth = 0.3, colour = "#D7D1C7"), panel.grid.major.y = ggplot2::element_blank(), panel.grid.minor = ggplot2::element_blank(), axis.line = ggplot2::element_blank(), axis.title = ggplot2::element_text(size = 10, face = "bold", colour = "#1F1F1F"), axis.text = ggplot2::element_text(size = 8.4, colour = "#1F1F1F"), legend.position = "right", legend.title = ggplot2::element_text(size = 8.6, face = "bold", margin = ggplot2::margin(b = 4)), legend.text = ggplot2::element_text(size = 8.1), plot.title = ggplot2::element_blank(), plot.subtitle = ggplot2::element_blank(), plot.margin = ggplot2::margin(5, 6, 5, 6))
}

wf_scale_fill_ref2_bubble <- function(limits = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver(), na.value = "#D9D9D9") {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package scales is required", call. = FALSE)
  ggplot2::scale_fill_gradientn(colours = wf_ref2_bubble_palette(), limits = limits, breaks = breaks, labels = labels, na.value = na.value, oob = scales::squish)
}

wf_plot_spatial_continuous <- function(df, title, legend_title = NULL, limits = NULL, palette = c("mako", "cividis", "viridis", "default"), theme_variant = c("default", "qc"), background = NULL, point_size = NULL, point_alpha = 0.96, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver()) {
  theme_variant <- match.arg(theme_variant)
  if (theme_variant == "qc") {
    return(plot_spatial_continuous_df(
      df = df,
      title = legend_title %||% title,
      legend_title = legend_title %||% title,
      limits = limits,
      palette = palette,
      theme_variant = theme_variant,
      background = background,
      point_size = point_size,
      point_alpha = point_alpha,
      legend_barheight_pt = legend_barheight_pt,
      legend_barwidth_pt = legend_barwidth_pt,
      breaks = breaks,
      labels = labels
    ))
  }
  wf_plot_spatial_feature_ref1_style(
    df = df,
    feature_name = legend_title %||% title,
    legend_title = legend_title %||% title,
    limits = limits,
    breaks = breaks,
    labels = labels,
    point_size = point_size,
    point_alpha = point_alpha,
    background = background,
    legend_barheight_pt = legend_barheight_pt,
    legend_barwidth_pt = legend_barwidth_pt
  )
}

wf_plot_spatial_discrete <- function(df, title, palette, legend_title = NULL, point_size = 1.72, point_alpha = 0.96, legend_levels = NULL) {
  wf_plot_spatial_structure_ref2_style(
    df = df,
    feature_name = title,
    palette = palette,
    legend_title = legend_title,
    point_size = point_size,
    point_alpha = point_alpha,
    legend_levels = legend_levels
  )
}

wf_plot_spatial_binary <- function(obj, column, title) {
  df <- wf_spatial_df(obj, column, source = "meta")
  df$value <- factor(df$value, levels = c("High", "Low"))
  wf_plot_spatial_structure_ref2_style(df, feature_name = title, palette = wf_group_palette(), legend_title = "Group", legend_levels = c("High", "Low"))
}

wf_detect_celltype_cols <- function(md, known = NULL) {
  num_cols <- names(md)[vapply(md, is.numeric, logical(1))]
  exclude <- grepl("^(nCount_|nFeature_|percent\\.)", num_cols) | grepl("^PTM_|^nhood_|^PC_|^UMAP_", num_cols) | grepl("domain|cluster|score|zscore", num_cols, ignore.case = TRUE)
  num_cols <- num_cols[!exclude]
  if (!is.null(known)) {
    known2 <- intersect(known, num_cols)
    if (length(known2) > 0) return(known2)
  }
  valid <- vapply(num_cols, function(x) {
    v <- md[[x]]
    v <- v[is.finite(v)]
    length(v) > 10 && mean(v >= 0 & v <= 1) > 0.8
  }, logical(1))
  num_cols[valid]
}

wf_binary_group <- function(values) {
  ranks <- rank(values, ties.method = "first", na.last = "keep")
  cutoff <- stats::median(ranks, na.rm = TRUE)
  factor(ifelse(ranks > cutoff, "High", "Low"), levels = c("High", "Low"))
}

wf_heatmap_save <- function(mat, step_dirs, stem, title, paper_level = "supplementary", note = "", manifest = wf_manifest_init()) {
  legend_title <- if (grepl("nes|enrichment", title, ignore.case = TRUE)) {
    "NES"
  } else if (any(mat < 0, na.rm = TRUE)) {
    "Correlation"
  } else {
    "Weight"
  }
  ht <- complex_heatmap_defaults(mat, title = title, legend_title = legend_title, palette = if (any(mat < 0, na.rm = TRUE)) "diverging" else "continuous")
  out <- file.path(step_dirs$pdf, paste0(stem, ".pdf"))
  save_complexheatmap_pdf(ht, out_file = out, width = 8.6, height = 6.2)
  wf_manifest_add(manifest, out, "pdf", paper_level = paper_level, note = note)
}

wf_ensure_local_lib <- function(cfg) {
  dir.create(cfg$deps$local_lib, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(cfg$deps$local_lib, .libPaths()))
}

wf_prepare_spacexr_vendor <- function(cfg) {
  vendor_dir <- file.path(cfg$project_root, "code", "vendor", "spacexr_patched")
  src <- cfg$deps$spacexr_source
  if (!dir.exists(src)) return(NULL)
  if (!dir.exists(vendor_dir)) {
    dir.create(vendor_dir, recursive = TRUE, showWarnings = FALSE)
    files <- list.files(src, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
    for (f in files) {
      rel <- substring(f, nchar(src) + 2L)
      out <- file.path(vendor_dir, rel)
      if (dir.exists(f)) dir.create(out, recursive = TRUE, showWarnings = FALSE) else {
        dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
        file.copy(f, out, overwrite = TRUE)
      }
    }
  }
  desc <- file.path(vendor_dir, "DESCRIPTION")
  if (file.exists(desc)) {
    txt <- readLines(desc, warn = FALSE)
    txt <- gsub("\\bRfast,\\s*", "", txt)
    txt <- gsub("\\s+Rfast\\s*$", "", txt)
    txt <- txt[!(trimws(txt) == "" & c(FALSE, head(grepl("^Imports:", txt), -1)))]
    txt <- txt[!(grepl("^\\s*$", txt) & seq_along(txt) > 1L & grepl("^\\s*$", c("", txt[-length(txt)])))]
    writeLines(txt, desc)
  }
  vendor_dir
}

wf_load_spacexr <- function(cfg) {
  wf_ensure_local_lib(cfg)
  if (requireNamespace("spacexr", quietly = TRUE)) return("installed")
  vendor_dir <- wf_prepare_spacexr_vendor(cfg)
  if (is.null(vendor_dir) || !requireNamespace("pkgload", quietly = TRUE)) return(NULL)
  pkgload::load_all(vendor_dir, helpers = FALSE, attach = FALSE, export_all = TRUE, quiet = TRUE)
  "pkgload"
}

wf_get_spacexr_export <- function(name) getExportedValue("spacexr", name)
wf_pdf_info_safe <- function(path) if (requireNamespace("pdftools", quietly = TRUE) && file.exists(path)) tryCatch(pdftools::pdf_info(path), error = function(e) NULL) else NULL
wf_md5 <- function(path) if (file.exists(path)) as.character(tools::md5sum(path)) else NA_character_

wf_make_simple_network_plot <- function(edge_df, centroids, title) {
  edge_df <- edge_df[!(edge_df$x_from == edge_df$x_to & edge_df$y_from == edge_df$y_to), , drop = FALSE]
  if (nrow(edge_df) == 0) return(ggplot() + annotate("text", x = 1, y = 1, label = "No significant LR edges") + theme_void())
  ggplot() +
    geom_curve(data = edge_df, aes(x = x_from, y = y_from, xend = x_to, yend = y_to, linewidth = weight), colour = "#F4A261", curvature = 0.18, alpha = 0.6) +
    geom_point(data = centroids, aes(x = x, y = y, fill = group), shape = 21, size = 6, colour = "#333333") +
    geom_text(data = centroids, aes(x = x, y = y, label = group), nudge_y = 7, size = 3.2) +
    scale_fill_manual(values = wf_named_palette(centroids$group, "d3")) +
    scale_linewidth(range = c(0.3, 2.5)) +
    coord_fixed() +
    labs(title = title, fill = "Celltype", linewidth = "Weight") +
    theme_void() +
    theme(legend.position = "right", plot.title = element_text(hjust = 0, face = "bold"))
}
