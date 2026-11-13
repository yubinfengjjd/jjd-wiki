qc_feature_labels <- function(feature_names, feature_labels = NULL) {
  out <- stats::setNames(as.list(feature_names), feature_names)
  if (!is.null(feature_labels)) {
    overlap <- intersect(feature_names, names(feature_labels))
    out[overlap] <- as.list(unname(feature_labels[overlap]))
  }
  out
}
