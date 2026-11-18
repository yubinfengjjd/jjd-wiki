---
type: template
id: coexpr-module-enrich-bars
title: 共表达模块功能富集分面条图
status: draft
layouts: []
sources:
- layouts/2026-11-19-hdwgcna-network__fig02
panels: []
language: r
primary_method: coexpression-ppi-network
data_domains:
- single-cell
- bulk-transcriptomics
tags:
- single-cell
chart_types:
- bar
keywords:
- hdWGCNA
- WGCNA
- enrichR
- GO
- patchwork
favorite: false
---
# 共表达模块功能富集分面条图

<!-- facts:start -->
- 来源：[[layouts/2026-11-19-hdwgcna-network__fig02|hdWGCNA 模块 GO 富集分面条图]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/bar]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

- 展示多模块 `hdWGCNA` / `WGCNA` 经 `RunEnrichr` 或 ORA 富集后各模块的 Top N 通路（`-log10(P-value)`），常与左图 [[templates/coexpr-sphere-network]]（球体共表达网络）拼图联动展示。
- 仅需整理好的 `enrich_plot_dat.csv`（`module`、`Term`、`log10p`、可选 `color`），支持任意模块数 `n` 自适应分面行高与深浅 strip 自动反白文字。

## 不适用

- 不直接执行线上 Enrichr 富集检验，需在上游完成 `RunEnrichr` 与 `P < 0.05` Top N 筛选后输入。

## 知识关联检查

2026-11-18：新建模板主归属方法 [[methods/coexpression-ppi-network]]，作为 [[templates/coexpr-sphere-network]] 的右半 Panel B 配套富集条图（可单独出图，也可通过 `patchwork` 拼为双面板组合图）。示例数据基于原图 0–8 刻度估读整理（`estimated`）。

## 数据要求

待填写 spec.json。

## 使用记录

<!-- user:start -->
<!-- user:end -->
