---
type: template
id: lr-bubble-matrix
title: 配受体互作概率气泡矩阵
status: draft
layouts: []
sources:
- methods/cell-cell-communication
panels: []
language: r
primary_method: cell-cell-communication
tags:
- single-cell
chart_types:
- bubble
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 配受体互作概率气泡矩阵

<!-- facts:start -->
- 来源：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/bubble]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

按有向细胞对与配体–受体对展示 CellChat 等工具估计的互作强度。对应 Cai 等主图 2K、5J、6C/F 及附图 6D。

## 不适用

不适用于证明直接结合、因果通讯或比较不同算法的绝对分数。图中空格可来自数据缺失或显示筛选。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-cell-communication]]。

## 数据要求

`lr_bubble_matrix.csv` 提供有向 `pair_label`（或 `source` 和 `target`）、配体–受体标识 `interaction` 及非负互作强度 `prob`。可附 `pval`，成图按强度决定填色、点径与显示顺序。

## 使用记录

<!-- user:start -->
<!-- user:end -->
