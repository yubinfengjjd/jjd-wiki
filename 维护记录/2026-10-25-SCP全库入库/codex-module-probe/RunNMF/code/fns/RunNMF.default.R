# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:108-162
# sha256(func-block)=a62dbc88dc0d388dd448eb2ef5038d06f722d9410416f4746e73d5fc0a509efe
# verbatim copy; read-only provenance
RunNMF.default <- function(object, assay = NULL, slot = "data", nbes = 50,
                           nmf.method = "RcppML", tol = 1e-5, maxit = 100, rev.nmf = FALSE,
                           ndims.print = 1:5, nfeatures.print = 30,
                           reduction.key = "BE_", verbose = TRUE, seed.use = 11, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }
  if (rev.nmf) {
    object <- t(object)
  }
  nbes <- min(nbes, nrow(x = object) - 1)
  if (nmf.method == "RcppML") {
    check_R("zdebruine/RcppML")
    options("RcppML.verbose" = FALSE)
    options("RcppML.threads" = 0)
    if (!"package:Matrix" %in% search()) {
      attachNamespace("Matrix")
    }
    nmf.results <- RcppML::nmf(
      t(object),
      k = nbes, tol = tol, maxit = maxit,
      verbose = verbose, ...
    )
    cell.embeddings <- nmf.results$w
    feature.loadings <- t(nmf.results$h)
  }
  if (nmf.method == "NMF") {
    check_R("NMF")
    seed <- NMF::seed
    nmf.results <- NMF::nmf(x = as_matrix(t(object)), rank = nbes)
    cell.embeddings <- nmf.results@fit@W
    feature.loadings <- t(nmf.results@fit@H)
  }

  rownames(x = feature.loadings) <- rownames(x = object)
  colnames(x = feature.loadings) <- paste0(reduction.key, 1:nbes)
  rownames(x = cell.embeddings) <- colnames(x = object)
  colnames(x = cell.embeddings) <- colnames(x = feature.loadings)
  reduction.data <- CreateDimReducObject(
    embeddings = cell.embeddings,
    loadings = feature.loadings,
    assay = assay,
    key = reduction.key,
    misc = list(slot = slot, nmf.results = nmf.results)
  )
  if (verbose) {
    msg <- capture.output(print(
      x = reduction.data,
      dims = ndims.print,
      nfeatures = nfeatures.print
    ))
    message(paste(msg, collapse = "\n"))
  }
  return(reduction.data)
}
