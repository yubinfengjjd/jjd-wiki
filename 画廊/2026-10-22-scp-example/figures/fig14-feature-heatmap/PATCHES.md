# PATCHES

本条目拆分表半/绘图半；ComplexHeatmap 的矩阵、列注释、行标签、图例和尺寸计算保留。

- Seurat 输入改为显式 matrix × feature × cell 长表；
- namespace 限定与本地 `theme_scp`/`palette_scp`；
- `FeatureHeatmap` 的 `$plot` 用 `ComplexHeatmap::draw()` 在固定设备上绘制；
- 未改变 zscore、聚类、配色或注释顺序。

Source 与 replica 使用同一 core，固定 8×6@150 PNG 逐字节一致。
