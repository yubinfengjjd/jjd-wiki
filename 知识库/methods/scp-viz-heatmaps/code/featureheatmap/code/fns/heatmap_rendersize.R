# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7543-7603
# sha256(func-block)=aef12b3c27a59800ee9e1bdc1331ca099d048446df17c3d463482bb5899b2b88
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
heatmap_rendersize <- function(width, height, units, ha_top_list, ha_left, ha_right, ht_list, legend_list, flip) {
  width_annotation <- height_annotation <- 0
  if (isTRUE(flip)) {
    width_sum <- width[1] %||% convertWidth(unit(1, "in"), units, valueOnly = TRUE)
    height_sum <- sum(height %||% convertHeight(unit(1, "in"), units, valueOnly = TRUE))
    if (length(ha_top_list) > 0) {
      width_annotation <- convertWidth(unit(width_annotation, units) + width.HeatmapAnnotation(ha_top_list[[1]]), units, valueOnly = TRUE)
    }
    if (!is.null(ha_left)) {
      height_annotation <- convertHeight(unit(height_annotation, units) + height.HeatmapAnnotation(ha_left), units, valueOnly = TRUE)
    }
    if (!is.null(ha_right)) {
      height_annotation <- convertHeight(unit(height_annotation, units) + height.HeatmapAnnotation(ha_right), units, valueOnly = TRUE)
    }
  } else {
    width_sum <- sum(width %||% convertWidth(unit(1, "in"), units, valueOnly = TRUE))
    height_sum <- height[1] %||% convertHeight(unit(1, "in"), units, valueOnly = TRUE)
    if (length(ha_top_list) > 0) {
      height_annotation <- convertHeight(unit(height_annotation, units) + height.HeatmapAnnotation(ha_top_list[[1]]), units, valueOnly = TRUE)
    }
    if (!is.null(ha_left)) {
      width_annotation <- convertWidth(unit(width_annotation, units) + width.HeatmapAnnotation(ha_left), units, valueOnly = TRUE)
    }
    if (!is.null(ha_right)) {
      width_annotation <- convertWidth(unit(width_annotation, units) + width.HeatmapAnnotation(ha_right), units, valueOnly = TRUE)
    }
  }
  dend_width <- name_width <- NULL
  dend_height <- name_height <- NULL
  if (inherits(ht_list, "HeatmapList")) {
    for (nm in names(ht_list@ht_list)) {
      ht <- ht_list@ht_list[[nm]]
      dend_width <- max(ht@row_dend_param$width, dend_width)
      dend_height <- max(ht@column_dend_param$height, dend_height)
      name_width <- max(ht@row_names_param$max_width, name_width)
      name_height <- max(ht@column_names_param$max_height, name_height)
    }
  } else if (inherits(ht_list, "Heatmap")) {
    ht <- ht_list
    dend_width <- max(ht@row_dend_param$width, dend_width)
    dend_height <- max(ht@column_dend_param$height, dend_height)
    name_width <- max(ht@row_names_param$max_width, name_width)
    name_height <- max(ht@column_names_param$max_height, name_height)
  } else {
    stop("ht_list is not a class of HeatmapList or Heatmap.")
  }

  lgd_width <- convertWidth(unit(unlist(lapply(legend_list, width.Legends)), unitType(width.Legends(legend_list[[1]]))), unitTo = units, valueOnly = TRUE)
  width_sum <- convertWidth(unit(width_sum, units) +
    unit(width_annotation, units) +
    dend_width +
    name_width, units, valueOnly = TRUE) + sum(lgd_width)
  height_sum <- max(
    convertHeight(unit(height_sum, units) +
      unit(height_annotation, units) +
      dend_height +
      name_height, units, valueOnly = TRUE),
    convertHeight(unit(0.95, "npc"), units, valueOnly = TRUE)
  )
  return(list(width_sum = width_sum, height_sum = height_sum))
}
