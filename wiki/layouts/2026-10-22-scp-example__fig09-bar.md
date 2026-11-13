---
type: layout
id: 2026-10-22-scp-example__fig09-bar
title: 分组计数柱图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig09-bar
gallery_version: 2
signedoff_version: 2
language: r
tags:
- 单细胞分析
panels:
  A: bar
chart_types:
- bar
templates:
- 2026-10-22-scp-example__fig09-bar--bar
template_panels:
  2026-10-22-scp-example__fig09-bar--bar:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- bar
- composition
---
# 分组计数柱图

![[layouts/2026-10-22-scp-example__fig09-bar/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig09-bar
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、bar、composition
- 图型：[[chart-types/bar]]
- 面板：[[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`CellStatPlot(plot_type = "bar")` 在 `pancreas_sub` 上的原生单 panel：x 轴是 5 个 CellType，柱内/柱上标注 Phase（G1/S/G2M）的计数，系列配色为 `Paired`，图例标题 `Phase:`。记录的 source 用上游默认 `position = "stack"`、`stat_type = "count"`、`label = TRUE`，8×6 in、150 dpi；适合比较各细胞类型的细胞周期构成绝对量。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`StatPlot()` 的 bar 分支，未改绘图几何；模板从 A panel 拆出，读取 `render-cell-metadata`。

## 不适用

- 不能替代细胞周期或组间差异的统计检验；柱高是计数，不是效应量。
- 参考 panel（Example-2 第 2 格）与本地 source 同为默认 stack 的计数柱；第 1 格是 dodge 变体，数据/配色相同但几何不同，不能把 source 当第 1 格的像素复刻。
- 只覆盖单组 `split.by = NULL` 的 5×3 示例；多 split、bg.by、individual、NA 类别未验证。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]]、[[methods/scp-cellqc-doublet]] 与 bar 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]] 从本页 A panel 拆出；读取 `render-cell-metadata`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `CellStatPlot(plot_type="bar")` 是同一原生实现，已登记 adaptable；CellType/Phase 由标准流程、注释投影或 marker 注释方法产生，需在课题内导出逐细胞元数据，模板不重算。
- 一图多方法：任何产生每个细胞一个 `group` 与一个 `stat` 标签的方法都可驱动模板。
- 验证范围：固定 8×6@150 与来源逐字节一致；stack/dodge/count/percent/label/flip 变体与上游一致；adaptive 与非法输入已测；未验证真实课题流水线。

## 使用记录

2026-10-22 从 SCP v0.5.6 `CellStatPlot(plot_type="bar")` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig09-bar--bar` 已建，固定回放与来源逐字节一致（SHA256 `d9375658…`）。

<!-- user:start -->
<!-- user:end -->
