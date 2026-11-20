---
type: template
id: stage-track-block-heatmap
title: 分期色带分块通路热图
status: draft
layouts: []
sources:
- methods/gene-set-scoring
panels: []
language: python
primary_method: gene-set-scoring
style_tier: variant
journal_style: Cancer Discovery
tags:
- single-cell
- transcriptomics
chart_types:
- heatmap
keywords:
- ssGSEA
- Z-score
- stage-track
- block-heatmap
- Cancer Discovery
favorite: false
---
# 分期色带分块通路热图

![[templates/stage-track-block-heatmap/preview.png]]

<!-- facts:start -->
- 来源：[[methods/gene-set-scoring|基因集与通路签名打分]]
- 语言：python
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

展示多微区/临床样本（按病理分期或解剖部位 `MIS → IR → bTIL → IB → IM → EM` 排序并加顶部色带标注）在功能分块（如 `IFN`、`Tumor`、`Immune`、`Skin`）通路 ssGSEA 得分或核心基因 Z-score 上的连续热图。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6C / 6G / 7H / S7C / S7H 同质归并画风。

## 不适用

不适用于聚簇级含左右患者/分期堆叠比例柱的复合热图（请改用 [[templates/rcn-composition-stacked-heatmap]]）或含发表 DEG 空心圆叠加的亚群均值热图（请用同槽位默认模板 [[templates/pathway-zscore-heatmap]]）；本模板按 `sample_id` 精确连接并支持跨分期可视化，不重算 ssGSEA 或差异检验。示例数据直接取自 `pmc9167783` 实测 `fig6c_ssgsea_scores.csv` 与 `mrseq_meta_small.csv`。

## 知识关联检查

2026-11-21：将 Nirmal 2022 中 5 个视觉同质的顶部色带+分块得分/Z-score 热图面板（Fig. 6C, 6G, 7H, S7C, S7H）归并提炼为 1 套代表性模板，主归属方法 [[methods/gene-set-scoring]]，挂入输出槽位 `(gene-set-scoring, heatmap)`。因该槽位已存在默认模板 [[templates/pathway-zscore-heatmap]]，本模板设为 `style_tier: variant`（`journal_style: Cancer Discovery`），并与默认模板对齐受控英文标签 `[single-cell, transcriptomics]`。

## 数据要求

### scores（stage_heatmap_scores.csv）：特征 × 样本得分或 Z-score 矩阵 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| feature | str | 通路签名或基因名 |

### sample_meta（stage_sample_meta.csv）：样本分期/微区部位注释表 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| sample_id | str | 与得分矩阵列名按 key 对齐的样本标识 |
| site | str | 病理分期或解剖分区标签 |

## 使用记录

<!-- user:start -->
<!-- user:end -->
