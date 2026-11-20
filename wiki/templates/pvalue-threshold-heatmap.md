---
type: template
id: pvalue-threshold-heatmap
title: 分期两两比较显著性阈值数值热图
status: draft
layouts: []
sources:
- methods/spatial-transcriptomics-microenvironment
panels: []
language: python
primary_method: spatial-transcriptomics-microenvironment
style_tier: variant
journal_style: Cancer Discovery
tags:
- single-cell
- transcriptomics
chart_types:
- heatmap
keywords:
- p-value-heatmap
- pairwise-comparison
- RCN
- significance-threshold
favorite: false
---
# 分期两两比较显著性阈值数值热图

![[templates/pvalue-threshold-heatmap/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各空间细胞邻域（RCN1-10）在演进分期两两比较下的统计检验 P 值可绘制为 P < 0.05 暖色渐变与 ns 灰块阈值数值热图。；前提：P 值由上游分期两两统计检验给出（0-1），模板按 alpha_threshold 分割着色。；适配：导出 stage_pairwise_pvalues.csv（RCN, comparison, p_value）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/pvalue-threshold-heatmap/spec.json；运行证据：无
<!-- facts:end -->

## 适用

将多个空间细胞邻域（RCN1–10）在各演进分期两两比较（如 N v P、P v MIS、P v IM、MIS v IM）下的统计检验 P 值绘制为阈值分割数值矩阵：显著格（`P < 0.05`）按深红至青绿连续色标（`#BA242A -> #D96F56 -> #83C8BE`）着色，非显著格（`P >= 0.05`）统一填充中性灰（`#A6A6A6`）并在格内印出精确 3 位小数 P 值，底部配 `0–0.05` 色标条与 `ns` 灰块图例。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. S3E 画风。

## 不适用

不适用于展示 RCN 内部细胞表型丰度聚类与分期比例复合热图（请用同槽位默认模板 [[templates/rcn-composition-stacked-heatmap]]）或离散三态共现/排斥置换检验矩阵（请用 [[templates/spatial-cooccurrence-matrix]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，挂入 `(spatial-transcriptomics-microenvironment, heatmap)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与同槽位默认模板 [[templates/rcn-composition-stacked-heatmap]] 共享主标签 `single-cell`。

## 数据要求

### pvalues（stage_pairwise_pvalues.csv）：各空间邻域在分期两两比较下的 P 值表（RCN, comparison, p_value，可选 diff_mean） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| RCN | str | 必需 | 空间细胞邻域或亚群名称（如 RCN1..RCN10） |
| comparison | str | 必需 | 分期两两比较键（如 Normal_vs_Precursor） |
| p_value | float | 必需 | 统计检验 P 值 |
| diff_mean | float | 可选 | 组间均值差（可选） |

### 可覆盖的 style

- `title`：`"Differences between stages"`
- `alpha_threshold`：`0.05`
- `ns_color`：`"#A6A6A6"`
- `dpi`：`300`
- `width_in`：`3.4`
- `height_in`：`4.6`
- `rect`：`[0.1, 0.06, 0.74, 0.8]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
