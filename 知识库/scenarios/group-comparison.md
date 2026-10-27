---
type: scenario
id: group-comparison
title: 组间比较
picks:
- id: recipes/figureya-162boxviolin
  note: 半小提琴 + 箱线 + 散点
- id: recipes/figureya-227boxdensity
  note: 箱线叠加密度（两组）
- id: recipes/figureya-173fancybar
  note: 含亚组的均值柱（mean ± se）
- id: templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot
  note: 箱线、散点与均值（L2）
- id: templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
  note: 分组小提琴含统计标注（L2）
tags:
- experimental-statistics
keywords:
- 组间比较
- 箱线图
- 小提琴图
- 柱状图
- 误差棒
- 密度
- boxplot
- violin
summary: 两组或多组连续指标的分布与差异展示：箱线、小提琴、密度、均值柱。
---

# 组间比较

## 什么时候用

- 比较两组或多组的一个连续变量，想同时展示原始点、分布与统计量。
- 实验分组含亚组，需要组间与亚组内比较。

## 首选组合

首选按常用顺序排列；`find` 命中本场景时这些条目排在前面。

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[recipes/figureya-162boxviolin|半小提琴箱线散点组合图]] | L1 | ready · 运行 pass | 半小提琴 + 箱线 + 散点 |
| [[recipes/figureya-227boxdensity|箱线图叠加密度分布图]] | L1 | ready · 运行 pass | 箱线叠加密度（两组） |
| [[recipes/figureya-173fancybar|含亚组的多组均值柱图与比较]] | L1 | ready · 运行 pass | 含亚组的均值柱（mean ± se） |
| [[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] | L2 | ready · 可用 | 箱线、散点与均值（L2） |
| [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]] | L2 | ready · 可用 | 分组小提琴含统计标注（L2） |
<!-- facts:end -->

## 注意

- 小样本优先展示原始点，不只画均值柱。
- SE 与 SD 的选择按期刊要求，改误差棒定义先问作者。

## 作者备注

<!-- user:start -->
<!-- user:end -->
