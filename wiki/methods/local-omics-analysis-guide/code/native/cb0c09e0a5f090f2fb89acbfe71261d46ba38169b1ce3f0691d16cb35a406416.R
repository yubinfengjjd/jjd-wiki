evaluate_quality <- function(df0, ko) {
  n_fdr <- sum(df0$`p.adj` < 0.05, na.rm = TRUE)
  n_fdr_ex <- sum(df0$`p.adj` < 0.05 & (df0$gene != ko), na.rm = TRUE)
  list(n_sig_fdr = n_fdr, n_sig_fdr_excl_ko = n_fdr_ex)
}
