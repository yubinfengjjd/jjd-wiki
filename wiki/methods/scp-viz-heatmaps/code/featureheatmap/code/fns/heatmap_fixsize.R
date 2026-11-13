# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7608-7672
# sha256(func-block)=6d608a012649279163bd662c21934b8c7a799180df1e827d679dc57cad1f5e20
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
heatmap_fixsize <- function(width, width_sum, height, height_sum, units, ht_list, legend_list) {
  gTree <- grid.grabExpr(
    {
      ht <- draw(ht_list, annotation_legend_list = legend_list)
      ht_width <- ComplexHeatmap:::width(ht)
      ht_height <- ComplexHeatmap:::height(ht)
      if (inherits(ht_list, "HeatmapList")) {
        for (nm in names(ht_list@ht_list)) {
          if (is.null(names(width))) {
            width_fix <- width[1]
          } else {
            width_fix <- width[nm]
          }
          if (is.null(names(height))) {
            height_fix <- height[1]
          } else {
            height_fix <- height[nm]
          }
          ht_list@ht_list[[nm]]@matrix_param$width <- unit(width_fix %||% dim(ht_list@ht_list[[nm]]@matrix)[1], units = "null")
          ht_list@ht_list[[nm]]@matrix_param$height <- unit(height_fix %||% dim(ht_list@ht_list[[nm]]@matrix)[2], units = "null")
        }
      } else if (inherits(ht_list, "Heatmap")) {
        ht_list@matrix_param$width <- unit(width[1] %||% dim(ht_list@matrix)[1], units = "null")
        ht_list@matrix_param$height <- unit(height[1] %||% dim(ht_list@matrix)[2], units = "null")
      } else {
        stop("ht_list is not a class of HeatmapList or Heatmap.")
      }
    },
    width = unit(width_sum, units = units),
    height = unit(height_sum, units = units),
    wrap = TRUE,
    wrap.grobs = TRUE
  )
  if (unitType(ht_width) == "npc") {
    ht_width <- unit(width_sum, units = units)
  }
  if (unitType(ht_height) == "npc") {
    ht_height <- unit(height_sum, units = units)
  }
  if (is.null(width)) {
    ht_width <- max(
      convertWidth(ht@layout$max_left_component_width, units, valueOnly = TRUE) +
        convertWidth(ht@layout$max_right_component_width, units, valueOnly = TRUE) +
        convertWidth(sum(ht@layout$max_title_component_width), units, valueOnly = TRUE) +
        convertWidth(ht@annotation_legend_param$size[1], units, valueOnly = TRUE) +
        convertWidth(unit(1, "in"), units, valueOnly = TRUE),
      convertWidth(unit(0.95, "npc"), units, valueOnly = TRUE)
    )
    ht_width <- unit(ht_width, units)
  }
  if (is.null(height)) {
    ht_height <- max(
      convertHeight(ht@layout$max_top_component_height, units, valueOnly = TRUE) +
        convertHeight(ht@layout$max_bottom_component_height, units, valueOnly = TRUE) +
        convertHeight(sum(ht@layout$max_title_component_height), units, valueOnly = TRUE) +
        convertHeight(unit(1, "in"), units, valueOnly = TRUE),
      convertHeight(ht@annotation_legend_param$size[2], units, valueOnly = TRUE),
      convertHeight(unit(0.95, "npc"), units, valueOnly = TRUE)
    )
    ht_height <- unit(ht_height, units)
  }
  ht_width <- convertUnit(ht_width, unitTo = units)
  ht_height <- convertUnit(ht_height, unitTo = units)
  return(list(ht_width = ht_width, ht_height = ht_height))
}
