---
type: template
id: stage-stacked-prop-bar
title: 演进分期百比堆叠构成条形图
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
- stacked-bar
- RCN
- cell-proportion
- progression-stage
favorite: false
---
# 演进分期百比堆叠构成条形图

![[templates/stage-stacked-prop-bar/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/stacked-bar-flow]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各演进分期下多类细胞邻域（RCN1-10）或细胞表型的归一化构成比例可切换为无流带纯净 100% 堆叠柱状图。；前提：每一分期（行）的各亚群比例之和须归一化为 1。；适配：导出 stage_rcn_proportions.csv（Stage 及各亚群比例列）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/stage-stacked-prop-bar/spec.json；运行证据：无
<!-- facts:end -->

## 适用

展示各疾病演进分期（如 N、P、MIS、IM）或分组下多类空间细胞邻域（RCN1–10）或细胞表型的 100% 堆叠构成比例，无跨柱流带连线、柱间保留紧凑留白、顶部排列多列色块图例。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 3D / 7F / S7F / S7G 画风。

## 不适用

不适用于需要展示相邻时间点跨柱流带轨迹的图景（请用默认模板 [[templates/cell-prop-flow-bar]]）或表皮/真皮双轨镜像对比（请用 [[templates/compartment-dual-track-bars]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-proportion-composition]]，挂入 `(cell-proportion-composition, stacked-bar-flow)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与同槽位默认带流带模板 [[templates/cell-prop-flow-bar]] 形成“带连线流带 vs 纯净分期堆叠柱”互补切换。

## 数据要求

### proportions（stage_rcn_proportions.csv）：各分期细胞邻域/亚群组成比例宽表（Stage 及各亚群比例列，每行和为 1） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| Stage | str | 必需 | 疾病分期或样本分组（如 Normal, Precursor, MIS, IM） |
| RCN1 | float | 可选 | RCN1 比例 |
| RCN2 | float | 可选 | RCN2 比例 |
| RCN3 | float | 可选 | RCN3 比例 |
| RCN4 | float | 可选 | RCN4 比例 |
| RCN5 | float | 可选 | RCN5 比例 |
| RCN6 | float | 可选 | RCN6 比例 |
| RCN7 | float | 可选 | RCN7 比例 |
| RCN8 | float | 可选 | RCN8 比例 |
| RCN9 | float | 可选 | RCN9 比例 |
| RCN10 | float | 可选 | RCN10 比例 |

### 可覆盖的 style

- `bar_width`：`0.72`
- `legend_cols`：`4`
- `ylabel`：`"Proportion"`
- `dpi`：`300`
- `width_in`：`3.2`
- `height_in`：`3.8`
- `rect`：`[0.2, 0.1, 0.74, 0.66]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
