---
type: template
id: lr-bubble-matrix
title: 配受体互作概率气泡矩阵
status: ready
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
style_tier: default
journal_style: Cai2026-npjPO
---
# 配受体互作概率气泡矩阵

![[templates/lr-bubble-matrix/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/bubble]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：有向细胞对（source->target）与配体-受体对的 CellChat/CellPhoneDB 互作概率可作为 default 主推气泡矩阵展示；模板不重算概率。；前提：同一统计阈值筛出的有向细胞对与 LR 对；缺失组合保持空位而不填零。；适配：导出 lr_bubble_matrix.csv（pair_label 或 source+target, interaction, prob, 可选 pval）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/lr-bubble-matrix/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按有向细胞对与配体–受体对展示 CellChat 等工具估计的互作强度。对应 Cai 等主图 2K、5J、6C/F 及附图 6D。

## 不适用

不适用于证明直接结合、因果通讯或比较不同算法的绝对分数。图中空格可来自数据缺失或显示筛选。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-cell-communication]]。

## 数据要求

### lr（lr_bubble_matrix.csv）：配受体互作矩阵表（pair_label 或 source+target、interaction、prob、pval） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| interaction | str | 必需 | 配受体对名称（如 COL1A1_CD44） |
| prob | float | 必需 | 通讯概率或平均互作强度 |
| pval | float | 可选 | 置换检验 p 值 |

### 可覆盖的 style

- `max_interactions`：`18`
- `max_pairs`：`22`
- `dpi`：`300`
- `width_in`：`7.6`
- `height_in`：`6.0`

## 使用记录

<!-- user:start -->
<!-- user:end -->
