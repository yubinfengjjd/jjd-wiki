# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:187-189
# sha256(func-block)=f4141761b109b9d9835ea13323754a6da574f8b1217592f61aab6fa8a6e893a7
# verbatim copy; read-only provenance
RunMDS <- function(object, ...) {
  UseMethod(generic = "RunMDS", object = object)
}
