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
