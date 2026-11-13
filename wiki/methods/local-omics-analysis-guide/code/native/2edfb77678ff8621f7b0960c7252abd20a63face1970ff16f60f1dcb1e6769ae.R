pick_seurat <- function(env, obj_names) {
  hits <- obj_names[vapply(obj_names, function(nm) is_seurat_obj(env[[nm]]), logical(1))]
  if (!length(hits)) return(list(name = NULL, obj = NULL))
  if ("UC" %in% hits) return(list(name = "UC", obj = env[["UC"]]))
  ncells <- vapply(hits, function(nm) {
    x <- env[[nm]]
    tryCatch(ncol(x), error = function(e) 0L)
  }, integer(1))
  nm <- hits[[which.max(ncells)]]
  list(name = nm, obj = env[[nm]])
}
