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
style_tier: variant
journal_style: Cai2026-npjPO
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
  - [[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：两类细胞群间的多对配体-受体双轴连线与检验检出率气泡可切换为 variant 双轴连线图；模板不重算 CellPhoneDB p 值。；前提：连线仅表示数据库配对与统计支持，不代表物理结合或因果调控。；适配：导出 lr_bipartite_edges.csv（ligand, receptor, support, rate）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/lr-bipartite-bubble/spec.json；运行证据：无
  - [[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：关键免疫抑制基质亚群与耗竭 T 细胞间的检查点配受体支持度可切换为 variant 双轴连线气泡图；模板不重算检验。；前提：明确展示的配体-受体对来源与检出率计算分母（tested pairs）。；适配：导出 lr_bipartite_edges.csv（ligand, receptor, support, rate）。
    - 关系证据：methods/immune-infiltration-tme.md#输出；templates/lr-bipartite-bubble/spec.json；运行证据：无
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
