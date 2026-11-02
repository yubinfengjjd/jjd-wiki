# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:715-721
# sha256(func-block)=0f682cf54ff183803969d0e75e7b23f320c3126a79f1e789d43bc96aa023f6a6
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
kegg_get <- function(url) {
  temp <- tempfile()
  on.exit(unlink(temp))
  download(url = url, destfile = temp)
  content <- as.data.frame(do.call(rbind, strsplit(readLines(temp), split = "\t")))
  return(content)
}
