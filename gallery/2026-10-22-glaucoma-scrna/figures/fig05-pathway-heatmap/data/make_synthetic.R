# Synthetic pathway-score matrix for the CNS-style heatmap.
# These are not original GSE251716 observations.
set.seed(20261022)

pathways <- c(
  "AP1_FOSB", "Complement_total", "Complement_classical", "Inflammation",
  "TNF_NFKB", "Microglia_activation", "Reactive_glia",
  "Oxidative_stress_NRF2", "RGC_injury", "RGC_identity"
)
celltypes <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)
conditions <- c("Control", "Glaucoma")

# Cell-type preference patterns (rows = pathways, cols = cell types).
preference <- matrix(0, nrow = length(pathways), ncol = length(celltypes),
                     dimnames = list(pathways, celltypes))
preference["Complement_total", c("Muller_Glia", "RPE", "Vascular_Pericyte")] <- 0.9
preference["Complement_classical", c("Muller_Glia", "RPE", "Vascular_Pericyte")] <- 0.8
preference["TNF_NFKB", c("RPE", "Vascular_Pericyte", "Amacrine")] <- 1.0
preference["AP1_FOSB", c("RPE", "Vascular_Pericyte")] <- 0.9
preference["Inflammation", c("Muller_Glia", "RPE")] <- 0.8
preference["Microglia_activation", c("RPE", "Vascular_Pericyte")] <- 0.7
preference["Reactive_glia", c("Muller_Glia", "RPE")] <- 0.8
preference["Oxidative_stress_NRF2", c("Rod_Photoreceptor", "Cone_Photoreceptor")] <- 0.7
preference["RGC_injury", c("RGC_like", "Rod_Photoreceptor")] <- 0.8
preference["RGC_identity", c("RGC_like", "Rod_Photoreceptor")] <- 0.9

base <- matrix(rnorm(length(pathways) * length(celltypes), 0, 0.18),
               nrow = length(pathways), dimnames = list(pathways, celltypes))
means <- base + preference

rows <- list()
for (ct in celltypes) {
  for (cond in conditions) {
    effect <- rnorm(length(pathways), 0, 0.12)
    names(effect) <- pathways
    if (cond == "Glaucoma") {
      effect[pathways %in% c("Complement_total", "Complement_classical", "Inflammation")] <-
        effect[pathways %in% c("Complement_total", "Complement_classical", "Inflammation")] + 0.25
      effect["RGC_identity"] <- effect["RGC_identity"] - 0.20
    }
    values <- means[, ct] + effect
    rows[[length(rows) + 1]] <- data.frame(
      pathway = pathways,
      column_id = paste(ct, cond, sep = "_"),
      value = as.numeric(values),
      stringsAsFactors = FALSE
    )
  }
}
df <- do.call(rbind, rows)
cols <- data.frame(
  column_id = unique(df$column_id),
  celltype = rep(celltypes, each = length(conditions)),
  condition = rep(conditions, times = length(celltypes)),
  stringsAsFactors = FALSE
)
write.csv(df, "data/estimated_data.csv", row.names = FALSE)
write.csv(cols, "data/estimated_columns.csv", row.names = FALSE)
cat("Wrote", nrow(df), "matrix rows and", nrow(cols), "column annotations\n")
