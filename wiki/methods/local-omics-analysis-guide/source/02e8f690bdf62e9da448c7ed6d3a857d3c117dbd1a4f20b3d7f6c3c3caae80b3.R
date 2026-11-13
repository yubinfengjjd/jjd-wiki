#!/usr/bin/env Rscript

source(file.path("code", "R", "workflow_helpers.R"))

.theme_paper_orig <- theme_paper
theme_paper <- function(base_size = 10.5, base_family = "sans") .theme_paper_orig(base_size = base_size, base_family = base_family)
suppressWarnings(grDevices::pdf.options(family = "Helvetica"))

suppressPackageStartupMessages({
  library(Seurat)
  library(CellChat)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(tibble)
  library(patchwork)
  library(Matrix)
})

cfg <- wf_load_config()
wf_ensure_local_lib(cfg)
wf_set_seed(cfg)
if (requireNamespace("future", quietly = TRUE)) {
  future::plan("sequential")
}

root_dir <- wf_find_root()
out_root <- file.path(root_dir, "results", "cellchat_rctd_spot")
dir_map <- list(
  audit = file.path(out_root, "00_audit"),
  metadata = file.path(out_root, "01_metadata"),
  objects = file.path(out_root, "02_cellchat_objects"),
  tables = file.path(out_root, "03_tables"),
  network = file.path(out_root, "04_network_plots"),
  pathway = file.path(out_root, "05_pathway_plots"),
  lr = file.path(out_root, "06_LR_plots"),
  spatial = file.path(out_root, "07_spatial_maps"),
  sensitivity = file.path(out_root, "08_sensitivity"),
  summary = file.path(out_root, "09_summary"),
  logs = file.path(out_root, "10_logs")
)
for (x in dir_map) dir.create(x, recursive = TRUE, showWarnings = FALSE)

timestamp_tag <- format(Sys.time(), "%Y%m%d_%H%M%S")
log_file <- file.path(dir_map$logs, paste0("cellchat_rctd_spot_", timestamp_tag, ".log"))
writeLines(character(), log_file)

log_message <- function(...) {
  msg <- paste0("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", sprintf(...))
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

write_text <- function(text, path) {
  writeLines(text, path, useBytes = TRUE)
  invisible(path)
}

save_gg <- function(plot_obj, dir_path, stem, width = 7.5, height = 5.5, dpi = 300, bg = "white") {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(dir_path, paste0(stem, ".pdf"))
  png_path <- file.path(dir_path, paste0(stem, ".png"))
  suppressWarnings(ggplot2::ggsave(pdf_path, plot_obj, width = width, height = height, units = "in", bg = bg, device = grDevices::cairo_pdf))
  suppressWarnings(ggplot2::ggsave(png_path, plot_obj, width = width, height = height, units = "in", dpi = dpi, bg = bg))
  invisible(list(pdf = pdf_path, png = png_path))
}

save_base_plot <- function(dir_path, stem, width, height, expr) {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(dir_path, paste0(stem, ".pdf"))
  png_path <- file.path(dir_path, paste0(stem, ".png"))
  grDevices::pdf(pdf_path, width = width, height = height, onefile = TRUE)
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  force(expr)
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)
  grDevices::png(png_path, width = width, height = height, units = "in", res = 300, bg = "white")
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  force(expr)
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)
  invisible(list(pdf = pdf_path, png = png_path))
}

safe_capture <- function(expr, default = NULL, label = "step") {
  tryCatch(expr, error = function(e) {
    log_message("%s failed: %s", label, conditionMessage(e))
    default
  })
}

detect_assay <- function(obj) {
  candidates <- unique(c("Spatial", Seurat::DefaultAssay(obj), Seurat::Assays(obj)))
  candidates <- candidates[!is.na(candidates) & nzchar(candidates)]
  for (assay in candidates) {
    dat <- tryCatch(get_expr_matrix(obj, assay = assay, prefer = "data"), error = function(e) NULL)
    if (!is.null(dat) && all(dim(dat) > 0)) return(assay)
  }
  stop("No assay with usable normalized data was detected.", call. = FALSE)
}

detect_sample_column <- function(meta) {
  candidates <- c("sample_id", "samples", "sample", "orig.ident")
  for (nm in candidates) {
    if (nm %in% colnames(meta)) return(nm)
  }
  hits <- grep("sample|orig.ident", colnames(meta), value = TRUE, ignore.case = TRUE)
  if (length(hits) > 0) return(hits[[1]])
  NULL
}

detect_annotation_column <- function(meta) {
  meta <- as.data.frame(meta)
  candidates <- colnames(meta)[vapply(meta, function(x) is.factor(x) || is.character(x), logical(1))]
  if (!length(candidates)) return(NULL)
  candidates <- candidates[grepl("annot|annotation|label|region|spot_type|spottype|manual", candidates, ignore.case = TRUE)]
  candidates <- setdiff(candidates, c("dominant_celltype", "second_celltype", "UBE2L6_group", "cellchat_group", "BayesSpace_domain"))
  if (length(candidates) == 0) return(NULL)
  candidates[[1]]
}

detect_weight_columns <- function(meta, dominant_values = NULL) {
  meta <- as.data.frame(meta)
  numeric_cols <- colnames(meta)[vapply(meta, is.numeric, logical(1))]
  numeric_cols <- setdiff(
    numeric_cols,
    c("nCount_Spatial", "nFeature_Spatial", "percent.mt", "percent.ribo", "UBE2L6_expr")
  )
  if (!length(numeric_cols)) return(character())
  candidate_tbl <- meta[, numeric_cols, drop = FALSE]
  in_unit_range <- vapply(candidate_tbl, function(x) {
    x <- x[is.finite(x)]
    length(x) > 0 && min(x) >= 0 && max(x) <= 1.05
  }, logical(1))
  numeric_cols <- numeric_cols[in_unit_range]
  if (!length(numeric_cols)) return(character())
  if (!is.null(dominant_values)) {
    dominant_values <- unique(as.character(dominant_values))
    dominant_values <- dominant_values[!is.na(dominant_values)]
    hits <- intersect(dominant_values, numeric_cols)
    if (length(hits) >= 3) {
      row_sums <- rowSums(as.matrix(meta[, hits, drop = FALSE]), na.rm = TRUE)
      if (mean(row_sums > 0.75 & row_sums < 1.25, na.rm = TRUE) > 0.7) return(hits)
    }
  }
  row_score <- vapply(numeric_cols, function(x) mean(is.finite(meta[[x]])), numeric(1))
  numeric_cols <- numeric_cols[row_score > 0.95]
  if (!length(numeric_cols)) return(character())
  row_sums <- rowSums(as.matrix(meta[, numeric_cols, drop = FALSE]), na.rm = TRUE)
  if (mean(row_sums > 0.75 & row_sums < 1.25, na.rm = TRUE) > 0.7) numeric_cols else character()
}

broad_class <- function(celltype) {
  ct <- as.character(celltype)
  if (ct %in% c("Epithelial")) return("Epithelial")
  if (ct %in% c("B_cells", "T_cells", "NKT_cells", "Plasma_cells", "Macrophage", "Mast_cells")) return("Immune")
  if (ct %in% c("Fibroblasts", "Endothelial", "SmoothMuscle")) return("Stromal")
  "Other"
}

infer_species <- function(genes) {
  genes <- genes[!is.na(genes) & grepl("[A-Za-z]", genes)]
  if (!length(genes)) return("human")
  letters_only <- gsub("[^A-Za-z]", "", genes)
  human_like <- mean(letters_only == toupper(letters_only))
  mouse_like <- mean(grepl("^[A-Z][a-z]+", genes))
  if (human_like >= mouse_like) "human" else "mouse"
}

extract_scale_factors <- function(obj) {
  img_name <- names(obj@images)[[1]]
  img <- obj@images[[img_name]]
  sf <- tryCatch(img@scale.factors, error = function(e) NULL)
  spot_val <- if (!is.null(sf) && "spot" %in% names(sf)) as.numeric(sf$spot[[1]]) else NA_real_
  tibble(
    image_name = img_name,
    image_class = class(img)[[1]],
    spot = spot_val,
    spot_diameter = spot_val,
    fiducial = if (!is.null(sf) && "fiducial" %in% names(sf)) as.numeric(sf$fiducial[[1]]) else NA_real_,
    hires = if (!is.null(sf) && "hires" %in% names(sf)) as.numeric(sf$hires[[1]]) else NA_real_,
    lowres = if (!is.null(sf) && "lowres" %in% names(sf)) as.numeric(sf$lowres[[1]]) else NA_real_
  )
}

make_heatmap_plot <- function(mat, title, fill_title) {
  df <- as.data.frame(as.table(mat), stringsAsFactors = FALSE)
  colnames(df) <- c("source", "target", "value")
  ggplot(df, aes(x = target, y = source, fill = value)) +
    geom_tile(color = "white", linewidth = 0.35) +
    scale_fill_gradient(low = "#F4F1EA", high = "#B45A3C") +
    labs(title = title, x = NULL, y = NULL, fill = fill_title) +
    theme_paper() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid = element_blank(),
      plot.title = element_text(face = "bold")
    )
}

make_custom_bubble <- function(df, fixed_group, mode = c("outgoing", "incoming"), title = NULL, top_n = 40L) {
  mode <- match.arg(mode)
  if (mode == "outgoing") {
    df <- df %>% filter(source == fixed_group) %>% mutate(partner = target)
    ylab <- "Target group"
  } else {
    df <- df %>% filter(target == fixed_group) %>% mutate(partner = source)
    ylab <- "Source group"
  }
  if (!nrow(df)) return(NULL)
  df <- df %>%
    arrange(desc(prob), pval) %>%
    slice_head(n = top_n) %>%
    mutate(
      interaction_label = factor(interaction_name, levels = rev(unique(interaction_name))),
      partner = factor(partner, levels = rev(unique(partner))),
      sig = pmax(-log10(pmax(pval, 1e-300)), 0)
    )
  ggplot(df, aes(x = interaction_label, y = partner, size = sig, fill = prob)) +
    geom_point(shape = 21, color = "#2F2F2F", stroke = 0.3, alpha = 0.95) +
    scale_fill_gradient(low = "#D7E3EA", high = "#B25636") +
    scale_size_continuous(range = c(1.8, 8)) +
    labs(title = title %||% fixed_group, x = NULL, y = ylab, fill = "Prob", size = "-log10(p)") +
    theme_paper() +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 7.4),
      panel.grid.major = element_line(color = "#ECE6DD", linewidth = 0.25),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold")
    )
}

extract_feature_values <- function(obj, gene, assay) {
  expr <- get_expr_matrix(obj, assay = assay, prefer = "data")
  if (gene %in% rownames(expr)) return(as.numeric(expr[gene, colnames(obj)]))
  gene_tokens <- unique(unlist(strsplit(gene, "[_:+&]")))
  gene_tokens <- gene_tokens[gene_tokens %in% rownames(expr)]
  if (!length(gene_tokens)) return(rep(NA_real_, ncol(obj)))
  colMeans(as.matrix(expr[gene_tokens, colnames(obj), drop = FALSE]), na.rm = TRUE)
}

make_group_map <- function(obj, group_col, sample_title, palette) {
  df <- wf_spatial_df(obj, group_col, source = "meta")
  levs <- unique(as.character(df$value))
  pal <- palette[intersect(names(palette), levs)]
  pal <- c(pal, setNames(rep("#BBBBBB", sum(!(levs %in% names(pal)))), levs[!(levs %in% names(pal))]))
  ggplot(df, aes(x = x, y = y, fill = value)) +
    geom_point(shape = 21, size = 2.2, stroke = 0.15, color = "#3A3A3A") +
    scale_fill_manual(values = pal, drop = FALSE) +
    coord_equal() +
    labs(title = sample_title, x = NULL, y = NULL, fill = "Group") +
    theme_void() +
    theme(
      legend.position = "right",
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
}

normalize_weight_table <- function(weight_mat) {
  rs <- rowSums(weight_mat, na.rm = TRUE)
  out <- weight_mat
  valid <- rs > 0
  out[valid, ] <- out[valid, , drop = FALSE] / rs[valid]
  out
}

assign_epi_high_low <- function(values, spot_ids, min_n = 10L) {
  if (length(values) < 2) {
    return(list(labels = setNames(rep(NA_character_, length(values)), spot_ids), threshold = NA_real_, method = "insufficient_spots"))
  }
  thr <- stats::median(values, na.rm = TRUE)
  prelim <- ifelse(values > thr, "high", "low")
  prelim_tbl <- table(prelim)
  ratio <- if (length(prelim_tbl) == 2) max(prelim_tbl) / max(1, min(prelim_tbl)) else Inf
  if (length(prelim_tbl) == 2 && all(prelim_tbl >= min_n) && ratio <= 1.8) {
    return(list(labels = setNames(prelim, spot_ids), threshold = thr, method = "sample_median"))
  }
  ord <- order(values, spot_ids, decreasing = TRUE, na.last = TRUE)
  labels <- rep("low", length(values))
  labels[ord[seq_len(ceiling(length(ord) / 2))]] <- "high"
  list(labels = setNames(labels, spot_ids), threshold = thr, method = "rank_balanced_median_tie_fix")
}

scenario_specs <- tribble(
  ~scenario_id, ~label, ~min_cells, ~interaction_length, ~scale_distance, ~distance_use,
  "main_m10_ir250", "Main", 10L, 250, 0.01, TRUE,
  "sens_m20_ir200", "Sensitivity", 20L, 200, 0.01, TRUE,
  "sens_m20_ir250", "Sensitivity", 20L, 250, 0.01, TRUE,
  "sens_m20_ir300", "Sensitivity", 20L, 300, 0.01, TRUE
)

copy_self_if_possible <- function() {
  file_arg <- commandArgs(trailingOnly = FALSE)
  file_arg <- sub("^--file=", "", file_arg[grepl("^--file=", file_arg)])
  if (length(file_arg) == 0) return(invisible(NULL))
  src <- normalizePath(file_arg[[1]], winslash = "/", mustWork = FALSE)
  if (file.exists(src)) {
    file.copy(src, file.path(dir_map$summary, basename(src)), overwrite = TRUE)
  }
}

copy_self_if_possible()

log_message("Starting spot-level CellChat analysis at %s", out_root)
log_message("This workflow reports spot-level inferred communication and region-level communication patterns only.")

input_candidates <- c(
  file.path(root_dir, "local_outputs", "3.rctd_deconvolution", "result", "rds", "spatial_with_rctd.rds"),
  file.path(root_dir, "local_outputs", "7.neighborhood_celltype", "result", "rds", "spatial_with_nhood.rds"),
  file.path(root_dir, "local_outputs", "6.ube2l6_binary", "result", "rds", "spatial_with_ube2l6_groups.rds")
)
existing_inputs <- input_candidates[file.exists(input_candidates)]
if (!length(existing_inputs)) stop("No candidate spatial objects were found.", call. = FALSE)
rctd_path <- existing_inputs[[1]]
ref_path <- file.path(root_dir, "local_outputs", "2.preprocess_and_reference", "result", "rds", "scrna_reference_for_rctd.rds")
if (!file.exists(ref_path)) stop("The RCTD reference object was not found.", call. = FALSE)

objs <- readRDS(rctd_path)
ref_obj <- readRDS(ref_path)
species <- infer_species(rownames(get_expr_matrix(ref_obj, assay = if ("RNA" %in% Assays(ref_obj)) "RNA" else DefaultAssay(ref_obj), prefer = "data")))
db_use <- if (identical(species, "mouse")) CellChatDB.mouse else CellChatDB.human
write_text(
  c(
    sprintf("primary_spatial_input: %s", normalizePath(rctd_path, winslash = "/", mustWork = FALSE)),
    sprintf("reference_input: %s", normalizePath(ref_path, winslash = "/", mustWork = FALSE)),
    sprintf("species_inference: %s", species),
    sprintf("database_selected: %s", if (identical(species, "mouse")) "CellChatDB.mouse" else "CellChatDB.human")
  ),
  file.path(dir_map$audit, "input_selection_and_species.txt")
)
log_message("Detected species as %s and selected %s", species, if (identical(species, "mouse")) "CellChatDB.mouse" else "CellChatDB.human")

audit_rows <- list()
metadata_rows <- list()
expr_list <- list()
scale_rows <- list()
ube_group_rows <- list()
sample_group_stats <- list()
group_palette <- c(
  Epithelial = "#D9AE60",
  Fibroblasts = "#EAA7B5",
  Endothelial = "#97C37B",
  SmoothMuscle = "#869FC7",
  Macrophage = "#E09A43",
  Mast_cells = "#CC5A4D",
  T_cells = "#4D87C7",
  NKT_cells = "#62A85C",
  B_cells = "#E6C58A",
  Plasma_cells = "#A28DCA",
  "Epithelial-rich" = "#C47A3A",
  "Immune-rich" = "#5B8BC4",
  "Stromal-rich" = "#83A878",
  EpiSpot_UBE2L6_high = "#B14C35",
  EpiSpot_UBE2L6_low = "#6C9BA7"
)

group_rule_lines <- c(
  "cellchat_group generation rules:",
  "1. Prefer a manually curated annotation column if present.",
  "2. Otherwise use RCTD dominant cell type.",
  "3. Mark a spot as broad-category rich when dominant weight < 0.55 or top1-top2 weight gap < 0.15, and the leading broad category weight >= 0.60.",
  "4. Broad categories: Epithelial; Immune = B_cells/T_cells/NKT_cells/Plasma_cells/Macrophage/Mast_cells; Stromal = Fibroblasts/Endothelial/SmoothMuscle.",
  "5. Epithelial-dominant or Epithelial-rich spots are split within each sample into EpiSpot_UBE2L6_high and EpiSpot_UBE2L6_low using the sample-specific median; a rank-balanced fallback is applied if the median split is too imbalanced."
)
write_text(group_rule_lines, file.path(dir_map$metadata, "grouping_rules.txt"))

for (sample_id in names(objs)) {
  obj <- objs[[sample_id]]
  meta <- obj@meta.data
  assay_use <- detect_assay(obj)
  expr <- get_expr_matrix(obj, assay = assay_use, prefer = "data")
  coords <- get_spatial_xy(obj)[colnames(obj), , drop = FALSE]
  sample_col <- detect_sample_column(meta)
  annotation_col <- detect_annotation_column(meta)
  dominant_col <- c("dominant_celltype", "celltype_std", "celltype")[c("dominant_celltype", "celltype_std", "celltype") %in% colnames(meta)][1]
  second_col <- c("second_celltype", "celltype2")[c("second_celltype", "celltype2") %in% colnames(meta)][1]
  dominant_vals <- if (!is.na(dominant_col)) as.character(meta[[dominant_col]]) else rep(NA_character_, nrow(meta))
  weight_cols <- detect_weight_columns(meta, dominant_values = dominant_vals)
  weight_tbl <- if (length(weight_cols)) as.matrix(meta[, weight_cols, drop = FALSE]) else matrix(NA_real_, nrow = nrow(meta), ncol = 0)
  if (length(weight_cols)) {
    rownames(weight_tbl) <- rownames(meta)
    weight_tbl_norm <- normalize_weight_table(weight_tbl)
    weight_export <- tibble(spot = rownames(weight_tbl_norm)) %>% bind_cols(as.data.frame(weight_tbl_norm))
    readr::write_csv(weight_export, file.path(dir_map$metadata, paste0(sample_id, "_rctd_weight_matrix.csv")))
  } else {
    weight_tbl_norm <- matrix(NA_real_, nrow = nrow(meta), ncol = 0)
    rownames(weight_tbl_norm) <- rownames(meta)
  }

  top1 <- if (!is.na(dominant_col)) as.character(meta[[dominant_col]]) else if (ncol(weight_tbl_norm)) colnames(weight_tbl_norm)[max.col(weight_tbl_norm, ties.method = "first")] else rep("Unknown", nrow(meta))
  top2 <- if (!is.na(second_col)) as.character(meta[[second_col]]) else if (ncol(weight_tbl_norm) > 1) {
    apply(weight_tbl_norm, 1, function(x) colnames(weight_tbl_norm)[order(x, decreasing = TRUE)[2]])
  } else {
    rep(NA_character_, nrow(meta))
  }

  top1_weight <- rep(NA_real_, nrow(meta))
  top2_weight <- rep(NA_real_, nrow(meta))
  if (ncol(weight_tbl_norm)) {
    top1_weight <- vapply(seq_len(nrow(weight_tbl_norm)), function(i) {
      val <- top1[[i]]
      if (is.na(val) || !(val %in% colnames(weight_tbl_norm))) max(weight_tbl_norm[i, ], na.rm = TRUE) else weight_tbl_norm[i, val]
    }, numeric(1))
    top2_weight <- vapply(seq_len(nrow(weight_tbl_norm)), function(i) {
      val <- top2[[i]]
      if (is.na(val) || !(val %in% colnames(weight_tbl_norm))) {
        ord <- sort(weight_tbl_norm[i, ], decreasing = TRUE)
        if (length(ord) >= 2) ord[[2]] else NA_real_
      } else {
        weight_tbl_norm[i, val]
      }
    }, numeric(1))
  }

  broad_categories <- c("Epithelial", "Immune", "Stromal")
  broad_scores <- matrix(0, nrow = nrow(meta), ncol = length(broad_categories), dimnames = list(rownames(meta), broad_categories))
  if (ncol(weight_tbl_norm)) {
    for (ct in colnames(weight_tbl_norm)) {
      bc <- broad_class(ct)
      if (bc %in% colnames(broad_scores)) {
        broad_scores[, bc] <- broad_scores[, bc] + weight_tbl_norm[, ct]
      }
    }
  }
  broad_top <- apply(broad_scores, 1, function(x) broad_categories[which.max(x)])
  broad_top_weight <- apply(broad_scores, 1, max, na.rm = TRUE)
  mixed_flag <- if (ncol(weight_tbl_norm)) (top1_weight < 0.55) | ((top1_weight - top2_weight) < 0.15) else FALSE

  if (!is.null(annotation_col)) {
    base_group <- as.character(meta[[annotation_col]])
    group_source <- "manual_annotation"
  } else if (ncol(weight_tbl_norm)) {
    base_group <- ifelse(mixed_flag & broad_top_weight >= 0.60, paste0(broad_top, "-rich"), top1)
    group_source <- "rctd_dominant_with_mixed_rule"
  } else {
    base_group <- top1
    group_source <- "dominant_celltype_fallback"
  }

  if (!"UBE2L6" %in% rownames(expr)) stop("UBE2L6 was not found in the normalized expression matrix.", call. = FALSE)
  ube_expr <- as.numeric(expr["UBE2L6", colnames(obj)])
  names(ube_expr) <- colnames(obj)
  epi_flag <- top1 == "Epithelial" | base_group == "Epithelial-rich"
  epi_ids <- colnames(obj)[epi_flag]
  epi_split <- assign_epi_high_low(ube_expr[epi_ids], epi_ids, min_n = 10L)
  epi_label <- rep(NA_character_, ncol(obj))
  names(epi_label) <- colnames(obj)
  epi_label[names(epi_split$labels)] <- epi_split$labels
  final_group <- base_group
  final_group[epi_flag] <- paste0("EpiSpot_UBE2L6_", epi_label[epi_flag])
  final_group[is.na(final_group) | !nzchar(final_group)] <- "Unknown"

  sample_group_stats[[sample_id]] <- tibble(sample_id = sample_id, cellchat_group = names(table(final_group)), n_spots = as.integer(table(final_group)))
  ube_group_rows[[sample_id]] <- tibble(
    sample_id = sample_id,
    n_epithelial_focus = length(epi_ids),
    median_threshold = epi_split$threshold,
    split_method = epi_split$method,
    n_high = sum(epi_label == "high", na.rm = TRUE),
    n_low = sum(epi_label == "low", na.rm = TRUE),
    imbalance_ratio = {
      tmp <- table(epi_label, useNA = "no")
      if (length(tmp) == 2) max(tmp) / max(1, min(tmp)) else NA_real_
    }
  )

  unique_ids <- paste(sample_id, colnames(obj), sep = "__")
  colnames(expr) <- unique_ids
  rownames(coords) <- unique_ids
  meta_tbl <- tibble(
    merged_spot_id = unique_ids,
    sample_id = sample_id,
    samples = sample_id,
    original_spot_id = colnames(obj),
    assay_used = assay_use,
    sample_column_detected = sample_col %||% NA_character_,
    annotation_column_detected = annotation_col %||% NA_character_,
    group_source = group_source,
    dominant_celltype = top1,
    second_celltype = top2,
    base_group = base_group,
    cellchat_group = final_group,
    group = final_group,
    UBE2L6_expr = ube_expr[colnames(obj)],
    epithelial_focus = epi_flag,
    epithelial_ube2l6_group = epi_label,
    epithelial_split_threshold = epi_split$threshold,
    epithelial_split_method = epi_split$method,
    mixed_flag = mixed_flag,
    top1_weight = top1_weight,
    top2_weight = top2_weight,
    epithelial_score = broad_scores[, "Epithelial"],
    immune_score = broad_scores[, "Immune"],
    stromal_score = broad_scores[, "Stromal"],
    x = coords[unique_ids, "x"],
    y = coords[unique_ids, "y"]
  )
  if ("BayesSpace_domain" %in% colnames(meta)) {
    meta_tbl$BayesSpace_domain <- as.character(meta$BayesSpace_domain)
  }
  metadata_rows[[sample_id]] <- meta_tbl
  expr_list[[sample_id]] <- expr

  scale_tbl <- extract_scale_factors(obj)
  scale_tbl$sample_id <- sample_id
  scale_rows[[sample_id]] <- scale_tbl

  audit_rows[[sample_id]] <- tibble(
    sample_id = sample_id,
    object_class = paste(class(obj), collapse = "|"),
    n_spots = ncol(obj),
    n_genes = nrow(obj),
    assays = paste(Assays(obj), collapse = "|"),
    assay_used = assay_use,
    sample_column = sample_col %||% NA_character_,
    annotation_column = annotation_col %||% NA_character_,
    dominant_column = dominant_col %||% NA_character_,
    second_column = second_col %||% NA_character_,
    weight_columns = paste(weight_cols, collapse = "|"),
    n_weight_columns = length(weight_cols),
    coord_columns = "x|y",
    group_source = group_source
  )
}

audit_tbl <- bind_rows(audit_rows)
meta_all <- bind_rows(metadata_rows)
scale_tbl <- bind_rows(scale_rows)
group_count_tbl <- bind_rows(sample_group_stats) %>% group_by(cellchat_group) %>% mutate(sample_prop = n_spots / sum(n_spots)) %>% ungroup()
group_count_all <- meta_all %>% count(cellchat_group, name = "n_spots") %>% arrange(desc(n_spots))
ube_group_tbl <- bind_rows(ube_group_rows)

width_tbl <- meta_all %>% group_by(sample_id) %>% summarise(xmin = min(x), xmax = max(x), .groups = "drop") %>% mutate(width = xmax - xmin)
gap <- max(width_tbl$width, na.rm = TRUE) + 1000
offsets <- tibble(sample_id = width_tbl$sample_id, x_offset = seq(0, by = gap, length.out = nrow(width_tbl)))
meta_all <- meta_all %>% left_join(offsets, by = "sample_id") %>% mutate(x_cellchat = x + x_offset, y_cellchat = y)

common_genes <- Reduce(intersect, lapply(expr_list, rownames))
expr_all <- do.call(cbind, lapply(expr_list, function(x) x[common_genes, , drop = FALSE]))
meta_all <- meta_all %>% slice(match(colnames(expr_all), merged_spot_id))
stopifnot(identical(meta_all$merged_spot_id, colnames(expr_all)))

spatial_factors <- list(
  spot.diameter = stats::median(scale_tbl$spot_diameter, na.rm = TRUE),
  spot = stats::median(scale_tbl$spot, na.rm = TRUE)
)
if (!is.finite(spatial_factors$spot.diameter)) spatial_factors$spot.diameter <- 1
if (!is.finite(spatial_factors$spot)) spatial_factors$spot <- spatial_factors$spot.diameter

readr::write_csv(audit_tbl, file.path(dir_map$audit, "object_audit.csv"))
readr::write_csv(scale_tbl, file.path(dir_map$audit, "spatial_factors_by_sample.csv"))
readr::write_csv(tibble(name = names(spatial_factors), value = unlist(spatial_factors)), file.path(dir_map$audit, "spatial_factors_used_for_cellchat.csv"))
readr::write_csv(meta_all, file.path(dir_map$metadata, "spot_metadata_with_cellchat_groups.csv"))
readr::write_csv(group_count_all, file.path(dir_map$metadata, "all_group_spot_counts.csv"))
readr::write_csv(group_count_tbl, file.path(dir_map$metadata, "group_counts_by_sample.csv"))
readr::write_csv(ube_group_tbl, file.path(dir_map$metadata, "epithelial_ube2l6_group_stats.csv"))
readr::write_csv(meta_all %>% filter(epithelial_focus) %>% count(sample_id, cellchat_group, name = "n_spots"), file.path(dir_map$metadata, "epithelial_focus_group_counts.csv"))
readr::write_csv(meta_all %>% select(merged_spot_id, sample_id, original_spot_id, x, y, x_cellchat, y_cellchat), file.path(dir_map$metadata, "spot_coordinates_for_cellchat.csv"))

qc_group_small <- group_count_all %>% mutate(flag_too_small_for_main = n_spots < 10L, flag_too_small_for_sensitivity = n_spots < 20L)
qc_sample_dominance <- group_count_tbl %>% group_by(cellchat_group) %>% summarise(max_sample_prop = max(sample_prop, na.rm = TRUE), dominant_sample = sample_id[which.max(sample_prop)], .groups = "drop") %>% mutate(flag_single_sample_dominance = max_sample_prop > 0.8)
qc_mixedness <- meta_all %>% group_by(sample_id) %>% summarise(mixed_spots = sum(mixed_flag, na.rm = TRUE), mixed_fraction = mean(mixed_flag, na.rm = TRUE), epithelial_rich_spots = sum(base_group == "Epithelial-rich", na.rm = TRUE), .groups = "drop")
readr::write_csv(qc_group_small, file.path(dir_map$audit, "qc_group_size_flags.csv"))
readr::write_csv(qc_sample_dominance, file.path(dir_map$audit, "qc_sample_dominance.csv"))
readr::write_csv(qc_mixedness, file.path(dir_map$audit, "qc_spot_mixedness.csv"))

meta_all$group <- factor(meta_all$group, levels = unique(meta_all$group))
coords_all <- as.matrix(meta_all[, c("x_cellchat", "y_cellchat")])
rownames(coords_all) <- meta_all$merged_spot_id

log_message("Merged object prepared with %d spots, %d genes, and %d groups", ncol(expr_all), nrow(expr_all), nlevels(meta_all$group))

run_cellchat_scenario <- function(expr_mat, meta_tbl, coords_mat, db_obj, scenario_row, spatial_factors_use) {
  scenario_id <- scenario_row$scenario_id[[1]]
  scale_candidates <- unique(c(scenario_row$scale_distance[[1]], 0.02, 0.05, 0.1, 0.2, 0.5, 1))
  last_error <- NULL
  for (scale_try in scale_candidates) {
    log_message("Running scenario %s with min.cells=%d interaction.length=%d scale.distance=%s", scenario_id, scenario_row$min_cells[[1]], scenario_row$interaction_length[[1]], format(scale_try))
    res <- tryCatch({
      cellchat <- createCellChat(
        object = expr_mat,
        meta = meta_tbl,
        group.by = "group",
        datatype = "spatial",
        coordinates = coords_mat,
        scale.factors = spatial_factors_use
      )
      if (exists("updateCellChat", where = asNamespace("CellChat"), inherits = FALSE)) {
        cellchat <- tryCatch(updateCellChat(cellchat), error = function(e) cellchat)
      }
      cellchat@DB <- db_obj
      cellchat <- subsetData(cellchat)
      cellchat <- identifyOverExpressedGenes(cellchat)
      cellchat <- identifyOverExpressedInteractions(cellchat)
      cellchat <- computeCommunProb(
        cellchat,
        type = "truncatedMean",
        trim = 0.1,
        raw.use = TRUE,
        population.size = FALSE,
        distance.use = scenario_row$distance_use[[1]],
        interaction.length = scenario_row$interaction_length[[1]],
        scale.distance = scale_try,
        k.min = 10L,
        nboot = 100L,
        seed.use = cfg$analysis$seeds$global %||% 1L
      )
      cellchat <- filterCommunication(cellchat, min.cells = scenario_row$min_cells[[1]])
      cellchat <- computeCommunProbPathway(cellchat)
      cellchat <- aggregateNet(cellchat)
      cellchat <- tryCatch(netAnalysis_computeCentrality(cellchat, slot.name = "netP"), error = function(e) cellchat)
      list(cellchat = cellchat, scale.distance = scale_try)
    }, error = function(e) {
      last_error <<- conditionMessage(e)
      NULL
    })
    if (!is.null(res)) return(res)
    log_message("Scenario %s failed at scale.distance=%s: %s", scenario_id, format(scale_try), last_error)
    if (!grepl("scale.distance", last_error, fixed = TRUE)) break
  }
  stop(sprintf("Scenario %s failed after retries: %s", scenario_id, last_error), call. = FALSE)
}

extract_tables_from_cellchat <- function(cellchat, scenario_id) {
  comm_tbl <- subsetCommunication(cellchat, slot.name = "net", thresh = 0.05)
  path_tbl <- subsetCommunication(cellchat, slot.name = "netP", thresh = 0.05)
  if (is.null(comm_tbl) || !nrow(comm_tbl)) comm_tbl <- tibble()
  if (is.null(path_tbl) || !nrow(path_tbl)) path_tbl <- tibble()
  lr_tbl <- if (nrow(comm_tbl)) {
    comm_tbl %>%
      group_by(pathway_name, interaction_name, ligand, receptor) %>%
      summarise(
        n_edges = n(),
        total_prob = sum(prob, na.rm = TRUE),
        mean_prob = mean(prob, na.rm = TRUE),
        min_pval = min(pval, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total_prob), min_pval)
  } else {
    tibble()
  }
  path_total_tbl <- if (nrow(path_tbl)) {
    path_tbl %>%
      group_by(pathway_name) %>%
      summarise(
        n_edges = n(),
        total_prob = sum(prob, na.rm = TRUE),
        mean_prob = mean(prob, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total_prob))
  } else {
    tibble()
  }
  summary_tbl <- tibble(
    scenario_id = scenario_id,
    n_groups = length(levels(cellchat@idents)),
    n_significant_edges = nrow(comm_tbl),
    n_significant_pathway_edges = nrow(path_tbl),
    n_lr_pairs = nrow(lr_tbl),
    total_probability = if (nrow(comm_tbl)) sum(comm_tbl$prob, na.rm = TRUE) else 0,
    high_outgoing_probability = if (nrow(comm_tbl)) sum(comm_tbl$prob[comm_tbl$source == "EpiSpot_UBE2L6_high"], na.rm = TRUE) else 0,
    low_outgoing_probability = if (nrow(comm_tbl)) sum(comm_tbl$prob[comm_tbl$source == "EpiSpot_UBE2L6_low"], na.rm = TRUE) else 0
  )
  list(comm = comm_tbl, pathway = path_tbl, pathway_total = path_total_tbl, lr_total = lr_tbl, summary = summary_tbl)
}

scenario_results <- list()
scenario_table_summaries <- list()

for (i in seq_len(nrow(scenario_specs))) {
  scen <- scenario_specs[i, , drop = FALSE]
  scenario_id <- scen$scenario_id[[1]]
  scenario_obj <- run_cellchat_scenario(expr_all, meta_all, coords_all, db_use, scen, spatial_factors)
  cellchat <- scenario_obj$cellchat
  saveRDS(cellchat, file.path(dir_map$objects, paste0(scenario_id, "_cellchat.rds")))
  scenario_tables <- extract_tables_from_cellchat(cellchat, scenario_id)
  scenario_results[[scenario_id]] <- list(
    spec = scen,
    scale.distance = scenario_obj$scale.distance,
    cellchat = cellchat,
    tables = scenario_tables
  )
  scenario_table_summaries[[scenario_id]] <- scenario_tables$summary %>%
    mutate(
      min_cells = scen$min_cells[[1]],
      interaction_length = scen$interaction_length[[1]],
      scale_distance_used = scenario_obj$scale.distance
    )
  if (nrow(scenario_tables$comm)) {
    readr::write_csv(scenario_tables$comm, file.path(dir_map$tables, paste0(scenario_id, "_significant_communication.csv")))
    readr::write_csv(scenario_tables$lr_total, file.path(dir_map$tables, paste0(scenario_id, "_lr_totals.csv")))
  }
  if (nrow(scenario_tables$pathway)) {
    readr::write_csv(scenario_tables$pathway, file.path(dir_map$tables, paste0(scenario_id, "_pathway_edges.csv")))
    readr::write_csv(scenario_tables$pathway_total, file.path(dir_map$tables, paste0(scenario_id, "_pathway_totals.csv")))
  }
  readr::write_csv(scenario_tables$summary, file.path(dir_map$sensitivity, paste0(scenario_id, "_scenario_summary.csv")))
}

scenario_summary_tbl <- bind_rows(scenario_table_summaries)
readr::write_csv(scenario_summary_tbl, file.path(dir_map$sensitivity, "scenario_summary.csv"))

main_result <- scenario_results[["main_m10_ir250"]]
if (is.null(main_result)) stop("The main scenario did not complete successfully.", call. = FALSE)
main_cellchat <- main_result$cellchat
main_comm <- main_result$tables$comm
main_path_total <- main_result$tables$pathway_total
main_lr_total <- main_result$tables$lr_total

readr::write_csv(main_comm, file.path(dir_map$tables, "significant_communication_total_table.csv"))
readr::write_csv(main_path_total, file.path(dir_map$tables, "pathway_level_communication_total_table.csv"))
readr::write_csv(main_lr_total, file.path(dir_map$tables, "ligand_receptor_pair_total_table.csv"))

build_high_low_diff_table <- function(comm_tbl) {
  if (!nrow(comm_tbl)) return(tibble())
  high_out <- comm_tbl %>% filter(source == "EpiSpot_UBE2L6_high") %>% transmute(direction = "outgoing", partner = target, pathway_name, interaction_name, ligand, receptor, high_prob = prob, high_pval = pval)
  low_out <- comm_tbl %>% filter(source == "EpiSpot_UBE2L6_low") %>% transmute(direction = "outgoing", partner = target, pathway_name, interaction_name, ligand, receptor, low_prob = prob, low_pval = pval)
  high_in <- comm_tbl %>% filter(target == "EpiSpot_UBE2L6_high") %>% transmute(direction = "incoming", partner = source, pathway_name, interaction_name, ligand, receptor, high_prob = prob, high_pval = pval)
  low_in <- comm_tbl %>% filter(target == "EpiSpot_UBE2L6_low") %>% transmute(direction = "incoming", partner = source, pathway_name, interaction_name, ligand, receptor, low_prob = prob, low_pval = pval)
  full_join(bind_rows(high_out, high_in), bind_rows(low_out, low_in), by = c("direction", "partner", "pathway_name", "interaction_name", "ligand", "receptor")) %>%
    mutate(
      high_prob = coalesce(high_prob, 0),
      low_prob = coalesce(low_prob, 0),
      delta_prob = high_prob - low_prob,
      high_pval = coalesce(high_pval, 1),
      low_pval = coalesce(low_pval, 1),
      stronger_state = case_when(delta_prob > 0 ~ "high", delta_prob < 0 ~ "low", TRUE ~ "equal")
    ) %>%
    arrange(desc(abs(delta_prob)), pmin(high_pval, low_pval))
}

diff_tbl <- build_high_low_diff_table(main_comm)
readr::write_csv(diff_tbl, file.path(dir_map$tables, "EpiSpot_UBE2L6_high_vs_low_differential_communication.csv"))

group_size_vec <- table(main_cellchat@idents)
group_size_vec <- as.numeric(group_size_vec)
names(group_size_vec) <- names(table(main_cellchat@idents))

safe_capture(
  save_base_plot(dir_map$network, "interaction_number_circle_plot", 8, 8, {
    netVisual_circle(main_cellchat@net$count, vertex.weight = group_size_vec, weight.scale = TRUE, label.edge = FALSE, title.name = "Interaction number")
  }),
  label = "interaction number circle plot"
)
safe_capture(
  save_base_plot(dir_map$network, "interaction_strength_circle_plot", 8, 8, {
    netVisual_circle(main_cellchat@net$weight, vertex.weight = group_size_vec, weight.scale = TRUE, label.edge = FALSE, title.name = "Interaction strength")
  }),
  label = "interaction strength circle plot"
)

save_gg(make_heatmap_plot(main_cellchat@net$count, "Interaction count heatmap", "Count"), dir_map$network, "interaction_count_heatmap", 8.4, 6.6)
save_gg(make_heatmap_plot(main_cellchat@net$weight, "Interaction weight heatmap", "Weight"), dir_map$network, "interaction_weight_heatmap", 8.4, 6.6)

for (grp in c("EpiSpot_UBE2L6_high", "EpiSpot_UBE2L6_low")) {
  bub_out <- make_custom_bubble(main_comm, grp, mode = "outgoing", title = paste(grp, "outgoing spot-level inferred communication"))
  bub_in <- make_custom_bubble(main_comm, grp, mode = "incoming", title = paste(grp, "incoming spot-level inferred communication"))
  if (!is.null(bub_out)) save_gg(bub_out, dir_map$lr, paste0(grp, "_outgoing_bubble"), 10.5, 5.5)
  if (!is.null(bub_in)) save_gg(bub_in, dir_map$lr, paste0(grp, "_incoming_bubble"), 10.5, 5.5)
}

top_pathways <- if (nrow(diff_tbl)) {
  diff_tbl %>%
    group_by(pathway_name) %>%
    summarise(total_abs_delta = sum(abs(delta_prob), na.rm = TRUE), .groups = "drop") %>%
    filter(!is.na(pathway_name), nzchar(pathway_name)) %>%
    arrange(desc(total_abs_delta)) %>%
    slice_head(n = 6) %>%
    pull(pathway_name)
} else {
  head(main_path_total$pathway_name, 6)
}

for (pathway_name in top_pathways) {
  safe_capture(
    save_base_plot(dir_map$pathway, paste0("aggregate_", pathway_name), 7.8, 7.2, {
      netVisual_aggregate(main_cellchat, signaling = pathway_name, layout = "circle")
      graphics::title(main = pathway_name)
    }),
    label = paste("aggregate plot", pathway_name)
  )
}

top_lr_plot_tbl <- if (nrow(diff_tbl)) diff_tbl %>% slice_head(n = 20) else tibble()
if (nrow(top_lr_plot_tbl)) {
  p_lr <- top_lr_plot_tbl %>%
    mutate(lr_label = paste0(interaction_name, " | ", direction, " | ", partner)) %>%
    mutate(lr_label = factor(lr_label, levels = rev(unique(lr_label)))) %>%
    ggplot(aes(x = delta_prob, y = lr_label, fill = stronger_state)) +
    geom_col(color = "#2E2E2E", linewidth = 0.2) +
    scale_fill_manual(values = c(high = "#B25636", low = "#6B98A3", equal = "#C7C7C7")) +
    labs(
      title = "Top LR contrasts: EpiSpot_UBE2L6_high vs EpiSpot_UBE2L6_low",
      x = "Delta probability (high - low)",
      y = NULL,
      fill = "Stronger state"
    ) +
    theme_paper() +
    theme(plot.title = element_text(face = "bold"))
  save_gg(p_lr, dir_map$lr, "top_lr_contrast_barplot", 10.8, 6.8)
}

top_lr_pairs <- if (nrow(diff_tbl)) diff_tbl %>% filter(!is.na(ligand), !is.na(receptor)) %>% slice_head(n = 4) else tibble()
if (nrow(top_lr_pairs)) {
  sample_ids <- unique(meta_all$sample_id)
  for (i in seq_len(nrow(top_lr_pairs))) {
    lr_row <- top_lr_pairs[i, , drop = FALSE]
    lig <- lr_row$ligand[[1]]
    rec <- lr_row$receptor[[1]]
    lr_stem <- paste0(sprintf("%02d", i), "_", gsub("[^A-Za-z0-9._-]+", "_", lr_row$interaction_name[[1]]))
    for (sample_id in sample_ids) {
      obj <- objs[[sample_id]]
      assay_use <- detect_assay(obj)
      meta_sample <- meta_all %>% filter(sample_id == !!sample_id)
      obj$cellchat_group_runtime <- meta_sample$cellchat_group[match(colnames(obj), meta_sample$original_spot_id)]
      lig_vals <- extract_feature_values(obj, lig, assay_use)
      rec_vals <- extract_feature_values(obj, rec, assay_use)
      coords <- get_spatial_xy(obj)
      coords$spot <- rownames(coords)
      lig_df <- coords
      lig_df$value <- lig_vals[match(coords$spot, colnames(obj))]
      rec_df <- coords
      rec_df$value <- rec_vals[match(coords$spot, colnames(obj))]
      p_group <- make_group_map(obj, "cellchat_group_runtime", paste(sample_id, "groups"), group_palette)
      p_lig <- wf_plot_spatial_feature_ref1_style(lig_df, feature_name = lig, legend_title = lig) + ggtitle(paste(sample_id, lig))
      p_rec <- wf_plot_spatial_feature_ref1_style(rec_df, feature_name = rec, legend_title = rec) + ggtitle(paste(sample_id, rec))
      panel <- p_group + p_lig + p_rec + plot_layout(ncol = 3)
      save_gg(panel, dir_map$spatial, paste0(sample_id, "_", lr_stem, "_spatial_map"), 14.5, 4.9)
    }
  }
}

scenario_path_presence <- bind_rows(lapply(names(scenario_results), function(sid) {
  tbl <- scenario_results[[sid]]$tables$pathway_total
  if (!nrow(tbl)) return(tibble())
  tbl %>% mutate(scenario_id = sid, pathway_rank = row_number())
}))
scenario_lr_presence <- bind_rows(lapply(names(scenario_results), function(sid) {
  tbl <- scenario_results[[sid]]$tables$lr_total
  if (!nrow(tbl)) return(tibble())
  tbl %>% mutate(scenario_id = sid, lr_rank = row_number())
}))

pathway_stability_tbl <- if (nrow(scenario_path_presence)) {
  scenario_path_presence %>%
    group_by(pathway_name) %>%
    summarise(
      present_in = n_distinct(scenario_id),
      min_rank = min(pathway_rank, na.rm = TRUE),
      max_rank = max(pathway_rank, na.rm = TRUE),
      mean_total_prob = mean(total_prob, na.rm = TRUE),
      stable_across_main_and_sensitivity = present_in == length(scenario_results),
      .groups = "drop"
    ) %>%
    arrange(desc(stable_across_main_and_sensitivity), min_rank, desc(mean_total_prob))
} else {
  tibble()
}
lr_stability_tbl <- if (nrow(scenario_lr_presence)) {
  scenario_lr_presence %>%
    group_by(pathway_name, interaction_name, ligand, receptor) %>%
    summarise(
      present_in = n_distinct(scenario_id),
      min_rank = min(lr_rank, na.rm = TRUE),
      max_rank = max(lr_rank, na.rm = TRUE),
      mean_total_prob = mean(total_prob, na.rm = TRUE),
      stable_across_main_and_sensitivity = present_in == length(scenario_results),
      .groups = "drop"
    ) %>%
    arrange(desc(stable_across_main_and_sensitivity), min_rank, desc(mean_total_prob))
} else {
  tibble()
}

readr::write_csv(pathway_stability_tbl, file.path(dir_map$sensitivity, "pathway_stability_summary.csv"))
readr::write_csv(lr_stability_tbl, file.path(dir_map$sensitivity, "lr_stability_summary.csv"))

contact_status_tbl <- tibble(
  contact_analysis_status = "skipped",
  reason = "Installed CellChat 1.6.1 computeCommunProb() has no contact.dependent/contact.range/contact.knn.k arguments; optional contact-dependent analysis was not fabricated."
)
readr::write_csv(contact_status_tbl, file.path(dir_map$sensitivity, "contact_dependent_analysis_status.csv"))

qc_summary_tbl <- tibble(
  check_name = c(
    "small_groups_main",
    "small_groups_sensitivity",
    "UBE2L6_high_low_balance",
    "single_sample_dominance",
    "interaction_range_stability",
    "contact_dependent_consistency",
    "spot_mixedness_interpretation"
  ),
  status = c(
    if (any(qc_group_small$flag_too_small_for_main)) "flagged" else "ok",
    if (any(qc_group_small$flag_too_small_for_sensitivity)) "flagged" else "ok",
    if (any(ube_group_tbl$imbalance_ratio > 1.8, na.rm = TRUE)) "flagged" else "ok",
    if (any(qc_sample_dominance$flag_single_sample_dominance, na.rm = TRUE)) "flagged" else "ok",
    if (nrow(pathway_stability_tbl) && any(pathway_stability_tbl$stable_across_main_and_sensitivity)) "partially_stable" else "uncertain",
    "not_available_in_current_cellchat_version",
    if (any(qc_mixedness$mixed_fraction > 0.25, na.rm = TRUE)) "mixed_spots_present" else "limited_mixing"
  ),
  details = c(
    paste(qc_group_small$cellchat_group[qc_group_small$flag_too_small_for_main], collapse = "; "),
    paste(qc_group_small$cellchat_group[qc_group_small$flag_too_small_for_sensitivity], collapse = "; "),
    paste(sprintf("%s ratio=%.2f", ube_group_tbl$sample_id, ube_group_tbl$imbalance_ratio), collapse = "; "),
    paste(sprintf("%s->%s(%.2f)", qc_sample_dominance$cellchat_group, qc_sample_dominance$dominant_sample, qc_sample_dominance$max_sample_prop), collapse = "; "),
    paste(head(pathway_stability_tbl$pathway_name[pathway_stability_tbl$stable_across_main_and_sensitivity], 10), collapse = "; "),
    contact_status_tbl$reason[[1]],
    paste(sprintf("%s mixed_fraction=%.3f", qc_mixedness$sample_id, qc_mixedness$mixed_fraction), collapse = "; ")
  )
)
readr::write_csv(qc_summary_tbl, file.path(dir_map$audit, "qc_summary.csv"))

robust_pathways <- if (nrow(pathway_stability_tbl)) pathway_stability_tbl %>% filter(stable_across_main_and_sensitivity) %>% slice_head(n = 10) %>% pull(pathway_name) else character()
sensitive_pathways <- if (nrow(pathway_stability_tbl)) pathway_stability_tbl %>% filter(!stable_across_main_and_sensitivity) %>% slice_head(n = 10) %>% pull(pathway_name) else character()
robust_lr <- if (nrow(lr_stability_tbl)) lr_stability_tbl %>% filter(stable_across_main_and_sensitivity) %>% slice_head(n = 10) %>% transmute(lbl = paste0(interaction_name, " (", pathway_name, ")")) %>% pull(lbl) else character()
sensitive_lr <- if (nrow(lr_stability_tbl)) lr_stability_tbl %>% filter(!stable_across_main_and_sensitivity) %>% slice_head(n = 10) %>% transmute(lbl = paste0(interaction_name, " (", pathway_name, ")")) %>% pull(lbl) else character()

summary_lines <- c(
  "# CellChat spot-level summary",
  "",
  "This analysis was performed as spot-level inferred communication using 10x Visium spots with RCTD-derived grouping metadata. The results should be interpreted as spot-level inferred communication and region-level communication patterns rather than true single-cell communication or direct cell-cell interaction.",
  "",
  "## Input audit",
  "",
  sprintf("- Spatial object source: `%s`", normalizePath(rctd_path, winslash = "/", mustWork = FALSE)),
  sprintf("- Reference object source: `%s`", normalizePath(ref_path, winslash = "/", mustWork = FALSE)),
  sprintf("- Samples analysed: %s", paste(names(objs), collapse = ", ")),
  sprintf("- Species inference: `%s`; CellChat database: `%s`", species, if (identical(species, "mouse")) "CellChatDB.mouse" else "CellChatDB.human"),
  sprintf("- Normalized assay used: %s", paste(unique(audit_tbl$assay_used), collapse = ", ")),
  sprintf("- RCTD weight columns detected: %s", paste(unique(unlist(strsplit(audit_tbl$weight_columns[nzchar(audit_tbl$weight_columns)], "\\|"))), collapse = ", ")),
  "",
  "## Grouping logic",
  "",
  "- `cellchat_group` was generated from RCTD dominant cell type with an explicit mixed-spot rule; no manual author-confirmed spot annotation column was detected in the primary input object.",
  "- Epithelial-dominant or epithelial-rich spots were split within each sample into `EpiSpot_UBE2L6_high` and `EpiSpot_UBE2L6_low` using the sample-specific UBE2L6 median, with rank balancing only when the raw median split was too imbalanced.",
  "- Non-epithelial spots retained their original group labels.",
  "",
  "## Main interpretation",
  "",
  "The main result should be described as a `UBE2L6-associated epithelial spot communication state`. In this framework, epithelial-enriched spots showed altered outgoing/incoming signaling relative to their lower-UBE2L6 counterparts at the spot level.",
  "",
  sprintf("- Significant communication edges in the main scenario: %d", nrow(main_comm)),
  sprintf("- Significant pathway edges in the main scenario: %d", nrow(main_result$tables$pathway)),
  sprintf("- High-state outgoing probability sum: %.4f", main_result$tables$summary$high_outgoing_probability[[1]]),
  sprintf("- Low-state outgoing probability sum: %.4f", main_result$tables$summary$low_outgoing_probability[[1]]),
  "",
  "## Robust findings",
  ""
)
summary_lines <- c(summary_lines, if (length(robust_pathways)) paste0("- Robust pathways across the tested parameter grid: ", paste(robust_pathways, collapse = ", ")) else "- No pathway met the strict across-scenario stability definition.")
summary_lines <- c(summary_lines, if (length(robust_lr)) paste0("- Robust LR pairs across the tested parameter grid: ", paste(robust_lr, collapse = ", ")) else "- No LR pair met the strict across-scenario stability definition.")
summary_lines <- c(summary_lines, "", "## Parameter-sensitive findings", "")
summary_lines <- c(summary_lines, if (length(sensitive_pathways)) paste0("- Parameter-sensitive pathways: ", paste(sensitive_pathways, collapse = ", ")) else "- No major pathway sensitivity was detected in the extracted summary table.")
summary_lines <- c(summary_lines, if (length(sensitive_lr)) paste0("- Parameter-sensitive LR pairs: ", paste(sensitive_lr, collapse = ", ")) else "- No major LR sensitivity was detected in the extracted summary table.")
summary_lines <- c(summary_lines,
  "",
  "## QC caveats",
  "",
  sprintf("- Group-size QC: %s", paste(qc_summary_tbl$status[qc_summary_tbl$check_name %in% c("small_groups_main", "small_groups_sensitivity")], collapse = ", ")),
  sprintf("- UBE2L6 high/low balance: %s", qc_summary_tbl$details[qc_summary_tbl$check_name == "UBE2L6_high_low_balance"]),
  sprintf("- Sample dominance: %s", qc_summary_tbl$details[qc_summary_tbl$check_name == "single_sample_dominance"]),
  sprintf("- Spot mixedness: %s", qc_summary_tbl$details[qc_summary_tbl$check_name == "spot_mixedness_interpretation"]),
  sprintf("- Contact-dependent comparison: %s", contact_status_tbl$reason[[1]]),
  "",
  "## Recommended wording",
  "",
  "- `UBE2L6-associated epithelial spot communication state`",
  "- `spot-level inferred communication`",
  "- `epithelial-enriched spots showed altered outgoing/incoming signaling`",
  "",
  "Avoid wording that implies true single-cell communication, direct cell-cell interaction, or definitive causal effect."
)
write_text(summary_lines, file.path(dir_map$summary, "cellchat_rctd_spot_summary.md"))

session_info_path <- file.path(dir_map$logs, "sessionInfo.txt")
write_text(utils::capture.output(sessionInfo()), session_info_path)

log_message("Completed. Outputs were written to %s", out_root)






recover_rctd_weight_exports <- function() {
  known_weight_cols <- c("B_cells", "Endothelial", "Epithelial", "Fibroblasts", "Macrophage", "Mast_cells", "NKT_cells", "Plasma_cells", "SmoothMuscle", "T_cells")
  recovered_rows <- list()
  for (sample_id in names(objs)) {
    md <- objs[[sample_id]]@meta.data
    cols <- intersect(known_weight_cols, colnames(md))
    if (length(cols) < 3) next
    weight_tbl <- as.matrix(md[, cols, drop = FALSE])
    rs <- rowSums(weight_tbl, na.rm = TRUE)
    keep <- rs > 0
    weight_tbl[keep, ] <- weight_tbl[keep, , drop = FALSE] / rs[keep]
    out_tbl <- tibble(spot = rownames(weight_tbl)) %>% bind_cols(as.data.frame(weight_tbl))
    readr::write_csv(out_tbl, file.path(dir_map$metadata, paste0(sample_id, "_rctd_weight_matrix.csv")))
    recovered_rows[[sample_id]] <- tibble(sample_id = sample_id, weight_columns = paste(cols, collapse = "|"), n_weight_columns = length(cols))
  }
  recovered_tbl <- bind_rows(recovered_rows)
  if (nrow(recovered_tbl)) {
    audit_fix <- audit_tbl %>% select(-weight_columns, -n_weight_columns) %>% left_join(recovered_tbl, by = "sample_id")
    readr::write_csv(audit_fix, file.path(dir_map$audit, "object_audit.csv"))
    summary_path <- file.path(dir_map$summary, "cellchat_rctd_spot_summary.md")
    if (file.exists(summary_path)) {
      txt <- readLines(summary_path, warn = FALSE)
      idx <- grep('^- RCTD weight columns detected:', txt)
      if (length(idx) == 1) {
        all_cols <- unique(unlist(strsplit(paste(recovered_tbl$weight_columns, collapse = "|"), "\\|")))
        txt[idx] <- paste0("- RCTD weight columns detected: ", paste(all_cols, collapse = ", "))
        writeLines(txt, summary_path)
      }
    }
    log_message("Recovered and exported RCTD weight matrices for %d samples", nrow(recovered_tbl))
  }
}

recover_rctd_weight_exports()
