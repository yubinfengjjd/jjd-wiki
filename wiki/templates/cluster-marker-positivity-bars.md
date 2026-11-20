---
type: template
id: cluster-marker-positivity-bars
title: 多亚群多标志物水平阳性率条形矩阵
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
- bar
keywords:
- horizontal-bar
- marker-positivity
- TCC
- CyCIF
favorite: false
---
# 多亚群多标志物水平阳性率条形矩阵

![[templates/cluster-marker-positivity-bars/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/bar]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各细胞亚群/空间簇在多个功能标志物上的阳性细胞比例可绘制为多列水平条形分面矩阵。；前提：阳性比例按各亚群内超过门控阈值的细胞占比汇总（0-100 或 0-1）。；适配：导出 cluster_marker_positivity.csv（TCC 及各标志物阳性率列）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/cluster-marker-positivity-bars/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按多个标志物（如 S100A⁺、MART1⁺、CCND1⁺、MYC⁺、HLA-II⁺）水平并排分面展示各细胞亚群/空间簇（如 TCC1–10）的阳性细胞比例（`0–1`），每一行对应一个亚群并按亚群专属调色板着色。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 5F 画风。

## 不适用

不适用于单一指标样本计数条形图（请用默认模板 [[templates/scp-count-bar]]）或组织构成+箱线组合图（请用 [[templates/tissue-ratio-prop-combo]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-proportion-composition]]，挂入 `(cell-proportion-composition, bar)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与默认模板 [[templates/scp-count-bar]] 共享受控主标签 `single-cell`。

## 数据要求

### positivity（cluster_marker_positivity.csv）：各细胞亚群在多个标志物上的阳性百分比宽表（TCC 及各标志物阳性率 0-100 列） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| TCC | str | 必需 | 细胞亚群或空间簇名称（如 TCC1..TCC10） |
| S100a | float | 可选 | S100A+ 阳性细胞百分比 |
| MART1 | float | 可选 | MART1+ 阳性细胞百分比 |
| CCND1 | float | 可选 | CCND1+ 阳性细胞百分比 |
| MYC | float | 可选 | MYC+ 阳性细胞百分比 |
| HLADPB1 | float | 可选 | HLA-II+ 阳性细胞百分比 |

### 可覆盖的 style

- `xlabel`：`"Fraction of cells"`
- `ylabel`：`"TCCs"`
- `bar_height`：`0.76`
- `dpi`：`300`
- `width_in`：`4.2`
- `height_in`：`3.4`
- `rect`：`[0.14, 0.14, 0.82, 0.74]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
