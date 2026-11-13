wf_spatial_celltype_palette <- function(labels) {
  canonical <- c(
    Epithelial = "#E8C27E",
    Fibroblasts = "#F2C2C8",
    Endothelial = "#A8D88F",
    SmoothMuscle = "#8FA1C7",
    Macrophage = "#F2B25B",
    Mast_cells = "#D95B54",
    T_cells = "#4F97D3",
    NKT_cells = "#56AE6C",
    B_cells = "#F4D9A6",
    Plasma_cells = "#B89AD9"
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
