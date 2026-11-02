wf_binary_group <- function(values) {
  ranks <- rank(values, ties.method = "first", na.last = "keep")
  cutoff <- stats::median(ranks, na.rm = TRUE)
  factor(ifelse(ranks > cutoff, "High", "Low"), levels = c("High", "Low"))
}
