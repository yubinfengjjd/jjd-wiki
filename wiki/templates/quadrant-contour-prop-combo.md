---
type: template
id: quadrant-contour-prop-combo
title: 二维核密度等高线四象限与比例组合图
status: draft
layouts: []
sources:
- methods/cell-proportion-composition
panels: []
language: python
primary_method: cell-proportion-composition
style_tier: default
journal_style: Cancer Discovery
tags:
- single-cell
- experimental-statistics
chart_types:
- density-scatter
keywords:
- 2D-KDE
- quadrant-gating
- contour-scatter
- stacked-proportion
favorite: false
---
# 二维核密度等高线四象限与比例组合图

![[templates/quadrant-contour-prop-combo/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：python
- 标签：single-cell、experimental-statistics
- 图型：[[chart-types/density-scatter]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：双标志物二维核密度等高线四象限门控散点可与象限细胞构成百分比堆叠柱并排联动展示。；前提：双标志物强度须统一缩放至 [0, 1] 并按预设阈值（如 0.5）划分四象限。；适配：导出 bivariate_density_cells.csv 与 quadrant_proportions.csv。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/quadrant-contour-prop-combo/spec.json；运行证据：无
<!-- facts:end -->

## 适用

在左侧绘制双标志物（如分化标志 MART1/MITF vs 增殖标志 CCND1/KI67 归一化强度）二维核密度等高线散点图与 `(0.5, 0.5)` 十字象限门控线，在右侧紧邻并排绘制四个功能象限（`hi/lo` 组合）的 100% 堆叠百分比条形图及底部双列象限图例。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. S5D 画风。

## 不适用

不适用于回归模型连续预测值对观测值的含边际直方图散点评估（请改用 [[templates/pred-density-scatter]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-proportion-composition]]，挂入 `(cell-proportion-composition, density-scatter)` 输出槽位（该槽位首个模板，标为 `style_tier: default`, `journal_style: Cancer Discovery`），沉淀单细胞/空间蛋白双标志物象限门控与构成比例联动图型。

## 数据要求

### cells（bivariate_density_cells.csv）：单细胞双标志物归一化坐标与所属象限表（cell_uid, Stage, x_scaled, y_scaled, quadrant） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_uid | str | 必需 | 细胞唯一标识 |
| Stage | str | 可选 | 所属演进分期 |
| x_scaled | float | 必需 | 纵轴标志物（如 CCND1/KI67）0-1 归一化强度 |
| y_scaled | float | 必需 | 横轴标志物（如 MART1/MITF）0-1 归一化强度 |
| quadrant | str | 必需 | 象限分类键 |

### quadrants（quadrant_proportions.csv）：各分期四象限细胞计数与百分比汇总表（Stage, quadrant, n_cells, pct_in_stage） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| Stage | str | 必需 | 所属演进分期 |
| quadrant | str | 必需 | 象限分类键 |
| n_cells | int | 必需 | 象限内细胞数 |
| pct_in_stage | float | 必需 | 象限占比百分比（0-100） |

### 可覆盖的 style

- `title`：`"Cell states (CCND1 vs MART1)"`
- `xlabel`：`"Scaled MART1 (MITF proxy)"`
- `ylabel`：`"Scaled CCND1 (KI67 proxy)"`
- `gate_x`：`0.5`
- `gate_y`：`0.5`
- `dpi`：`300`
- `width_in`：`4.4`
- `height_in`：`3.6`
- `rect`：`[0.15, 0.06, 0.8, 0.8]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
