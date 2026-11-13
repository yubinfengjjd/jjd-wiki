#!/usr/bin/env Rscript

source(file.path("code", "R", "workflow_helpers.R"))

suppressPackageStartupMessages({
    library(Seurat)
    library(CellChat)
    library(ggplot2)
    library(dplyr)
    library(patchwork)
    library(viridis)
})

cfg <- wf_load_config()
wf_ensure_local_lib(cfg)
wf_set_seed(cfg)

# 1. Load Core Data
root_dir <- wf_find_root()
out_root <- file.path(root_dir, "results", "cellchat_rctd_spot")
enhanced_dir <- file.path(out_root, "05_pathway_plots_enhanced")
dir.create(enhanced_dir, recursive = TRUE, showWarnings = FALSE)

cellchat_path <- file.path(out_root, "02_cellchat_objects", "main_m10_ir250_cellchat.rds")
if (!file.exists(cellchat_path)) stop("CellChat object not found.")
cellchat <- readRDS(cellchat_path)

meta_path <- file.path(out_root, "01_metadata", "spot_metadata_with_cellchat_groups.csv")
meta_all <- readr::read_csv(meta_path, show_col_types = FALSE)

step6_rds <- file.path(root_dir, "local_outputs", "6.ube2l6_binary", "result", "rds", "spatial_with_ube2l6_groups.rds")
objs <- readRDS(step6_rds)

pathways_show <- c("MIF", "COLLAGEN", "LAMININ")

log_message <- function(...) {
    msg <- paste0("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", sprintf(...))
    cat(msg, "\n")
}

# Ensure ggnewscale is available for multiple scales (discrete groups + continuous prob)
if (!requireNamespace("ggnewscale", quietly = TRUE)) {
    install.packages("ggnewscale", lib = cfg$deps$local_lib, repos = "https://cloud.r-project.org")
}
library(ggnewscale)

# Standard Palette for Groups
group_cols <- wf_spatial_celltype_palette(unique(meta_all$cellchat_group))
group_cols["EpiSpot_UBE2L6_high"] <- "#FF4500"
group_cols["EpiSpot_UBE2L6_low"] <- "#4682B4"

# 2. REFINED Spatial Communication Map (Spot-based Background)
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

log_message("Generating Refined Spatial Communication Maps...")
for (sample_id in names(objs)) {
    obj <- objs[[sample_id]]
    meta_sample <- meta_all %>% filter(sample_id == !!sample_id)
    for (pathway in pathways_show) {
        p_spat <- tryCatch(plot_spatial_aggregate_spots(obj, cellchat, meta_sample, pathway, sample_id), error = function(e) {
            log_message("Error in %s: %s", pathway, e$message)
            NULL
        })
        if (!is.null(p_spat)) {
            stem <- paste0(sample_id, "_spatial_comm_spots_", pathway)
            ggsave(file.path(enhanced_dir, paste0(stem, ".pdf")), p_spat, width = 11, height = 8)
            ggsave(file.path(enhanced_dir, paste0(stem, ".png")), p_spat, width = 11, height = 8, dpi = 300)
            log_message("Saved spot-map for %s in %s", pathway, sample_id)
        }
    }
}

# 3. REFINED Bubble Plot
log_message("Generating Cleaned Bubble Plots...")
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

group_names <- levels(cellchat@idents)
targets.use <- setdiff(group_names, c("EpiSpot_UBE2L6_high", "EpiSpot_UBE2L6_low"))
p_high <- plot_bubble_refined(cellchat, "EpiSpot_UBE2L6_high", targets.use, "Refined Signaling: UBE2L6_high")
p_low <- plot_bubble_refined(cellchat, "EpiSpot_UBE2L6_low", targets.use, "Refined Signaling: UBE2L6_low")

if (!is.null(p_high)) {
    ggsave(file.path(enhanced_dir, "bubble_refined_high.pdf"), p_high, width = 11, height = 7)
    ggsave(file.path(enhanced_dir, "bubble_refined_high.png"), p_high, width = 11, height = 7, dpi = 300)
}
if (!is.null(p_low)) {
    ggsave(file.path(enhanced_dir, "bubble_refined_low.pdf"), p_low, width = 11, height = 7)
    ggsave(file.path(enhanced_dir, "bubble_refined_low.png"), p_low, width = 11, height = 7, dpi = 300)
}

log_message("All tasks complete.")
