#!/usr/bin/env Rscript
# Verification driver for survival-prognosis-analysis / cox-km-optimal-cutpoint

parse_args <- function(argv) {
  out <- list()
  i <- 1L
  while (i <= length(argv)) {
    if (startsWith(argv[i], "--") && i < length(argv)) {
      out[[substring(argv[i], 3L)]] <- argv[i + 1L]
      i <- i + 2L
    } else {
      i <- i + 1L
    }
  }
  out
}

args <- parse_args(commandArgs(trailingOnly = TRUE))
dir.create(args$out, recursive = TRUE, showWarnings = FALSE)
source(file.path(args$code, "cox_km_optimal_cutpoint.R"))

tcga <- utils::read.csv(file.path(args$example, "tcga_skcm_s100b_120.csv"), stringsAsFactors = FALSE)
markers <- intersect(c("S100B", "SOX10", "PMEL", "CDK2", "TYR"), colnames(tcga))

res_med <- run_cox_km_optimal_cutpoint(tcga, marker_cols = markers, method = "median")
res_q <- run_cox_km_optimal_cutpoint(tcga, marker_cols = markers, method = "quartile")
res_opt <- run_cox_km_optimal_cutpoint(tcga, marker_cols = markers, method = "maxstat", minprop = 0.2)

# 1. Fixed predefined cutpoint verification (median & quartile): HR, CI ordering, and exact survdiff/coxph match
for (pair in list(list(res = res_med, mode = "median"), list(res = res_q, mode = "quartile"))) {
  st <- pair$res$stats
  stopifnot(nrow(st) == length(markers))
  stopifnot(all(st$cutpoint_mode == "predefined_fixed"))
  stopifnot(all(st$n_candidate_cutpoints == 1L))
  stopifnot(all(is.na(st$bonferroni_adjusted_p)))
  stopifnot(all(is.finite(st$cox_hr) & st$cox_hr > 0))
  stopifnot(all(st$cox_ci95_low < st$cox_hr & st$cox_hr < st$cox_ci95_high))
  stopifnot(all(st$logrank_p >= 0 & st$logrank_p <= 1))

  for (r in seq_len(nrow(st))) {
    mk <- st$marker[r]
    sub <- tcga[!is.na(tcga[[mk]]) & !is.na(tcga$OS.time) & !is.na(tcga$OS) & tcga$OS.time > 0, , drop = FALSE]
    x <- as.numeric(sub[[mk]])
    time_v <- as.numeric(sub$OS.time) / 365.25
    event_v <- as.integer(sub$OS)
    if (pair$mode == "median") {
      ct <- stats::median(x, na.rm = TRUE)
      grp <- factor(ifelse(x >= ct, "High", "Low"), levels = c("Low", "High"))
      df_ref <- data.frame(time = time_v, event = event_v, group = grp)
    } else {
      q25 <- stats::quantile(x, probs = 0.25, na.rm = TRUE)
      q75 <- stats::quantile(x, probs = 0.75, na.rm = TRUE)
      keep <- (x <= q25) | (x >= q75)
      grp <- factor(ifelse(x[keep] >= q75, "High", "Low"), levels = c("Low", "High"))
      df_ref <- data.frame(time = time_v[keep], event = event_v[keep], group = grp)
    }
    ref_sd <- survival::survdiff(survival::Surv(time, event) ~ group, data = df_ref)
    ref_lr_p <- as.numeric(1 - stats::pchisq(ref_sd$chisq, df = 1L))
    ref_cx <- summary(survival::coxph(survival::Surv(time, event) ~ group, data = df_ref))
    stopifnot(abs(st$logrank_p[r] - signif(ref_lr_p, 6)) < 1e-6)
    stopifnot(abs(st$cox_hr[r] - round(ref_cx$conf.int[1, "exp(coef)"], 4)) < 1e-4)
    stopifnot(abs(st$cox_ci95_low[r] - round(ref_cx$conf.int[1, "lower .95"], 4)) < 1e-4)
    stopifnot(abs(st$cox_ci95_high[r] - round(ref_cx$conf.int[1, "upper .95"], 4)) < 1e-4)
  }
}

# 2. Exploratory maxstat cutpoint mode verification
opt_st <- res_opt$stats
expected_note <- paste0(
  "Exploratory cutpoint selection on same cohort; ",
  "nominal log-rank/Cox P is unadjusted for selection bias",
  "\u2014validate cutpoint on independent cohort"
)
stopifnot(nrow(opt_st) == length(markers))
stopifnot(all(opt_st$cutpoint_mode == "exploratory_maxstat"))
stopifnot(all(opt_st$n_candidate_cutpoints >= 1L))
stopifnot(all(is.finite(opt_st$bonferroni_adjusted_p)))
stopifnot(all(opt_st$bonferroni_adjusted_p >= opt_st$logrank_p - 1e-6 & opt_st$bonferroni_adjusted_p <= 1.0))
stopifnot(all(opt_st$inference_note == expected_note))

all_stats <- rbind(res_med$stats, res_q$stats, res_opt$stats)
utils::write.csv(all_stats, file.path(args$out, "survival_stats_all_modes.csv"), row.names = FALSE)
utils::write.csv(res_med$km_curves, file.path(args$out, "km_curves_median.csv"), row.names = FALSE)

checks_json <- sprintf(
  '{\n  "scope": "Real TCGA-SKCM 120-patient clinical cohort (Nirmal 2022, %d markers); verified fixed predefined cutpoint inference (median/quartile Cox HR, 95%% CI, and exact survdiff/coxph agreement) separately from exploratory maxstat cutpoint search (with candidate count, Bonferroni adjustment, and selection-bias warning).",\n  "checks": [\n    "cohort_n=%d, markers_tested=%d",\n    "fixed_cutpoint_modes_verified=median,quartile",\n    "fixed_ci95_low_lt_hr_lt_ci95_high_and_survdiff_coxph_exact=true",\n    "exploratory_maxstat_bonferroni_adjusted_p_ge_nominal_p=true",\n    "exploratory_maxstat_inference_note_present=true"\n  ]\n}\n',
  length(markers), nrow(tcga), length(markers)
)
writeLines(checks_json, con = file.path(args$out, "checks.json"), useBytes = TRUE)
