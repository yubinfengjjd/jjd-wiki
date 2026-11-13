---
type: layout
id: 2026-10-22-scp-example__fig11-chord
title: 分组流向和弦图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig11-chord
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: chord
chart_types:
- chord
templates:
- 2026-10-22-scp-example__fig11-chord--chord
template_panels:
  2026-10-22-scp-example__fig11-chord--chord:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- chord
- composition
---
# 分组流向和弦图

![[layouts/2026-10-22-scp-example__fig11-chord/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig11-chord
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、chord、composition
- 图型：[[chart-types/chord]]
- 面板：[[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`CellStatPlot(plot_type = "chord")` 在 `pancreas_sub` 上的原生单 panel：CellType（5 类）与 Phase（3 类）排在圆周上，弦宽表示二维计数，`circlize::chordDiagram()` 绘制，透明度和边框沿用上游默认（`transparency = 0.2`、`link.lwd/lty/border = 1`）。适合展示两个互斥分类维度之间的多对多交叉，例如细胞类型与细胞周期、药物与靶点。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`StatPlot()` 的 chord 分支，返回 `recordedplot`；模板从 A panel 拆出，读取 `render-cell-linkage` 长表，用同一 PNG/PDF/SVG 设备重放。

## 不适用

- 必须恰好两个维度；第三个维度不画；`group.by` 被忽略，`stat_type` 强制为 count。
- 弦宽是计数，不是概率或效应量；环形布局不编码方向或时间。
- 同一类别名在两个维度中会合并为同一扇区；两维度的「NA」也会合并，需上游先区分。
- 上游 chord 不使用 ggplot 图例；`label`、`alpha` 等 style 键保留但不应改变几何。
- 只覆盖单 split；多面板 `split.by` 未实现。
- `recordedplot` 与设备相关；PNG 逐字节一致只在该环境与固定设备下成立。
- 示例数据不是病例/对照设计，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]]、[[methods/scp-de-enrichment-dynamic]] 与 chord 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]] 从本页 A panel 拆出；读取 `render-cell-linkage`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `CellStatPlot(plot_type="chord")` 是同一原生实现，已登记 adaptable；CellType/Phase 由标准流程/注释/细胞周期方法产生，需在课题内导出长表，模板不重算。
- 一图多方法：任何产生两个互斥分类维度的细胞级标签的方法都可驱动模板。
- 验证范围：表半 `table()` 矩阵 identical；固定 8×6@150 与来源逐字节一致；adaptive 与设备边界已测；未验证多面板、第三维度和真实课题流水线。

## 使用记录

2026-10-22 从 SCP v0.5.6 `CellStatPlot(plot_type="chord")` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig11-chord--chord` 已建，固定回放与来源逐字节一致（SHA256 `6674db75…`）。

<!-- user:start -->
<!-- user:end -->
