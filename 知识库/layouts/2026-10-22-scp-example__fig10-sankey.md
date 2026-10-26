---
type: layout
id: 2026-10-22-scp-example__fig10-sankey
title: 分组流向桑基图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig10-sankey
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: sankey
chart_types:
- sankey
templates:
- 2026-10-22-scp-example__fig10-sankey--sankey
template_panels:
  2026-10-22-scp-example__fig10-sankey--sankey:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- sankey
- composition
---
# 分组流向桑基图

![[layouts/2026-10-22-scp-example__fig10-sankey/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig10-sankey
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、sankey、composition
- 图型：[[chart-types/sankey]]
- 面板：[[templates/2026-10-22-scp-example__fig10-sankey--sankey|分组流向桑基图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`CellStatPlot(plot_type = "sankey")` 在 `pancreas_sub` 上的原生单 panel：左侧 CellType（5 类）、右侧 Phase（3 类），连线宽度表示细胞计数，两个维度各有图例，单 panel 8×6 in、150 dpi。适合展示同一批细胞在两个互斥分类维度之间的分配，例如细胞类型与细胞周期、处理与状态。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`StatPlot()` 的 sankey 分支；模板从 A panel 拆出，读取 `render-cell-linkage` 长表。为适配当前 gtable/patchwork/ggplot2 版本，图例组合做了三处记录在 `PATCHES.md` 的兼容，节点/流量几何不变。

## 不适用

- 上游 sankey 忽略 `group.by`，强制 `stat_type = "count"`；不能画比例、概率或转移率。
- 连线宽度是原始计数，总样本量不同的队列不能直接比较；维度顺序不能读成时间或因果。
- 一个细胞可属于多个集合时不能用 sankey（改用 venn/upset）；`category` 不能是 NA。
- 只覆盖默认单 split；多 split、>100 水平、NA 类别未验证。
- 图例顺序按因子水平，Example-2 panel 12 是字母序；这是已记录的视觉差异。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]]、[[methods/scp-de-enrichment-dynamic]] 与 sankey 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig10-sankey--sankey|分组流向桑基图]] 从本页 A panel 拆出；读取 `render-cell-linkage`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `CellStatPlot(plot_type="sankey")` 是同一原生实现，已登记 adaptable；CellType/Phase 由标准流程/注释/细胞周期方法产生，需在课题内导出长表，模板不重算。
- 一图多方法：任何产生两个以上互斥分类维度的细胞级标签的方法都可驱动模板。
- 验证范围：表半与上游 `make_long()` 一致；固定 8×6@150 与来源逐字节一致；adaptive 与非法输入已测；未验证多 split、NA 类别与真实课题流水线。

## 使用记录

2026-10-22 从 SCP v0.5.6 `CellStatPlot(plot_type="sankey")` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig10-sankey--sankey` 已建，固定回放与来源逐字节一致（SHA256 `7b16c620…`）。

<!-- user:start -->
<!-- user:end -->
