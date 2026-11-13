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
  library(grid)
})

cfg <- wf_load_config()
wf_ensure_local_lib(cfg)
wf_set_seed(cfg)

root_dir <- wf_find_root()
out_root <- file.path(root_dir, 'results', 'cellchat_rctd_spot')
out_dir <- file.path(out_root, '05_pathway_plots', 'samplewise_spatial_comm')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
summary_dir <- file.path(out_root, '09_summary')
dir.create(summary_dir, recursive = TRUE, showWarnings = FALSE)

copy_self_if_possible <- function() {
  file_arg <- commandArgs(trailingOnly = FALSE)
  file_arg <- sub('^--file=', '', file_arg[grepl('^--file=', file_arg)])
  if (length(file_arg) == 0) return(invisible(NULL))
  src <- normalizePath(file_arg[[1]], winslash = '/', mustWork = FALSE)
  if (file.exists(src)) file.copy(src, file.path(summary_dir, basename(src)), overwrite = TRUE)
}
copy_self_if_possible()

save_gg <- function(plot_obj, stem, width = 7.2, height = 6.6, dpi = 320, bg = 'white') {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(out_dir, paste0(stem, '.pdf'))
  png_path <- file.path(out_dir, paste0(stem, '.png'))
  suppressWarnings(ggplot2::ggsave(pdf_path, plot_obj, width = width, height = height, units = 'in', bg = bg, device = grDevices::cairo_pdf))
  suppressWarnings(ggplot2::ggsave(png_path, plot_obj, width = width, height = height, units = 'in', dpi = dpi, bg = bg))
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
      subtitle = 'Spot background aligned to reference style; edge width = pathway communication probability',
      fill = 'Group',
      linewidth = 'Prob'
    ) +
    theme_spatial_paper() +
    theme(
      plot.title = element_text(face = 'bold', size = 12.4, hjust = 0.5),
      plot.subtitle = element_text(size = 8.7, hjust = 0.5, colour = '#555555'),
      plot.background = element_rect(fill = 'white', colour = NA),
      panel.background = element_rect(fill = 'white', colour = NA),
      legend.position = 'right',
      legend.title = element_text(face = 'bold', size = 9),
      legend.text = element_text(size = 8.2),
      plot.margin = margin(6, 7, 6, 7)
    )
}

cellchat <- readRDS(file.path(out_root, '02_cellchat_objects', 'main_m10_ir250_cellchat.rds'))
meta_all <- readr::read_csv(file.path(out_root, '01_metadata', 'spot_metadata_with_cellchat_groups.csv'), show_col_types = FALSE)
objs <- readRDS(file.path(root_dir, 'local_outputs', '3.rctd_deconvolution', 'result', 'rds', 'spatial_with_rctd.rds'))

selected_pathways <- c('COLLAGEN', 'LAMININ', 'MIF')
pathway_tables <- lapply(selected_pathways, function(pw) subsetCommunication(cellchat, signaling = pw, slot.name = 'netP', thresh = 0.05))
names(pathway_tables) <- selected_pathways

for (sample_id in intersect(names(objs), unique(meta_all$sample_id))) {
  obj <- objs[[sample_id]]
  meta_sample <- meta_all %>% filter(sample_id == !!sample_id)
  for (pw in selected_pathways) {
    p <- make_samplewise_pathway_plot(sample_id, obj, meta_sample, pw, pathway_tables[[pw]], top_n = 14L)
    if (!is.null(p)) {
      save_gg(p, paste0(sample_id, '_', pw, '_samplewise_spatial_comm'), width = 7.4, height = 6.7)
    }
  }
}

writeLines(
  c(
    '# UC samplewise spatial communication',
    '',
    'This round renders one slice per file rather than merging GSM5695834_B8 and GSM5695835_B9 in the same panel.',
    'Spot background uses the reference-1 style direction: white canvas, neutral spot backdrop, restrained borders, and single-slice geometry.',
    'Pathways shown: COLLAGEN, LAMININ, MIF.'
  ),
  file.path(summary_dir, 'uc_samplewise_spatial_comm_summary.md')
)
