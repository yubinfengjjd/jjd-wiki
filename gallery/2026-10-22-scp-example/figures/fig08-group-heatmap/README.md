# fig08 GroupHeatmap

Source: SCP v0.5.6 `GroupHeatmap(srt = pancreas_sub, features = ..., group.by = c("CellType", "SubCellType"))`,
commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, GPL (>= 3).

- `source/fig08.png` is the unmodified upstream function output at 8x6 in, 150 dpi.
- `output/replica.png` is the template table+plot path on the same matrices; SHA-256 equals the source.
- `data/render-group-heatmap.csv` is the long table: one row per matrix x feature x group.
- `code/scp_group_heatmap_native.R` keeps the native ComplexHeatmap construction; table preparation is separate.
- Not verified: real Seurat object -> CSV -> template, add_dot/add_violin/feature_split branches, and scientific validity.
