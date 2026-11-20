---
type: template
id: compartment-dual-track-bars
title: 表皮真皮双区室堆叠条图
status: draft
layouts: []
sources:
- methods/cell-proportion-composition
panels: []
language: python
primary_method: cell-proportion-composition
style_tier: variant
journal_style: Cancer Discovery
tags:
- single-cell
chart_types:
- stacked-bar-flow
keywords:
- compartment
- epidermis
- dermis
- stacked-bar
- Cancer Discovery
favorite: false
---
# 表皮真皮双区室堆叠条图

![[templates/compartment-dual-track-bars/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/stacked-bar-flow]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

对比两种组织空间区室（如上层 `Epidermis` 与下层 `Dermis`）在多个疾病进展分期（如 `MIS`、`Normal`、`IM`）下的多谱系分层（`Stroma`、`Myeloid`、`Lymphoid`）细胞构成水平堆叠条形图。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 7G-bars 与 Fig. S7I-bars 同质合并画风。

## 不适用

不适用于单区室常规分组比例堆叠流带图（请用同槽位默认模板 [[templates/cell-prop-flow-bar]]）或邻域功能饼图组合（请用 [[templates/rcn-horizontal-bar-pie]]）；本模板仅绘制已归一化的区室组成比例，不做样本级假设检验。示例数据直接取自 `pmc9167783` 实测 `fig7fg_compartment_cell_composition.csv`。

## 知识关联检查

2026-11-21：将 Nirmal 2022 中视觉同质的 Fig. 7G-bars 与 Fig. S7I-bars 归并提炼为 1 套代表性模板，主归属方法 [[methods/cell-proportion-composition]]，挂入输出槽位 `(cell-proportion-composition, stacked-bar-flow)`。因该槽位已有默认模板 [[templates/cell-prop-flow-bar]]，本模板设为 `style_tier: variant`（`journal_style: Cancer Discovery`），并与同槽位模板对齐受控标签 `[single-cell]`。

## 数据要求

### composition（compartment_cell_composition.csv）：双组织区室在各分期下的细胞类型构成表 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| Stage | str | 进展分期或条件标签 |
| compartment_proxy | str | 组织区室标识（如 Epidermis / Dermis） |

## 使用记录

<!-- user:start -->
<!-- user:end -->
