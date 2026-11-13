---
type: layout
id: 2026-10-22-scp-example__fig12-venn
title: 多集合交集维恩图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig12-venn
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: venn
chart_types:
- venn
templates:
- 2026-10-22-scp-example__fig12-venn--venn
template_panels:
  2026-10-22-scp-example__fig12-venn--venn:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- venn
- composition
---
# 多集合交集维恩图

![[layouts/2026-10-22-scp-example__fig12-venn/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig12-venn
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、venn、composition
- 图型：[[chart-types/venn]]
- 面板：[[templates/2026-10-22-scp-example__fig12-venn--venn|多集合交集维恩图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`CellStatPlot(plot_type = "venn")` 在 `pancreas_sub` 上的原生单 panel：四个集合 Ductal（488）、Endocrine（512）、G1S（923）、G2M（77），椭圆重叠区域标注交集计数与百分比；非空交集为 512、411、77。集合由 CellType/Phase 派生：Ductal = Ductal + Ngn3 low/high EP，Endocrine = Pre-endocrine + Endocrine，G1S = G1 + S，G2M = G2M。8×6 in、150 dpi。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`StatPlot()` 的 venn 分支，使用 ggVennDiagram 1.5.7 并对几何/`setedge` 名称做记录在 `PATCHES.md` 的兼容；模板从 A panel 拆出，读取 `render-cell-membership`。

## 不适用

- 集合数限制 2–7；5 个以上通常不可读，应改用 UpSet。
- 圆/椭圆面积不与集合大小成比例；不能按面积读大小，必须看计数。
- 交集计数不能相加当全集；百分比分母是区域计数之和（上游行为），不是背景全集。
- 所有集合必须来自同一细胞全集；缺失/重复 `cell × set` 会改变计数；`member` 只接受 0/1，NA 被拒绝。
- 集合定义（阈值、过滤、注释版本）必须在课题内固定；模板不重算阈值，也不做富集检验。
- 只覆盖单 split；未与 ggVennDiagram 1.2.x 逐字节交叉验证。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]]、[[methods/scp-cellqc-doublet]]、[[methods/scp-de-enrichment-dynamic]] 与 venn 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig12-venn--venn|多集合交集维恩图]] 从本页 A panel 拆出；读取 `render-cell-membership`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `CellStatPlot(plot_type="venn")` 是同一原生实现，已登记 adaptable；集合成员由标准流程/注释/QC/DE 方法在课题内定义并导出长表，模板不重算。
- 一图多方法：任何产生同一细胞全集多个 0/1 集合的方法都可驱动模板。
- 验证范围：区域/集合表与上游一致；固定 8×6@150 与来源逐字节一致；adaptive 与非法输入已测；未与旧版 ggVennDiagram 交叉验证，未验证真实课题流水线。

## 使用记录

2026-10-22 从 SCP v0.5.6 `CellStatPlot(plot_type="venn")` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig12-venn--venn` 已建，固定回放与来源逐字节一致（SHA256 `a5bf1995…`）。

<!-- user:start -->
<!-- user:end -->
