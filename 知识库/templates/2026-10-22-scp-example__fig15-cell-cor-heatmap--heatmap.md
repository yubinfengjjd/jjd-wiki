---
type: template
id: 2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap
title: 细胞相似度热图
status: ready
layouts:
- 2026-10-22-scp-example__fig15-cell-cor-heatmap
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- heatmap
favorite: false
---
# 细胞相似度热图

![[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig15-cell-cor-heatmap|细胞相似度热图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/heatmap]]
- 输入接口：[[interfaces/render-correlation-heatmap|相似度矩阵长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-correlation-heatmap` 的相似度矩阵长表（row, column, similarity, row_group, column_group, row_order, column_order），重建 `row × column` 矩阵并调用 `plot_scp_cellcor_heatmap()`，复现 `CellCorHeatmap()` 的 ComplexHeatmap 构造：查询/参考分组注释、相似度色标、标题、图例、边框和 `heatmap_rendersize` 尺寸计算。`similarity` 已由上游 `RunKNNPredict`/相似度步骤算好，模板不重算相关、距离或 KNN。

示例为 `pancreas_sub` + `Standard_SCP` 后按 SubCellType 折叠的 8×8 查询-查询 cosine 相似度，8×6 in @150 dpi；固定输出与画廊 source 逐字节一致（SHA256 `6f96f3c2…`）。行/列标签、分组、顺序从数据读取，不写死 8 个组。

## 不适用

- `similarity` 必须是已计算的相似度矩阵；模板不重算 cosine/Pearson/KNN，也不把距离当相似度。
- 必须完整 `row × column` 笛卡尔积；缺失/重复会报错；行列标签、分组、顺序必须显式。
- 只覆盖默认的 query-query、组水平折叠、无 cell annotation 的路径；参考数据集（panc8）、细胞级不折叠、`nlabel`/`label_cutoff`、query/ref cell annotation、`flip`/cluster 未验证。
- 相似度量纲/方向由上游决定；不同 metric 的矩阵不能混在同一色标，需在图注写明。
- 组数/标签过长时按 `sizing` 增宽/增高；max 超限报错，不缩字体。
- 示例数据不是病例/对照设计，不能据此作生物学结论；相似度热图不替代统计检验或细胞类型注释。
- P1 兼容 `RunKNNPredict()` 的 metadata 名称写回；相似度矩阵与上游 identical。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-integration`、`scp-annotation-projection`、`scp-visualization-interface`）与 templates（fig08 GroupHeatmap、fig14 FeatureHeatmap、本模板）。

- 候选方法：[[methods/scp-integration]] 的整合/相似度评估、[[methods/scp-standard-workflow]] 的 Standard_SCP、[[methods/scp-annotation-projection]] 的参考投影都可产生相似度矩阵；它们需要在课题内先算好 row×column 相似度并导出 `render-correlation-heatmap` 长表，模板不重算。
- 一方法多图：同一份相似度矩阵可由本模板绘制；FeatureHeatmap/GroupHeatmap 画的是表达矩阵，不是相似度，不能互相替代。
- 一图多方法：任何产生完整 row×column 相似度矩阵的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig15-cell-cor-heatmap|细胞相似度热图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-correlation-heatmap`，验证状态 example。
- 验证范围：表半 `simil_matrix` 与上游 `identical`；固定 8×6@150 与画廊 source 逐字节一致；adaptive 与非法输入已测。未验证参考数据集、细胞级不折叠、nlabel/label_cutoff、annotation、flip/cluster、真实 Seurat→CSV→模板流水线与科学有效性。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### correlation（render-correlation-heatmap.csv）：已计算的相似度矩阵长表（row, column, similarity, row_group, column_group, row_order, column_order）；模板只重建矩阵并绘制，不重算相似度 [[interfaces/render-correlation-heatmap|相似度矩阵长表]]

| 列 | 类型 | 含义 |
|---|---|---|
| row | str | 行标签（查询细胞/组）；与 column 组成完整矩阵 |
| column | str | 列标签（参考细胞/组）；与 row 组成完整矩阵 |
| similarity | float | 已计算的相似度；模板不重算 |
| row_group | str | 行分组注释；每个 row 一个值 |
| column_group | str | 列分组注释；每个 column 一个值 |
| row_order | int | 行顺序；从 1 起 |
| column_order | int | 列顺序；从 1 起 |

### 可覆盖的 style

- `simil_name`：`"Cosine similarity"`
- `query_group`：`"SubCellType"`
- `ref_group`：`"SubCellType"`
- `query_collapsing`：`true`
- `ref_collapsing`：`true`
- `ref_legend`：`false`
- `heatmap_palette`：`"RdBu"`
- `heatmap_palcolor`：`null`
- `query_group_palette`：`"Paired"`
- `query_group_palcolor`：`null`
- `ref_group_palette`：`"Paired"`
- `ref_group_palcolor`：`null`
- `limits`：`null`
- `show_row_names`：`false`
- `show_column_names`：`false`
- `row_names_side`：`"left"`
- `column_names_side`：`"top"`
- `row_names_rot`：`0`
- `column_names_rot`：`90`
- `row_title`：`null`
- `column_title`：`null`
- `row_title_side`：`"left"`
- `column_title_side`：`"top"`
- `row_title_rot`：`90`
- `column_title_rot`：`0`
- `nlabel`：`0`
- `label_cutoff`：`0`
- `label_by`：`"row"`
- `label_size`：`10`
- `cluster_rows`：`false`
- `cluster_columns`：`false`
- `border`：`true`
- `flip`：`false`
- `use_raster`：`null`
- `raster_device`：`"png"`
- `raster_by_magick`：`false`
- `ht_params`：`{}`
- `seed`：`11`
- `width_in`：`8`
- `height_in`：`6`
- `dpi`：`150`
- `sizing`：`{"mode": "adaptive", "base_width_in": 6, "per_x_in": 0.35, "base_height_in": 5, "per_y_in": 0.35, "min_width_in": 5, "min_height_in": 5, "base_label_chars": 10, "per_label_char_in": 0.1, "aspect": 1, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig15-cell-cor-heatmap` 的 A panel 拆出；原生调用 `pancreas_sub <- Standard_SCP(pancreas_sub); CellCorHeatmap(srt_query = pancreas_sub, query_group = "SubCellType")`。表半 `scp_cellcor_simil()` 的 `simil_matrix` 与上游 identical；绘图半保留 ComplexHeatmap 构造。P1 对 `RunKNNPredict()` 的 metadata 写回加 `unname()`，适配 SeuratObject >= 5.4，矩阵不变。固定 8×6@150 与画廊 source 逐字节一致（SHA256 `6f96f3c2…`），`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
