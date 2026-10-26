---
type: layout
id: 2026-10-22-scp-example__fig08-group-heatmap
title: GroupHeatmap (CellType / SubCellType)
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig08-group-heatmap
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
keywords:
- SCP
- pancreas_sub
- GroupHeatmap
- heatmap
- marker
panels:
  A: heatmap
chart_types:
- heatmap
templates:
- 2026-10-22-scp-example__fig08-group-heatmap--heatmap
template_panels:
  2026-10-22-scp-example__fig08-group-heatmap--heatmap:
  - A
favorite: false
---
# GroupHeatmap (CellType / SubCellType)

![[layouts/2026-10-22-scp-example__fig08-group-heatmap/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig08-group-heatmap
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、GroupHeatmap、heatmap、marker
- 图型：[[chart-types/heatmap]]
- 面板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

单细胞 marker 基因在两组分组变量（CellType、SubCellType）上的聚合表达热图：行是 13 个 marker，列是各分组的细胞类型，`CellType` 与 `SubCellType` 两个矩阵并排；颜色为 zscore 聚合值。适合检查 marker 是否落在预期细胞类型，以及同一基因在不同分组粒度下是否一致。

来源是 SCP v0.5.6 `GroupHeatmap()` 在 `pancreas_sub` 上的原生输出（8×6 in、150 dpi），未改绘图几何。

## 不适用

- 不能替代差异检验、富集或细胞类型注释；热图只显示聚合表达。
- 不支持 `add_dot`、`add_violin`、`feature_split`/`row_split`、cell/feature annotation、enrichment 注释；这些是上游其他分支。
- 输入不是 Seurat 对象；模板读取已聚合的 `render-group-heatmap` 长表，不重新聚合或 zscore。
- `percent` 只用于可选点大小，本 panel 默认不画点；不能把 percent 当统计显著性。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-de-enrichment-dynamic]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]] 与 heatmap 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] 从本页 A panel 拆出；读取 `render-group-heatmap`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `GroupHeatmap()` 是同一原生实现，已登记 adaptable；marker/DE 与 celltype 分组方法需在课题内导出聚合长表，模板不重算。
- 一图多方法：任何产生 feature×group 聚合值的方法都可驱动模板，不限于 SCP。
- 验证范围：表半 matrix_list 与原生 identical；绘图半固定输出与 source 逐字节一致；未验证真实课题流水线与 add_dot 等分支。

## 使用记录

2026-10-22 从 SCP v0.5.6 `GroupHeatmap()` 的原生 ht1 输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig08-group-heatmap--heatmap` 已建，固定回放与来源逐字节一致。

<!-- user:start -->
<!-- user:end -->
