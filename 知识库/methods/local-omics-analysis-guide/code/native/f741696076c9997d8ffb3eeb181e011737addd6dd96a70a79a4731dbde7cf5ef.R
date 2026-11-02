detect_sample_column <- function(meta) {
  candidates <- c("sample_id", "samples", "sample", "orig.ident")
  for (nm in candidates) {
    if (nm %in% colnames(meta)) return(nm)
  }
  hits <- grep("sample|orig.ident", colnames(meta), value = TRUE, ignore.case = TRUE)
  if (length(hits) > 0) return(hits[[1]])
  NULL
}
