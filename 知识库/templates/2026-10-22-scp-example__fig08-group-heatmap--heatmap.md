---
type: template
id: 2026-10-22-scp-example__fig08-group-heatmap--heatmap
title: 分组热图（多分组注释）
status: ready
layouts:
- 2026-10-22-scp-example__fig08-group-heatmap
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- heatmap
favorite: false
---
# 分组热图（多分组注释）

![[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig08-group-heatmap|GroupHeatmap (CellType / SubCellType)]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/heatmap]]
- 输入接口：[[interfaces/render-group-heatmap|分组热图长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

把一个或多个分组变量下的聚合表达矩阵画成并排热图。输入是 `render-group-heatmap` 长表：每个 `matrix × feature × group` 一行，`value` 已按 `exp_method`（默认 zscore）变换，`percent` 为组内阳性细胞比例。适合展示 marker 基因在 celltype/subcelltype 等分组上的相对表达，并按矩阵并列比较；组数、feature 数、矩阵数由数据读取，不写死 13×5/13×8。

绘图核心来自 SCP v0.5.6 `GroupHeatmap()`（commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，GPL >= 3）：保留 ComplexHeatmap 的列注释块、行标签、图例、颜色映射与 `heatmap_rendersize` 尺寸计算。`plot_scp_group_heatmap()` 消费已聚合矩阵；`scp_group_heatmap_matrix()` 只作为表半归档/对照，不在 render 中运行。固定示例为 8×6 in、150 dpi，与原生 `ht1` 逐字节一致（SHA256 `00b0698d…`）。

## 不适用

- 输入必须是已聚合的 feature×group×matrix 表；模板不读 Seurat 对象、不重新聚合/zscore/percent。
- `value` 不是原始表达；不要把 zscore 当绝对丰度或跨数据集比较。
- `percent` 必须是 0–1，不是 0–100；`value` 不允许 NA/Inf（上游已处理）。
- 只实现原生 ht1 路径：不支持 `add_dot`、`add_violin`、`feature_split`/`row_split`、cell/feature annotation、enrichment 注释；这些分支需另建/扩展。
- 不能替代差异检验或通路富集；热图只显示聚合值，不证明组间显著。
- 同一 `matrix` 内 `feature × group` 必须完整且唯一；各矩阵的 feature 集合与顺序必须一致。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-visualization-interface`、`scp-de-enrichment-dynamic`、`scp-standard-workflow`、`scp-annotation-projection`）与 templates（fig03 dotplot、fig06 violin、fig08 本模板）。

- 候选方法：[[methods/scp-visualization-interface]] 的 `GroupHeatmap()` 是同一原生实现；本模板消费聚合表，不调用 SCP 函数。[[methods/scp-de-enrichment-dynamic]] 的 marker/DE 表可整理成 `render-group-heatmap`；[[methods/scp-standard-workflow]]/[[methods/scp-annotation-projection]] 提供 celltype 分组。均需在课题内导出长表，模板不重算。
- 一方法多图：GroupHeatmap 与 dotplot/violin 都展示 marker，但热图保留多分组矩阵和 value/percent 两列；不互相替代。
- 一图多方法：任何产生 feature×group 聚合值的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig08-group-heatmap|GroupHeatmap 来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-group-heatmap`，验证状态 example。
- 验证范围：表半 `matrix_list` 与原生 `ht1$matrix_list` identical；绘图半固定 8×6@150 与 `ht1.png` 逐字节一致。未验证真实 Seurat→CSV→模板、add_dot/violin、feature_split 与科学有效性。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### heatmap（render-group-heatmap.csv）：一个 matrix × feature × group 的长表；模板按 matrix 重建多个热图矩阵 [[interfaces/render-group-heatmap|分组热图长表]]

| 列 | 类型 | 含义 |
|---|---|---|
| matrix | str | 分组变量/矩阵名，如 CellType；同一 feature 可出现在多个矩阵 |
| feature | str | 基因或元数据特征标识；同一矩阵内唯一 |
| group | str | 列分组/细胞类型；同一矩阵内唯一 |
| value | float | 聚合后的表达值，已按 exp_method 变换（如 zscore） |
| percent | float | 该组中 value > exp_cutoff 的细胞比例，0–1 |
| matrix_order | int | 矩阵显示顺序，从 1 起 |
| group_order | int | 同一矩阵内列顺序，从 1 起 |
| feature_order | int | 行顺序，从 1 起；同一 feature 在各矩阵保持一致 |

### 可覆盖的 style

- `exp_method`：`"zscore"`
- `exp_legend_title`：`"zscore(normalized counts)"`
- `heatmap_palette`：`"RdBu"`
- `heatmap_palcolor`：`null`
- `group_palette`：`"Paired"`
- `group_palcolor`：`null`
- `nlabel`：`20`
- `features_label`：`null`
- `label_size`：`10`
- `label_color`：`"black"`
- `flip`：`false`
- `dpi`：`150`
- `width_in`：`8`
- `height_in`：`6`
- `seed`：`11`
- `sizing`：`{"mode": "adaptive", "base_width_in": 3, "per_x_in": 0.35, "base_height_in": 2, "per_y_in": 0.25, "min_width_in": 6, "min_height_in": 5, "base_label_chars": 8, "per_label_char_in": 0.08, "aspect": null, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig08-group-heatmap` 的 A panel 拆出；表半 `scp_group_heatmap_matrix()` 与原生 `ht1$matrix_list` identical；绘图半用原生 ComplexHeatmap 构造，固定 8×6@150 与 `ht1.png` 逐字节一致。方法关系登记在 [[methods/scp-visualization-interface]]；`verify-template` exit 0，`check-entry --record` 已记录。

<!-- user:start -->
<!-- user:end -->
