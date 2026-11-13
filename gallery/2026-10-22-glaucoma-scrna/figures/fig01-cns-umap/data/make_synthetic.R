# Synthetic UMAP-like coordinates for style replay only.
# These are not original observations from GSE251716.
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

df <- do.call(rbind, c(blobs, list(bipolar)))
group_levels <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)
df$group <- factor(df$group, levels = group_levels)
df <- df[sample(nrow(df)), ]

dir.create("data", showWarnings = FALSE)
write.csv(df, "data/estimated_data.csv", row.names = FALSE)
cat("Wrote", nrow(df), "synthetic cells to data/estimated_data.csv\n")
