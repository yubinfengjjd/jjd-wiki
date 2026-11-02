---
type: scenario
id: differential-enrichment
title: 差异表达与富集分析
picks:
- id: templates/2026-10-22-scp-example__fig01-volcano--volcano
  note: 已确认可换数据的火山图模板（L2）
- id: recipes/figureya-59volcanov2
  note: FigureYa 经典与进阶火山图
- id: recipes/figureya-13gsea-java-update
  note: Java GSEA 输出的多通路美化图
- id: recipes/figureya-61gsva
  note: GSVA 通路评分 + limma 差异
- id: recipes/figureya-39bar
  note: 正负方向发散柱图（接 GSVA 结果）
- id: recipes/figureya-11bubble
  note: 多组富集对角气泡图
- id: recipes/figureya-153ccgraph
  note: 层级关系同心环图
- id: methods/differential-expression
  note: 差异表达方法页
- id: methods/gene-set-enrichment
  note: 基因集富集方法页
tags:
- transcriptomics
keywords:
- 火山图
- 差异表达
- DEG
- limma
- GSEA
- GSVA
- 富集
- GO
- KEGG
- 气泡图
- 通路
summary: 两组或多组的差异基因展示（火山图）与通路层面的结果（GSEA、GSVA、富集气泡/柱图）。
---

# 差异表达与富集分析

## 什么时候用

- 已有差异分析表，要展示整体变化与重点基因。
- 要把多个通路的 GSEA / 富集结果放进一张图。
- 要把样本×基因矩阵转成样本×通路评分再比组间。

## 首选组合

首选按常用顺序排列；`find` 命中本场景时这些条目排在前面。

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]] | L2 | ready · 可用 | 已确认可换数据的火山图模板（L2） |
| [[recipes/figureya-59volcanov2|差异表达火山图（经典与进阶）]] | L1 | ready · 运行 pass | FigureYa 经典与进阶火山图 |
| [[recipes/figureya-13gsea-java-update|Java GSEA 结果多通路美化图]] | L1 | ready · 运行 pass | Java GSEA 输出的多通路美化图 |
| [[recipes/figureya-61gsva|GSVA 通路评分与组间差异]] | L1 | draft · 运行 fail | GSVA 通路评分 + limma 差异 |
| [[recipes/figureya-39bar|分组着色柱图与正负富集柱图]] | L1 | ready · 运行 pass | 正负方向发散柱图（接 GSVA 结果） |
| [[methods/differential-expression|差异表达分析]] | note | ready | 差异表达方法页 |
| [[methods/gene-set-enrichment|基因集富集分析]] | note | ready | 基因集富集方法页 |
<!-- facts:end -->

## 注意

- 火山图阈值（log2FC、校正 P）按课题定，改阈值含义前先问作者。
- 富集结果图只画上游给定的统计量，不重算 P 值。

<!-- figureya-selection:start -->
## 样式筛选记录

2026-11-02 按作者的 FigureYa 样式筛选更新当前首选展示：原 9 项，当前展示 7 项。

被移除项退出当前首选表；原 `picks` 关系保留用于恢复和溯源，不能据历史关系重新推荐已移除样式。
<!-- figureya-selection:end -->

## 作者备注

<!-- user:start -->
<!-- user:end -->
