plot_spatial_aggregate_spots <- function(obj, cellchat, meta_sample, pathway, sample_id) {
    # Get Spot Coordinates and Metadata
    coords_raw <- GetTissueCoordinates(obj)

    # Standardize sample metadata
    nodes <- meta_sample %>%
        mutate(
            plot_x = x,
            plot_y = y,
            group = factor(cellchat_group, levels = names(group_cols))
        )

    # Calculate Group Centroids for the edges
    centroids <- nodes %>%
        group_by(cellchat_group) %>%
        summarise(
            x = mean(plot_x, na.rm = TRUE),
            y = mean(plot_y, na.rm = TRUE),
            .groups = "drop"
        )

    # Filter communication edges (aggregate pathway level)
    df_net <- tryCatch(subsetCommunication(cellchat, signaling = pathway, slot.name = "netP"), error = function(e) NULL)
    if (is.null(df_net) || nrow(df_net) == 0) {
        return(NULL)
    }

    # Map centroids to edges
    edge_list <- list()
    for (i in 1:nrow(df_net)) {
        s_grp <- as.character(df_net$source[i])
        t_grp <- as.character(df_net$target[i])
        if (s_grp == t_grp) next
        s_c <- centroids %>% filter(cellchat_group == s_grp)
        t_c <- centroids %>% filter(cellchat_group == t_grp)
        if (nrow(s_c) == 0 || nrow(t_c) == 0) next
        edge_list[[length(edge_list) + 1]] <- data.frame(
            x = s_c$x, y = s_c$y, xend = t_c$x, yend = t_c$y,
            prob = df_net$prob[i]
        )
    }

    if (length(edge_list) == 0) {
        return(NULL)
    }
    edges <- do.call(rbind, edge_list)

    # Plot
    p <- ggplot() +
        # Background Spots Layer (Discrete Scale)
        geom_point(data = nodes, aes(x = plot_x, y = plot_y, color = group), size = 1.0, alpha = 0.6) +
        scale_color_manual(values = group_cols, name = "Group") +
        # Add new color scale for the edges
        new_scale_color() +
        # Communication Edges Layer (Continuous Scale)
        geom_curve(
            data = edges, aes(x = x, y = y, xend = xend, yend = yend, color = prob, linewidth = prob),
            curvature = 0.2, alpha = 0.9, arrow = arrow(length = unit(0.07, "inches"), type = "closed")
        ) +
        scale_color_viridis_c(option = "plasma", name = "Path. Prob") +
        scale_linewidth_continuous(range = c(0.4, 1.8), guide = "none") +
        # Centroid markers
        geom_point(data = centroids, aes(x = x, y = y), color = "black", shape = 21, fill = "white", size = 1.5, stroke = 0.5) +
        ggrepel::geom_text_repel(
            data = centroids, aes(x = x, y = y, label = cellchat_group),
            size = 2.8, fontface = "bold", box.padding = 0.4, segment.color = "grey50", bg.color = "white", bg.r = 0.1
        ) +
        # Flip and axis setup
        scale_y_reverse() + # Standard Seurat orientation
        coord_fixed() +
        theme_void() +
        theme(
            plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
            legend.position = "right",
            legend.title = element_text(size = 9, face = "bold"),
            legend.text = element_text(size = 8)
        ) +
        labs(title = paste0(sample_id, ": ", pathway))

    return(p)
}
