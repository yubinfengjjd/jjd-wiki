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
dirs <- wf_step_dirs(cfg, "9.21", "spatial_comm_premium", "9.21_spatial_comm_premium.R")
manifest <- wf_manifest_init()

# 1. Load Core Data
cellchat_path <- "D:/fyb/UC-20/20.sptial/ST_FROM_RAW_2026-03-06/results/cellchat_rctd_spot/02_cellchat_objects/main_m10_ir250_cellchat.rds"
cellchat <- readRDS(cellchat_path)

# Spatial backgrounds (H&E alignment logic)
step6_rds <- file.path(wf_step_dirs(cfg, "6", "ube2l6_binary")$rds, "spatial_with_ube2l6_groups.rds")
objs <- readRDS(step6_rds)

# Selected pathways for UC
pathways_show <- c("MIF", "COLLAGEN", "LAMININ")

# 2. Premium Bubble Plot Style (Ref: Folder 19)
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

log_message <- function(...) {
    msg <- paste0("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", sprintf(...))
    cat(msg, "\n")
}

# 3. Spatial Image Alignment & Comm Plot
# We use the previous manual coordinate mirroring logic (Definitive Alignment)
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

# 4. Generate Final Outputs
log_message("Generating Premium Bubble Plots...")
p_bubble_high <- plot_premium_bubble(cellchat, "EpiSpot_UBE2L6_high", levels(cellchat@idents), "Outgoing: UBE2L6-High Epithelial Spots")
p_bubble_low <- plot_premium_bubble(cellchat, "EpiSpot_UBE2L6_low", levels(cellchat@idents), "Outgoing: UBE2L6-Low Epithelial Spots")

if (!is.null(p_bubble_high)) {
    ggsave(file.path(dirs$pdf, "bubble_premium_high.pdf"), p_bubble_high, width = 10, height = 7)
    ggsave(file.path(dirs$pdf, "bubble_premium_high.png"), p_bubble_high, width = 10, height = 7, dpi = 300)
}
if (!is.null(p_bubble_low)) {
    ggsave(file.path(dirs$pdf, "bubble_premium_low.pdf"), p_bubble_low, width = 10, height = 7)
    ggsave(file.path(dirs$pdf, "bubble_premium_low.png"), p_bubble_low, width = 10, height = 7, dpi = 300)
}

log_message("Generating Spatial Communication Maps...")
for (sample_id in names(objs)) {
    obj <- objs[[sample_id]]
    for (pathway in pathways_show) {
        p_spat <- plot_spatial_pathway_premium(obj, cellchat, pathway, sample_id)
        if (!is.null(p_spat)) {
            stem <- paste0(sample_id, "_spatial_comm_", pathway)
            ggsave(file.path(dirs$pdf, paste0(stem, ".pdf")), p_spat, width = 8, height = 7)
            ggsave(file.path(dirs$pdf, paste0(stem, ".png")), p_spat, width = 8, height = 7, dpi = 300)
            manifest <- wf_manifest_add(manifest, file.path(dirs$pdf, paste0(stem, ".pdf")), "pdf", "main_text", paste("Spatial comm", pathway))
        }
    }
}

wf_manifest_write(dirs, manifest)
cat("Task complete.\n")
