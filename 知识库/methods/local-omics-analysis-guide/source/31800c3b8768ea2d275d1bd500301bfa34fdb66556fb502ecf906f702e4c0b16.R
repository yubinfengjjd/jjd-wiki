#!/usr/bin/env Rscript

source(file.path('code', 'R', 'workflow_helpers.R'))

suppressWarnings(grDevices::pdf.options(family = 'Helvetica'))

suppressPackageStartupMessages({
  library(Seurat)
  library(CellChat)
  library(ComplexHeatmap)
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(tibble)
  library(patchwork)
  library(grid)
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
  pathway_samplewise = file.path(out_root, '05_pathway_plots', 'samplewise_spatial_comm'),
  lr = file.path(out_root, '06_LR_plots'),
  spatial = file.path(out_root, '07_spatial_maps'),
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

log_file <- file.path(dir_map$logs, paste0('uc_epithelial_polish_', format(Sys.time(), '%Y%m%d_%H%M%S'), '.log'))
writeLines(character(), log_file)
log_message <- function(...) {
  msg <- paste0('[', format(Sys.time(), '%Y-%m-%d %H:%M:%S'), '] ', sprintf(...))
  cat(msg, '\n')
  cat(msg, '\n', file = log_file, append = TRUE)
}

save_gg_to_dir <- function(plot_obj, dir_path, stem, width = 7.2, height = 6.6, dpi = 320, bg = 'white') {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(dir_path, paste0(stem, '.pdf'))
  png_path <- file.path(dir_path, paste0(stem, '.png'))
  suppressWarnings(ggplot2::ggsave(pdf_path, plot_obj, width = width, height = height, units = 'in', bg = bg, device = grDevices::cairo_pdf))
  suppressWarnings(ggplot2::ggsave(png_path, plot_obj, width = width, height = height, units = 'in', dpi = dpi, bg = bg))
  invisible(list(pdf = pdf_path, png = png_path))
}

save_pdf_only <- function(plot_obj, out_file, width = 10.5, height = 6.8, bg = 'white') {
  suppressWarnings(ggplot2::ggsave(out_file, plot_obj, width = width, height = height, units = 'in', bg = bg, device = grDevices::cairo_pdf))
  invisible(out_file)
}

save_heatmap_to_dir <- function(heatmap_obj, dir_path, stem, width = 7.8, height = 6.4, dpi = 320) {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(dir_path, paste0(stem, '.pdf'))
  png_path <- file.path(dir_path, paste0(stem, '.png'))

  grDevices::pdf(pdf_path, width = width, height = height, family = 'Helvetica')
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  ComplexHeatmap::draw(
    heatmap_obj,
    newpage = FALSE,
    heatmap_legend_side = 'right',
    annotation_legend_side = 'right',
    merge_legend = TRUE,
    padding = grid::unit(c(2.2, 4.6, 1.8, 2.2), 'mm')
  )
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)

  grDevices::png(png_path, width = width, height = height, units = 'in', res = dpi, bg = 'white')
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  ComplexHeatmap::draw(
    heatmap_obj,
    newpage = FALSE,
    heatmap_legend_side = 'right',
    annotation_legend_side = 'right',
    merge_legend = TRUE,
    padding = grid::unit(c(2.2, 4.6, 1.8, 2.2), 'mm')
  )
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)

  invisible(list(pdf = pdf_path, png = png_path))
}

tune_signaling_role_heatmap <- function(heatmap_obj) {
  n_rows <- nrow(heatmap_obj@matrix)
  row_font <- if (n_rows >= 75) 4.8 else if (n_rows >= 55) 5.8 else 7.1
  col_font <- if (n_rows >= 55) 7.8 else 8.8
  heatmap_obj@row_names_param$gp <- grid::gpar(fontsize = row_font, fontface = 'bold', lineheight = 0.9)
  heatmap_obj@column_names_param$gp <- grid::gpar(fontsize = col_font, lineheight = 0.96)
  heatmap_obj@row_names_param$max_width <- grid::unit(34, 'mm')
  heatmap_obj@column_names_param$max_height <- grid::unit(30, 'mm')
  heatmap_obj
}

archive_matching_files <- function(dir_path, pattern, archive_tag) {
  files <- list.files(dir_path, pattern = pattern, full.names = TRUE)
  files <- files[file.info(files)$isdir %in% FALSE]
  if (!length(files)) return(invisible(NULL))
  archive_dir <- file.path(dir_path, archive_tag)
  dir.create(archive_dir, recursive = TRUE, showWarnings = FALSE)
  for (f in files) {
    dest <- file.path(archive_dir, basename(f))
    if (file.exists(dest)) file.remove(dest)
    file.rename(f, dest)
  }
  invisible(archive_dir)
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

make_reference_bubble <- function(df, fixed_group, title = NULL, top_n = 24L) {
  df <- df %>%
    filter(source == fixed_group, is.finite(prob), prob > 0, is.finite(pval), pval <= 0.05) %>%
    arrange(desc(prob), pval) %>%
    slice_head(n = top_n)
  if (!nrow(df)) return(NULL)

  df <- df %>%
    mutate(
      partner = factor(target, levels = rev(unique(target))),
      interaction_label = paste0(pathway_name, ' | ', interaction_name),
      interaction_label = factor(interaction_label, levels = rev(unique(interaction_label)))
    )

  prob_limits <- range(df$prob, na.rm = TRUE)
  prob_breaks <- pretty(prob_limits, n = 4)
  prob_breaks <- prob_breaks[prob_breaks >= prob_limits[1] & prob_breaks <= prob_limits[2]]
  if (length(prob_breaks) < 3) prob_breaks <- seq(prob_limits[1], prob_limits[2], length.out = 4)

  ggplot(df, aes(x = interaction_label, y = partner, size = prob, fill = prob)) +
    geom_point(shape = 21, colour = '#202020', stroke = 0.28, alpha = 0.94) +
    coord_flip() +
    scale_size_continuous(range = c(3, 10), breaks = prob_breaks) +
    scale_fill_gradientn(colours = c('#2C6FB7', '#F1D37A', '#C9413C'), limits = prob_limits, breaks = prob_breaks) +
    labs(
      title = title,
      x = NULL,
      y = 'Target group',
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
      plot.title = element_text(face = 'bold', size = 11, hjust = 0.5),
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

make_samplewise_pathway_plot <- function(sample_id, obj, meta_sample, pathway_name, path_tbl, top_n = 14L) {
  ref1 <- wf_spatial_ref1_spec()
  coords <- get_spatial_xy(obj)
  coords$spot <- rownames(coords)
  coords$group <- meta_sample$cellchat_group[match(coords$spot, meta_sample$original_spot_id)]
  coords <- coords %>% filter(!is.na(group), nzchar(group))
  if (!nrow(coords)) return(NULL)

  present_groups <- unique(as.character(coords$group))
  centroids <- coords %>%
    group_by(group) %>%
    summarise(x = median(x, na.rm = TRUE), y = median(y, na.rm = TRUE), n_spots = n(), .groups = 'drop')

  edge_df <- path_tbl %>%
    filter(source %in% present_groups, target %in% present_groups, prob > 0) %>%
    arrange(desc(prob), pval) %>%
    slice_head(n = top_n) %>%
    left_join(centroids %>% select(group, x_from = x, y_from = y), by = c('source' = 'group')) %>%
    left_join(centroids %>% select(group, x_to = x, y_to = y), by = c('target' = 'group')) %>%
    filter(is.finite(x_from), is.finite(y_from), is.finite(x_to), is.finite(y_to), source != target, !(x_from == x_to & y_from == y_to))

  pal <- build_group_palette(present_groups)
  node_df <- centroids %>% mutate(group = factor(group, levels = wf_order_discrete_levels(group, names(pal))))

  ggplot() +
    geom_point(
      data = coords,
      aes(x = x, y = y),
      shape = 21,
      size = ref1$point_size * 0.98,
      stroke = max(ref1$stroke * 0.65, 0.15),
      fill = '#F2F2F2',
      colour = '#D8D8D8',
      alpha = 1
    ) +
    geom_curve(
      data = edge_df,
      aes(x = x_from, y = y_from, xend = x_to, yend = y_to, linewidth = prob),
      inherit.aes = FALSE,
      curvature = 0.16,
      colour = '#B65A3A',
      alpha = 0.62,
      arrow = arrow(length = unit(0.085, 'inches'), type = 'closed')
    ) +
    geom_point(
      data = node_df,
      aes(x = x, y = y, fill = group),
      shape = 21,
      size = 5.3,
      stroke = 0.28,
      colour = '#3C3C3C'
    ) +
    geom_text(
      data = node_df,
      aes(x = x, y = y, label = group),
      size = 3.0,
      fontface = 'bold',
      colour = '#2F2F2F',
      nudge_y = 220,
      check_overlap = TRUE
    ) +
    scale_fill_manual(values = pal, drop = FALSE) +
    scale_linewidth_continuous(range = c(0.35, 2.25)) +
    scale_x_continuous(expand = expansion(mult = 0.04)) +
    scale_y_reverse(expand = expansion(mult = 0.04)) +
    coord_fixed() +
    labs(
      title = paste0(sample_id, ' | ', pathway_name),
      fill = 'Group',
      linewidth = 'Prob'
    ) +
    theme_spatial_paper() +
    theme(
      plot.title = element_text(face = 'bold', size = 12.4, hjust = 0.5),
      plot.subtitle = element_blank(),
      plot.background = element_rect(fill = 'white', colour = NA),
      panel.background = element_rect(fill = 'white', colour = NA),
      legend.position = 'right',
      legend.title = element_text(face = 'bold', size = 9),
      legend.text = element_text(size = 8.2),
      plot.margin = margin(6, 7, 6, 7)
    )
}

# Literature-curated UC epithelial barrier pathways retained for the focused LR and spatial panels.
selected_pathways <- c('LAMININ', 'CDH', 'DESMOSOME')
selected_labels <- c(
  LAMININ = 'Basement-membrane anchoring axis',
  CDH = 'E-cadherin adherens-junction axis',
  DESMOSOME = 'Desmosome epithelial-barrier axis'
)
literature_curated_tbl <- tibble(
  pathway_name = selected_pathways,
  epithelial_axis = unname(selected_labels[selected_pathways]),
  supporting_pmid = c('10766090', '9828841', '26224314'),
  literature_basis = c(
    'UC colonic mucosa shows epithelial basement-membrane laminin deficiency with disturbed epithelial-matrix interactions.',
    'Active UC ulcer margins show altered membranous E-cadherin/catenin expression during epithelial restitution.',
    'Desmoglein-2 ectodomain shedding is detected in inflamed intestinal mucosa of UC patients and compromises epithelial barrier adhesion.'
  )
)

cellchat <- readRDS(file.path(dir_map$objects, 'main_m10_ir250_cellchat.rds'))
meta_all <- readr::read_csv(file.path(dir_map$metadata, 'spot_metadata_with_cellchat_groups.csv'), show_col_types = FALSE)
diff_tbl <- readr::read_csv(file.path(dir_map$tables, 'EpiSpot_UBE2L6_high_vs_low_differential_communication.csv'), show_col_types = FALSE)
objs <- readRDS(file.path(root_dir, 'local_outputs', '3.rctd_deconvolution', 'result', 'rds', 'spatial_with_rctd.rds'))

selected_pathways <- intersect(selected_pathways, cellchat@netP$pathways)
if (length(selected_pathways) != 3) stop('Required epithelial pathways are not all present in the CellChat object.', call. = FALSE)

main_comm <- subsetCommunication(cellchat, slot.name = 'net', thresh = 0.05)
outgoing_diff <- diff_tbl %>%
  filter(direction == 'outgoing', pathway_name %in% selected_pathways) %>%
  mutate(abs_delta = abs(delta_prob))

if (!nrow(outgoing_diff)) stop('No outgoing differential communication rows were found for the selected epithelial pathways.', call. = FALSE)

pathway_selection_tbl <- outgoing_diff %>%
  group_by(pathway_name) %>%
  summarise(
    signed_delta = sum(delta_prob, na.rm = TRUE),
    total_abs_delta = sum(abs_delta, na.rm = TRUE),
    max_abs_delta = max(abs_delta, na.rm = TRUE),
    n_outgoing_edges = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    stronger_state = case_when(
      signed_delta > 0 ~ 'high',
      signed_delta < 0 ~ 'low',
      TRUE ~ 'equal'
    )
  ) %>%
  mutate(epithelial_axis = unname(selected_labels[pathway_name])) %>%
  arrange(match(pathway_name, selected_pathways))
readr::write_csv(pathway_selection_tbl, file.path(dir_map$summary, 'uc_epithelial_selected_pathways.csv'))
readr::write_csv(literature_curated_tbl, file.path(dir_map$summary, 'uc_epithelial_literature_curated_pathways.csv'))

representative_pairs <- outgoing_diff %>%
  group_by(pathway_name, interaction_name, ligand, receptor) %>%
  summarise(
    total_abs_delta = sum(abs_delta, na.rm = TRUE),
    max_abs_delta = max(abs_delta, na.rm = TRUE),
    stronger_state = stronger_state[which.max(abs_delta)][1],
    .groups = 'drop'
  ) %>%
  arrange(match(pathway_name, selected_pathways), desc(total_abs_delta), desc(max_abs_delta)) %>%
  group_by(pathway_name) %>%
  slice_head(n = 1) %>%
  ungroup()
readr::write_csv(representative_pairs, file.path(dir_map$summary, 'uc_epithelial_representative_lr_pairs.csv'))

stamp <- format(Sys.time(), '%Y%m%d_%H%M%S')
archive_matching_files(dir_map$pathway_samplewise, '\\.(pdf|png)$', paste0('legacy_', stamp))
archive_matching_files(dir_map$lr, 'incoming_bubble\\.(pdf|png)$', paste0('legacy_incoming_', stamp))
archive_matching_files(dir_map$lr, 'cellchat_signaling_role_heatmap_.*\\.(pdf|png)$', paste0('legacy_role_heatmap_', stamp))
archive_matching_files(dir_map$lr, 'EpiSpot_UBE2L6_.*pathway_probability_heatmap\\.(pdf|png)$', paste0('legacy_old_probability_heatmap_', stamp))
archive_matching_files(dir_map$lr, 'cellchat_all_signaling_outgoing_high_low_delta_barplot\\.(pdf|png)$', paste0('legacy_all_signal_delta_barplot_', stamp))
archive_matching_files(dir_map$spatial, '(_spatial_map|_feature_stack|group_maps_reference|_group_map_reference)\\.(pdf|png)$', paste0('legacy_', stamp))

log_message('Rendering 05 samplewise spatial pathway plots for epithelial pathways: %s', paste(selected_pathways, collapse = ', '))
pathway_tables <- lapply(selected_pathways, function(pw) subsetCommunication(cellchat, signaling = pw, slot.name = 'netP', thresh = 0.05))
names(pathway_tables) <- selected_pathways

sample_ids <- intersect(names(objs), unique(meta_all$sample_id))
for (sample_id in sample_ids) {
  obj <- objs[[sample_id]]
  meta_sample <- meta_all %>% filter(sample_id == !!sample_id)
  for (pw in selected_pathways) {
    p <- make_samplewise_pathway_plot(sample_id, obj, meta_sample, pw, pathway_tables[[pw]], top_n = 14L)
    if (!is.null(p)) save_gg_to_dir(p, dir_map$pathway_samplewise, paste0(sample_id, '_', pw, '_samplewise_spatial_comm'), width = 7.4, height = 6.7)
  }
}

log_message('Rendering 06 outgoing-only bubble plots for the selected epithelial pathways.')
outgoing_comm <- main_comm %>% filter(pathway_name %in% selected_pathways)
for (grp in c('EpiSpot_UBE2L6_high', 'EpiSpot_UBE2L6_low')) {
  p_bubble <- make_reference_bubble(outgoing_comm, grp, title = paste0('Outgoing signaling from ', grp))
  if (!is.null(p_bubble)) save_gg_to_dir(p_bubble, dir_map$lr, paste0(grp, '_outgoing_bubble'), width = 11.4, height = 5.9)
}

pathway_bar_tbl <- pathway_selection_tbl %>%
  mutate(pathway_name = factor(pathway_name, levels = rev(selected_pathways)))
if (nrow(pathway_bar_tbl)) {
  p_bar <- ggplot(pathway_bar_tbl, aes(x = signed_delta, y = pathway_name, fill = stronger_state)) +
    geom_col(color = '#2E2E2E', linewidth = 0.25, width = 0.68) +
    geom_vline(xintercept = 0, colour = '#5E5E5E', linewidth = 0.35, linetype = 'dashed') +
    scale_fill_manual(values = c(high = '#B25636', low = '#6B98A3', equal = '#C7C7C7')) +
    labs(
      title = 'Outgoing epithelial pathway contrast: signed delta by pathway',
      subtitle = 'Signed communication probability difference = UBE2L6_high - UBE2L6_low',
      x = 'Signed delta probability',
      y = NULL,
      fill = 'Stronger state'
    ) +
    theme_paper() +
    theme(
      plot.title = element_text(face = 'bold'),
      plot.subtitle = element_text(size = 9.2, colour = '#4A4A4A')
    )
  save_gg_to_dir(p_bar, dir_map$lr, 'top_lr_contrast_barplot', width = 8.8, height = 4.9)
}
readr::write_csv(pathway_bar_tbl, file.path(dir_map$lr, 'selected_epithelial_pathway_signed_delta_table.csv'))

outgoing_edge_bar_tbl <- outgoing_diff %>%
  arrange(desc(abs_delta), pmin(high_pval, low_pval)) %>%
  slice_head(n = 15) %>%
  mutate(bar_label = paste0(pathway_name, ' | ', interaction_name, ' | ', partner)) %>%
  mutate(bar_label = factor(bar_label, levels = rev(unique(bar_label))))
if (nrow(outgoing_edge_bar_tbl)) {
  p_edge_bar <- ggplot(outgoing_edge_bar_tbl, aes(x = delta_prob, y = bar_label, fill = stronger_state)) +
    geom_col(color = '#2E2E2E', linewidth = 0.2) +
    scale_fill_manual(values = c(high = '#B25636', low = '#6B98A3', equal = '#C7C7C7')) +
    labs(
      title = 'Outgoing epithelial LR-edge contrasts within selected pathways',
      x = 'Delta probability (high - low)',
      y = NULL,
      fill = 'Stronger state'
    ) +
    theme_paper() +
    theme(plot.title = element_text(face = 'bold'))
  save_gg_to_dir(p_edge_bar, dir_map$lr, 'top_lr_edge_contrast_barplot', width = 10.8, height = 6.6)
}
readr::write_csv(outgoing_diff, file.path(dir_map$lr, 'selected_epithelial_outgoing_diff_table.csv'))

prob_arr <- cellchat@netP$prob
src_names <- dimnames(prob_arr)[[1]]
pathway_names <- dimnames(prob_arr)[[3]]
high_idx <- match('EpiSpot_UBE2L6_high', src_names)
low_idx <- match('EpiSpot_UBE2L6_low', src_names)
if (is.na(high_idx) || is.na(low_idx)) stop('Cannot find EpiSpot_UBE2L6_high/low source groups in CellChat netP array.', call. = FALSE)

all_signal_delta_tbl <- tibble(
  pathway_name = pathway_names,
  high_outgoing_prob = vapply(seq_along(pathway_names), function(i) sum(prob_arr[high_idx, , i], na.rm = TRUE), numeric(1)),
  low_outgoing_prob = vapply(seq_along(pathway_names), function(i) sum(prob_arr[low_idx, , i], na.rm = TRUE), numeric(1))
) %>%
  mutate(
    signed_delta = high_outgoing_prob - low_outgoing_prob,
    abs_delta = abs(signed_delta),
    stronger_state = case_when(
      signed_delta > 0 ~ 'high',
      signed_delta < 0 ~ 'low',
      TRUE ~ 'equal'
    )
  ) %>%
  arrange(desc(abs_delta), pathway_name)
readr::write_csv(all_signal_delta_tbl, file.path(dir_map$lr, 'cellchat_all_signaling_outgoing_high_low_delta_table.csv'))

top_n_signaling <- min(20L, nrow(all_signal_delta_tbl))
top_signal_delta_tbl <- all_signal_delta_tbl %>% slice_head(n = top_n_signaling)
top_signal_names <- top_signal_delta_tbl$pathway_name

log_message('Rendering 06 CellChat signaling-role overview heatmaps for the top %s pathways ranked by epithelial outgoing delta.', top_n_signaling)
role_pathway_count <- length(top_signal_names)
role_heatmap_body_width <- 12.8
role_heatmap_body_height <- max(9.6, role_pathway_count * 0.42)
role_heatmap_specs <- list(
  list(pattern = 'all', stem = 'cellchat_signaling_role_heatmap_all_signals', title = sprintf('CellChat signaling-role overview for top %s epithelial delta pathways', top_n_signaling)),
  list(pattern = 'outgoing', stem = 'cellchat_signaling_role_heatmap_outgoing', title = sprintf('CellChat outgoing signaling-role overview for top %s epithelial delta pathways', top_n_signaling)),
  list(pattern = 'incoming', stem = 'cellchat_signaling_role_heatmap_incoming', title = sprintf('CellChat incoming signaling-role overview for top %s epithelial delta pathways', top_n_signaling))
)
for (spec in role_heatmap_specs) {
  hm <- tryCatch(
    netAnalysis_signalingRole_heatmap(
      cellchat,
      pattern = spec$pattern,
      slot.name = 'netP',
      signaling = top_signal_names,
      cluster.rows = FALSE,
      cluster.cols = FALSE,
      color.heatmap = 'BuGn',
      title = spec$title,
      width = role_heatmap_body_width,
      height = role_heatmap_body_height,
      font.size = 8,
      font.size.title = 10
    ),
    error = function(e) {
      log_message('Signaling-role heatmap failed for pattern=%s: %s', spec$pattern, conditionMessage(e))
      NULL
    }
  )
  if (!is.null(hm)) {
    hm <- tune_signaling_role_heatmap(hm)
    hm_height <- max(7.0, role_heatmap_body_height / 1.8)
    save_heatmap_to_dir(hm, dir_map$lr, spec$stem, width = 8.9, height = hm_height)
  }
}

log_message('Rendering 06 outgoing signaling delta bar plot for the top %s pathways ranked by epithelial outgoing delta.', top_n_signaling)
all_signal_delta_plot_tbl <- top_signal_delta_tbl %>%
  mutate(pathway_name = factor(pathway_name, levels = rev(pathway_name)))

if (nrow(all_signal_delta_plot_tbl)) {
  p_all_signal_delta <- ggplot(all_signal_delta_plot_tbl, aes(x = signed_delta, y = pathway_name, fill = stronger_state)) +
    geom_col(color = '#2E2E2E', linewidth = 0.2, width = 0.7) +
    geom_vline(xintercept = 0, colour = '#5E5E5E', linewidth = 0.35, linetype = 'dashed') +
    scale_fill_manual(values = c(high = '#B25636', low = '#6B98A3', equal = '#C7C7C7')) +
    labs(
      title = sprintf('Top %s signaling pathways: outgoing communication delta from epithelial UBE2L6 high vs low', top_n_signaling),
      subtitle = 'Ranked by absolute signed delta probability; signed delta = outgoing strength of EpiSpot_UBE2L6_high - EpiSpot_UBE2L6_low',
      x = 'Signed delta probability',
      y = NULL,
      fill = 'Stronger state'
    ) +
    theme_paper() +
    theme(
      plot.title = element_text(face = 'bold'),
      plot.subtitle = element_text(size = 9.2, colour = '#4A4A4A'),
      axis.text.y = element_text(size = 6.2)
    )
  save_gg_to_dir(
    p_all_signal_delta,
    dir_map$lr,
    'cellchat_all_signaling_outgoing_high_low_delta_barplot',
    width = 9.8,
    height = max(8.4, nrow(all_signal_delta_plot_tbl) * 0.18)
  )
}

all_groups <- unique(as.character(na.omit(meta_all$cellchat_group)))
log_message('Rendering 07 maps with separate per-sample group-map PDFs and vertical ligand/receptor stacks.')
all_groups <- unique(as.character(na.omit(meta_all$cellchat_group)))
group_pal <- build_group_palette(all_groups)
group_map_plots <- list()
for (sample_id in sample_ids) {
  obj <- objs[[sample_id]]
  meta_sample <- meta_all %>% filter(sample_id == !!sample_id)
  obj$cellchat_group_runtime <- meta_sample$cellchat_group[match(colnames(obj), meta_sample$original_spot_id)]
  group_map_plots[[sample_id]] <- make_corrected_group_map(obj, 'cellchat_group_runtime', paste0(sample_id, ' groups'), group_pal)
  save_gg_to_dir(group_map_plots[[sample_id]], dir_map$spatial, paste0(sample_id, '_group_map_reference'), width = 7.2, height = 6.2)
}
for (sample_id in sample_ids) {
  obj <- objs[[sample_id]]
  assay_use <- if ('Spatial' %in% Assays(obj)) 'Spatial' else DefaultAssay(obj)
  coords <- get_spatial_xy(obj)
  coords$spot <- rownames(coords)

  for (pw in selected_pathways) {
    pair_row <- representative_pairs %>% filter(pathway_name == !!pw) %>% slice_head(n = 1)
    if (!nrow(pair_row)) next
    lig <- pair_row$ligand[[1]]
    rec <- pair_row$receptor[[1]]
    interaction_label <- pair_row$interaction_name[[1]]

    lig_df <- coords
    lig_df$value <- extract_feature_values(obj, lig, assay_use)[match(coords$spot, colnames(obj))]
    rec_df <- coords
    rec_df$value <- extract_feature_values(obj, rec, assay_use)[match(coords$spot, colnames(obj))]

    p_lig <- make_feature_map(lig_df, lig)
    p_rec <- make_feature_map(rec_df, rec)
    stack_plot <- (p_lig / p_rec) +
      plot_layout(ncol = 1, heights = c(1, 1)) +
      plot_annotation(title = paste0(sample_id, ' | ', pw, ' | ', interaction_label), theme = theme(plot.title = element_text(face = 'bold', hjust = 0.5, size = 12)))

    stem <- paste0(sample_id, '_', pw, '_', gsub('[^A-Za-z0-9._-]+', '_', interaction_label), '_feature_stack')
    save_gg_to_dir(stack_plot, dir_map$spatial, stem, width = 7.0, height = 10.2)
  }
}

writeLines(
  c(
    '# UC epithelial polish summary',
    '',
    'Pathway curation: the focused pathway set was retained by literature support for ulcerative-colitis epithelial barrier biology, not by global delta ranking alone.',
    'Supporting PMIDs: LAMININ (10766090), CDH / E-cadherin (9828841), DESMOSOME / DSG2 (26224314).',
    '05_pathway_plots/samplewise_spatial_comm: rerendered as epithelial-focused samplewise pathway maps for the literature-curated UC epithelial pathways LAMININ, CDH, and DESMOSOME.',
    '06_LR_plots: replaced the previous LR-edge-leading top_lr_contrast_barplot with a true pathway-level signed-delta barplot (high - low), kept the LR-edge ranking as top_lr_edge_contrast_barplot, limited the CellChat signaling-role overview heatmaps and the all-signal outgoing delta barplot to the top 20 pathways ranked by absolute epithelial UBE2L6-high vs UBE2L6-low outgoing delta, and resized the heatmaps to keep pathway labels readable.',
    '07_spatial_maps: kept the focused spatial ligand/receptor stacks for the same literature-curated epithelial top-three pathways; left group panel remains a standalone PDF and ligand/receptor feature maps are stacked vertically per pathway.',
    paste0('Selected epithelial pathways: ', paste(selected_pathways, collapse = ', '), '.'),
    'Representative LR pairs used in 07 were selected from outgoing differential communication within those pathways.'
  ),
  file.path(dir_map$summary, 'uc_epithelial_polish_summary.md')
)

log_message('UC epithelial polish complete.')
