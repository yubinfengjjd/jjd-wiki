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
style_tier: variant
journal_style: Cai2026-npjPO
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
  - [[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：全部有向发送者×接收者亚群间显著互作计数矩阵及边际总和柱图可切换为 variant 计数热图；模板不做置换检验。；前提：所有细胞对采用同一置换检验显著性阈值统计 count；未测组合保留 NA。；适配：导出 interaction_counts.csv（SOURCE, TARGET, count）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/cellchat-count-heatmap/spec.json；运行证据：无
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
