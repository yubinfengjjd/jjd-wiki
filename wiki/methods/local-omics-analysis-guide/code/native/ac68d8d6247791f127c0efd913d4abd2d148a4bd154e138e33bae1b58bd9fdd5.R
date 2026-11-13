wf_scatter_stats_label <- function(df, x, y, method = "spearman") {
  vals <- df[, c(x, y), drop = FALSE]
  vals <- vals[stats::complete.cases(vals), , drop = FALSE]
  if (nrow(vals) < 3) return(NULL)
  tst <- suppressWarnings(tryCatch(stats::cor.test(vals[[x]], vals[[y]], method = method), error = function(e) NULL))
  if (is.null(tst)) return(NULL)
  paste(c("Spearman", paste0("R = ", formatC(unname(tst$estimate), format = "f", digits = 3)), wf_format_p_value(tst$p.value)), collapse = "\n")
}
