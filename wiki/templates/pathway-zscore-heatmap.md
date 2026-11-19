---
type: template
id: pathway-zscore-heatmap
title: 功能基因与通路Zscore热图
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
- heatmap
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 功能基因与通路Zscore热图

<!-- facts:start -->
- 来源：[[methods/gene-set-enrichment|基因集富集分析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

对齐不同亚群的功能基因 Z 分数或 PROGENy 通路活性，展示相对偏高与偏低的模式。对应 Cai 等主图 2、4、5 的功能矩阵。

## 不适用

原始计数、富集 P 值及不同标度的分数应在上游整理。缺失值过多时不要进行层次聚类，Z 分数也不能解释为绝对表达量。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/gene-set-enrichment]]。

## 数据要求

`zscore_matrix.csv` 的首列为唯一行标识，其余为数值矩阵。首列为 `canonical_subcluster` 时默认转置，使亚群位于横轴。可在样式中用 `column_groups` 提供横轴列名到分组标签的完整映射，组序按映射中的首次出现排列。默认采用功能基因配色，`palette: "progeny"` 可选 PROGENy 配色。

## 使用记录

<!-- user:start -->
<!-- user:end -->
