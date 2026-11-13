---
type: layout
id: 2026-10-22-scp-example__fig07-dot
title: 组成点阵图（SCP 示例）
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig07-dot
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
keywords:
- SCP
- pancreas_sub
- dot
- composition
panels:
  A: dot
chart_types:
- dot
templates:
- 2026-10-22-scp-example__fig07-dot--dot
template_panels:
  2026-10-22-scp-example__fig07-dot--dot:
  - A
favorite: false
---
# 组成点阵图（SCP 示例）

![[layouts/2026-10-22-scp-example__fig07-dot/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig07-dot
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、dot、composition
- 图型：[[chart-types/dot]]
- 面板：[[templates/2026-10-22-scp-example__fig07-dot--dot|分组构成点图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

SCP `CellStatPlot(plot_type = "dot")` 的单 panel 示例，使用 `pancreas_sub` 的真实示例数据（1000 个细胞）。group × stat 网格，点面积表示组内比例。每个细胞一行 `cell, group, stat`；组数/类别数从数据读取，不写死示例规模。

source 由未修改的上游函数在固定设备上生成：

```r
CellStatPlot(pancreas_sub, stat.by = "Phase", group.by = "CellType", plot_type = "dot")
# ggsave 8 x 6 in, 150 dpi
```

模板 [[templates/2026-10-22-scp-example__fig07-dot--dot|点图]] 使用同一原生分支；固定 8×6 输出与 `source/fig07.png` 逐字节一致。本条目只覆盖一个逻辑 panel；SCP 原函数的多图组合不进入 Wiki。

## 不适用

- 不能替代分类组成的统计检验；图只展示计数或组内比例。
- 不能把 `pancreas_sub` 示例数据当真实病例/对照队列；它没有这样的设计。
- 不能把多个图型或整组 Example-2 拼图塞进本条目；本条目只代表 `dot` 一个逻辑 panel。
- 组数/类别数很多或标签很长时会拥挤；模板 `sizing` 会增宽/增高，设置上限后超限停止并报所需尺寸，不缩小字体。
- 不能把颜色当定量刻度；颜色只区分 stat 类别。
- 无额外裁切；点大小图例顺序 G1/S/G2M 与 source 一致。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig04 stacked-bar-flow、fig02 ring、fig03–fig07 同批 CellStat 模板）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype/cluster；[[methods/scp-cellqc-doublet]] 可用 QC Pass/Fail 作为 stat；[[methods/scp-de-enrichment-dynamic]] 产出分组/富集结果，但本图只做组成展示。它们都需要在课题内整理成 `render-cell-metadata`（cell, group, stat），模板不重算分析。
- 一方法多图：同一份细胞级元数据可驱动 pie/rose/trend/area/dot 五种结构编码；它们不互相替代，也不替代 fig04 的堆叠/流带。
- 一图多方法：任何产生 `group × stat` 细胞级标签的方法都可驱动本图，不限于 SCP。
- 结构关系：模板 [[templates/2026-10-22-scp-example__fig07-dot--dot|点图]] 已从 A panel 拆出；固定示例逐字节一致；方法页 [[methods/scp-visualization-interface]] 已登记 `adaptable` 关系，验证状态 example。来源 layout 只作 evidence。
- 验证范围：source 由上游函数生成；复刻/模板固定 8×6 输出逐字节一致；机械 QA 0 failure；agent 目视与哈希记录见条目 `qa_report.md`。不证明任意课题数据或统计有效。
- 边界：不复刻多图整组；不改变计数/比例计算或分组定义；不把示例数据当真实结论。

## 使用记录

<!-- user:start -->
<!-- user:end -->
