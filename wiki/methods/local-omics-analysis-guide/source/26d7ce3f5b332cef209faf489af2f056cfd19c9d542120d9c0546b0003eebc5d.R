#!/usr/bin/env Rscript

source(file.path('code', 'R', 'workflow_helpers.R'))

suppressWarnings(grDevices::pdf.options(family = 'Helvetica'))

suppressPackageStartupMessages({
  library(Seurat)
  library(CellChat)
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(tibble)
  library(patchwork)
})

cfg <- wf_load_config()
wf_ensure_local_lib(cfg)
wf_set_seed(cfg)

root_dir <- wf_find_root()
out_root <- file.path(root_dir, 'results', 'cellchat_rctd_spot')
dir_map <- list(
  objects = file.path(out_root, '02_cellchat_objects'),
  metadata = file.path(out_root, '01_metadata'),
  tables = file.path(out_root, '03_tables'),
  pathway = file.path(out_root, '05_pathway_plots'),
  lr = file.path(out_root, '06_LR_plots'),
  spatial = file.path(out_root, '07_spatial_maps'),
  sensitivity = file.path(out_root, '08_sensitivity'),
  summary = file.path(out_root, '09_summary'),
  logs = file.path(out_root, '10_logs')
)
for (x in dir_map) dir.create(x, recursive = TRUE, showWarnings = FALSE)

copy_self_if_possible <- function() {
  file_arg <- commandArgs(trailingOnly = FALSE)
  file_arg <- sub('^--file=', '', file_arg[grepl('^--file=', file_arg)])
  if (length(file_arg) == 0) return(invisible(NULL))
  src <- normalizePath(file_arg[[1]], winslash = '/', mustWork = FALSE)
  if (file.exists(src)) file.copy(src, file.path(dir_map$summary, basename(src)), overwrite = TRUE)
}
copy_self_if_possible()

log_file <- file.path(dir_map$logs, paste0('uc_visual_polish_', format(Sys.time(), '%Y%m%d_%H%M%S'), '.log'))
writeLines(character(), log_file)
log_message <- function(...) {
  msg <- paste0('[', format(Sys.time(), '%Y-%m-%d %H:%M:%S'), '] ', sprintf(...))
  cat(msg, '\n')
  cat(msg, '\n', file = log_file, append = TRUE)
}

save_gg <- function(plot_obj, dir_path, stem, width = 7.5, height = 5.5, dpi = 320, bg = 'white') {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(dir_path, paste0(stem, '.pdf'))
  png_path <- file.path(dir_path, paste0(stem, '.png'))
  suppressWarnings(ggplot2::ggsave(pdf_path, plot_obj, width = width, height = height, units = 'in', bg = bg, device = grDevices::cairo_pdf))
  suppressWarnings(ggplot2::ggsave(png_path, plot_obj, width = width, height = height, units = 'in', dpi = dpi, bg = bg))
  invisible(list(pdf = pdf_path, png = png_path))
}

save_base_plot <- function(dir_path, stem, width, height, expr) {
  stem <- wf_sanitize_stem(stem)
  expr_sub <- substitute(expr)
  expr_env <- parent.frame()
  pdf_path <- file.path(dir_path, paste0(stem, '.pdf'))
  png_path <- file.path(dir_path, paste0(stem, '.png'))
  grDevices::pdf(pdf_path, width = width, height = height, onefile = TRUE)
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  eval(expr_sub, envir = expr_env)
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)
  grDevices::png(png_path, width = width, height = height, units = 'in', res = 320, bg = 'white')
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  eval(expr_sub, envir = expr_env)
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)
  invisible(list(pdf = pdf_path, png = png_path))
}

build_group_palette <- function(labels) {
  base_pal <- c(
    Epithelial = '#D9AE60',
    Fibroblasts = '#EAA7B5',
    Endothelial = '#97C37B',
    SmoothMuscle = '#869FC7',
    Macrophage = '#E09A43',
    Mast_cells = '#CC5A4D',
    T_cells = '#4D87C7',
    NKT_cells = '#62A85C',
    B_cells = '#E6C58A',
    Plasma_cells = '#A28DCA',
    'Epithelial-rich' = '#C47A3A',
    'Immune-rich' = '#5B8BC4',
    'Stromal-rich' = '#83A878',
    EpiSpot_UBE2L6_high = '#B14C35',
    EpiSpot_UBE2L6_low = '#6C9BA7'
  )
  labels <- as.character(labels)
  missing_labels <- setdiff(labels, names(base_pal))
  if (length(missing_labels)) {
    base_pal <- c(base_pal, setNames(wf_project_palette(length(missing_labels), palette_name = 'd3'), missing_labels))
  }
  base_pal[labels]
}

extract_feature_values <- function(obj, gene, assay) {
  expr <- get_expr_matrix(obj, assay = assay, prefer = 'data')
  if (gene %in% rownames(expr)) return(as.numeric(expr[gene, colnames(obj)]))
  gene_tokens <- unique(unlist(strsplit(gene, '[_:+&]')))
  gene_tokens <- gene_tokens[gene_tokens %in% rownames(expr)]
  if (!length(gene_tokens)) return(rep(NA_real_, ncol(obj)))
  colMeans(as.matrix(expr[gene_tokens, colnames(obj), drop = FALSE]), na.rm = TRUE)
}

make_reference_bubble <- function(df, fixed_group, mode = c('outgoing', 'incoming'), title = NULL, top_n = 36L) {
  mode <- match.arg(mode)
  if (mode == 'outgoing') {
    df <- df %>% filter(source == fixed_group)
    y_lab <- 'Target group'
  } else {
    df <- df %>% filter(target == fixed_group) %>% mutate(source_tmp = source)
    y_lab <- 'Source group'
  }
  df <- df %>% filter(is.finite(prob), prob > 0, is.finite(pval), pval <= 0.05)
  if (!nrow(df)) return(NULL)

  partner_col <- if (mode == 'outgoing') 'target' else 'source_tmp'
  df <- df %>%
    arrange(desc(prob), pval) %>%
    slice_head(n = top_n) %>%
    mutate(
      partner = .data[[partner_col]],
      interaction_label = paste0(pathway_name, ' | ', interaction_name),
      interaction_label = factor(interaction_label, levels = rev(unique(interaction_label))),
      partner = factor(partner, levels = rev(unique(partner)))
    )

  prob_limits <- range(df$prob, na.rm = TRUE)
  prob_breaks <- pretty(prob_limits, n = 4)
  prob_breaks <- prob_breaks[prob_breaks >= prob_limits[1] & prob_breaks <= prob_limits[2]]
  if (length(prob_breaks) < 3) prob_breaks <- seq(prob_limits[1], prob_limits[2], length.out = 4)

  ggplot(df, aes(x = interaction_label, y = partner, size = prob, fill = prob)) +
    geom_point(shape = 21, colour = '#202020', stroke = 0.28, alpha = 0.94) +
    coord_flip() +
    scale_size_continuous(range = c(3, 10), breaks = prob_breaks) +
    scale_fill_gradientn(
      colours = c('#2C6FB7', '#F1D37A', '#C9413C'),
      limits = prob_limits,
      breaks = prob_breaks
    ) +
    labs(
      title = title,
      x = NULL,
      y = y_lab,
      size = 'Interaction\nStrength',
      fill = 'Communication\nProbability'
    ) +
    theme_bw(base_size = 10.5) +
    theme(
      axis.text.x = element_text(size = 8.3, face = 'bold'),
      axis.text.y = element_text(size = 7.4),
      panel.grid.major = element_line(colour = '#EAEAEA', linewidth = 0.25),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(colour = '#222222', fill = NA, linewidth = 0.6),
      legend.position = 'right',
      legend.title = element_text(face = 'bold', size = 8.7),
      legend.text = element_text(size = 8.1),
      plot.title = element_text(face = 'bold', size = 10.5)
    )
}

make_corrected_group_map <- function(obj, group_col, sample_title, palette) {
  group_df <- wf_spatial_df(obj, group_col, source = 'meta')
  present_levels <- wf_order_discrete_levels(group_df$value, names(palette))
  wf_plot_spatial_structure_ref2_style(
    group_df,
    feature_name = sample_title,
    palette = palette,
    legend_title = 'Group',
    legend_levels = present_levels
  ) +
    ggtitle(sample_title) +
    theme(
      plot.title = element_text(face = 'bold', size = 10.8, hjust = 0.5),
      legend.position = 'right'
    )
}

make_feature_map <- function(df, feature_title) {
  wf_plot_spatial_feature_ref1_style(df, feature_name = feature_title, legend_title = feature_title) +
    ggtitle(feature_title) +
    theme(
      plot.title = element_text(face = 'bold', size = 10.8, hjust = 0.5),
      legend.position = 'right'
    )
}

log_message('Loading existing CellChat and spatial objects for visual polish only.')
cellchat_path <- file.path(dir_map$objects, 'main_m10_ir250_cellchat.rds')
meta_path <- file.path(dir_map$metadata, 'spot_metadata_with_cellchat_groups.csv')
diff_path <- file.path(dir_map$tables, 'EpiSpot_UBE2L6_high_vs_low_differential_communication.csv')
pathway_total_path <- file.path(dir_map$tables, 'main_m10_ir250_pathway_totals.csv')
pathway_stability_path <- file.path(dir_map$sensitivity, 'pathway_stability_summary.csv')
spatial_rds_path <- file.path(root_dir, 'local_outputs', '3.rctd_deconvolution', 'result', 'rds', 'spatial_with_rctd.rds')

if (!file.exists(cellchat_path)) stop('CellChat object not found.', call. = FALSE)
if (!file.exists(meta_path)) stop('Spot metadata file not found.', call. = FALSE)
if (!file.exists(diff_path)) stop('Differential communication table not found.', call. = FALSE)
if (!file.exists(pathway_total_path)) stop('Pathway totals table not found.', call. = FALSE)
if (!file.exists(pathway_stability_path)) stop('Pathway stability table not found.', call. = FALSE)
if (!file.exists(spatial_rds_path)) stop('Spatial Seurat list not found.', call. = FALSE)

cellchat <- readRDS(cellchat_path)
meta_all <- readr::read_csv(meta_path, show_col_types = FALSE)
diff_tbl <- readr::read_csv(diff_path, show_col_types = FALSE)
pathway_total_tbl <- readr::read_csv(pathway_total_path, show_col_types = FALSE)
pathway_stability_tbl <- readr::read_csv(pathway_stability_path, show_col_types = FALSE)
objs <- readRDS(spatial_rds_path)

selected_pathways <- c('COLLAGEN', 'LAMININ', 'MIF')
selected_pathways <- intersect(selected_pathways, cellchat@netP$pathways)
if (length(selected_pathways) < 3) stop('One or more selected UC-related pathways are absent in the CellChat object.', call. = FALSE)

selected_reason_tbl <- tibble(
  pathway_name = selected_pathways,
  uc_axis = c('ECM remodeling', 'Basement membrane and epithelial barrier', 'Inflammatory signaling'),
  selection_reason = c(
    'Highest stable pathway by total probability in the current spot-level analysis; retained to represent stromal remodeling around ulcerated mucosa.',
    'Second highest stable pathway; retained to represent basement-membrane and epithelial barrier architecture relevant to UC injury and repair.',
    'Stable high-ranking non-ECM inflammatory pathway; retained to represent immune activation rather than adding a third structural pathway.'
  )
) %>%
  left_join(pathway_total_tbl %>% mutate(main_rank = row_number()), by = 'pathway_name') %>%
  left_join(pathway_stability_tbl %>% select(pathway_name, present_in, stable_across_main_and_sensitivity), by = 'pathway_name')

readr::write_csv(selected_reason_tbl, file.path(dir_map$summary, 'uc_top3_pathways_selected.csv'))
writeLines(
  c(
    'Selected pathways for UC-focused spatial communication display:',
    paste0('- ', selected_reason_tbl$pathway_name, ': ', selected_reason_tbl$selection_reason)
  ),
  file.path(dir_map$summary, 'uc_top3_pathways_selected.txt')
)

color_use <- build_group_palette(levels(cellchat@idents))
log_message('Rendering spatial aggregate CellChat plots for: %s', paste(selected_pathways, collapse = ', '))

render_spatial_pathway_literal <- function(pathway_literal) {
  stem <- wf_sanitize_stem(paste0('aggregate_spatial_', pathway_literal))
  pdf_path <- file.path(dir_map$pathway, paste0(stem, '.pdf'))
  png_path <- file.path(dir_map$pathway, paste0(stem, '.png'))

  grDevices::pdf(pdf_path, width = 9.2, height = 7.1, onefile = TRUE)
  par(mar = c(0.6, 0.6, 2.2, 0.6), xpd = NA)
  netVisual_aggregate(
    cellchat,
    signaling = pathway_literal,
    layout = 'spatial',
    edge.width.max = 2.2,
    vertex.size.max = 3.2,
    vertex.label.cex = 1.45,
    alpha.image = 0.16
  )
  grDevices::dev.off()

  grDevices::png(png_path, width = 9.2, height = 7.1, units = 'in', res = 320, bg = 'white')
  par(mar = c(0.6, 0.6, 2.2, 0.6), xpd = NA)
  netVisual_aggregate(
    cellchat,
    signaling = pathway_literal,
    layout = 'spatial',
    edge.width.max = 2.2,
    vertex.size.max = 3.2,
    vertex.label.cex = 1.45,
    alpha.image = 0.16
  )
  grDevices::dev.off()
}

render_spatial_pathway_literal('COLLAGEN')
render_spatial_pathway_literal('LAMININ')
render_spatial_pathway_literal('MIF')

main_comm <- subsetCommunication(cellchat, slot.name = 'net', thresh = 0.05)
if (nrow(main_comm)) {
  log_message('Rendering reference-style bubble plots.')
  bubble_specs <- tribble(
    ~group_name, ~mode, ~stem, ~title,
    'EpiSpot_UBE2L6_high', 'outgoing', 'EpiSpot_UBE2L6_high_outgoing_bubble', 'Signaling from EpiSpot_UBE2L6_high spots',
    'EpiSpot_UBE2L6_high', 'incoming', 'EpiSpot_UBE2L6_high_incoming_bubble', 'Signaling toward EpiSpot_UBE2L6_high spots',
    'EpiSpot_UBE2L6_low', 'outgoing', 'EpiSpot_UBE2L6_low_outgoing_bubble', 'Signaling from EpiSpot_UBE2L6_low spots',
    'EpiSpot_UBE2L6_low', 'incoming', 'EpiSpot_UBE2L6_low_incoming_bubble', 'Signaling toward EpiSpot_UBE2L6_low spots'
  )
  for (i in seq_len(nrow(bubble_specs))) {
    spec <- bubble_specs[i, ]
    p_bubble <- make_reference_bubble(main_comm, spec$group_name[[1]], spec$mode[[1]], spec$title[[1]])
    if (!is.null(p_bubble)) save_gg(p_bubble, dir_map$lr, spec$stem[[1]], width = 11.6, height = 6.3)
  }
}

sample_ids <- intersect(names(objs), unique(meta_all$sample_id))
top_lr_pairs <- diff_tbl %>% filter(!is.na(ligand), !is.na(receptor)) %>% slice_head(n = 4)
if (nrow(top_lr_pairs)) {
  log_message('Re-rendering top LR spatial maps with corrected group-panel coordinates.')
  for (i in seq_len(nrow(top_lr_pairs))) {
    lr_row <- top_lr_pairs[i, , drop = FALSE]
    lig <- lr_row$ligand[[1]]
    rec <- lr_row$receptor[[1]]
    lr_stem <- paste0(sprintf('%02d', i), '_', gsub('[^A-Za-z0-9._-]+', '_', lr_row$interaction_name[[1]]))

    for (sample_id in sample_ids) {
      obj <- objs[[sample_id]]
      assay_use <- if ('Spatial' %in% Assays(obj)) 'Spatial' else DefaultAssay(obj)
      meta_sample <- meta_all %>% filter(sample_id == !!sample_id)
      obj$cellchat_group_runtime <- meta_sample$cellchat_group[match(colnames(obj), meta_sample$original_spot_id)]

      coords <- get_spatial_xy(obj)
      coords$spot <- rownames(coords)
      lig_df <- coords
      lig_df$value <- extract_feature_values(obj, lig, assay_use)[match(coords$spot, colnames(obj))]
      rec_df <- coords
      rec_df$value <- extract_feature_values(obj, rec, assay_use)[match(coords$spot, colnames(obj))]

      present_groups <- unique(as.character(na.omit(obj$cellchat_group_runtime)))
      pal <- build_group_palette(present_groups)
      sample_label <- paste0(sample_id, ' groups')
      p_group <- make_corrected_group_map(obj, 'cellchat_group_runtime', sample_label, pal)
      p_lig <- make_feature_map(lig_df, lig)
      p_rec <- make_feature_map(rec_df, rec)

      panel <- p_group + p_lig + p_rec + plot_layout(ncol = 3, widths = c(1.16, 1, 1))
      save_gg(panel, dir_map$spatial, paste0(sample_id, '_', lr_stem, '_spatial_map'), width = 15, height = 5.2)
    }
  }
}

writeLines(
  c(
    '# UC visual polish summary',
    '',
    'This round changed presentation only; no CellChat inference, grouping logic, statistics, or pathway tables were recomputed.',
    '',
    'Outputs refreshed:',
    '- `05_pathway_plots/aggregate_spatial_{COLLAGEN,LAMININ,MIF}`',
    '- `06_LR_plots/EpiSpot_UBE2L6_{high,low}_{outgoing,incoming}_bubble`',
    '- corrected `07_spatial_maps/*_spatial_map` composites for the top 4 LR pairs',
    '',
    'Three selected UC-focused pathways: COLLAGEN, LAMININ, MIF.',
    'Rationale combines current spot-level pathway strength/stability with disease relevance across remodeling, barrier, and inflammatory axes.'
  ),
  file.path(dir_map$summary, 'uc_visual_polish_summary.md')
)

log_message('UC visual polish complete.')
