qc_feature_param <- function(value, feature_names) {
  if (is.list(value) && !is.null(names(value))) {
    out <- stats::setNames(vector("list", length(feature_names)), feature_names)
    for (nm in intersect(feature_names, names(value))) out[[nm]] <- value[[nm]]
    return(out)
  }
  stats::setNames(rep(list(value), length(feature_names)), feature_names)
}
