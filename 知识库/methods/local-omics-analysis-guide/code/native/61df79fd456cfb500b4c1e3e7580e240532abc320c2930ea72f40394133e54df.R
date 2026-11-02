normalize_diffreg <- function(df0) {
  if (is.null(df0) || !nrow(df0)) stop("diffRegulation missing or empty")
  cn <- colnames(df0)
  colnames(df0) <- tolower(cn)
  if (!("gene" %in% colnames(df0))) {
    hit <- intersect(c("genes", "symbol", "genename"), colnames(df0))
    if (length(hit)) df0$gene <- df0[[hit[[1]]]]
  }
  if (!("p.value" %in% colnames(df0))) {
    hit <- intersect(c("pvalue", "pval", "p_val"), colnames(df0))
    if (length(hit)) df0$`p.value` <- df0[[hit[[1]]]]
  }
  if (!("p.adj" %in% colnames(df0))) {
    hit <- intersect(c("padj", "p_adj", "fdr", "qvalue", "q_value"), colnames(df0))
    if (length(hit)) df0$`p.adj` <- df0[[hit[[1]]]]
  }
  if (!("distance" %in% colnames(df0))) {
    hit <- intersect(c("dist", "delta", "perturbation"), colnames(df0))
    if (length(hit)) df0$distance <- df0[[hit[[1]]]]
  }
  need <- c("gene", "distance", "fc", "p.value")
  miss <- setdiff(need, colnames(df0))
  if (length(miss)) stop("diffRegulation missing required columns: ", paste(miss, collapse = ","))
  df0$gene <- as.character(df0$gene)
  df0$distance <- as.numeric(df0$distance)
  df0$fc <- as.numeric(df0$fc)
  df0$`p.value` <- as.numeric(df0$`p.value`)
  if (!("p.adj" %in% colnames(df0)) || all(!is.finite(df0$`p.adj`))) {
    df0$`p.adj` <- p.adjust(df0$`p.value`, method = "BH")
  } else {
    df0$`p.adj` <- as.numeric(df0$`p.adj`)
    bad <- which(!is.finite(df0$`p.adj`))
    if (length(bad)) df0$`p.adj`[bad] <- p.adjust(df0$`p.value`[bad], method = "BH")
  }
  df0
}
