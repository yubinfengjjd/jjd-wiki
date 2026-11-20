---
type: template
id: stage-boxplot-jitter-sig
title: 演进分期箱线抖动散点与显著性图
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
- boxplot
keywords:
- boxplot
- jitter
- progression-stage
- significance-bracket
favorite: false
---
# 演进分期箱线抖动散点与显著性图

![[templates/stage-boxplot-jitter-sig/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：python
- 标签：single-cell、experimental-statistics
- 图型：[[chart-types/boxplot]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各视野/样本在演进分期下的特定细胞亚群或双阳性比例可绘制为分期箱线+抖动散点+红色显著性星号横线。；前提：每个散点必须对应独立样本或独立 ROI（sample_id），严禁以单细胞为重复单位做 t 检验。；适配：导出 stage_proportion_points.csv（sample_id, stage, value）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/stage-boxplot-jitter-sig/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按疾病演进分期（如 N、P、MIS、IM）展示特定细胞亚群或双阳性表型在各视野（ROI/样本）中的占比分布，叠加半透明分期配色箱线图、黑色抖动散点以及顶部红色显著性星号横线（`#E31A1C`）与非显著黑色 `ns` 横线。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 2C / S3B 画风。

## 不适用

不适用于多基因并排均值±SEM 柱状比较（请用 [[templates/group-bar-jitter-sig]]）或对数空间距离分布（请用 [[templates/stage-distance-boxen-grid]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-proportion-composition]]，挂入 `(cell-proportion-composition, boxplot)` 输出槽位（该槽位首个模板，标为 `style_tier: default`, `journal_style: Cancer Discovery`），填补细胞比例/阳性率按疾病演进分期箱线比较的风格空白。

## 数据要求

### data（stage_proportion_points.csv）：各演进分期 ROI/样本比例观测表（sample_id, stage, value） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| sample_id | str | 必需 | 样本或 ROI 唯一编号 |
| stage | str | 必需 | 演进分期或分组标签（如 N, P, MIS, IM） |
| value | float | 必需 | 细胞亚群或标志物阳性比例（0-1 或百分比） |

### 可覆盖的 style

- `title`：`"S100A expression"`
- `ylabel`：`"Fraction SOX10$^+$ cells\nalso S100A$^+$"`
- `point_size`：`14.0`
- `dpi`：`300`
- `width_in`：`3.4`
- `height_in`：`2.9`
- `rect`：`[0.24, 0.14, 0.68, 0.72]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
