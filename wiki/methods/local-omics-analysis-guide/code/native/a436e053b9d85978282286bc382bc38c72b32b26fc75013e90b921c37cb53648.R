pick_matrix <- function(env, obj_names, exclude = character()) {
  nms <- setdiff(obj_names, exclude)
  ok <- vapply(nms, function(nm) {
    x <- env[[nm]]
    inherits(x, "dgCMatrix") || is.matrix(x) || is.data.frame(x)
  }, logical(1))
  nms <- nms[ok]
  if (!length(nms)) return(list(name = NULL, mat = NULL))
  dims <- vapply(nms, function(nm) {
    x <- env[[nm]]
    if (is.data.frame(x)) x <- as.matrix(x)
    if (is.null(dim(x))) return(0)
    prod(dim(x))
  }, numeric(1))
  nm <- nms[[which.max(dims)]]
  list(name = nm, mat = env[[nm]])
}
