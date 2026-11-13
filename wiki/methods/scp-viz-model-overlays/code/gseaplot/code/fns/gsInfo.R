# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14545-14568
# sha256(func-block)=5468cf9293f02e7e39bfa411fb69002d6a1f6bd48ac11f01dbab07953822d87c
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
gsInfo <- function(object, id_use) {
  geneList <- object@geneList
  if (is.numeric(id_use)) {
    id_use <- object@result[id_use, "ID"]
  }
  geneSet <- object@geneSets[[id_use]]
  exponent <- object@params[["exponent"]]
  df <- gseaScores(geneList, geneSet, exponent)
  df$ymin <- 0
  df$ymax <- 0
  pos <- df$position == 1
  h <- diff(range(df$runningScore)) / 20
  df$ymin[pos] <- -h
  df$ymax[pos] <- h
  df$geneList <- geneList
  df$Description <- object@result[id_use, "Description"]
  df$CoreGene <- object@result[id_use, "core_enrichment"]
  if (length(object@gene2Symbol) == length(object@geneList)) {
    df$GeneName <- object@gene2Symbol
  } else {
    df$GeneName <- df$gene
  }
  return(df)
}
