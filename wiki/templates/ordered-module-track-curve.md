---
type: template
id: ordered-module-track-curve
title: 排序样本共表达模块曲线与分期色带图
status: ready
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
chart_types:
- trend
keywords:
- coexpression-module
- ordered-curve
- S100B
- stage-track
favorite: false
---
# 排序样本共表达模块曲线与分期色带图

![[templates/ordered-module-track-curve/preview.png]]

<!-- facts:start -->
- 来源：[[methods/coexpression-ppi-network|共表达网络（WGCNA）与分子互作网络分析]]
- 语言：python
- 标签：transcriptomics
- 图型：[[chart-types/trend]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/coexpression-ppi-network|共表达网络（WGCNA）与分子互作网络分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：共表达模块（如 S100B 模块）在按分期与活性排序的微区域/样本上的平均表达轨迹可与底部组织学分期色带组合展示。；前提：mean_log2_norm 为模块内基因在各样本上的平均对数归一化表达量。；适配：导出 ordered_module_expression.csv（sample_id, site, mean_log2_norm）。
    - 关系证据：methods/coexpression-ppi-network.md#输出；templates/ordered-module-track-curve/spec.json；运行证据：无
<!-- facts:end -->

## 适用

将所有样本/空间微区域（mROI）按组织学演进分期（如 MIS、IR、bTIL、IB、IM、EM）及模块表达量排序，在上方绘制共表达模块（如 S100B 模块）均值表达折线散点轨迹，在紧贴底部的窄轨绘制各样本所属组织分期色带，直观展示模块活性在特定分期的跳变富集。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6J 画风。

## 不适用

不适用于展示模块内部基因共表达拓扑连边结构（请用 [[templates/coexpr-hub-radial-network]] 或 [[templates/coexpr-sphere-network]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/coexpression-ppi-network]]，挂入 `(coexpression-ppi-network, trend)` 输出槽位（该槽位首个模板，标为 `style_tier: default`, `journal_style: Cancer Discovery`），补齐共表达模块跨样本演进轨迹与底部注释色带组合图型。

## 数据要求

### curve（ordered_module_expression.csv）：各样本/mROI 的共表达模块平均表达量与所属分期表（sample_id, site, mean_log2_norm） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| sample_id | str | 样本或微区域唯一标识 |
| site | str | 所属组织学分期或区域类型（如 MIS, IR, bTIL, IB, IM, EM） |
| mean_log2_norm | float | 模块基因平均 log2 归一化表达量 |

### 可覆盖的 style

- `ylabel`：`"Mean expression (log$_2$)\nS100B module"`
- `xlabel`：`"mROI"`
- `point_size`：`9.0`
- `dpi`：`300`
- `width_in`：`4.8`
- `height_in`：`3.2`
- `rect`：`[0.18, 0.12, 0.78, 0.8]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
