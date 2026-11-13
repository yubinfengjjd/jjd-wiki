---
type: layout
id: 2026-10-22-scp-example__fig17-group-heatmap-dot
title: 分组表达点阵热图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig17-group-heatmap-dot
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
- 2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap
template_panels:
  2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- GroupHeatmap
- add_dot
- percent-size
---
# 分组表达点阵热图

![[layouts/2026-10-22-scp-example__fig17-group-heatmap-dot/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig17-group-heatmap-dot
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、GroupHeatmap、add_dot、percent-size
- 图型：[[chart-types/heatmap]]
- 面板：[[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

单细胞 marker 基因在一个分组变量（CellType）上的聚合表达热图，并在每格叠加"阈值阳性细胞比例"点：行是 12 个 marker，列是 5 个细胞类型；每格底色为白，格内圆点 **fill 颜色**映射 zscore 聚合值（RdBu 双向色标），圆点**直径**为 `percent`（0–1，原式 `size = dot_size * perc`，按直径线性缩放非面积正比，点图例 20%–100%），列顶色条仅标识分组身份 + 行侧 marker 标注。适合同时检查 marker 的平均表达强度与表达普及度，比纯色块热图多一层比例信息。

来源是 SCP v0.5.6 `GroupHeatmap(add_dot=TRUE)` 在 `pancreas_sub` 上本次实跑的原生输出（8×6 in、150 dpi），未改绘图几何；是 `add_dot` 分支的单 panel。

## 不适用

- 不覆盖同函数其他分支：`add_violin`、`flip`、`split.by` 多列切分、`feature_split`、`n_split`、cell/feature annotation 均未实现（候选代码显式拒绝）。
- `percent` 只能来自逐细胞表达（经原调用声明的 lib_normalize 后、聚合/zscore 前）`> exp_cutoff` 比例的预计算结果，不能对聚合 value 列再取阈值得到；模板不重算、不补 pct、不隐式聚合。
- 输入不是 Seurat 对象；候选读取已聚合的 `render-group-heatmap` 长表。
- percent 是描述性比例，不是统计显著性；示例数据非病例/对照设计，不能据此作生物学结论。
- 不能替代差异检验、富集或细胞类型注释。

## 知识关联检查

2026-10-25已核对原生GroupHeatmap点阵与ht1：点颜色表示聚合变换表达、点直径表示逐细胞阈值比例，保留不同结构来源。可调用入口现为[[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；原生代码与来源panel仍在画廊，只读溯源。本来源不代替分析方法，也不自动授予其他GroupHeatmap分支可用。

## 使用记录

2026-10-25作者明确确认后正常签核来源并组装、真实verify和确认模板；独立对照及保护记录见维护记录/2026-10-25-SCP全库入库。源码与既有作者备注保留。

<!-- user:start -->
<!-- user:end -->
