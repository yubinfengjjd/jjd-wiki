---
type: template
id: roe-cox-heatmap
title: 多因素Cox与Ro/e热图
status: draft
layouts: []
sources:
- methods/cell-proportion-composition
panels: []
language: r
primary_method: cell-proportion-composition
tags:
- single-cell
- survival-analysis
chart_types:
- heatmap
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 多因素Cox与Ro/e热图

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：r
- 标签：single-cell、survival-analysis
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

按相同的细胞亚群对齐多变量 Cox 方向及组织、临床亚型的观察数／期望数（Ro/e）。对应 Cai 等主图 2C、4C、5C。

## 不适用

需要展示 HR 及其置信区间、检验比例风险假设，或从细胞计数重新估计 Ro/e 时，应使用可输出这些统计量的分析方法。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-proportion-composition]]。

## 数据要求

`roe_cox_input.csv` 每行一个唯一 `canonical_subcluster`，至少各有一列 `roe_subtype_*` 和 `roe_tissue_*` 非负数值。提供可用队列的 `tcga_HR` 或 `inhouse_HR` 及可选同队列 `*_p_value`（0–1）。HR 缺失保留未检验色，Ro/e 标签显示一位小数，色阶上限可调。

## 使用记录

<!-- user:start -->
<!-- user:end -->
