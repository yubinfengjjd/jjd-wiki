# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:964-967
# sha256(func-block)=26bbbd608c83e2071af399576ff812221450fbb5ef202ea1f9f9088ab1bbf866
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
minimump <- function(p, alpha = 0.05, log.p = FALSE) {
  res <- wilkinsonp(p, r = 1, alpha, log.p)
  res
}
