---
type: scenario
id: correlation
title: 相关性分析
picks:
- id: recipes/figureya-92immune-gene-update
  note: 基因 × 免疫浸润相关点图与散点
- id: recipes/figureya-228linkcor
  note: 相关热图 + 连线蝴蝶图
- id: recipes/figureya-76corrgram
  note: 多变量相关矩阵散点热图
- id: recipes/figureya-37correlationv2-update
  note: 圆形布局基因相关连线
- id: recipes/figureya-143survcor-update
  note: 相关散点叠加最佳截断四象限（重）
- id: templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter
  note: 密度散点与边缘分布（L2）
tags:
- transcriptomics
- experimental-statistics
keywords:
- 相关性
- correlation
- 相关热图
- 免疫浸润
- 共表达
- corrgram
- 散点
summary: 变量两两相关、基因与免疫浸润/通路的相关，以及相关结果的热图、连线、散点展示。
---

# 相关性分析

## 什么时候用

- 少量连续变量的相关矩阵。
- 一个基因与多个免疫细胞、通路或基因的相关。
- 相关与生存截断结合解读。

## 首选组合

首选按常用顺序排列；`find` 命中本场景时这些条目排在前面。

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[recipes/figureya-92immune-gene-update|基因与免疫浸润相关性图]] | L1 | draft · 运行 pass | 基因 × 免疫浸润相关点图与散点 |
| [[recipes/figureya-228linkcor|相关热图与连线蝴蝶图]] | L1 | draft · 运行 pass | 相关热图 + 连线蝴蝶图 |
| [[recipes/figureya-76corrgram|多变量相关矩阵散点热图]] | L1 | draft · 运行 pass | 多变量相关矩阵散点热图 |
| [[recipes/figureya-37correlationv2-update|圆形布局基因相关连线图]] | L1 | draft · 运行 pass | 圆形布局基因相关连线 |
| [[recipes/figureya-143survcor-update|相关性散点叠加最佳截断四象限]] | L1 | draft · 运行 pass | 相关散点叠加最佳截断四象限（重） |
| [[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]] | L2 | ready · 可用 | 密度散点与边缘分布（L2） |
<!-- facts:end -->

## 注意

- Pearson / Spearman 的选择沿用上游；换方法属于改统计逻辑，先问作者。
- 相关不代表因果；多重比较校正方式要在图注写清。

## 作者备注

<!-- user:start -->
<!-- user:end -->
