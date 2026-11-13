---
type: layout
id: 2026-10-22-scp-example__fig14-feature-heatmap
title: 特征表达热图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig14-feature-heatmap
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: heatmap
chart_types:
- heatmap
templates:
- 2026-10-22-scp-example__fig14-feature-heatmap--heatmap
template_panels:
  2026-10-22-scp-example__fig14-feature-heatmap--heatmap:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- heatmap
- feature
---
# 特征表达热图

![[layouts/2026-10-22-scp-example__fig14-feature-heatmap/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig14-feature-heatmap
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、heatmap、feature
- 图型：[[chart-types/heatmap]]
- 面板：[[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`FeatureHeatmap()` 在 `pancreas_sub` 上的原生单 panel：20 个 DE 基因（`RunDEtest` 过滤后 `head(20)`）× CellType 5 组，列按 CellType 分块，颜色为 cell-level `zscore(normalized counts)`，保留 ComplexHeatmap 的列注释、行标签、图例和边框。适合检查 marker/DE 基因在细胞类型上的表达模式与细胞级异质性；8×6 in、150 dpi。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`FeatureHeatmap()`；模板从 A panel 拆出，读取 `render-feature-heatmap` 长表。

## 不适用

- 不能替代差异检验、富集或细胞类型注释；热图只显示表达。
- 只覆盖默认单 panel；`split.by`、`add_dot`/`add_violin`、`feature_split`/`row_split`、cell/feature annotation、enrichment 注释未实现。
- 示例只用 20 个基因；完整基因集需在课题内调整 nlabel/sizing，不能假设 8×6 可读。
- `value` 是 zscore(normalized counts)，不是原始 counts 或 group 均值；不能跨数据集比较颜色。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-de-enrichment-dynamic]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]] 与 heatmap 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] 从本页 A panel 拆出；读取 `render-feature-heatmap`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `FeatureHeatmap()` 是同一原生实现，已登记 adaptable；DE 基因由 `RunDEtest`/marker 方法产生，CellType 由标准流程/注释方法产生，需在课题内导出长表，模板不重算。
- 一图多方法：任何产生 feature×cell 表达矩阵与分组注释的方法都可驱动模板。
- 验证范围：表半矩阵/注释与上游一致；固定 8×6@150 与来源逐字节一致；adaptive 与非法输入已测；未验证 split/add_dot 等分支、完整基因集与真实课题流水线。

## 使用记录

2026-10-22 从 SCP v0.5.6 `FeatureHeatmap()` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig14-feature-heatmap--heatmap` 已建，固定回放与来源逐字节一致（SHA256 `6a614cfd…`）。

<!-- user:start -->
<!-- user:end -->
