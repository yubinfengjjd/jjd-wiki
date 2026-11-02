wf_spatial_domain_palette <- function(labels) {
  base_cols <- c("#6A9BD1", "#F4A261", "#8BCB88", "#D95F5F", "#9C89D9", "#E9C46A", "#4FB3BF", "#C97EBC")
  setNames(rep(base_cols, length.out = length(labels)), labels)
}
