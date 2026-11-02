# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:6287-6631
# sha256(func-block)=4fcb40a934293a5d730e230f3c658fa49e4bcad07e600a126bf7b82434d9b2c2
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
GraphPlot <- function(node, edge, transition = NULL,
                      node_coord = c("x", "y"), node_group = NULL, node_palette = "Paired", node_palcolor = NULL, node_size = 4, node_alpha = 1,
                      node_highlight = NULL, node_highlight_color = "red",
                      label = FALSE, label.size = 3.5, label.fg = "white", label.bg = "black", label.bg.r = 0.1,
                      label_insitu = FALSE, label_repel = FALSE, label_repulsion = 20,
                      label_point_size = 1, label_point_color = "black", label_segment_color = "black",
                      edge_threshold = 0.01, use_triangular = c("upper", "lower", "both"), edge_line = c("straight", "curved"), edge_line_curvature = 0.3, edge_line_angle = 90,
                      edge_color = "grey40", edge_size = c(0.2, 1), edge_alpha = 0.5,
                      edge_shorten = 0, edge_offset = 0, edge_highlight = NULL, edge_highlight_color = "red",
                      transition_threshold = 0.01, transition_line = c("straight", "curved"), transition_line_curvature = 0.3, transition_line_angle = 90,
                      transition_color = "black", transition_size = c(0.2, 1), transition_alpha = 1,
                      transition_arrow_type = "closed", transition_arrow_angle = 20, transition_arrow_length = unit(0.02, "npc"),
                      transition_shorten = 0.05, transition_offset = 0, transition_highlight = NULL, transition_highlight_color = "red",
                      aspect.ratio = 1, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                      legend.position = "right", legend.direction = "vertical",
                      theme_use = "theme_scp", theme_args = list(),
                      return_layer = FALSE) {
  use_triangular <- match.arg(use_triangular)
  edge_line <- match.arg(edge_line)
  transition_line <- match.arg(transition_line)
  if (!is.data.frame(node)) {
    stop("'node' must be a data.frame object.")
  }
  if (!is.matrix(edge)) {
    stop("'edge' must be a matrix object.")
  }
  if (!identical(nrow(edge), ncol(edge))) {
    stop("nrow and ncol is not identical in edge matrix")
  }
  if (!identical(nrow(edge), nrow(node))) {
    stop("nrow is not identical between edge and node.")
  }
  if (!identical(rownames(edge), rownames(node))) {
    warning("rownames of node is not identical with edge matrix. They will correspond according to the order.", immediate. = TRUE)
    colnames(edge) <- rownames(edge) <- rownames(node) <- rownames(node) %||% colnames(edge) %||% rownames(edge)
  }
  if (!all(node_coord %in% colnames(node))) {
    stop("Cannot find the node_coord ", paste(node_coord[!node_coord %in% colnames(node)], collapse = ","), " in the node column")
  }
  if (!is.null(transition)) {
    if (!identical(nrow(transition), nrow(node))) {
      stop("nrow is not identical between transition and node.")
    }
    if (!identical(rownames(transition), rownames(node))) {
      warning("rownames of node is not identical with transition matrix. They will correspond according to the order.", immediate. = TRUE)
      colnames(transition) <- rownames(transition) <- rownames(node) <- rownames(node) %||% colnames(transition) %||% rownames(transition)
    }
  }
  if (identical(theme_use, "theme_blank")) {
    theme_args[["xlab"]] <- xlab
    theme_args[["ylab"]] <- ylab
  }

  node <- as.data.frame(node)
  node[["x"]] <- node[[node_coord[1]]]
  node[["y"]] <- node[[node_coord[2]]]
  node[["node_name"]] <- rownames(node)
  node_group <- node_group %||% "node_name"
  node_size <- node_size %||% 5
  node_alpha <- node_alpha %||% 1
  if (!node_group %in% colnames(node)) {
    node[["node_group"]] <- node_group
  } else {
    node[["node_group"]] <- node[[node_group]]
  }
  if (!is.factor(node[["node_group"]])) {
    node[["node_group"]] <- factor(node[["node_group"]], levels = unique(node[["node_group"]]))
  }
  if (!node_size %in% colnames(node)) {
    if (!is.numeric(node_size)) {
      node_size <- 5
    }
    node[["node_size"]] <- node_size
    scale_size <- scale_size_identity()
  } else {
    node[["node_size"]] <- node[[node_size]]
    if (is.numeric(node[[node_size]])) {
      scale_size <- scale_size_continuous(name = node_size)
    } else {
      scale_size <- scale_size_discrete()
    }
  }
  if (!node_alpha %in% colnames(node)) {
    if (!is.numeric(node_alpha)) {
      node_alpha <- 1
    }
    node[["node_alpha"]] <- node_alpha
    scale_alpha <- scale_alpha_identity()
  } else {
    node[["node_alpha"]] <- node[[node_alpha]]
    if (is.numeric(node[[node_alpha]])) {
      scale_alpha <- scale_alpha_continuous()
    } else {
      scale_alpha <- scale_alpha_discrete()
    }
  }

  if (isTRUE(label) && !isTRUE(label_insitu)) {
    label_use <- paste0(1:nlevels(node[["node_group"]]), ": ", levels(node[["node_group"]]))
  } else {
    label_use <- levels(node[["node_group"]])
  }
  global_size <- sqrt(max(node[["x"]], na.rm = TRUE)^2 + max(node[["y"]], na.rm = TRUE)^2)

  edge[edge <= edge_threshold] <- NA
  if (use_triangular == "upper") {
    edge[lower.tri(edge)] <- NA
  } else if (use_triangular == "lower") {
    edge[upper.tri(edge)] <- NA
  }
  edge_df <- melt(edge, na.rm = TRUE, stringsAsFactors = FALSE)
  if (nrow(edge_df) == 0) {
    edge_layer <- NULL
  } else {
    colnames(edge_df) <- c("from", "to", "size")
    edge_df[, "from"] <- as.character(edge_df[, "from"])
    edge_df[, "to"] <- as.character(edge_df[, "to"])
    edge_df[, "size"] <- as.numeric(edge_df[, "size"])
    edge_df[, "x"] <- node[edge_df[, "from"], "x"]
    edge_df[, "y"] <- node[edge_df[, "from"], "y"]
    edge_df[, "xend"] <- node[edge_df[, "to"], "x"]
    edge_df[, "yend"] <- node[edge_df[, "to"], "y"]
    rownames(edge_df) <- edge_df[, "edge_name"] <- paste0(edge_df[, "from"], "-", edge_df[, "to"])
    edge_df <- segementsDf(edge_df, global_size * edge_shorten, global_size * edge_shorten, global_size * edge_offset)

    linetype <- ifelse(is.null(transition), 1, 2)
    if (edge_line == "straight") {
      edge_layer <- list(
        geom_segment(
          data = edge_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
          lineend = "round", linejoin = "mitre", linetype = linetype, color = edge_color, alpha = edge_alpha,
          inherit.aes = FALSE, show.legend = FALSE
        )
      )
      if (!is.null(edge_highlight)) {
        edge_df_highlight <- edge_df[edge_df[["edge_name"]] %in% edge_highlight, , drop = FALSE]
        edge_layer <- c(
          edge_layer,
          list(
            geom_segment(
              data = edge_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
              lineend = "round", linejoin = "mitre", linetype = linetype, color = edge_highlight_color, alpha = 1,
              inherit.aes = FALSE, show.legend = FALSE
            )
          )
        )
      }
    } else {
      edge_layer <- list(
        geom_curve(
          data = edge_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
          curvature = edge_line_curvature, angle = edge_line_angle,
          lineend = "round", linetype = linetype, color = edge_color, alpha = edge_alpha,
          inherit.aes = FALSE, show.legend = FALSE
        )
      )
      if (!is.null(edge_highlight)) {
        edge_df_highlight <- edge_df[edge_df[["edge_name"]] %in% edge_highlight, , drop = FALSE]
        edge_layer <- c(
          edge_layer,
          list(
            geom_curve(
              data = edge_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
              curvature = edge_line_curvature, angle = edge_line_angle,
              lineend = "round", linetype = linetype, color = edge_highlight_color, alpha = 1,
              inherit.aes = FALSE, show.legend = FALSE
            )
          )
        )
      }
    }
    edge_layer <- c(edge_layer, list(
      scale_linewidth_continuous(range = range(edge_size), guide = "none"),
      new_scale("linewidth")
    ))
  }

  if (!is.null(transition)) {
    trans2 <- trans1 <- as_matrix(transition)
    trans1[lower.tri(trans1)] <- 0
    trans2[upper.tri(trans2)] <- 0
    trans <- t(trans1) - trans2
    trans[abs(trans) <= transition_threshold] <- NA
    trans_df <- melt(trans, na.rm = TRUE, stringsAsFactors = FALSE)
    if (nrow(trans_df) == 0) {
      trans_layer <- NULL
    } else {
      trans_df <- as.data.frame(t(apply(trans_df, 1, function(x) {
        if (as.numeric(x[3]) < 0) {
          return(c(x[c(2, 1)], -as.numeric(x[3])))
        } else {
          return(x)
        }
      })))
      colnames(trans_df) <- c("from", "to", "size")
      trans_df[, "from"] <- as.character(trans_df[, "from"])
      trans_df[, "to"] <- as.character(trans_df[, "to"])
      trans_df[, "size"] <- as.numeric(trans_df[, "size"])
      trans_df[, "x"] <- node[trans_df[, "from"], "x"]
      trans_df[, "y"] <- node[trans_df[, "from"], "y"]
      trans_df[, "xend"] <- node[trans_df[, "to"], "x"]
      trans_df[, "yend"] <- node[trans_df[, "to"], "y"]
      rownames(trans_df) <- trans_df[, "trans_name"] <- paste0(trans_df[, "from"], "-", trans_df[, "to"])
      trans_df <- segementsDf(trans_df, global_size * transition_shorten, global_size * transition_shorten, global_size * transition_offset)

      if (transition_line == "straight") {
        trans_layer <- list(
          geom_segment(
            data = trans_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
            arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
            lineend = "round", linejoin = "mitre", color = transition_color, alpha = transition_alpha,
            inherit.aes = FALSE, show.legend = FALSE
          )
        )
        if (!is.null(transition_highlight)) {
          trans_df_highlight <- trans_df[trans_df[["trans_name"]] %in% transition_highlight, , drop = FALSE]
          trans_layer <- c(
            trans_layer,
            list(
              geom_segment(
                data = trans_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
                arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
                lineend = "round", linejoin = "mitre", color = transition_highlight_color, alpha = 1,
                inherit.aes = FALSE, show.legend = FALSE
              )
            )
          )
        }
      } else {
        trans_layer <- list(
          geom_curve(
            data = trans_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
            arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
            curvature = transition_line_curvature, angle = transition_line_angle,
            lineend = "round", color = transition_color, alpha = transition_alpha,
            inherit.aes = FALSE, show.legend = FALSE
          )
        )
        if (!is.null(edge_highlight)) {
          trans_df_highlight <- trans_df[trans_df[["trans_name"]] %in% transition_highlight, , drop = FALSE]
          trans_layer <- c(
            trans_layer,
            list(
              geom_curve(
                data = trans_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
                arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
                curvature = transition_line_curvature, angle = transition_line_angle,
                lineend = "round", color = transition_highlight_color, alpha = 1,
                inherit.aes = FALSE, show.legend = FALSE
              )
            )
          )
        }
      }
      trans_layer <- c(trans_layer, list(
        scale_linewidth_continuous(range = range(transition_size), guide = "none"),
        new_scale("linewidth")
      ))
    }
  } else {
    trans_layer <- NULL
  }

  node_layer <- list(
    geom_point(data = node, aes(x = x, y = y, size = node_size * 1.2), color = "black", show.legend = FALSE, inherit.aes = FALSE),
    geom_point(data = node, aes(x = x, y = y, size = node_size, color = node_group, alpha = node_alpha), inherit.aes = FALSE)
  )
  if (!is.null(node_highlight)) {
    node_highlight <- node[node[["node_name"]] %in% node_highlight, , drop = FALSE]
    node_layer <- c(
      node_layer,
      list(
        geom_point(data = node_highlight, aes(x = x, y = y, size = node_size * 1.3), color = node_highlight_color, show.legend = FALSE, inherit.aes = FALSE),
        geom_point(data = node_highlight, aes(x = x, y = y, size = node_size, color = node_group, alpha = node_alpha), inherit.aes = FALSE)
      )
    )
  }
  node_layer <- c(node_layer, list(
    scale_color_manual(
      name = node_group, values = palette_scp(node[["node_group"]], palette = node_palette, palcolor = node_palcolor), labels = label_use,
      guide = guide_legend(
        title.hjust = 0,
        order = 1,
        override.aes = list(size = 4, alpha = 1)
      )
    ),
    scale_size,
    scale_alpha
  ))

  if (isTRUE(label)) {
    if (isTRUE(label_insitu)) {
      node[, "label"] <- node[["node_group"]]
    } else {
      node[, "label"] <- as.numeric(node[["node_group"]])
    }
    if (isTRUE(label_repel)) {
      label_layer <- list(geom_point(
        data = node, mapping = aes(x = .data[["x"]], y = .data[["y"]]),
        color = label_point_color, size = label_point_size, inherit.aes = FALSE
      ), geom_text_repel(
        data = node, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]]),
        fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
        point.size = label_point_size, max.overlaps = 100, force = label_repulsion,
        color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE
      ))
    } else {
      label_layer <- list(geom_text_repel(
        data = node, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]]),
        fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
        point.size = NA, max.overlaps = 100, force = 0,
        color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE
      ))
    }
  } else {
    label_layer <- NULL
  }

  lab_layer <- list(labs(title = title, subtitle = subtitle, x = xlab, y = ylab))
  theme_layer <- list(do.call(theme_use, theme_args) +
    theme(
      aspect.ratio = aspect.ratio,
      legend.position = legend.position,
      legend.direction = legend.direction
    ))

  if (isTRUE(return_layer)) {
    return(list(
      edge_layer = edge_layer,
      trans_layer = trans_layer,
      node_layer = node_layer,
      label_layer = label_layer,
      lab_layer = lab_layer,
      theme_layer = theme_layer
    ))
  } else {
    return(ggplot() +
      edge_layer +
      trans_layer +
      node_layer +
      label_layer +
      lab_layer +
      theme_layer)
  }
}
