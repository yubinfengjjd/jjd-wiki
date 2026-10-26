---
type: layout
id: 2026-10-22-scp-example__fig13-upset
title: 多集合交集 UpSet 图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig13-upset
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: upset
chart_types:
- upset
templates:
- 2026-10-22-scp-example__fig13-upset--upset
template_panels:
  2026-10-22-scp-example__fig13-upset--upset:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- upset
- composition
---
# 多集合交集 UpSet 图

![[layouts/2026-10-22-scp-example__fig13-upset/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig13-upset
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、upset、composition
- 图型：[[chart-types/upset]]
- 面板：[[templates/2026-10-22-scp-example__fig13-upset--upset|多集合交集 UpSet 图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`CellStatPlot(plot_type = "upset")` 在 `pancreas_sub` 上的原生单 panel：四个集合 Ductal、Endocrine、G1S、G2M，交集按大小排序，非空交集 512、411、77；上方是交集大小条形图，下方是集合成员矩阵。8×6 in、150 dpi。适合集合较多、需要按交集大小排序并查看组合成员的情况。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`StatPlot()` 的 upset 分支，使用 ggupset 0.4.1；模板从 A panel 拆出，读取 `render-cell-membership` 长表。

## 不适用

- 条形高度是交集大小，不是单个集合大小；集合大小需另标或另图。
- `n_intersections = 20` 会截断更多交集，必须在图注说明；空交集不显示。
- 所有集合必须来自同一细胞全集；缺失/重复 `cell × set` 会改变计数；`member` 只接受 0/1，NA 被拒绝。
- 交集大小不是富集显著性，不能据此宣称生物学重要性。
- 只覆盖单 split；`aspect.ratio = 0.6`、组合矩阵字号/间距是上游常数，不随画布缩放。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]]、[[methods/scp-cellqc-doublet]]、[[methods/scp-de-enrichment-dynamic]] 与 upset 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig13-upset--upset|多集合交集 UpSet 图]] 从本页 A panel 拆出；读取 `render-cell-membership`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `CellStatPlot(plot_type="upset")` 是同一原生实现，已登记 adaptable；集合成员由标准流程/注释/QC/DE 方法在课题内定义并导出长表，模板不重算。
- 一图多方法：任何产生同一细胞全集多个 0/1 集合的方法都可驱动模板。
- 验证范围：交集计数与上游一致；固定 8×6@150 与来源逐字节一致；adaptive 2–8 集合、2–16 交集已测；>20 交集截断分支未测；未验证真实课题流水线。

## 使用记录

2026-10-22 从 SCP v0.5.6 `CellStatPlot(plot_type="upset")` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig13-upset--upset` 已建，固定回放与来源逐字节一致（SHA256 `b2f0322d…`）。

<!-- user:start -->
<!-- user:end -->
