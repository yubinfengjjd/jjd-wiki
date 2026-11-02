# Synthetic dot-plot values for the top-journal bubble style.
# These are not original GSE251716 observations.
set.seed(20261022)

x_levels <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)

markers <- list(
  RGC = c("Pou4f1", "Thy1", "Rbpms", "Sncg", "Nefl"),
  Amacrine = c("Gad1", "Slc6a9", "Pvalb", "Tac1"),
  Horizontal = c("Calb1", "Lhx1", "Onecut1"),
  Bipolar = c("Vsx2", "Grik1", "Cabp5", "Prkca"),
  Photoreceptor = c("Rho", "Gnat1", "Nrl", "Opn1mw"),
  Muller_Glia = c("Glul", "Rlbp1", "Aqp4", "Vim", "Sox2"),
  Astrocyte = c("Gfap", "Aldh1l1", "Slc1a3"),
  Microglia = c("Cx3cr1", "Tmem119", "P2ry12", "Aif1"),
  Macrophage = c("Ctsb", "Lyz2", "Cd68", "Itgam"),
  Endothelial = c("Pecam1", "Cldn5", "Flt1", "Tek"),
  Pericyte = c("Pdgfrb", "Cspg4", "Rgs5", "Des"),
  Fibroblast = c("Col1a1", "Col1a2", "Dcn", "Lum"),
  RPE = c("Rpe65", "Mitf", "Tyr", "Best1")
)
group_to_target <- c(
  RGC = "RGC_like",
  Amacrine = "Amacrine",
  Horizontal = "Amacrine_Horizontal_like",
  Bipolar = "Bipolar",
  Photoreceptor = "Rod_Photoreceptor",
  Muller_Glia = "Muller_Glia",
  RPE = "RPE",
  Pericyte = "Vascular_Pericyte",
  Astrocyte = NA,
  Microglia = NA,
  Macrophage = NA,
  Endothelial = NA,
  Fibroblast = NA
)

feature_group <- rep(names(markers), lengths(markers))
features <- unlist(markers, use.names = FALSE)
feature_target <- unname(group_to_target[feature_group])

df <- expand.grid(
  feature = features,
  group = x_levels,
  stringsAsFactors = FALSE
)
df$target_group <- feature_target[match(df$feature, features)]
df$is_target <- !is.na(df$target_group) & df$group == df$target_group

n <- nrow(df)
df$avg_expression <- ifelse(df$is_target, runif(n, 0.55, 1.00), runif(n, 0.00, 0.35))
df$pct_expressed <- ifelse(df$is_target, runif(n, 55, 95), runif(n, 5, 40))
na_rows <- is.na(df$target_group)
df$avg_expression[na_rows] <- runif(sum(na_rows), 0, 0.25)
df$pct_expressed[na_rows] <- runif(sum(na_rows), 5, 30)

df <- df[, c("group", "feature", "avg_expression", "pct_expressed", "target_group")]
write.csv(df, "data/estimated_data.csv", row.names = FALSE)
cat("Wrote", nrow(df), "rows;", length(features), "features;", length(x_levels), "groups\n")
