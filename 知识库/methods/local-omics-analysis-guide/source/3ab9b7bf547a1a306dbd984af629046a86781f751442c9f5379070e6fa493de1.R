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
  out <- list(
    root = root,
    code = code_dir,
    result = result_dir,
    pdf = file.path(result_dir, "pdf"),
    tables = file.path(result_dir, "tables"),
    rds = file.path(result_dir, "rds"),
    logs = file.path(result_dir, "logs"),
    manifest = file.path(result_dir, "manifest.csv")
  )
  for (x in out[c("root", "code", "result", "pdf", "tables", "rds", "logs")]) dir.create(x, recursive = TRUE, showWarnings = FALSE)
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
  files <- save_figure(plot, out_prefix = out_prefix, width = width, height = height, dpi = png_dpi, bg = "white")
  manifest <- wf_manifest_add(manifest, files$pdf, "pdf", paper_level = paper_level, note = note)
  wf_manifest_add(manifest, files$png, "png", "reject", note)
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
wf_group_palette <- function() c(High = "#E07A5F", Low = "#7FB7C8")
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
    Epithelial = "#355C9A",
    Fibroblasts = "#B05AA9",
    Endothelial = "#14967F",
    SmoothMuscle = "#7A6A4F",
    Macrophage = "#9F7A12",
    Mast_cells = "#C12F2A",
    T_cells = "#2A86C0",
    NKT_cells = "#4DAF4A",
    B_cells = "#F39C12",
    Plasma_cells = "#E55E2E"
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
  base_cols <- c("#6A9BD1", "#F4A261", "#8BCB88", "#D95F5F", "#9C89D9", "#E9C46A", "#4FB3BF", "#C97EBC")
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

wf_plot_spatial_continuous <- function(df, title, legend_title = NULL, limits = NULL, palette = c("mako", "cividis", "viridis", "default"), theme_variant = c("default", "qc"), background = NULL, point_size = NULL, point_alpha = 0.96, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver()) {
  palette <- match.arg(palette)
  theme_variant <- match.arg(theme_variant)
  spec <- get_figure_spec()
  qc <- spec$qc %||% list()
  if (is.null(limits)) {
    limits <- wf_pretty_limits(df$value, lower_q = 0.02, upper_q = 0.98, include_zero = all(df$value >= 0, na.rm = TRUE))
  }
  if (inherits(breaks, "waiver")) {
    breaks <- wf_pretty_breaks(limits, n = 4, include_zero = all(limits >= 0))
  }
  if (is.null(point_size)) {
    point_size <- if (theme_variant == "qc") qc$spatial_spot_size_factor %||% 2.35 else 1.8
  }
  if (is.null(legend_barheight_pt)) {
    legend_barheight_pt <- if (theme_variant == "qc") qc$spatial_legend_barheight_pt %||% 34 else 38
  }
  if (is.null(legend_barwidth_pt)) {
    legend_barwidth_pt <- if (theme_variant == "qc") qc$spatial_legend_barwidth_pt %||% 7.5 else 8
  }
  plot_spatial_continuous_df(
    df = df,
    title = title,
    legend_title = legend_title,
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
  )
}

wf_plot_spatial_discrete <- function(df, title, palette, legend_title = NULL, point_size = 1.72, point_alpha = 0.96, legend_levels = NULL) {
  legend_levels <- legend_levels %||% wf_order_discrete_levels(df$value, names(palette))
  df$value <- factor(as.character(df$value), levels = legend_levels)
  ggplot(df, aes(x = x, y = y, colour = value)) +
    geom_point(size = point_size, alpha = point_alpha, stroke = 0, shape = 16) +
    scale_x_continuous(expand = ggplot2::expansion(mult = 0.015)) +
    scale_y_reverse(expand = ggplot2::expansion(mult = 0.015)) +
    coord_fixed() +
    scale_colour_manual(values = palette[legend_levels], breaks = legend_levels, drop = FALSE, na.value = "#DDD7C8") +
    labs(title = title, colour = legend_title %||% "") +
    guides(colour = guide_legend(override.aes = list(size = 3.2, alpha = 1), byrow = TRUE)) +
    theme_spatial_paper() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      legend.title = ggplot2::element_text(size = 8.5, face = "bold"),
      legend.text = ggplot2::element_text(size = 8.1),
      legend.key.height = grid::unit(8, "pt"),
      legend.spacing.y = grid::unit(1.5, "pt")
    )
}

wf_plot_spatial_binary <- function(obj, column, title) {
  df <- wf_spatial_df(obj, column, source = "meta")
  df$value <- factor(df$value, levels = c("High", "Low"))
  wf_plot_spatial_discrete(df, title, palette = wf_group_palette(), legend_title = "Group")
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
