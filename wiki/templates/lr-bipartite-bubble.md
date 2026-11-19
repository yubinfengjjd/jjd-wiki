---
type: template
id: lr-bipartite-bubble
title: 配受体双轴连线气泡图
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
---
# 配受体双轴连线气泡图

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

以有向连线展示预先选定的配体–受体候选关系，并用两端气泡比较平均表达与表达比例。连线样式参考 Cai 等主图 3D。

## 不适用

不适用于仅有互作 P 值或要估计空间邻近、通讯概率的输入。原图 3D 的 CellPhoneDB 置换检验支持度和显著比例须按原图的统计口径另行展示。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-cell-communication]]。

## 数据要求

`lr_bipartite_pairs.csv` 每行一组 `ligand`、`receptor`，两端分别提供 `ligand_expr`、`receptor_expr` 和 `ligand_pct`、`receptor_pct`（0–100）。表达强度使用同一标度，同一端节点重复出现时保持统计值一致。

## 使用记录

<!-- user:start -->
<!-- user:end -->
