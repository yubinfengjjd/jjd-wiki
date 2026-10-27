---
type: template
id: figureya-6rhrsv2--forest
title: 亚组分析森林图
status: draft
layouts: []
sources:
- recipes/figureya-6rhrsv2
panels: []
language: r
license: CC-BY-NC-SA-4.0
tags:
- survival-analysis
chart_types:
- forest
keywords:
- subgroup analysis
- forestplot
- hazard ratio
favorite: false
---
# 亚组分析森林图

> 许可：CC BY-NC-SA 4.0（FigureYa，Lu X, et al. iMetaMed 2025, doi:10.1002/imm3.70005）。仅限非商业使用，署名并引用；改编代码须相同方式共享；`code/` 与 `example/` 不进 Git、不推送。

<!-- facts:start -->
- 来源：[[recipes/figureya-6rhrsv2|临床亚组分析森林图]]
- 语言：r
- 许可证：CC-BY-NC-SA-4.0
- 标签：survival-analysis
- 图型：[[chart-types/forest]]
- 输入接口：[[interfaces/subgroup-effect-table|亚组效应量汇总表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

已经算好的亚组效应量（HR/OR 等比值及 95% CI）画成带表格列的临床亚组森林图：亚组标题行（效应量留空，可带交互 P）与亚组行按显示顺序排列，行数任意；给出 n/percent/p 列时自动显示相应表格列，percent 决定方块大小。

## 不适用

需要从原始数据拟合 Cox/Logistic 或做交互检验（模板不计算，先用分析方法得到效应量表）；均值差等非比值效应时须设 `xlog: false`、`zero: 0` 并改表头；行数很多（>60）时考虑拆图。

## 知识关联检查

2026-10-27：查了 chart-types/forest 与全部模板、方法页。库内此前无森林图模板；[[recipes/figureya-193risktable]] 也画森林表但输入为表达矩阵与生存表，未合并。无产出亚组效应表的方法页，故不写 figure_relations。与上游差异：去掉上游的空白占位行与第 3 行在 1 处的占位点，表头与末行横线随行数定位（上游写死为第 30 行）。

## 数据要求

模板化后生成。

## 使用记录

<!-- user:start -->
<!-- user:end -->
