---
type: template
id: 2026-10-22-scp-example__fig14-feature-heatmap--heatmap
title: 特征表达热图
status: ready
layouts:
- 2026-10-22-scp-example__fig14-feature-heatmap
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- heatmap
favorite: false
---
# 特征表达热图

![[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig14-feature-heatmap|特征表达热图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/heatmap]]
- 输入接口：[[interfaces/render-feature-heatmap|特征×细胞表达矩阵长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-feature-heatmap` 的 matrix × feature × cell 长表，按 matrix 重建特征×细胞矩阵、列分组注释、行/列顺序和 `zscore(normalized counts)` 色标，再复现 `FeatureHeatmap()` 的 ComplexHeatmap 构造：列注释块、行标签、图例、边框与 `heatmap_rendersize` 尺寸计算。`value` 已由上游按 `exp_method` 变换，模板不重算 zscore、归一化或聚类。

示例为 `pancreas_sub` 的 20 个 DE 基因（`RunDEtest` 过滤后 `head(20)`）× CellType 5 组，8×6 in @150 dpi；固定输出与画廊 source 逐字节一致（SHA256 `6a614cfd…`）。矩阵数、特征数与细胞数从数据读取，不写死 20×5；`nlabel`、`features_label`、`cluster_rows/columns` 等由 style 给出。

## 不适用

- 只画 `FeatureHeatmap` 的默认单 panel；`split.by` 分面、`add_dot`、`add_violin`、`feature_split`/`row_split`、cell/feature annotation、enrichment 注释未实现。
- `value` 必须是已变换的表达值（示例 zscore），不是原始 counts 或 group 均值；模板不重算。
- 长表必须每个 matrix × feature × cell 恰好一行；各矩阵的 feature 集合/顺序需一致；`value` 不能有 NA/Inf。
- 示例只用 `head(20)` 个 DE 基因；完整基因集（数百行）未验证可读性，需在课题内按 nlabel/sizing 调整。
- 组数/特征数/细胞数过多时按 `sizing` 增宽/增高；`max_width_in`/`max_height_in` 超限报错，不缩字体。
- 示例数据不是病例/对照设计，不能据此作生物学结论；热图不替代差异检验或注释。
- 聚类默认关闭；若开启，排序由上游给定，模板不重新聚类。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig08 GroupHeatmap、本模板）。

- 候选方法：[[methods/scp-de-enrichment-dynamic]] 的 `RunDEtest`/marker 表提供 features；[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 提供 CellType 分组。它们需要在课题内把表达矩阵、分组与顺序导出成 `render-feature-heatmap` 长表，模板不重算 DE 或 zscore。
- 一方法多图：同一份 marker/DE 表可由 FeatureHeatmap（cell-level）或 [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|GroupHeatmap]]（feature×group 聚合）表达；前者保留细胞级异质性，后者更紧凑；两者不互相替代。
- 一图多方法：任何产生 feature×cell 表达矩阵与分组注释的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig14-feature-heatmap|特征表达热图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-feature-heatmap`，验证状态 example。
- 验证范围：表半矩阵/注释与上游绘制对象一致；固定 8×6@150 与画廊 source 逐字节一致；adaptive 与非法输入已测。未验证 split.by、add_dot/add_violin/feature_split/annotation、完整 DE 基因集、真实 Seurat→CSV→模板流水线与科学有效性。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### heatmap（render-feature-heatmap.csv）：一个 matrix × feature × cell 的长表（matrix 为 group.by 变量名）；模板按 matrix 重建特征×细胞矩阵、分组注释与显式行/列顺序，表达变换在上游完成，模板不重算 [[interfaces/render-feature-heatmap|特征×细胞表达矩阵长表]]

| 列 | 类型 | 含义 |
|---|---|---|
| matrix | str | 矩阵/分组变量名；同一图可含多个 matrix |
| feature | str | 基因或特征标识；同一矩阵内唯一 |
| cell | str | 细胞标识；同一矩阵内唯一；每个细胞每个特征一行 |
| group | str | 细胞所属分组（列注释）；每个细胞一个值 |
| value | float | 已按 exp_method 变换的表达值（如 zscore）；模板不重算变换 |
| matrix_order | int | 矩阵显示顺序；从 1 起 |
| feature_order | int | 特征行顺序；从 1 起；各矩阵需一致 |
| cell_order | int | 细胞列顺序；从 1 起 |
| group_order | int | 分组图例/注释顺序；从 1 起 |

### 可覆盖的 style

- `exp_method`：`"zscore"`
- `exp_legend_title`：`"zscore(normalized counts)"`
- `heatmap_palette`：`"RdBu"`
- `heatmap_palcolor`：`null`
- `group_palette`：`"Paired"`
- `group_palcolor`：`null`
- `group_levels`：`null`
- `nlabel`：`20`
- `features_label`：`null`
- `label_size`：`10`
- `label_color`：`"black"`
- `flip`：`false`
- `cluster_rows`：`false`
- `cluster_columns`：`false`
- `cluster_row_slices`：`false`
- `cluster_column_slices`：`false`
- `border`：`true`
- `show_row_names`：`false`
- `show_column_names`：`false`
- `row_names_rot`：`0`
- `column_names_rot`：`90`
- `use_raster`：`null`
- `raster_device`：`"png"`
- `raster_by_magick`：`false`
- `width`：`null`
- `height`：`null`
- `units`：`"inch"`
- `dpi`：`150`
- `width_in`：`8`
- `height_in`：`6`
- `seed`：`11`
- `sizing`：`{"mode": "adaptive", "base_width_in": 4, "per_x_in": 0.004, "base_height_in": 2.5, "per_y_in": 0.18, "min_width_in": 6, "min_height_in": 5, "base_label_chars": 12, "per_label_char_in": 0.08, "aspect": null, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig14-feature-heatmap` 的 A panel 拆出；原生调用 `FeatureHeatmap(srt = pancreas_sub, features = head(de_filter$gene, 20), group.by = "CellType")`，`de_filter` 来自 `RunDEtest`（p_val_adj < 0.05、avg_log2FC > 1）。表半保留 matrix/feature/cell/group/value 与顺序；绘图半保留 ComplexHeatmap 构造。固定 8×6@150 与画廊 source 逐字节一致（SHA256 `6a614cfd…`），`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
