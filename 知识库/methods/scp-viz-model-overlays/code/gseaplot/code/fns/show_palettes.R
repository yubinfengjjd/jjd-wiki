# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:298-343
# sha256(func-block)=2ee3daa4dfd8db468e47c030738aa76d3a47510fad3db40f607a822724953d15
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
show_palettes <- function(palettes = NULL, type = c("discrete", "continuous"), index = NULL, palette_names = NULL, return_names = TRUE, return_palettes = FALSE) {
  palette_list <- palette_list
  if (!is.null(palettes)) {
    palette_list <- palettes
  } else {
    palette_list <- palette_list[unlist(lapply(palette_list, function(x) isTRUE(attr(x, "type") %in% type)))]
  }
  index <- index[index %in% seq_along(palette_list)]
  if (!is.null(index)) {
    palette_list <- palette_list[index]
  }
  if (is.null(names(palette_list))) {
    names(palette_list) <- seq_along(palette_list)
  }
  if (is.null(palette_names)) {
    palette_names <- palette_names %||% names(palette_list)
  }
  if (any(!palette_names %in% names(palette_list))) {
    stop(paste("Can not find the palettes: ", paste0(palette_names[!palette_names %in% names(palette_list)], collapse = ",")))
  }
  palette_list <- palette_list[palette_names]

  df <- data.frame(palette = rep(names(palette_list), sapply(palette_list, length)), color = unlist(palette_list))
  df[["palette"]] <- factor(df[["palette"]], levels = rev(unique(df[["palette"]])))
  df[["color_order"]] <- factor(seq_len(nrow(df)), levels = seq_len(nrow(df)))
  df[["proportion"]] <- as.numeric(1 / table(df$palette)[df$palette])

  p <- ggplot(data = df, aes(y = .data[["palette"]], x = .data[["proportion"]], fill = .data[["color_order"]])) +
    geom_col(show.legend = FALSE) +
    scale_fill_manual(values = df[["color"]]) +
    scale_x_continuous(expand = c(0, 0), trans = "reverse") +
    theme_scp(
      axis.title = element_blank(),
      axis.ticks = element_blank(),
      axis.text.x = element_blank(),
      panel.border = element_blank()
    )
  print(p)

  if (isTRUE(return_palettes)) {
    return(palette_list)
  }
  if (isTRUE(return_names)) {
    return(palette_names)
  }
}
