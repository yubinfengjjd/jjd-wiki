---
type: template
id: pathway-zscore-heatmap
title: 功能基因与通路Zscore热图
status: draft
layouts: []
sources:
- methods/gene-set-enrichment
panels: []
language: r
primary_method: gene-set-enrichment
tags:
- single-cell
- transcriptomics
chart_types:
- heatmap
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 功能基因与通路Zscore热图

<!-- facts:start -->
- 来源：[[methods/gene-set-enrichment|基因集富集分析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/differential-expression|差异表达分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：差异基因（如趋化因子、MHC-I/II）在各亚群的 Z-score 标准化表达可与 DE 显著圆圈标记联合绘制为 variant 分组热图；模板不重算 DE。；前提：Z-score 为跨亚群行标准化均值；DE 圆圈标记须显式注明筛选阈值与对比口径。；适配：导出 pathway_zscore_heatmap.csv（cluster, feature, block, zscore, is_deg）。
    - 关系证据：methods/differential-expression.md#输出；templates/pathway-zscore-heatmap/spec.json；运行证据：无
  - [[methods/gene-set-scoring|基因集与通路签名打分]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：PROGENy 等通路活性或功能模块基因集跨亚群 Z-score 均值可切换为 variant 分块矩阵热图；模板不重算打分。；前提：Z-score 按亚群聚合后跨群标准化；不同打分算法的分数不可直接混在同一标尺。；适配：导出 pathway_zscore_heatmap.csv（cluster, feature, block, zscore, 可选 is_deg）。
    - 关系证据：methods/gene-set-scoring.md#输出；templates/pathway-zscore-heatmap/spec.json；运行证据：无
<!-- facts:end -->

## 适用

对齐不同亚群的功能基因 Z 分数或 PROGENy 通路活性，展示相对偏高与偏低的模式。对应 Cai 等主图 2、4、5 的功能矩阵。

## 不适用

原始计数、富集 P 值及不同标度的分数应在上游整理。缺失值过多时不要进行层次聚类，Z 分数也不能解释为绝对表达量。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/gene-set-enrichment]]。

## 数据要求

`zscore_matrix.csv` 的首列为唯一行标识，其余为数值矩阵。首列为 `canonical_subcluster` 时默认转置，使亚群位于横轴。可在样式中用 `column_groups` 提供横轴列名到分组标签的完整映射，组序按映射中的首次出现排列。默认采用功能基因配色，`palette: "progeny"` 可选 PROGENy 配色。

## 使用记录

<!-- user:start -->
<!-- user:end -->
