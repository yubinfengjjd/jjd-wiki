# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:12727-13438
# sha256(func-block)=a023be817e00efb56c38bbee1f9a78f5cb701f726f438ec824d612149d2ed297
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
EnrichmentPlot <- function(srt, db = "GO_BP", group_by = NULL, test.use = "wilcox", res = NULL,
                           plot_type = c("bar", "dot", "lollipop", "network", "enrichmap", "wordcloud", "comparison"),
                           split_by = c("Database", "Groups"), color_by = "Database",
                           group_use = NULL, id_use = NULL, pvalueCutoff = NULL, padjustCutoff = 0.05,
                           topTerm = ifelse(plot_type == "enrichmap", 100, 6), compare_only_sig = FALSE,
                           topWord = 100, word_type = c("term", "feature"), word_size = c(2, 8), words_excluded = NULL,
                           network_layout = "fr", network_labelsize = 5, network_blendmode = "blend",
                           network_layoutadjust = TRUE, network_adjscale = 60, network_adjiter = 100,
                           enrichmap_layout = "fr", enrichmap_cluster = "fast_greedy", enrichmap_label = c("term", "feature"), enrichmap_labelsize = 5,
                           enrlichmap_nlabel = 4, enrichmap_show_keyword = FALSE, enrichmap_mark = c("ellipse", "hull"), enrichmap_expand = c(0.5, 0.5),
                           character_width = 50, lineheight = 0.5,
                           palette = "Spectral", palcolor = NULL,
                           aspect.ratio = 1, legend.position = "right", legend.direction = "vertical",
                           theme_use = "theme_scp", theme_args = list(),
                           combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, seed = 11) {
  set.seed(seed)
  plot_type <- match.arg(plot_type)
  word_type <- match.arg(word_type)
  enrichmap_label <- match.arg(enrichmap_label)
  enrichmap_mark <- match.arg(enrichmap_mark)
  words_excluded <- words_excluded %||% words_excluded

  if (any(!split_by %in% c("Database", "Groups"))) {
    stop("'split_by' must be either 'Database', 'Groups', or both of them")
  }
  if (plot_type %in% c("network", "enrichmap") & length(split_by) == 1) {
    warning("When 'plot_type' is 'network' or 'enrichmap', the 'split_by' parameter does not take effect.", immediate. = TRUE)
    split_by <- c("Database", "Groups")
  }

  if (is.null(res)) {
    if (is.null(group_by)) {
      stop("'group_by' must be provided.")
    }
    slot <- paste("Enrichment", group_by, test.use, sep = "_")
    if (!slot %in% names(srt@tools)) {
      stop("No enrichment result found. You may perform RunEnrichment first.")
    }
    enrichment <- srt@tools[[slot]][["enrichment"]]
  } else {
    enrichment <- res[["enrichment"]]
  }

  if (is.null(pvalueCutoff) && is.null(padjustCutoff)) {
    stop("One of 'pvalueCutoff' or 'padjustCutoff' must be specified")
  }
  if (!is.factor(enrichment["Groups"])) {
    enrichment[["Groups"]] <- factor(enrichment[["Groups"]], levels = unique(enrichment[["Groups"]]))
  }
  if (length(db[!db %in% enrichment[["Database"]]]) > 0) {
    stop(paste0(db[!db %in% enrichment[["Database"]]], " is not in the enrichment result."))
  }
  if (!is.factor(enrichment[["Database"]])) {
    enrichment[["Database"]] <- factor(enrichment[["Database"]], levels = unique(enrichment[["Database"]]))
  }
  if (!is.null(group_use)) {
    enrichment <- enrichment[enrichment[["Groups"]] %in% group_use, , drop = FALSE]
  }
  if (length(id_use) > 0) {
    topTerm <- Inf
    if (is.list(id_use)) {
      if (is.null(names(id_use))) {
        stop("'id_use' must be named when it is a list.")
      }
      if (!all(names(id_use) %in% enrichment[["Groups"]])) {
        stop(paste0("Names in 'id_use' is invalid: ", paste0(names(id_use)[!names(id_use) %in% enrichment[["Groups"]]], collapse = ",")))
      }
      enrichment_list <- list()
      for (i in seq_along(id_use)) {
        enrichment_list[[i]] <- enrichment[enrichment[["ID"]] %in% id_use[[i]] & enrichment[["Groups"]] %in% names(id_use)[i], , drop = FALSE]
      }
      enrichment <- do.call(rbind, enrichment_list)
    } else {
      enrichment <- enrichment[enrichment[["ID"]] %in% unlist(id_use), , drop = FALSE]
    }
  }

  metric <- ifelse(is.null(padjustCutoff), "pvalue", "p.adjust")
  metric_value <- ifelse(is.null(padjustCutoff), pvalueCutoff, padjustCutoff)

  pvalueCutoff <- ifelse(is.null(pvalueCutoff), Inf, pvalueCutoff)
  padjustCutoff <- ifelse(is.null(padjustCutoff), Inf, padjustCutoff)

  if (any(db %in% c("GO_sim", "GO_BP_sim", "GO_CC_sim", "GO_MF_sim"))) {
    enrichment_sim <- enrichment[enrichment[["Database"]] %in% gsub("_sim", "", db), , drop = FALSE]
  }
  enrichment <- enrichment[enrichment[["Database"]] %in% db, , drop = FALSE]

  enrichment_sig <- enrichment[enrichment[[metric]] < metric_value | enrichment[["ID"]] %in% unlist(id_use), , drop = FALSE]
  enrichment_sig <- enrichment_sig[order(enrichment_sig[[metric]]), , drop = FALSE]
  if (nrow(enrichment_sig) == 0) {
    stop(
      "No term enriched using the threshold: ",
      paste0("pvalueCutoff = ", pvalueCutoff), "; ",
      paste0("padjustCutoff = ", padjustCutoff)
    )
  }
  df_list <- split(enrichment_sig, formula(paste0("~", split_by, collapse = "+")))
  df_list <- df_list[lapply(df_list, nrow) > 0]

  facet <- switch(paste0(split_by, collapse = "~"),
    "Groups" = formula(paste0("Database ~ Groups")),
    "Database" = formula(paste0("Groups ~ Database")),
    formula(paste0(split_by, collapse = "~"))
  )

  if (plot_type == "comparison") {
    # comparison -------------------------------------------------------------------------------------------------
    ids <- NULL
    for (i in seq_along(df_list)) {
      df <- df_list[[i]]
      df_groups <- split(df, list(df$Database, df$Groups))
      df_groups <- lapply(df_groups, function(group) {
        filtered_group <- group[head(seq_len(nrow(group)), topTerm), , drop = FALSE]
        return(filtered_group)
      })
      df <- do.call(rbind, df_groups)
      ids <- unique(c(ids, df[, "ID"]))
    }
    if (any(db %in% c("GO_sim", "GO_BP_sim", "GO_CC_sim", "GO_MF_sim"))) {
      enrichment_sub <- subset(enrichment_sim, ID %in% ids)
      enrichment_sub[["Database"]][enrichment_sub[["Database"]] %in% c("GO", "GO_BP", "GO_CC", "GO_MF")] <- paste0(enrichment_sub[["Database"]][enrichment_sub[["Database"]] %in% c("GO", "GO_BP", "GO_CC", "GO_MF")], "_sim")
    } else {
      enrichment_sub <- subset(enrichment, ID %in% ids)
    }
    enrichment_sub[["Database"]] <- factor(enrichment_sub[["Database"]], levels = db)
    enrichment_sub[["GeneRatio"]] <- sapply(enrichment_sub[["GeneRatio"]], function(x) {
      sp <- strsplit(x, "/")[[1]]
      GeneRatio <- as.numeric(sp[1]) / as.numeric(sp[2])
    })
    enrichment_sub[["BgRatio"]] <- sapply(enrichment_sub[["BgRatio"]], function(x) {
      sp <- strsplit(x, "/")[[1]]
      BgRatio <- as.numeric(sp[1]) / as.numeric(sp[2])
      return(BgRatio)
    })
    enrichment_sub[["EnrichmentScore"]] <- enrichment_sub[["GeneRatio"]] / enrichment_sub[["BgRatio"]]
    enrichment_sub[["Description"]] <- capitalize(enrichment_sub[["Description"]])
    enrichment_sub[["Description"]] <- str_wrap(enrichment_sub[["Description"]], width = character_width)
    terms <- setNames(enrichment_sub[["Description"]], enrichment_sub[["ID"]])
    enrichment_sub[["Description"]] <- factor(enrichment_sub[["Description"]], levels = unique(rev(terms[ids])))
    if (isTRUE(compare_only_sig)) {
      enrichment_sub <- enrichment_sub[enrichment_sub[[metric]] < metric_value, , drop = FALSE]
    }
    p <- ggplot(enrichment_sub, aes(x = Groups, y = Description)) +
      geom_point(aes(size = GeneRatio, fill = .data[[metric]], color = ""), shape = 21) +
      scale_size_area(name = "GeneRatio", max_size = 6, n.breaks = 4) +
      guides(size = guide_legend(override.aes = list(fill = "grey30", shape = 21), order = 1)) +
      scale_fill_gradientn(
        name = paste0(metric),
        limits = c(0, min(metric_value, 1)),
        n.breaks = 3,
        colors = palette_scp(palette = palette, palcolor = palcolor, reverse = TRUE),
        na.value = "grey80",
        guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0, order = 2)
      ) +
      scale_color_manual(values = NA, na.value = "black") +
      guides(colour = if (isTRUE(compare_only_sig)) guide_none() else guide_legend("Non-sig", override.aes = list(colour = "black", fill = "grey80", size = 3))) +
      facet_grid(Database ~ ., scales = "free") +
      do.call(theme_use, theme_args) +
      theme(
        aspect.ratio = aspect.ratio,
        legend.position = legend.position,
        legend.direction = legend.direction,
        panel.grid.major = element_line(colour = "grey80", linetype = 2),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
        axis.text.y = element_text(
          lineheight = lineheight, hjust = 1,
          face = ifelse(grepl("\n", levels(enrichment_sub[["Description"]])), "italic", "plain")
        )
      )
    plist <- list(p)
  } else if (plot_type == "bar") {
    # bar -------------------------------------------------------------------------------------------------
    plist <- suppressWarnings(lapply(df_list, function(df) {
      df_groups <- split(df, list(df$Database, df$Groups))
      df_groups <- lapply(df_groups, function(group) {
        filtered_group <- group[head(seq_len(nrow(group)), topTerm), , drop = FALSE]
        return(filtered_group)
      })
      df <- do.call(rbind, df_groups)

      df[["metric"]] <- -log10(df[[metric]])
      df[["Description"]] <- capitalize(df[["Description"]])
      df[["Description"]] <- str_wrap(df[["Description"]], width = character_width)
      df[["Description"]] <- factor(df[["Description"]], levels = unique(rev(df[["Description"]])))

      p <- ggplot(df, aes(
        x = .data[["Description"]], y = .data[["metric"]],
        fill = .data[[color_by]], label = .data[["Count"]]
      )) +
        geom_bar(width = 0.9, stat = "identity", color = "black") +
        geom_text(hjust = -0.5, size = 3.5, color = "white", fontface = "bold") +
        geom_text(hjust = -0.5, size = 3.5) +
        labs(x = "", y = paste0("-log10(", metric, ")")) +
        scale_fill_manual(
          values = palette_scp(levels(df[[color_by]]), palette = palette, palcolor = palcolor),
          na.value = "grey80",
          guide = "none"
        ) +
        scale_y_continuous(limits = c(0, 1.3 * max(df[["metric"]], na.rm = TRUE)), expand = expansion(0, 0)) +
        facet_grid(facet, scales = "free") +
        coord_flip() +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = legend.position,
          legend.direction = legend.direction,
          panel.grid.major = element_line(colour = "grey80", linetype = 2),
          axis.text.y = element_text(
            lineheight = lineheight, hjust = 1,
            face = ifelse(grepl("\n", levels(df[["Description"]])), "italic", "plain")
          )
        )
      return(p)
    }))
  } else if (plot_type == "dot") {
    # dot -------------------------------------------------------------------------------------------------
    plist <- suppressWarnings(lapply(df_list, function(df) {
      df_groups <- split(df, list(df$Database, df$Groups))
      df_groups <- lapply(df_groups, function(group) {
        filtered_group <- group[head(seq_len(nrow(group)), topTerm), , drop = FALSE]
        return(filtered_group)
      })
      df <- do.call(rbind, df_groups)

      df[["GeneRatio"]] <- sapply(df[["GeneRatio"]], function(x) {
        sp <- strsplit(x, "/")[[1]]
        GeneRatio <- as.numeric(sp[1]) / as.numeric(sp[2])
      })
      df <- df[order(df[["GeneRatio"]], decreasing = TRUE), ]
      df[["metric"]] <- -log10(df[[metric]])
      df[["Description"]] <- capitalize(df[["Description"]])
      df[["Description"]] <- str_wrap(df[["Description"]], width = character_width)
      df[["Description"]] <- factor(df[["Description"]], levels = unique(rev(df[["Description"]])))

      p <- ggplot(df, aes(
        x = .data[["Description"]], y = .data[["GeneRatio"]]
      )) +
        geom_point(aes(fill = .data[["metric"]], size = .data[["Count"]]), color = "black", shape = 21) +
        labs(x = "", y = "GeneRatio") +
        scale_size(name = "Count", range = c(3, 6), scales::breaks_extended(n = 4)) +
        guides(size = guide_legend(override.aes = list(fill = "grey30", shape = 21), order = 1)) +
        scale_fill_gradientn(
          name = paste0("-log10(", metric, ")"),
          n.breaks = 3,
          colors = palette_scp(palette = palette, palcolor = palcolor),
          na.value = "grey80",
          guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0)
        ) +
        scale_y_continuous(limits = c(0, 1.3 * max(df[["GeneRatio"]], na.rm = TRUE)), expand = expansion(0, 0)) +
        facet_grid(facet, scales = "free") +
        coord_flip() +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = legend.position,
          legend.direction = legend.direction,
          panel.grid.major = element_line(colour = "grey80", linetype = 2),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
          axis.text.y = element_text(
            lineheight = lineheight, hjust = 1,
            face = ifelse(grepl("\n", levels(df[["Description"]])), "italic", "plain")
          )
        )
      return(p)
    }))
  } else if (plot_type == "lollipop") {
    # lollipop -------------------------------------------------------------------------------------------------
    plist <- suppressWarnings(lapply(df_list, function(df) {
      df_groups <- split(df, list(df$Database, df$Groups))
      df_groups <- lapply(df_groups, function(group) {
        filtered_group <- group[head(seq_len(nrow(group)), topTerm), , drop = FALSE]
        return(filtered_group)
      })
      df <- do.call(rbind, df_groups)

      df[["GeneRatio"]] <- sapply(df[["GeneRatio"]], function(x) {
        sp <- strsplit(x, "/")[[1]]
        GeneRatio <- as.numeric(sp[1]) / as.numeric(sp[2])
      })
      df[["BgRatio"]] <- sapply(df[["BgRatio"]], function(x) {
        sp <- strsplit(x, "/")[[1]]
        BgRatio <- as.numeric(sp[1]) / as.numeric(sp[2])
        return(BgRatio)
      })
      df[["FoldEnrichment"]] <- df[["GeneRatio"]] / df[["BgRatio"]]
      df[["metric"]] <- -log10(df[[metric]])
      df[["Description"]] <- capitalize(df[["Description"]])
      df[["Description"]] <- str_wrap(df[["Description"]], width = character_width)
      df[["Description"]] <- factor(df[["Description"]], levels = unique(df[order(df[["FoldEnrichment"]]), "Description"]))

      p <- ggplot(df, aes(
        x = .data[["Description"]], y = .data[["FoldEnrichment"]],
        fill = .data[["metric"]]
      )) +
        geom_blank() +
        geom_segment(
          aes(y = 0, xend = .data[["Description"]], yend = .data[["FoldEnrichment"]]),
          color = "black", linewidth = 2
        ) +
        geom_segment(
          aes(y = 0, xend = .data[["Description"]], yend = .data[["FoldEnrichment"]], color = .data[["metric"]]),
          linewidth = 1
        ) +
        geom_point(aes(size = .data[["GeneRatio"]]), shape = 21, color = "black") +
        scale_size(name = "GeneRatio", range = c(3, 6), scales::breaks_extended(n = 4)) +
        guides(size = guide_legend(override.aes = list(fill = "grey30", shape = 21), order = 1)) +
        scale_y_continuous(limits = c(0, 1.2 * max(df[["FoldEnrichment"]], na.rm = TRUE)), expand = expansion(0, 0)) +
        labs(x = "", y = "Fold Enrichment") +
        scale_fill_gradientn(
          name = paste0("-log10(", metric, ")"),
          n.breaks = 3,
          colors = palette_scp(palette = palette, palcolor = palcolor),
          na.value = "grey80",
          guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0),
          aesthetics = c("color", "fill")
        ) +
        facet_grid(facet, scales = "free") +
        coord_flip() +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = legend.position,
          legend.direction = legend.direction,
          panel.grid.major = element_line(colour = "grey80", linetype = 2),
          axis.text.y = element_text(
            lineheight = lineheight, hjust = 1,
            face = ifelse(grepl("\n", levels(df[["Description"]])), "italic", "plain")
          )
        )
      return(p)
    }))
  } else if (plot_type == "network") {
    # network -------------------------------------------------------------------------------------------------
    plist <- suppressWarnings(lapply(df_list, function(df) {
      df_groups <- split(df, list(df$Database, df$Groups))
      df_groups <- lapply(df_groups, function(group) {
        filtered_group <- group[head(seq_len(nrow(group)), topTerm), , drop = FALSE]
        return(filtered_group)
      })
      df <- do.call(rbind, df_groups)

      df[["metric"]] <- -log10(df[[metric]])
      df[["Description"]] <- capitalize(df[["Description"]])
      df[["Description"]] <- str_wrap(df[["Description"]], width = character_width)
      df[["Description"]] <- factor(df[["Description"]], levels = unique(df[["Description"]]))
      df$geneID <- strsplit(df$geneID, "/")
      df_unnest <- unnest(df, cols = "geneID")

      nodes <- rbind(
        data.frame("ID" = df[["Description"]], class = "term", metric = df[["metric"]]),
        data.frame("ID" = unique(df_unnest$geneID), class = "gene", metric = 0)
      )
      nodes$Database <- df$Database[1]
      nodes$Groups <- df$Groups[1]
      edges <- as.data.frame(df_unnest[, c("Description", "geneID")])
      colnames(edges) <- c("from", "to")
      edges[["weight"]] <- 1
      graph <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
      if (network_layout %in% c("circle", "tree", "grid")) {
        layout <- switch(network_layout,
          "circle" = layout_in_circle(graph),
          "tree" = layout_as_tree(graph),
          "grid" = layout_on_grid(graph)
        )
      } else {
        layout <- do.call(paste0("layout_with_", network_layout), list(graph))
      }
      df_graph <- as_data_frame(graph, what = "both")

      df_nodes <- df_graph$vertices
      if (isTRUE(network_layoutadjust)) {
        width <- nchar(df_nodes$name)
        width[df_nodes$class == "term"] <- 8
        layout <- adjustlayout(
          graph = graph, layout = layout, width = width, height = 2,
          scale = network_adjscale, iter = network_adjiter
        )
      }
      df_nodes[["dim1"]] <- layout[, 1]
      df_nodes[["dim2"]] <- layout[, 2]

      df_edges <- df_graph$edges
      df_edges[["from_dim1"]] <- df_nodes[df_edges[["from"]], "dim1"]
      df_edges[["from_dim2"]] <- df_nodes[df_edges[["from"]], "dim2"]
      df_edges[["to_dim1"]] <- df_nodes[df_edges[["to"]], "dim1"]
      df_edges[["to_dim2"]] <- df_nodes[df_edges[["to"]], "dim2"]

      colors <- palette_scp(levels(df[["Description"]]), palette = palette, palcolor = palcolor)
      df_edges[["color"]] <- colors[df_edges$from]
      node_colors <- aggregate(df_unnest$Description, by = list(df_unnest$geneID), FUN = function(x) blendcolors(colors = colors[x], mode = network_blendmode))
      colors <- c(colors, setNames(node_colors[, 2], node_colors[, 1]))
      label_colors <- ifelse(colSums(col2rgb(colors)) > 255 * 2, "black", "white")
      df_nodes[["color"]] <- colors[df_nodes$name]
      df_nodes[["label_color"]] <- label_colors[df_nodes$name]
      df_nodes[["label"]] <- NA
      df_nodes[levels(df[["Description"]]), "label"] <- seq_len(nlevels(df[["Description"]]))

      draw_key_cust <- function(data, params, size) {
        data_text <- data
        data_text$label <- which(levels(df[["Description"]]) %in% names(colors)[colors == data_text$fill])
        data_text$colour <- "black"
        data_text$alpha <- 1
        data_text$size <- 11 / .pt
        grobTree(
          draw_key_point(data, list(color = "white", shape = 21)),
          ggrepel:::shadowtextGrob(label = data_text$label, bg.colour = "black", bg.r = 0.1, gp = gpar(col = "white", fontface = "bold"))
        )
      }

      p <- ggplot() +
        geom_segment(data = df_edges, aes(x = from_dim1, y = from_dim2, xend = to_dim1, yend = to_dim2, color = color), alpha = 1, lineend = "round", show.legend = FALSE) +
        geom_label(data = df_nodes[df_nodes$class == "gene", ], aes(x = dim1, y = dim2, label = name, fill = color, color = label_color), size = 3, show.legend = FALSE) +
        geom_point(data = df_nodes[df_nodes$class == "term", ], aes(x = dim1, y = dim2), size = 8, color = "black", fill = "black", stroke = 1, shape = 21, show.legend = FALSE) +
        geom_point(data = df_nodes[df_nodes$class == "term", ], aes(x = dim1, y = dim2, fill = color), size = 7, color = "white", stroke = 1, shape = 21, key_glyph = draw_key_cust) +
        geom_text_repel(
          data = df_nodes[df_nodes$class == "term", ], aes(x = dim1, y = dim2, label = label),
          fontface = "bold", min.segment.length = 0, segment.color = "black",
          point.size = NA, max.overlaps = 100, force = 0, color = "white", bg.color = "black", bg.r = 0.1, size = network_labelsize
        ) +
        scale_color_identity(guide = "none") +
        scale_fill_identity(
          name = "Term:", guide = "legend",
          labels = levels(df[["Description"]]),
          breaks = colors[levels(df[["Description"]])]
        ) +
        guides(color = guide_legend(override.aes = list(color = "transparent"))) +
        labs(x = "", y = "") +
        facet_grid(facet, scales = "free") +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = legend.position,
          legend.direction = legend.direction
        )
      return(p)
    }))
  } else if (plot_type == "enrichmap") {
    # enrichmap -------------------------------------------------------------------------------------------------
    plist <- suppressWarnings(lapply(df_list, function(df) {
      df_groups <- split(df, list(df$Database, df$Groups))
      df_groups <- lapply(df_groups, function(group) {
        filtered_group <- group[head(seq_len(nrow(group)), topTerm), , drop = FALSE]
        return(filtered_group)
      })
      df <- do.call(rbind, df_groups)

      df[["metric"]] <- -log10(df[[metric]])
      df[["Description"]] <- capitalize(df[["Description"]])
      df[["Description"]] <- factor(df[["Description"]], levels = unique(df[["Description"]]))
      df$geneID <- strsplit(df$geneID, "/")
      rownames(df) <- df[["ID"]]

      nodes <- df
      edges <- as.data.frame(t(combn(nodes$ID, 2)))
      colnames(edges) <- c("from", "to")
      edges[["weight"]] <- mapply(function(x, y) length(intersect(df[[x, "geneID"]], df[[y, "geneID"]])), edges$from, edges$to)
      edges <- edges[edges[["weight"]] > 0, , drop = FALSE]
      graph <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
      if (enrichmap_layout %in% c("circle", "tree", "grid")) {
        layout <- switch(enrichmap_layout,
          "circle" = layout_in_circle(graph),
          "tree" = layout_as_tree(graph),
          "grid" = layout_on_grid(graph)
        )
      } else {
        layout <- do.call(paste0("layout_with_", enrichmap_layout), list(graph))
      }
      clusters <- do.call(paste0("cluster_", enrichmap_cluster), list(graph))
      df_graph <- as_data_frame(graph, what = "both")

      df_nodes <- df_graph$vertices
      df_nodes[["dim1"]] <- layout[, 1]
      df_nodes[["dim2"]] <- layout[, 2]
      df_nodes[["clusters"]] <- factor(paste0("C", clusters$membership), paste0("C", unique(sort(clusters$membership))))

      if (isTRUE(enrichmap_show_keyword)) {
        df_keyword1 <- df_nodes %>%
          mutate(keyword = strsplit(tolower(as.character(.data[["Description"]])), "\\s|\\n", perl = TRUE)) %>%
          unnest(cols = "keyword") %>%
          group_by(.data[["keyword"]], Database, Groups, clusters) %>%
          reframe(
            keyword = capitalize(.data[["keyword"]]),
            score = sum(-(log10(.data[[metric]]))),
            count = n(),
            Database = .data[["Database"]],
            Groups = .data[["Groups"]],
            .groups = "keep"
          ) %>%
          filter(!grepl(pattern = "\\[.*\\]", x = .data[["keyword"]])) %>%
          filter(nchar(.data[["keyword"]]) >= 1) %>%
          filter(!tolower(.data[["keyword"]]) %in% tolower(words_excluded)) %>%
          distinct() %>%
          group_by(Database, Groups, clusters) %>%
          arrange(desc(score)) %>%
          slice_head(n = enrlichmap_nlabel) %>%
          reframe(keyword = paste0(.data[["keyword"]], collapse = " ")) %>%
          as.data.frame()
        rownames(df_keyword1) <- as.character(df_keyword1[["clusters"]])
        df_keyword1[["keyword"]] <- str_wrap(df_keyword1[["keyword"]], width = character_width)
        df_keyword1[["label"]] <- paste0(df_keyword1[["clusters"]], ":\n", df_keyword1[["keyword"]])
      } else {
        if (enrichmap_label == "term") {
          df_nodes[["Description"]] <- str_wrap(df_nodes[["Description"]], width = character_width)
        }
        df_keyword1 <- df_nodes %>%
          group_by(Database, Groups, clusters) %>%
          arrange(desc(metric)) %>%
          reframe(keyword = Description) %>%
          distinct() %>%
          group_by(Database, Groups, clusters) %>%
          slice_head(n = enrlichmap_nlabel) %>%
          reframe(keyword = paste0(.data[["keyword"]], collapse = "\n")) %>%
          as.data.frame()
        rownames(df_keyword1) <- as.character(df_keyword1[["clusters"]])
        df_keyword1[["label"]] <- paste0(df_keyword1[["clusters"]], ":\n", df_keyword1[["keyword"]])
      }

      df_keyword2 <- df_nodes %>%
        mutate(keyword = .data[["geneID"]]) %>%
        unnest(cols = "keyword") %>%
        group_by(.data[["keyword"]], Database, Groups, clusters) %>%
        reframe(
          keyword = .data[["keyword"]],
          score = sum(-(log10(.data[[metric]]))),
          count = n(),
          Database = .data[["Database"]],
          Groups = .data[["Groups"]],
          .groups = "keep"
        ) %>%
        distinct() %>%
        group_by(Database, Groups, clusters) %>%
        arrange(desc(score)) %>%
        slice_head(n = enrlichmap_nlabel) %>%
        reframe(keyword = paste0(.data[["keyword"]], collapse = " ")) %>%
        as.data.frame()
      rownames(df_keyword2) <- as.character(df_keyword2[["clusters"]])
      df_keyword2[["keyword"]] <- str_wrap(df_keyword2[["keyword"]], width = character_width)
      df_keyword2[["label"]] <- paste0(df_keyword2[["clusters"]], ":\n", df_keyword2[["keyword"]])

      df_nodes[["keyword1"]] <- df_keyword1[as.character(df_nodes$clusters), "keyword"]
      df_nodes[["keyword2"]] <- df_keyword2[as.character(df_nodes$clusters), "keyword"]

      df_edges <- df_graph$edges
      df_edges[["from_dim1"]] <- df_nodes[df_edges[["from"]], "dim1"]
      df_edges[["from_dim2"]] <- df_nodes[df_edges[["from"]], "dim2"]
      df_edges[["to_dim1"]] <- df_nodes[df_edges[["to"]], "dim1"]
      df_edges[["to_dim2"]] <- df_nodes[df_edges[["to"]], "dim2"]

      if (enrichmap_mark == "hull") {
        check_R("concaveman")
      }
      mark_layer <- do.call(
        switch(enrichmap_mark,
          "ellipse" = "geom_mark_ellipse",
          "hull" = "geom_mark_hull"
        ),
        list(
          data = df_nodes, aes(
            x = dim1, y = dim2, color = clusters, fill = clusters,
            label = clusters, description = if (enrichmap_label == "term") keyword1 else keyword2
          ),
          expand = unit(3, "mm"),
          alpha = 0.1,
          label.margin = margin(1, 1, 1, 1, "mm"),
          label.fontsize = enrichmap_labelsize * 2,
          label.fill = "grey95",
          label.minwidth = unit(character_width, "in"),
          label.buffer = unit(0, "mm"),
          con.size = 1,
          con.cap = 0
        )
      )

      p <- ggplot() +
        mark_layer +
        geom_segment(data = df_edges, aes(x = from_dim1, y = from_dim2, xend = to_dim1, yend = to_dim2, linewidth = weight), alpha = 0.1, lineend = "round") +
        geom_point(data = df_nodes, aes(x = dim1, y = dim2, size = Count, fill = clusters), color = "black", shape = 21) +
        labs(x = "", y = "") +
        scale_size(name = "Count", range = c(2, 6), scales::breaks_extended(n = 4)) +
        guides(size = guide_legend(override.aes = list(fill = "grey30", shape = 21), order = 1)) +
        scale_linewidth(name = "Intersection", range = c(0.3, 3), scales::breaks_extended(n = 4)) +
        guides(linewidth = guide_legend(override.aes = list(alpha = 1, color = "grey"), order = 2)) +
        scale_fill_manual(
          name = switch(enrichmap_label,
            "term" = "Feature:",
            "feature" = "Term:"
          ),
          values = palette_scp(levels(df_nodes[["clusters"]]), palette = palette, palcolor = palcolor),
          labels = if (enrichmap_label == "term") df_keyword2[levels(df_nodes[["clusters"]]), "label"] else df_keyword1[levels(df_nodes[["clusters"]]), "label"],
          na.value = "grey80",
          aesthetics = c("colour", "fill")
        ) +
        guides(fill = guide_legend(override.aes = list(alpha = 1, color = "black", shape = NA), byrow = TRUE, order = 3)) +
        guides(color = guide_none()) +
        scale_x_continuous(expand = expansion(c(enrichmap_expand[1], enrichmap_expand[1]), 0)) +
        scale_y_continuous(expand = expansion(c(enrichmap_expand[2], enrichmap_expand[2]), 0)) +
        facet_grid(facet, scales = "free") +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = legend.position,
          legend.direction = legend.direction
        )
      return(p)
    }))
  } else if (plot_type == "wordcloud") {
    # wordcloud -------------------------------------------------------------------------------------------------
    check_R("ggwordcloud")
    check_R("jokergoo/simplifyEnrichment")
    plist <- lapply(df_list, function(df) {
      if (word_type == "term") {
        df_groups <- split(df, list(df$Database, df$Groups))
        df_groups <- df_groups[sapply(df_groups, nrow) > 0]
        for (i in seq_along(df_groups)) {
          df_sub <- df_groups[[i]]
          if (all(df_sub$Database %in% c("GO", "GO_BP", "GO_CC", "GO_MF"))) {
            df0 <- simplifyEnrichment::keyword_enrichment_from_GO(df_sub[["ID"]])
            if (nrow(df0 > 0)) {
              df_sub <- df0 %>%
                reframe(
                  keyword = .data[["keyword"]],
                  score = -(log10(.data[["padj"]])),
                  count = .data[["n_term"]],
                  Database = df_sub[["Database"]][1],
                  Groups = df_sub[["Groups"]][1]
                ) %>%
                filter(!grepl(pattern = "\\[.*\\]", x = .data[["keyword"]])) %>%
                filter(nchar(.data[["keyword"]]) >= 1) %>%
                filter(!tolower(.data[["keyword"]]) %in% tolower(words_excluded)) %>%
                distinct() %>%
                mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(60, 40))) %>%
                as.data.frame()
              df_sub <- df_sub[head(order(df_sub[["score"]], decreasing = TRUE), topWord), , drop = FALSE]
            } else {
              df_sub <- NULL
            }
          } else {
            df_sub <- df_sub %>%
              mutate(keyword = strsplit(tolower(as.character(.data[["Description"]])), " ")) %>%
              unnest(cols = "keyword") %>%
              group_by(.data[["keyword"]], Database, Groups) %>%
              reframe(
                keyword = .data[["keyword"]],
                score = sum(-(log10(.data[[metric]]))),
                count = n(),
                Database = .data[["Database"]],
                Groups = .data[["Groups"]],
                .groups = "keep"
              ) %>%
              filter(!grepl(pattern = "\\[.*\\]", x = .data[["keyword"]])) %>%
              filter(nchar(.data[["keyword"]]) >= 1) %>%
              filter(!tolower(.data[["keyword"]]) %in% tolower(words_excluded)) %>%
              distinct() %>%
              mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(60, 40))) %>%
              as.data.frame()
            df_sub <- df_sub[head(order(df_sub[["score"]], decreasing = TRUE), topWord), , drop = FALSE]
          }
          df_groups[[i]] <- df_sub
        }
        df <- do.call(rbind, df_groups)
      } else {
        df <- df %>%
          mutate(keyword = strsplit(as.character(.data[["geneID"]]), "/")) %>%
          unnest(cols = "keyword") %>%
          group_by(.data[["keyword"]], Database, Groups) %>%
          reframe(
            keyword = .data[["keyword"]],
            score = sum(-(log10(.data[[metric]]))),
            count = n(),
            Database = .data[["Database"]],
            Groups = .data[["Groups"]],
            .groups = "keep"
          ) %>%
          distinct() %>%
          mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(60, 40))) %>%
          as.data.frame()
        df <- df[head(order(df[["score"]], decreasing = TRUE), topWord), , drop = FALSE]
      }
      colors <- palette_scp(df[["score"]], type = "continuous", palette = palette, palcolor = palcolor, matched = FALSE)
      colors_value <- seq(min(df[["score"]], na.rm = TRUE), quantile(df[["score"]], 0.99, na.rm = TRUE) + 0.001, length.out = 100)
      p <- ggplot(df, aes(label = .data[["keyword"]], size = .data[["count"]], color = .data[["score"]], angle = .data[["angle"]])) +
        ggwordcloud::geom_text_wordcloud(rm_outside = TRUE, eccentricity = 1, shape = "square", show.legend = TRUE, grid_margin = 3) +
        scale_color_gradientn(
          name = "Score:", colours = colors, values = rescale(colors_value),
          guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0)
        ) +
        scale_size(name = "Count", range = word_size, breaks = ceiling(seq(min(df[["count"]], na.rm = TRUE), max(df[["count"]], na.rm = TRUE), length.out = 3))) +
        guides(size = guide_legend(override.aes = list(colour = "black", label = "G"), order = 1)) +
        facet_grid(facet, scales = "free") +
        coord_flip() +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = legend.position,
          legend.direction = legend.direction
        )
      return(p)
    })
  }

  if (isTRUE(combine)) {
    if (length(plist) > 1) {
      plot <- wrap_plots(plotlist = plist, nrow = nrow, ncol = ncol, byrow = byrow)
    } else {
      plot <- plist[[1]]
    }
    return(plot)
  } else {
    return(plist)
  }
}
