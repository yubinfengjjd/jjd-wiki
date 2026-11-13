# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14570-14594
# sha256(func-block)=7efef00c3d1e5f1d981cd6fa07e190a68c2bbecc28e7c703ff1bb915a72ccf8c
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
gseaScores <- function(geneList, geneSet, exponent = 1) {
  geneSet <- intersect(geneSet, names(geneList))
  N <- length(geneList)
  Nh <- length(geneSet)
  Phit <- Pmiss <- numeric(N)
  hits <- names(geneList) %in% geneSet
  Phit[hits] <- abs(geneList[hits])^exponent
  NR <- sum(Phit)
  Phit <- cumsum(Phit / NR)
  Pmiss[!hits] <- 1 / (N - Nh)
  Pmiss <- cumsum(Pmiss)
  runningES <- Phit - Pmiss
  max.ES <- max(runningES, na.rm = TRUE)
  min.ES <- min(runningES, na.rm = TRUE)
  if (abs(max.ES) > abs(min.ES)) {
    ES <- max.ES
  } else {
    ES <- min.ES
  }
  df <- data.frame(
    x = seq_along(runningES), runningScore = runningES,
    position = as.integer(hits), gene = names(geneList)
  )
  return(df)
}
