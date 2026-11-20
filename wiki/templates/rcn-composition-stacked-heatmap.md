---
type: template
id: rcn-composition-stacked-heatmap
title: RCN 聚簇与分期堆叠复合热图
status: draft
layouts: []
sources:
- methods/spatial-transcriptomics-microenvironment
panels: []
language: python
primary_method: spatial-transcriptomics-microenvironment
style_tier: default
journal_style: Cancer Discovery
tags:
- single-cell
chart_types:
- heatmap
keywords:
- RCN
- Spatial-LDA
- K-means
- stacked-annotation
- Cancer Discovery
favorite: false
---
# RCN 聚簇与分期堆叠复合热图

![[templates/rcn-composition-stacked-heatmap/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：20 um 空间邻域 LDA/K-means（RCN）或空间滞后肿瘤群落（TCC）的特征 Z-score 可与患者、分期比例轨道合并展示为主推默认（default）复合热图；模板不执行聚类。；前提：主矩阵与左右轨道表须按 cluster_id 一一对齐；患者与分期比例按独立样本或连续 FOV 汇总。；适配：导出 rcn_cluster_zscore.csv 与 rcn_cluster_tracks.csv。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/rcn-composition-stacked-heatmap/spec.json；运行证据：无
<!-- facts:end -->

## 适用

展示空间邻域主题建模（Spatial LDA / K-means）或空间域聚类后，各子聚簇在细胞表型/蛋白程序上的 Z-score 层次聚类热图（含顶部列聚类树），并在左侧对齐患者构成堆叠条与大类括弧（如 `RCN1–10`）、右侧对齐进展分期堆叠条与簇编号。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 2D / Fig. 5C / Fig. S2E 风格。

## 不适用

不适用于不含左右双侧多维比例轨道的普通通路 Z-score 热图（请改用 [[templates/pathway-zscore-heatmap]]）；本模板只负责可视化已算好的聚簇 Z-score 与真实比例表，不执行 Spatial LDA 或 K-means 聚类。示例表直接取自 `lda_cluster30_composition.csv` 与 `fov_cells_with_rcn.csv`（`MEL09/MEL11` 1,418 个连续 FOV 真实细胞）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，槽位 `(spatial-transcriptomics-microenvironment, heatmap)`此前尚无 `default` 模板，故置为 `style_tier: default` 并挂载至方法页 `figure_relations`。

## 数据要求

### zscore_matrix（rcn_cluster_zscore.csv）：聚簇 × 特征 Z-score 宽表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| rcn_group | str | 必需 | 归并后 RCN/TCC 大类标签 |
| cluster_id | str | 必需 | 子聚簇编号 |

### cluster_tracks（rcn_cluster_tracks.csv）：患者与分期堆叠占比轨道表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cluster_id | str | 必需 | 与主矩阵对齐的聚簇编号 |
| rcn_group | str | 必需 | 大类标签 |

### 可覆盖的 style

- `z_min`：`-2.0`
- `z_max`：`2.0`
- `dpi`：`300`
- `width_in`：`6.4`
- `height_in`：`6.8`

## 使用记录

<!-- user:start -->
<!-- user:end -->
