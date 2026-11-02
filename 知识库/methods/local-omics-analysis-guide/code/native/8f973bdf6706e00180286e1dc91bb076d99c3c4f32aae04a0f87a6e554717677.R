plot_premium_bubble <- function(cellchat, sources, targets, title = "") {
    df <- subsetCommunication(cellchat, sources.use = sources, targets.use = targets)
    if (nrow(df) == 0) {
        return(NULL)
    }

    # Format
    df$p_val_cat <- cut(df$pval, breaks = c(-Inf, 0.01, 0.05, Inf), labels = c("p < 0.01", "0.01 < p < 0.05", "ns"))
    df <- df %>% filter(p_val_cat != "ns")

    # Color palette (Spectral)
    spectral_pal <- c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FFFFBF", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B")

    # Labels on top
    p <- ggplot(df, aes(x = interaction_name, y = target, size = p_val_cat, fill = prob)) +
        geom_point(shape = 21, color = "black", stroke = 0.3) +
        scale_fill_gradientn(
            colours = rev(spectral_pal), name = "Commun. Prob.",
            labels = c("min", "max"), breaks = range(df$prob),
            guide = guide_colorbar(barheight = 5, barwidth = 0.8, title.position = "top")
        ) +
        scale_size_manual(values = c("p < 0.01" = 3.5, "0.01 < p < 0.05" = 1.5), name = "p-value") +
        scale_x_discrete(position = "top") +
        theme_bw() +
        theme(
            axis.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5, size = 6.5, family = "sans", face = "bold"),
            axis.text.y = element_text(size = 8, face = "bold"),
            panel.grid.major = element_line(size = 0.1, color = "grey90"),
            panel.border = element_rect(color = "black", fill = NA, size = 1.2),
            legend.position = "right",
            plot.title = element_text(size = 10, face = "bold")
        ) +
        labs(x = NULL, y = NULL, title = title)

    p
}
