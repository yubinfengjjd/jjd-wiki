---
type: template
id: coexpr-hub-radial-network
title: 枢纽基因共表达放射网络图
status: draft
layouts: []
sources:
- methods/coexpression-ppi-network
panels: []
language: python
primary_method: coexpression-ppi-network
style_tier: default
journal_style: Cancer Discovery
tags:
- transcriptomics
- network-pharmacology
chart_types:
- network
keywords:
- co-expression
- Pearson-network
- S100B
- hub-gene
- Cancer Discovery
favorite: false
---
# 枢纽基因共表达放射网络图

![[templates/coexpr-hub-radial-network/preview.png]]

<!-- facts:start -->
- 来源：[[methods/coexpression-ppi-network|共表达网络（WGCNA）与分子互作网络分析]]
- 语言：python
- 标签：transcriptomics、network-pharmacology
- 图型：[[chart-types/network]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/coexpression-ppi-network|共表达网络（WGCNA）与分子互作网络分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：标准化表达谱构建的 Pearson/WGCNA 共表达网络节点坐标、边表与枢纽基因一步邻域标记可直接渲染为 default 焦橙核心放射网络图；模板不拟合相关矩阵。；前提：节点与边来自同一相关阈值过滤后的连通分量；明确相关性阈值（如 r >= 0.6）。；适配：导出 network_nodes.csv（gene_symbol, x, y, in_s100b_1step, is_key_label）与 network_edges.csv（from, to, weight）。
    - 关系证据：methods/coexpression-ppi-network.md#输出；templates/coexpr-hub-radial-network/spec.json；运行证据：无
<!-- facts:end -->

## 适用

在整体高相关共表达网络（如 Pearson `r >= 0.6`）背景中以焦橙色高亮显示中心枢纽基因的一步邻域子模块，并在四周自动无重叠放射状排布关键基因白底圆角胶囊斜体标签与统计摘要（总节点/总边数）。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6I 风格。

## 不适用

本模板直接消费已构建好的网络节点坐标与边表，不执行相关矩阵拟合或力导向布局计算；需要多组 WGCNA 模块球形分组或蛋白互作多轨弦图时，请参考 [[templates/coexpr-sphere-network]]。示例数据取自 `GSE171888` PickSeq 120 mROIs 实测 Pearson 网络（207 个节点、1,374 条边）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/coexpression-ppi-network]]，槽位 `(coexpression-ppi-network, network)` 此前尚无 `default` 模板（`coexpr-sphere-network` 为无分层基础版），故设为 `style_tier: default` 并挂载至方法页 `figure_relations`。

## 数据要求

### nodes（network_nodes.csv）：共表达网络节点表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene_symbol | str | 必需 | 基因名称 |
| x | float | 必需 | 节点横坐标 |
| y | float | 必需 | 节点纵坐标 |
| in_s100b_1step | bool | 必需 | 是否属于枢纽基因一步邻域模块 |
| is_key_label | bool | 可选 | 是否放射状显示胶囊基因标签 |

### edges（network_edges.csv）：共表达网络边表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| from | str | 必需 | 起点基因 |
| to | str | 必需 | 终点基因 |
| weight | float | 可选 | 相关系数权重 |

### 可覆盖的 style

- `hub_gene`：`"S100B"`
- `r_threshold`：`0.6`
- `half_w`：`11.5`
- `half_h`：`10.5`
- `dpi`：`300`
- `width_in`：`5.2`
- `height_in`：`4.0`

## 使用记录

<!-- user:start -->
<!-- user:end -->
