---
type: layout
id: 2026-10-22-scp-example__fig16-cell-density
title: 分组表达密度图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig16-cell-density
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: ridge
chart_types:
- ridge
templates:
- 2026-10-22-scp-example__fig16-cell-density--ridge
template_panels:
  2026-10-22-scp-example__fig16-cell-density--ridge:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- ridge
- density
---
# 分组表达密度图

![[layouts/2026-10-22-scp-example__fig16-cell-density/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig16-cell-density
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、ridge、density
- 图型：[[chart-types/ridge]]
- 面板：[[templates/2026-10-22-scp-example__fig16-cell-density--ridge|分组表达密度图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`CellDensityPlot(features = "Sox9", group.by = "SubCellType")` 在 `pancreas_sub` 上的原生单 panel：8 个 SubCellType 各一条 Sox9 表达密度脊线，x 轴为 data slot 的表达值，颜色为 `Paired`，图例标题 `SubCellType:`。适合比较多个有序组的连续特征分布形状、峰值和重叠；8×6 in、150 dpi。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`CellDensityPlot()`，使用 ggridges；模板从 A panel 拆出，读取 `render-cell-feature-values`。

## 不适用

- 每组观测很少时核密度不可靠；应改用箱线/逐点并标 n。
- 密度高度按组归一化，不能比较组的总量；不同 n 的组不能按曲线高度读比例。
- `value` 的单位/变换必须明确；多个 feature 量纲不同时不能共用一个坐标解释。
- 组数/特征数/标签过长会拥挤；按 sizing 增宽/增高，max 超限报错，不缩字体。
- 只覆盖单 split、默认带宽；flip/reverse/x_order 非默认值未验证。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]]、[[methods/scp-cellqc-doublet]] 与 ridge 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig16-cell-density--ridge|分组表达密度图]] 从本页 A panel 拆出；读取 `render-cell-feature-values`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `CellDensityPlot()` 是同一原生实现，已登记 adaptable；细胞类型/QC/表达值由标准流程、注释或 QC 方法产生，需在课题内导出长表，模板不重算。
- 一图多方法：任何产生同一细胞全集连续特征值与分组的方法都可驱动模板。
- 验证范围：表半与上游 ggplot_build 数据一致；固定 8×6@150 与来源逐字节一致；adaptive 2/12 组、3 特征、长标签与 max 拒绝已测；未验证真实课题流水线、非默认参数与 CJK 标签。

## 使用记录

2026-10-22 从 SCP v0.5.6 `CellDensityPlot()` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig16-cell-density--ridge` 已建，固定回放与来源逐字节一致（SHA256 `72a7a07a…`）。

<!-- user:start -->
<!-- user:end -->
