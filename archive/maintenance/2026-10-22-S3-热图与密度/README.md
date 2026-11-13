# 2026-10-22 S3：FeatureHeatmap / CellCorHeatmap / CellDensityPlot

本记录覆盖 S3 的原生复刻、画廊、模板、接口与方法关系。工作区：`E:/research-wiki-env/work/scp-native-claude/s3/`。

## 1. 画廊与来源

| 条目 | 原生调用 | source SHA256 |
|---|---|---|
| `fig14-feature-heatmap` | `RunDEtest` → `FeatureHeatmap(features=head(de_filter$gene, 20), group.by="CellType")` | `6a614cfd…` |
| `fig15-cell-cor-heatmap` | `Standard_SCP` → `CellCorHeatmap(srt_query=pancreas_sub, query_group="SubCellType")` | `6f96f3c2…` |
| `fig16-cell-density` | `CellDensityPlot(features="Sox9", group.by="SubCellType")` | `72a7a07a…` |

## 2. 表半与绘图半

- FeatureHeatmap：matrix × feature × cell 长表；矩阵/注释与上游绘制对象一致；`value` 为 zscore(normalized counts)，模板不重算。
- CellCorHeatmap：`scp_cellcor_simil()` 的 `simil_matrix` 与上游 `identical`（8×8）；模板只重建矩阵；绘图半保留 ComplexHeatmap 构造。
- CellDensityPlot：`plot_data` 与上游 `ggplot_build()` 在列、行、顺序、分组水平上一致；绘图半保留 ggplot/ggridges。

## 3. 依赖兼容补丁

- CellCorHeatmap P1：`RunKNNPredict()` 写回 per-cell metadata 时加 `unname()`，适配 SeuratObject >= 5.4；相似度矩阵与上游 identical。
- FeatureHeatmap / CellDensityPlot：表/绘图拆分、namespace 限定、本地 `theme_scp`/`palette_scp`；绘图几何不变。

## 4. 模板与接口

| 模板 | 标题 | 接口 | 固定 SHA256 |
|---|---|---|---|
| `...fig14-feature-heatmap--heatmap` | 特征表达热图 | `render-feature-heatmap` | `6a614cfd…` |
| `...fig15-cell-cor-heatmap--heatmap` | 细胞相似度热图 | `render-correlation-heatmap` | `6f96f3c2…` |
| `...fig16-cell-density--ridge` | 分组表达密度图 | `render-cell-feature-values` | `72a7a07a…` |

- 新接口：
  - `render-feature-heatmap`：matrix, feature, cell, group, value, matrix_order, feature_order, cell_order, group_order。
  - `render-correlation-heatmap`：row, column, similarity, row_group, column_group, row_order, column_order。
  - `render-cell-feature-values`：cell, feature, value, group, feature_order, group_order。
- 三模板 `verify-template` exit 0、`mark-ready`、`check-entry --record` 通过。

## 5. 构建过程与验证

- S3 工作流（3 个 build + 3 个 verify）在 build 阶段因 API 余额不足（402）中断，未返回结构化结果。
- 主会话基于 staged 产物完成：
  - 检查/补齐 FeatureHeatmap 与 CellDensityPlot 模板（fixed 回放已与 source 一致）。
  - 为 CellCorHeatmap 补写 `render.R`/`panel.R`/`spec.json`，fixed 回放与 `native/ht1.png` 同 SHA256。
  - 为三个类型构建画廊条目（meta/README/qa/data/original_code/compare/thumb）。
  - 集成到 Wiki，补 layout/chart-type/interface/method 页。
- 固定输出 8×6@150 与各自 source 逐字节一致；FeatureHeatmap/CellDensityPlot 的 adaptive、max 拒绝、输入不变、异目录复制由 staged validation 覆盖；CellCor 的 adaptive 由主会话补测（8×8 → 9.1×9.1 in，`max_width_in: 8` 正确拒绝），fixed 与 source 同 SHA256。
- `wiki.py lint` OK；`pending --json` 为空；`pytest` 405 passed / 2 skipped。

## 6. 未验证

- FeatureHeatmap：split.by、add_dot/add_violin、feature_split/annotation、完整 DE 基因集。
- CellCorHeatmap：panc8 参考集、细胞级不折叠、nlabel/label_cutoff、query/ref annotation、flip/cluster。
- CellDensityPlot：flip/reverse/x_order 非默认值、CJK 标签。
- 三者均未验证真实 Seurat→CSV→模板流水线与科学有效性。

## 7. 停止点

作者 2026-10-22 明确“做完这组停了”。S3 完成后本会话停止；S4（CellDimPlot/FeatureDimPlot）起未启动。
