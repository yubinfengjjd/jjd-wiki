wf_spatial_celltype_palette <- function(labels) {
  canonical <- c(
    Epithelial = "#355C9A",
    Fibroblasts = "#B05AA9",
    Endothelial = "#14967F",
    SmoothMuscle = "#7A6A4F",
    Macrophage = "#9F7A12",
    Mast_cells = "#C12F2A",
    T_cells = "#2A86C0",
    NKT_cells = "#4DAF4A",
    B_cells = "#F39C12",
    Plasma_cells = "#E55E2E"
  )
  labels <- as.character(labels)
  out <- rep(NA_character_, length(labels))
  for (i in seq_along(labels)) {
    hit <- names(canonical)[tolower(names(canonical)) == tolower(labels[[i]])]
    if (length(hit) > 0) out[[i]] <- canonical[[hit[[1]]]]
  }
  if (anyNA(out)) {
    fallback <- wf_project_palette(sum(is.na(out)), palette_name = "d3")
    out[is.na(out)] <- fallback
  }
  setNames(out, labels)
}
