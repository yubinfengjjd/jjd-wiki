plot_spatial_pathway_premium <- function(obj, cellchat, pathway, sample_id) {
    # Get H&E backdrop
    backdrop <- wf_spatial_backdrop_df(obj)
    coords <- GetTissueCoordinates(obj)
    max_row <- max(coords$imagerow)
    min_row <- min(coords$imagerow)
    s_fact <- obj@images[[1]]@scale.factors$lowres

    # Filter communication edges for this pathway and sample
    # Note: cellchat object barcodes are sample__barcode
    df_net <- subsetCommunication(cellchat, signaling = pathway)
    # Standardize IDs: strip sample prefix if present in the ID_RAW but CellChat might have it
    # We'll use a safer prefix matching
    df_net <- df_net %>% filter(grepl(paste0("^", sample_id), source), grepl(paste0("^", sample_id), target))

    if (nrow(df_net) == 0) {
        return(NULL)
    }

    # Map spot coordinates
    get_coord <- function(id_merged) {
        # Remove sample prefix (sample__barcode)
        bid <- sub(paste0("^", sample_id, "__"), "", as.character(id_merged))
        # If not found, try stripping just the underscore
        if (!(bid %in% rownames(coords))) {
            bid <- sub(paste0("^", sample_id, "_"), "", as.character(id_merged))
        }

        if (!(bid %in% rownames(coords))) {
            return(NULL)
        }

        c_raw <- coords[bid, ]
        list(
            x = c_raw$imagecol * s_fact,
            y = (max_row + min_row - c_raw$imagerow) * s_fact
        )
    }

    edge_list <- list()
    for (i in 1:nrow(df_net)) {
        s_c <- get_coord(df_net$source[i])
        t_c <- get_coord(df_net$target[i])
        if (is.null(s_c) || is.null(t_c)) next
        edge_list[[length(edge_list) + 1]] <- data.frame(
            x = s_c$x, y = s_c$y, xend = t_c$x, yend = t_c$y,
            prob = df_net$prob[i],
            interaction = df_net$interaction_name[i]
        )
    }

    if (length(edge_list) == 0) {
        return(NULL)
    }
    edges <- do.call(rbind, edge_list)

    # Nodes (Spots)
    nodes <- coords %>%
        tibble::rownames_to_column("spot") %>%
        mutate(
            x = imagecol * s_fact,
            y = (max_row + min_row - imagerow) * s_fact,
            ident = as.character(obj@meta.data[spot, "cellchat_group"])
        )

    p <- ggplot() +
        # H&E Layer
        geom_raster(data = backdrop, aes(x = x, y = y, fill = rgb(r, g, b, maxColorValue = 255)), alpha = 0.5) +
        scale_fill_identity() +
        # Edges
        geom_curve(
            data = edges, aes(x = x, y = y, xend = xend, yend = yend, color = prob, linewidth = prob),
            curvature = 0.1, alpha = 0.6, arrow = arrow(length = unit(0.05, "inches"), type = "closed")
        ) +
        # High-express epithelial spots
        geom_point(
            data = nodes %>% filter(grepl("high", ident, ignore.case = TRUE)),
            aes(x = x, y = y), color = "#FF4500", size = 0.8, alpha = 0.8
        ) +
        scale_color_viridis_c(option = "plasma", name = "Comm. Prob") +
        scale_linewidth_continuous(range = c(0.1, 1.2), guide = "none") +
        coord_fixed() +
        theme_void() +
        theme(
            plot.title = element_text(size = 11, face = "bold", hjust = 0.5),
            plot.margin = margin(5, 5, 5, 5),
            legend.position = "right"
        ) +
        labs(title = paste0(sample_id, ": ", pathway))

    p
}
