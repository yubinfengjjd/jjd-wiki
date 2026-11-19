---
type: template
id: metabolism-lollipop-dotplot
title: 多亚群代谢通路棒棒糖图
status: draft
layouts: []
sources:
- methods/gene-set-enrichment
panels: []
language: r
primary_method: gene-set-enrichment
tags:
- single-cell
- transcriptomics
chart_types:
- lollipop
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 多亚群代谢通路棒棒糖图

<!-- facts:start -->
- 来源：[[methods/gene-set-enrichment|基因集富集分析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/lollipop]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

按亚群比较代谢通路富集的显著性及效应量，横轨显示该通路最强的显著性位置。参考 Cai 等主图 4K、5K 和附图 2E 的版式。

## 不适用

不要把 KEGG 富集代理解释为代谢通量或 scMetabolism 活性。不同检验或不同含义的点径值应分开绘制。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/gene-set-enrichment]]。

## 数据要求

`metabolism_lollipop.csv` 每行一个 `pathway` × `cluster` 组合，含 `neg_log10_p`（同一来源 P 值的 −log10）和非负 `score`（如统一定义的富集倍数）。颜色表示亚群。

## 使用记录

<!-- user:start -->
<!-- user:end -->
