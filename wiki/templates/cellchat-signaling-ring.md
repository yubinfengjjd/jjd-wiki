---
type: template
id: cellchat-signaling-ring
title: 通路定向细胞通讯弦图
status: draft
layouts: []
sources:
- methods/cell-cell-communication
panels: []
language: r
primary_method: cell-cell-communication
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- single-cell
chart_types:
- chord
keywords:
- CellChat
- signaling-pathway
- circular-network
favorite: false
---
# 通路定向细胞通讯弦图

<!-- facts:start -->
- 来源：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/chord]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

展示特定信号通路（如 VEGF、CCL、CXCL）在全图谱亚群环形目录间的有向通讯网络，同时保留无连边的孤立目录节点与重点枢纽红标。对应 Cai 等附图 5D 的 52 节点环形网络风格。

## 不适用

不适用于展示具体配体–受体对矩阵或高维成对通讯总览；若要比较成对热图或具体 LR 概率，请改用 [[templates/cellchat-count-heatmap]] 或 [[templates/lr-bubble-matrix]]。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-cell-communication]]，作为 `variant` 风格模板（来源风格 `Cai2026-npjPO`），与默认矩阵风格 [[templates/lr-bubble-matrix]]、计数矩阵 [[templates/cellchat-count-heatmap]] 及双轴连线 [[templates/lr-bipartite-bubble]] 互补，专用于单通路全目录环形通讯连线与孤立节点保留。

## 数据要求

### nodes（ring_nodes.csv）：圆形通讯环全部目录节点（含孤立节点）、分组着色与枢纽高亮标记 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| node | str | 必需 | 细胞亚群或节点名称 |
| compartment | str | 可选 | 所属大类分区（用于默认离散着色） |
| color | str | 可选 | 可选自定义十六进制节点色 |
| is_hub | int | 可选 | 是否为重点高亮枢纽节点（1 为高亮红标，0 为常规） |

### edges（ring_edges.csv）：有向细胞间通讯边列表（from、to、weight） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| from | str | 必需 | 发送者细胞亚群（对应 nodes.node） |
| to | str | 必需 | 接收者细胞亚群（对应 nodes.node） |
| weight | float | 必需 | 通路通讯概率或汇总强度 |

### 可覆盖的 style

- `node_size`：`4.2`
- `label_size`：`2.25`
- `hub_label_color`：`"#D7191C"`
- `default_label_color`：`"#252229"`
- `dpi`：`300`
- `width_in`：`7.6`
- `height_in`：`7.4`

## 使用记录

<!-- user:start -->
<!-- user:end -->
