# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:27-29
# sha256(func-block)=9f7d18c8ee0aeec534096c6dcb7a25f1f75dde7abe596baf4d71f1b21108a8c0
# verbatim copy; read-only provenance
RunNMF <- function(object, ...) {
  UseMethod(generic = "RunNMF", object = object)
}
