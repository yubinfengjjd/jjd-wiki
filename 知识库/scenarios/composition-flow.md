---
type: scenario
id: composition-flow
title: 组成与流向
picks:
- id: recipes/figureya-25sankey-update
  note: 多层分类流向桑基图
- id: recipes/figureya-196panpie
  note: 分组 × 临床分期扇形矩阵
- id: recipes/figureya-236circgroup
  note: 分型对应关系圈状热图
- id: templates/2026-10-22-scp-example__fig10-sankey--sankey
  note: 分组流向桑基图（L2）
- id: templates/2026-10-22-scp-example__fig02-ring--ring
  note: 分组构成同心环（L2）
- id: templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  note: 细胞比例堆叠流带（L2）
tags:
- experimental-statistics
- multi-omics
keywords:
- 组成
- 构成
- 比例
- 桑基图
- 饼图
- 流向
- 分型对应
- sankey
- pie
summary: 分类变量的构成比例、层级之间的流向与分型对应关系。
---

# 组成与流向

## 什么时候用

- 展示各组在分期、亚型等分类上的构成差异。
- 多层分类之间的交叉与流向。
- 不同分型方案之间的一致性。

## 首选组合

首选按常用顺序排列；`find` 命中本场景时这些条目排在前面。

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[recipes/figureya-25sankey-update|多层分类流向桑基图]] | L1 | draft · 运行 pass | 多层分类流向桑基图 |
| [[recipes/figureya-196panpie|分组临床分期扇形矩阵图]] | L1 | draft · 运行 pass | 分组 × 临床分期扇形矩阵 |
| [[recipes/figureya-236circgroup|分型对应关系圈状热图]] | L1 | draft · 运行 pass | 分型对应关系圈状热图 |
| [[templates/2026-10-22-scp-example__fig10-sankey--sankey|分组流向桑基图]] | L2 | ready · 可用 | 分组流向桑基图（L2） |
| [[templates/2026-10-22-scp-example__fig02-ring--ring|分组构成同心环图]] | L2 | ready · 可用 | 分组构成同心环（L2） |
| [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]] | L2 | ready · 可用 | 细胞比例堆叠流带（L2） |
<!-- facts:end -->

## 注意

- 类别过多时饼图难读，考虑堆叠柱或流带图。
- 构成差异的检验（卡方、Fisher）另做并写进图注。

## 作者备注

<!-- user:start -->
<!-- user:end -->
