---
type: template
id: pathway-zscore-heatmap
title: 功能基因与通路Zscore热图
status: ready
layouts: []
sources:
- methods/gene-set-enrichment
panels: []
language: r
primary_method: gene-set-scoring
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

![[templates/pathway-zscore-heatmap/preview.png]]

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

### matrix（zscore_matrix.csv）：首列为标识列（feature 或 canonical_subcluster），其余数值列为Z-score表达或PROGENy通路活性矩阵 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| feature | str | 可选 | 行名标识（若首列为 canonical_subcluster 则自动转置以匹配横轴亚群） |

### 可覆盖的 style

- `z_cap`：`2.0`
- `palette`：`"functional"`
- `column_groups`：`{}`
- `cluster_rows`：`true`
- `cluster_cols`：`true`
- `transpose_subcluster_cols`：`true`
- `dpi`：`300`
- `width_in`：`6.4`
- `height_in`：`5.2`

## 使用记录

<!-- user:start -->
<!-- user:end -->
