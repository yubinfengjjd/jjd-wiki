---
type: template
id: fy-crosslink
title: 分组节点跨列连线图
status: ready
layouts: []
sources:
- recipes/figureya-199crosslink
panels: []
language: r
license: CC-BY-NC-SA-4.0
tags:
- experimental-statistics
- single-cell
chart_types:
- network
keywords:
- crosslink
- CellChat
- ggplot2
- columnCross2
- scales
favorite: false
primary_method: set-intersection-and-group-stats
---
# 分组节点跨列连线图

![[templates/fy-crosslink/preview.png]]

> 许可：CC-BY-NC-SA-4.0（由 [[recipes/figureya-199crosslink|分组节点跨列连线图]] 整理为独立可调用原生模板；`example/` 内含精简/虚拟测试数据用于端到端回归测试）。

<!-- facts:start -->
- 来源：[[recipes/figureya-199crosslink|分组节点跨列连线图]]
- 语言：r
- 许可证：CC-BY-NC-SA-4.0
- 标签：experimental-statistics、single-cell
- 图型：[[chart-types/network]]
- 输入接口：未声明 · 未声明 · 未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

适用于与 [[recipes/figureya-199crosslink|分组节点跨列连线图]] 相同图型与表格输入结构的科研可视化绘图；已将上游 R Markdown 抽离为独立可调用脚本 `code/render.R`，可通过 Studio 或 CLI 传入自定义表格。

## 不适用

模板脚本仅承接绘图渲染与既定展示统计，不替代上游全流程统计建模前提审查；若数据结构或列名与示例表差异较大，须先整理匹配列结构。

## 知识关联检查

派生自已过审 L1 配方 [[recipes/figureya-199crosslink]]，输入表采用模板内联表结构（`easy_input2_edges.csv`、`easy_input2_nodes.csv`、`easy_input_edges.csv`、`easy_input_nodes.csv`），已按 method-map 挂载至分析方法 [[methods/set-intersection-and-group-stats]]。

## 数据要求

输入表文件：`easy_input2_edges.csv`、`easy_input2_nodes.csv`、`easy_input_edges.csv`、`easy_input_nodes.csv`（详见 `spec.json` 与 `example/` 示例表）。

<!-- user:start -->
<!-- user:end -->
