# Synthetic UMAP coordinates and marker expression for style replay only.
# These are not original GSE251716 observations.
set.seed(20261022)

make_blob <- function(n, cx, cy, sx, sy, group, prefix = group) {
  data.frame(
    cell_id = sprintf("%s_%04d", prefix, seq_len(n)),
    umap_1 = rnorm(n, cx, sx),
    umap_2 = rnorm(n, cy, sy),
    group = group,
    stringsAsFactors = FALSE
  )
}

blobs <- list(
  make_blob(520,  9.0,   0.0, 0.55, 0.75, "Muller_Glia"),
  make_blob(460,  0.0, -12.0, 0.45, 0.85, "Rod_Photoreceptor"),
  make_blob(60,  -7.0,  -8.0, 0.55, 0.45, "Cone_Photoreceptor"),
  make_blob(120,  2.0,   9.0, 1.10, 0.65, "RGC_like"),
  make_blob(28,   2.0,  -5.0, 0.30, 0.35, "RPE"),
  make_blob(32,   8.0,   4.0, 0.35, 0.30, "Vascular_Pericyte"),
  make_blob(18,  -3.0,  12.0, 0.20, 0.20, "Amacrine"),
  make_blob(26,  10.0,   7.0, 0.25, 0.22, "Amacrine_Horizontal_like")
)
bipolar_centers <- list(
  c(-4.2, 5.0), c(-2.4, -0.8), c(2.2, -5.2), c(4.0, 2.0),
  c(6.0, -2.0), c(-6.0, -4.0), c(0.0, 3.0), c(-1.0, 6.5),
  c(3.0, 6.0), c(-5.0, 1.0), c(5.0, -6.0), c(7.0, 1.0)
)
bipolar <- do.call(rbind, lapply(seq_along(bipolar_centers), function(i) {
  make_blob(45, bipolar_centers[[i]][1], bipolar_centers[[i]][2],
            0.35, 0.35, "Bipolar", prefix = sprintf("Bipolar%02d", i))
}))

coords <- do.call(rbind, c(blobs, list(bipolar)))
# Stretch x slightly so the 3x3 small-multiples grid fills an 11x10 canvas.
coords$umap_1 <- coords$umap_1 * 1.8
coords$group <- factor(coords$group, levels = c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
))
coords <- coords[sample(nrow(coords)), ]

gene_targets <- c(
  Pou4f1 = "RGC_like",
  Gad1 = "Amacrine",
  Onecut1 = "Amacrine_Horizontal_like",
  Vsx2 = "Bipolar",
  Rho = "Rod_Photoreceptor",
  Opn1mw = "Cone_Photoreceptor",
  Glul = "Muller_Glia",
  Rpe65 = "RPE",
  Pdgfrb = "Vascular_Pericyte"
)

expr_list <- lapply(names(gene_targets), function(gene) {
  target <- unname(gene_targets[[gene]])
  is_target <- coords$group == target
  value <- numeric(nrow(coords))
  target_n <- sum(is_target)
  value[is_target] <- ifelse(
    runif(target_n) < 0.85,
    rlnorm(target_n, meanlog = log(2.2), sdlog = 0.55),
    0
  )
  other_n <- sum(!is_target)
  value[!is_target] <- ifelse(
    runif(other_n) < 0.10,
    rlnorm(other_n, meanlog = log(0.4), sdlog = 0.8),
    0
  )
  data.frame(
    cell_id = coords$cell_id,
    feature = gene,
    value = value,
    stringsAsFactors = FALSE
  )
})
expr <- do.call(rbind, expr_list)

dir.create("data", showWarnings = FALSE)
write.csv(coords[, c("cell_id", "umap_1", "umap_2", "group")],
          "data/estimated_coordinates.csv", row.names = FALSE)
write.csv(expr, "data/estimated_expression.csv", row.names = FALSE)
merged <- merge(expr, coords, by = "cell_id", all.x = TRUE)
merged <- merged[, c("cell_id", "umap_1", "umap_2", "group", "feature", "value")]
write.csv(merged, "data/estimated_data.csv", row.names = FALSE)
cat("Wrote", nrow(coords), "cells and", nrow(expr), "expression rows\n")
