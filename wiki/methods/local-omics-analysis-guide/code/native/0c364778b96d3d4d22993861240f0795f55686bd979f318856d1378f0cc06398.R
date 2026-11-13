detect_annotation_column <- function(meta) {
  meta <- as.data.frame(meta)
  candidates <- colnames(meta)[vapply(meta, function(x) is.factor(x) || is.character(x), logical(1))]
  if (!length(candidates)) return(NULL)
  candidates <- candidates[grepl("annot|annotation|label|region|spot_type|spottype|manual", candidates, ignore.case = TRUE)]
  candidates <- setdiff(candidates, c("dominant_celltype", "second_celltype", "UBE2L6_group", "cellchat_group", "BayesSpace_domain"))
  if (length(candidates) == 0) return(NULL)
  candidates[[1]]
}
