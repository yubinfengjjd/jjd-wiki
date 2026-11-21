# Cox proportional hazards regression and Kaplan-Meier Log-rank stratification
# separating predefined fixed-cutpoint inference (median, quartile) from
# exploratory optimal-cutpoint search (maxstat).
# Adapted from Nirmal et al., Cancer Discovery 2022 (07_s100b_network_tcga_survival.R).

run_cox_km_optimal_cutpoint <- function(
  surv_df,
  marker_cols,
  time_col = "OS.time",
  event_col = "OS",
  time_scale = 365.25,
  method = c("median", "quartile", "maxstat"),
  minprop = 0.2
) {
  if (!requireNamespace("survival", quietly = TRUE)) {
    stop("Missing required R package: survival")
  }
  method <- match.arg(method)
  if (!is.data.frame(surv_df) || nrow(surv_df) == 0L) {
    stop("surv_df must be a non-empty data.frame")
  }
  req <- c(time_col, event_col, marker_cols)
  missing <- setdiff(req, colnames(surv_df))
  if (length(missing) > 0L) {
    stop("Missing required columns: ", paste(missing, collapse = ", "))
  }

  find_maxstat_cutpoint <- function(x, time_v, event_v, minp) {
    ux <- sort(unique(x))
    n <- length(x)
    q_lo <- stats::quantile(x, probs = minp, na.rm = TRUE)
    q_hi <- stats::quantile(x, probs = 1 - minp, na.rm = TRUE)
    cands <- ux[ux >= q_lo & ux <= q_hi]
    if (length(cands) == 0L) {
      return(list(
        cutpoint = as.numeric(stats::median(x, na.rm = TRUE)),
        n_candidate_cutpoints = 1L
      ))
    }
    best_cut <- stats::median(x, na.rm = TRUE)
    best_stat <- -Inf
    n_eval <- 0L
    for (ct in cands) {
      grp <- factor(ifelse(x >= ct, "High", "Low"), levels = c("Low", "High"))
      if (min(table(grp)) < max(3L, floor(n * minp))) next
      n_eval <- n_eval + 1L
      sd_fit <- survival::survdiff(survival::Surv(time_v, event_v) ~ grp)
      if (is.finite(sd_fit$chisq) && sd_fit$chisq > best_stat) {
        best_stat <- sd_fit$chisq
        best_cut <- ct
      }
    }
    list(
      cutpoint = as.numeric(best_cut),
      n_candidate_cutpoints = max(1L, as.integer(n_eval))
    )
  }

  exploratory_note <- paste0(
    "Exploratory cutpoint selection on same cohort; ",
    "nominal log-rank/Cox P is unadjusted for selection bias",
    "\u2014validate cutpoint on independent cohort"
  )
  fixed_note <- "Predefined fixed cutpoint; standard log-rank and Cox PH inference without cutpoint selection bias"

  stat_rows <- list()
  km_rows <- list()

  for (mk in marker_cols) {
    sub <- surv_df[
      !is.na(surv_df[[mk]]) & !is.na(surv_df[[time_col]]) &
        !is.na(surv_df[[event_col]]) & surv_df[[time_col]] > 0,
      ,
      drop = FALSE
    ]
    x <- as.numeric(sub[[mk]])
    time_v <- as.numeric(sub[[time_col]]) / as.numeric(time_scale)
    event_v <- as.integer(sub[[event_col]])

    if (method == "median") {
      cut_val <- as.numeric(stats::median(x, na.rm = TRUE))
      grp <- factor(ifelse(x >= cut_val, "High", "Low"), levels = c("Low", "High"))
      sub_use <- data.frame(time = time_v, event = event_v, group = grp, marker = x)
      cutpoint_mode <- "predefined_fixed"
      n_cands <- 1L
    } else if (method == "quartile") {
      q25 <- as.numeric(stats::quantile(x, probs = 0.25, na.rm = TRUE))
      q75 <- as.numeric(stats::quantile(x, probs = 0.75, na.rm = TRUE))
      cut_val <- q75
      keep_q <- (x <= q25) | (x >= q75)
      grp <- factor(ifelse(x[keep_q] >= q75, "High", "Low"), levels = c("Low", "High"))
      sub_use <- data.frame(time = time_v[keep_q], event = event_v[keep_q], group = grp, marker = x[keep_q])
      cutpoint_mode <- "predefined_fixed"
      n_cands <- 1L
    } else {
      ms <- find_maxstat_cutpoint(x, time_v, event_v, minprop)
      cut_val <- ms$cutpoint
      n_cands <- ms$n_candidate_cutpoints
      grp <- factor(ifelse(x >= cut_val, "High", "Low"), levels = c("Low", "High"))
      sub_use <- data.frame(time = time_v, event = event_v, group = grp, marker = x)
      cutpoint_mode <- "exploratory_maxstat"
    }

    sf <- survival::survfit(survival::Surv(time, event) ~ group, data = sub_use)
    sd_test <- survival::survdiff(survival::Surv(time, event) ~ group, data = sub_use)
    lr_p <- as.numeric(1 - stats::pchisq(sd_test$chisq, df = length(sd_test$n) - 1L))
    cx <- survival::coxph(survival::Surv(time, event) ~ group, data = sub_use)
    cx_sum <- summary(cx)
    hr <- cx_sum$conf.int[1, "exp(coef)"]
    hr_low <- cx_sum$conf.int[1, "lower .95"]
    hr_high <- cx_sum$conf.int[1, "upper .95"]
    cox_p <- cx_sum$coefficients[1, "Pr(>|z|)"]

    bonf_p <- if (method == "maxstat") {
      signif(min(1.0, lr_p * as.numeric(n_cands)), 6)
    } else {
      NA_real_
    }
    inf_note <- if (method == "maxstat") exploratory_note else fixed_note

    stat_rows[[mk]] <- data.frame(
      marker = mk,
      cutpoint_method = method,
      cutpoint_mode = cutpoint_mode,
      cutpoint_value = round(cut_val, 4),
      n_candidate_cutpoints = as.integer(n_cands),
      n_samples = nrow(sub_use),
      n_events = sum(sub_use$event == 1L),
      n_high = sum(sub_use$group == "High"),
      n_low = sum(sub_use$group == "Low"),
      logrank_chisq = round(as.numeric(sd_test$chisq), 4),
      logrank_p = signif(lr_p, 6),
      bonferroni_adjusted_p = bonf_p,
      cox_hr = round(as.numeric(hr), 4),
      cox_ci95_low = round(as.numeric(hr_low), 4),
      cox_ci95_high = round(as.numeric(hr_high), 4),
      cox_p = signif(as.numeric(cox_p), 6),
      inference_note = inf_note,
      stringsAsFactors = FALSE
    )

    s_names <- names(sf$strata)
    idx_start <- 1L
    for (i in seq_along(sf$strata)) {
      k <- sf$strata[i]
      idx <- idx_start:(idx_start + k - 1L)
      idx_start <- idx_start + k
      grp_lbl <- sub("^group=", "", s_names[i])
      km_rows[[length(km_rows) + 1L]] <- data.frame(
        marker = mk,
        cutpoint_method = method,
        group = grp_lbl,
        time = c(0, sf$time[idx]),
        surv = c(1, sf$surv[idx]),
        lower = c(1, sf$lower[idx]),
        upper = c(1, sf$upper[idx]),
        n_risk = c(sf$n[i], sf$n.risk[idx]),
        n_event = c(0L, sf$n.event[idx]),
        stringsAsFactors = FALSE
      )
    }
  }

  list(
    stats = do.call(rbind, stat_rows),
    km_curves = do.call(rbind, km_rows)
  )
}
