---
type: template
id: cellchat-signaling-ring
title: 通路定向细胞通讯弦图
status: ready
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

![[templates/cellchat-signaling-ring/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/chord]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：特定信号通路（如 VEGF）在全图谱亚群环形目录间的有向通讯弧线（含孤立目录节点）可切换为 variant 环形网络图。；前提：环形目录节点需包含全图谱所有比较亚群，避免因孤立节点被过滤而改变拓扑外观。；适配：导出 ring_nodes.csv（node, compartment, color, is_hub）与 ring_edges.csv（from, to, weight）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/cellchat-signaling-ring/spec.json；运行证据：无
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

| 列 | 类型 | 含义 |
|---|---|---|
| from | str | 发送者细胞亚群（对应 nodes.node） |
| to | str | 接收者细胞亚群（对应 nodes.node） |
| weight | float | 通路通讯概率或汇总强度 |

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
