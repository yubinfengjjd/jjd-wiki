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
