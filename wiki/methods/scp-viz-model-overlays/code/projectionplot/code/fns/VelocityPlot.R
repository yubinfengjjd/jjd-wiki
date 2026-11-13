# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:6745-6945
# sha256(func-block)=9d6ac731951048f8e84fdafe44443deae7c53d45d968aec6f9641cdc28c09cd1
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
VelocityPlot <- function(srt, reduction, dims = c(1, 2), cells = NULL, velocity = "stochastic", plot_type = c("raw", "grid", "stream"),
                         group_by = NULL, group_palette = "Paired", group_palcolor = NULL,
                         n_neighbors = ceiling(ncol(srt@assays[[1]]) / 50), density = 1, smooth = 0.5, scale = 1, min_mass = 1, cutoff_perc = 5,
                         arrow_angle = 20, arrow_color = "black",
                         streamline_L = 5, streamline_minL = 1, streamline_res = 1, streamline_n = 15,
                         streamline_width = c(0, 0.8), streamline_alpha = 1, streamline_color = NULL, streamline_palette = "RdYlBu", streamline_palcolor = NULL,
                         streamline_bg_color = "white", streamline_bg_stroke = 0.5,
                         aspect.ratio = 1, title = "Cell velocity", subtitle = NULL, xlab = NULL, ylab = NULL,
                         legend.position = "right", legend.direction = "vertical",
                         theme_use = "theme_scp", theme_args = list(),
                         return_layer = FALSE, seed = 11) {
  set.seed(seed)

  plot_type <- match.arg(plot_type)
  check_R("metR")

  if (!reduction %in% names(srt@reductions)) {
    stop(paste0(reduction, " is not in the srt reduction names."))
  }
  V_reduction <- paste0(velocity, "_", reduction)
  if (!V_reduction %in% names(srt@reductions)) {
    stop("Cannot find the velocity embedding ", V_reduction, ".")
  }
  X_emb <- srt@reductions[[reduction]]@cell.embeddings[, dims]
  V_emb <- srt@reductions[[V_reduction]]@cell.embeddings[, dims]
  if (!is.null(cells)) {
    X_emb <- X_emb[intersect(rownames(X_emb), cells), , drop = FALSE]
    V_emb <- V_emb[intersect(rownames(V_emb), cells), , drop = FALSE]
  }

  reduction_key <- srt@reductions[[reduction]]@key
  xlab <- xlab %||% paste0(reduction_key, dims[1])
  ylab <- ylab %||% paste0(reduction_key, dims[2])
  if (identical(theme_use, "theme_blank")) {
    theme_args[["xlab"]] <- xlab
    theme_args[["ylab"]] <- ylab
  }

  if (plot_type == "raw") {
    if (!is.null(density) && (density > 0 && density < 1)) {
      s <- ceiling(density * nrow(X_emb))
      ix_choice <- sample(seq_len(nrow(X_emb)), size = s, replace = FALSE)
      X_emb <- X_emb[ix_choice, ]
      V_emb <- V_emb[ix_choice, ]
    }
    if (!is.null(scale)) {
      V_emb <- V_emb * scale
    }
    df_field <- cbind.data.frame(X_emb, V_emb)
    colnames(df_field) <- c("x", "y", "u", "v")
    df_field[["length"]] <- sqrt(df_field[["u"]]^2 + df_field[["v"]]^2)
    global_size <- sqrt(max(df_field[["x"]], na.rm = TRUE)^2 + max(df_field[["y"]], na.rm = TRUE)^2)
    df_field[["length_perc"]] <- df_field[["length"]] / global_size

    if (!is.null(group_by)) {
      df_field[["group_by"]] <- srt@meta.data[rownames(df_field), group_by, drop = TRUE]
      velocity_layer <- list(
        geom_segment(
          data = df_field, aes(x = x, y = y, xend = x + u, yend = y + v, color = group_by),
          arrow = arrow(length = unit(df_field[["length_perc"]], "npc"), type = "closed", angle = arrow_angle),
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        scale_color_manual(
          name = group_by, values = palette_scp(df_field[["group_by"]], palette = group_palette, palcolor = group_palcolor),
          guide = guide_legend(title.hjust = 0, order = 1, override.aes = list(linewidth = 2, alpha = 1))
        )
      )
    } else {
      velocity_layer <- list(
        geom_segment(
          data = df_field, aes(x = x, y = y, xend = x + u, yend = y + v),
          color = arrow_color,
          arrow = arrow(length = unit(df_field[["length_perc"]], "npc"), type = "closed", angle = arrow_angle),
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        )
      )
    }
  }
  if (plot_type == "grid") {
    res <- compute_velocity_on_grid(X_emb, V_emb,
      density = density, smooth = smooth, n_neighbors = n_neighbors,
      min_mass = min_mass, scale = scale
    )
    X_grid <- res$X_grid
    V_grid <- res$V_grid

    df_field <- cbind.data.frame(X_grid, V_grid)
    colnames(df_field) <- c("x", "y", "u", "v")
    df_field[["length"]] <- sqrt(df_field[["u"]]^2 + df_field[["v"]]^2)
    global_size <- sqrt(max(df_field[["x"]], na.rm = TRUE)^2 + max(df_field[["y"]], na.rm = TRUE)^2)
    df_field[["length_perc"]] <- df_field[["length"]] / global_size
    velocity_layer <- list(
      geom_segment(
        data = df_field, aes(x = x, y = y, xend = x + u, yend = y + v),
        color = arrow_color,
        arrow = arrow(length = unit(df_field[["length_perc"]], "npc"), type = "closed", angle = arrow_angle),
        lineend = "round", linejoin = "mitre", inherit.aes = FALSE
      )
    )
  }
  if (plot_type == "stream") {
    check_R("metR")
    res <- compute_velocity_on_grid(X_emb, V_emb,
      density = density, smooth = smooth, n_neighbors = n_neighbors,
      min_mass = min_mass, scale = 1, cutoff_perc = cutoff_perc,
      adjust_for_stream = TRUE
    )
    X_grid <- res$X_grid
    V_grid <- res$V_grid

    # if (!is.null(density) && (density > 0 & density < 1)) {
    #   s <- ceiling(density * ncol(X_grid))
    #   ix_choice <- sample(1:ncol(X_grid), size = s, replace = FALSE)
    #   X_grid <- X_grid[, ix_choice]
    #   V_grid <- V_grid[, ix_choice, ix_choice]
    # }

    df_field <- expand.grid(X_grid[1, ], X_grid[2, ])
    colnames(df_field) <- c("x", "y")
    u <- melt(t(V_grid[1, , ]))
    v <- melt(t(V_grid[2, , ]))
    df_field[, "u"] <- u$value
    df_field[, "v"] <- v$value
    df_field[is.na(df_field)] <- 0

    if (!is.null(streamline_color)) {
      velocity_layer <- list(
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, size = max(streamline_width, na.rm = TRUE) + streamline_bg_stroke, color = streamline_bg_color, alpha = streamline_alpha,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, size = max(streamline_width, na.rm = TRUE), color = streamline_color, alpha = streamline_alpha,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, linetype = 0, color = arrow_color,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        )
      )
    } else {
      velocity_layer <- list(
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, size = max(streamline_width, na.rm = TRUE) + streamline_bg_stroke, color = streamline_bg_color, alpha = streamline_alpha,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v, size = after_stat(step), color = sqrt(after_stat(dx)^2 + after_stat(dy)^2)),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, alpha = streamline_alpha,
          arrow = NULL, lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, linetype = 0, color = arrow_color,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        scale_color_gradientn(
          name = "Velocity", colors = palette_scp(palette = streamline_palette, palcolor = streamline_palcolor),
          guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0, order = 1)
        ),
        scale_size(range = range(streamline_width), guide = "none")
      )
    }
  }

  lab_layer <- list(labs(title = title, subtitle = subtitle, x = xlab, y = ylab))
  theme_layer <- list(do.call(theme_use, theme_args) + theme(
    aspect.ratio = aspect.ratio,
    legend.position = legend.position,
    legend.direction = legend.direction
  ))

  if (isTRUE(return_layer)) {
    return(list(
      velocity_layer = velocity_layer,
      lab_layer = lab_layer,
      theme_layer = theme_layer
    ))
  } else {
    return(ggplot() +
      velocity_layer +
      lab_layer +
      lab_layer +
      theme_layer)
  }
}
