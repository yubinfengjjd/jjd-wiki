---
type: layout
id: 2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow
title: 细胞比例堆叠与流带（GSE251716）
status: pending_template
gallery_entry: 2026-10-22-glaucoma-scrna/figures/fig04-cell-proportion-flow
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: stacked-bar-flow
chart_types:
- stacked-bar-flow
templates:
- 2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
template_panels:
  2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow:
  - A
favorite: false
keywords:
- GSE251716
- proportion
---
# 细胞比例堆叠与流带（GSE251716）

![[layouts/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow/thumb.png]]

<!-- facts:start -->
- 来源：青光眼单细胞项目（GSE251716）图表复刻
- 公众号：作者课题
- 日期：2026-10-22
- 画廊条目：2026-10-22-glaucoma-scrna/figures/fig04-cell-proportion-flow
- 语言：r
- 数据来源：synthetic
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：GSE251716、proportion
- 图型：[[chart-types/stacked-bar-flow]]
- 面板：[[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

两组或多组的细胞类型比例展示：输入 `group, celltype, proportion`，每组比例可归一化到 1。画堆叠柱 + 相邻组流带、右侧逆序图例、y 轴 0–1。组数/细胞类型数由数据识别，示例 2×9 不是限制。

## 不适用

比例未按组归一化或存在缺组；需要组间统计检验；组数过多导致流带不可读；不能把流带当细胞轨迹、统计估计或因果变化。流带只是相邻柱的视觉插值。

## 知识关联检查

2026-10-22 查过 M2（celltype 注释）、比例图相关图型页。V5 与 M2 语义相关：M2 产出 `cell-proportions.csv`；本模板只画比例，不做检验。当前来源为合成示例；模板待作者签核后建立并补 `figure_relations`。

## 使用记录

2026-10-22 从 `2026-10-22-glaucoma-scrna/figures/fig04-cell-proportion-flow` 收录；机械 QA 0 失败；作者签核待完成。

<!-- user:start -->
<!-- user:end -->
