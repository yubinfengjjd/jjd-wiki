---
type: template
id: cellchat-count-heatmap
title: 细胞通讯计数柱状热图
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
- heatmap
keywords: []
favorite: false
---
# 细胞通讯计数柱状热图

<!-- facts:start -->
- 来源：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

比较有向发送者与接收者间的显著配体–受体对计数，并查看同一矩阵的发送者及接收者边际合计。Cai 等主图 4I、6B 使用发表的 CellPhoneDB 计数。

## 不适用

不适用于单对配体–受体的概率矩阵，或直接比较检验阈值与候选配体–受体库不同的分析。缺测组合须保留缺测状态。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-cell-communication]]。

## 数据要求

`interaction_counts.csv` 每行一个唯一的有向 `SOURCE` × `TARGET` 组合。`count` 为同一阈值下筛出的非负显著互作对数，已确认的零以 0 表示。边际柱为已提供计数的合计，轴以千计。

## 使用记录

<!-- user:start -->
<!-- user:end -->
