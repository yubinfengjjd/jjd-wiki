---
type: template
id: spatial-cooccurrence-matrix
title: 空间邻域置换检验离散三态共现矩阵
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
- spatial-cooccurrence
- permutation-test
- avoidance
- TCC
favorite: false
---
# 空间邻域置换检验离散三态共现矩阵

![[templates/spatial-cooccurrence-matrix/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：空间滞后簇（TCC1-10）与邻近免疫/基质细胞的 1,000 次空间置换检验结果可绘制为共现/排斥/非显著离散三态矩阵。；前提：置换检验双侧显著性（P < 0.05）及 Z 分数方向须在上游汇总为 Co-occurrence / Avoidance / Non-Sig。；适配：导出 spatial_cooccurrence_states.csv（TCC, neighbour, sig_state）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-cooccurrence-matrix/spec.json；运行证据：无
<!-- facts:end -->

## 适用

展示空间滞后聚簇（如 TCC1–10）与微环境免疫/基质细胞或相邻聚簇之间的空间置换检验（1,000 permutations）显著性结果：将每一对空间关系编码为离散三态色块——显著共现 `Co-occurrence`（亮黄 `#EAE33C`）、显著排斥 `Avoidance`（深紫 `#3D164A`）与非显著 `Non-Sig (P >= 0.05)`（中性灰 `#8E8E8E`）。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. S5C 画风。

## 不适用

不适用于展示连续相关性矩阵或连续 P 值梯度（请用 [[templates/pvalue-threshold-heatmap]] 或 [[templates/rcn-composition-stacked-heatmap]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，挂入 `(spatial-transcriptomics-microenvironment, heatmap)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与同槽位默认模板 [[templates/rcn-composition-stacked-heatmap]] 及 P 值矩阵变体 [[templates/pvalue-threshold-heatmap]] 共享主标签 `single-cell`。

## 数据要求

### cooccurrence（spatial_cooccurrence_states.csv）：空间邻域置换检验共现/排斥离散状态表（TCC, neighbour, sig_state，可选 z_score, p_value） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| TCC | str | 必需 | 列方向主空间簇名称（如 TCC1..TCC10） |
| neighbour | str | 必需 | 行方向邻域细胞类型或空间簇名称 |
| sig_state | str | 必需 | 显著性三态分类（Co-occurrence / Avoidance / Non-Sig） |
| z_score | float | 可选 | 置换检验 Z 分数（可选） |
| p_value | float | 可选 | 置换检验双侧 P 值（可选） |

### 可覆盖的 style

- `title`：`"Co-occurrence of spatial lag clusters"`
- `cooccur_color`：`"#EAE33C"`
- `avoid_color`：`"#3D164A"`
- `nonsig_color`：`"#8E8E8E"`
- `dpi`：`300`
- `width_in`：`5.2`
- `height_in`：`3.8`
- `rect`：`[0.22, 0.14, 0.74, 0.76]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
