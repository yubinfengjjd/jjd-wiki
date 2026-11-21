# Chi-squared Ro/e tissue/group enrichment ratio calculation.
# Adapted from Zhang et al. (Nature 2018) and Cai et al. (npj Precision Oncology 2026, 02_progeny_roe_cox.R).

run_roe_tissue_enrichment <- function(
  meta_df,
  cluster_col = "canonical_subcluster",
  group_col = "tissue",
  count_col = NULL
) {
  if (!is.data.frame(meta_df) || nrow(meta_df) == 0L) {
    stop("meta_df must be a non-empty data.frame")
  }
  for (col in c(cluster_col, group_col)) {
    if (!(col %in% colnames(meta_df))) {
      stop("Missing required column: ", col)
    }
  }

  if (is.null(count_col)) {
    obs_tab <- table(meta_df[[cluster_col]], meta_df[[group_col]])
    obs_mat <- as.matrix(obs_tab)
  } else {
    if (!(count_col %in% colnames(meta_df))) {
      stop("Missing count_col: ", count_col)
    }
    agg <- stats::xtabs(
      stats::as.formula(paste(count_col, "~", cluster_col, "+", group_col)),
      data = meta_df
    )
    obs_mat <- as.matrix(agg)
  }

  obs_mat <- obs_mat[rowSums(obs_mat) > 0, colSums(obs_mat) > 0, drop = FALSE]
  chi_warn <- NULL
  chi <- withCallingHandlers(
    stats::chisq.test(obs_mat),
    warning = function(w) {
      chi_warn <<- conditionMessage(w)
      invokeRestart("muffleWarning")
    }
  )

  exp_mat <- chi$expected
  roe_mat <- obs_mat / exp_mat

  roe_wide <- data.frame(
    cluster = rownames(roe_mat),
    as.data.frame.matrix(round(roe_mat, 4)),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  classify_roe <- function(v) {
    ifelse(v == 0, "-",
      ifelse(v < 0.8, "+/-",
        ifelse(v <= 1.2, "+",
          ifelse(v <= 2.0, "++", "+++"))))
  }

  grid_idx <- expand.grid(
    cluster = rownames(obs_mat),
    group = colnames(obs_mat),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  roe_long <- data.frame(
    cluster = grid_idx$cluster,
    group = grid_idx$group,
    observed = as.numeric(obs_mat),
    expected = round(as.numeric(exp_mat), 4),
    roe = round(as.numeric(roe_mat), 4),
    enrichment_symbol = classify_roe(as.numeric(roe_mat)),
    stringsAsFactors = FALSE
  )

  list(
    roe_wide = roe_wide,
    roe_long = roe_long,
    chi_square = list(
      statistic = unname(as.numeric(chi$statistic)),
      df = unname(as.numeric(chi$parameter)),
      p_value = as.numeric(chi$p.value),
      warning = chi_warn
    )
  )
}
