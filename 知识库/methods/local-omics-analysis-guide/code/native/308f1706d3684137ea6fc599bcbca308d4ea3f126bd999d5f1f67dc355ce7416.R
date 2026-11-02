plot_bubble_refined <- function(cellchat, sources, targets, title = "") {
    # netVisual_bubble already filters pval < 0.05 by default usually, but we can be explicit
    p <- netVisual_bubble(
        cellchat,
        sources.use = sources,
        targets.use = targets,
        remove.isolate = TRUE,
        angle.x = 45
    ) +
        coord_flip() +
        ggtitle(title)

    # Filter for readability if too many rows
    if (nrow(p$data) > 30) {
        # Keep top signaling names based on aggregate prob
        top_sigs <- p$data %>%
            group_by(pathway_name) %>%
            summarize(s = sum(prob)) %>%
            top_n(15, s) %>%
            pull(pathway_name)
        p$data <- p$data %>% filter(pathway_name %in% top_sigs)
    }

    enhanced_plot <- p +
        scale_size_continuous(range = c(2, 7.5), name = "Strength") +
        scale_color_gradientn(
            colors = c("blue", "yellow", "red"),
            name = "Prob",
            limits = c(0, max(p$data$prob, 0.1))
        ) +
        theme_bw() +
        theme(
            axis.text.x = element_text(size = 8, face = "bold"),
            axis.text.y = element_text(size = 8, face = "bold"),
            panel.grid.major = element_line(size = 0.1, color = "grey92")
        )
    return(enhanced_plot)
}
