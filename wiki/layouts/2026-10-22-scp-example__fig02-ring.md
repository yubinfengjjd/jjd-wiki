---
type: layout
id: 2026-10-22-scp-example__fig02-ring
title: 环形组成图（SCP 示例）
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig02-ring
gallery_version: 3
signedoff_version: 3
language: r
tags:
- 单细胞分析
keywords:
- SCP
- pancreas_sub
- ring
- composition
panels:
  A: ring
chart_types:
- ring
templates:
- 2026-10-22-scp-example__fig02-ring--ring
template_panels:
  2026-10-22-scp-example__fig02-ring--ring:
  - A
favorite: false
---
# 环形组成图（SCP 示例）

![[layouts/2026-10-22-scp-example__fig02-ring/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig02-ring
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、ring、composition
- 图型：[[chart-types/ring]]
- 面板：[[templates/2026-10-22-scp-example__fig02-ring--ring|分组构成同心环图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

SCP `CellStatPlot(plot_type = "ring")` 的单 panel 示例：按 `group` 分环、按 `celltype` 分扇区，展示每个 group 内各 celltype 的比例。适合细胞类型/细胞周期/样本组成等“两分类变量 + 比例”的展示；环数和扇区数可从数据读取，不写死 5 组或 3 类。

本条目只覆盖一个逻辑 panel；SCP 原函数的多图组合不进入 Wiki。

## 不适用

- 不能替代比例差异的统计检验；环图只展示组内比例，不做检验。
- 不能把 `pancreas_sub` 示例数据当真实队列；它没有病例/对照设计。
- 不能把每个 group 的行直接堆叠；接口要求每个 group 的 `proportion` 之和为 1。
- 组数很多（例如 >10 环）或扇区很多时，环宽和标签会拥挤；需要先确认画布扩展或合并稀有类别，不能靠缩小字体硬塞。
- 不能把环图当时间趋势或轨迹；环的顺序是分类顺序，不是时间。
- 不能把颜色当定量刻度；颜色只区分 celltype。
- 当前图的标签在小组扇区可能重叠；换数据要检查并调整 `min_label_prop`/画布。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-visualization-interface`）与 templates（fig04 stacked-bar-flow、fig01/fig03/fig06；尚无 ring 模板）。

- 候选方法：[[methods/scp-standard-workflow]] 或 [[methods/scp-annotation-projection]] 产出 celltype/cluster；本图消费 `render-cell-proportions`（group, celltype, proportion），需要从元数据按 group 统计比例。[[methods/scp-cellqc-doublet]] 也可用 QC Pass/Fail 作为 celltype 画 QC 组成。
- 一方法多图：同一 proportions 表也可进 fig04（堆叠比例+流带）；ring 是另一种结构编码，不替代 fig04。
- 一图多方法：任何产生 group×celltype 比例的方法都可驱动本图；不限于 SCP。
- 结构关系：本 layout 尚无模板，不能标 direct；待 ring 模板 ready 后在方法页补 `figure_relations`。
- 验证范围：原 SCP `CellStatPlot` 已用 `pancreas_sub` 运行并生成 source；复刻用同一 proportions 表；机械 QA 0 failure；agent 目视初评：整体 PASS，小组扇区标签重叠 WARN；作者/审签确认待定。
- 边界：不复刻多图整组；不改变比例计算或分组定义；不把示例数据当真实结论。

## 使用记录

2026-10-22 创建画廊条目 `2026-10-22-scp-example/figures/fig02-ring`；SCP `CellStatPlot(plot_type="ring")` 生成单 panel source；复刻代码在条目 `code/`；`ingest-figure` 建 layout，待审签。

<!-- user:start -->
<!-- user:end -->
