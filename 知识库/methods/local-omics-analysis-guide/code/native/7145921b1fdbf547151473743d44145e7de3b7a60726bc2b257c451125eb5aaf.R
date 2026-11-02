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
