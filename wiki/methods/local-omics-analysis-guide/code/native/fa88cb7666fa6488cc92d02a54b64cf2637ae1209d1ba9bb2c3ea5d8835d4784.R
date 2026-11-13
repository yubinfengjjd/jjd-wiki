wf_spatial_domain_palette <- function(labels) {
  base_cols <- c("#E8C27E", "#F1463A", "#F3BDC3", "#47A447", "#A8D88F", "#2C7FB8", "#C7D7B5", "#D5A16D")
  setNames(rep(base_cols, length.out = length(labels)), labels)
}
