# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:916-920
# sha256(func-block)=f89d4fc841a4517c3557da67ee51fc5ceabdafa5568922a68a8fee937a2b6545
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
metap <- function(p, method = c("maximump", "minimump", "wilkinsonp", "meanp", "sump", "votep"), ...) {
  method <- match.arg(method)
  res <- do.call(method, args = list(p = p, ...))
  return(res)
}
