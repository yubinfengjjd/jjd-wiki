build_group_palette <- function(labels) {
  base_pal <- c(
    Epithelial = '#D9AE60',
    Fibroblasts = '#EAA7B5',
    Endothelial = '#97C37B',
    SmoothMuscle = '#869FC7',
    Macrophage = '#E09A43',
    Mast_cells = '#CC5A4D',
    T_cells = '#4D87C7',
    NKT_cells = '#62A85C',
    B_cells = '#E6C58A',
    Plasma_cells = '#A28DCA',
    'Epithelial-rich' = '#C47A3A',
    'Immune-rich' = '#5B8BC4',
    'Stromal-rich' = '#83A878',
    EpiSpot_UBE2L6_high = '#B14C35',
    EpiSpot_UBE2L6_low = '#6C9BA7'
  )
  labels <- as.character(labels)
  missing_labels <- setdiff(labels, names(base_pal))
  if (length(missing_labels)) {
    base_pal <- c(base_pal, setNames(wf_project_palette(length(missing_labels), palette_name = 'd3'), missing_labels))
  }
  base_pal[labels]
}
