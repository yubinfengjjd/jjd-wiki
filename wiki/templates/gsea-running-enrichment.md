---
type: template
id: gsea-running-enrichment
title: 富集跑分曲线与条码图
status: ready
layouts: []
sources:
- methods/gene-set-enrichment
panels: []
language: python
primary_method: gene-set-enrichment
style_tier: default
journal_style: Cancer Discovery
tags:
- transcriptomics
chart_types:
- gsea-curve
keywords:
- GSEA
- running-enrichment-score
- NES
- FDR
- Cancer Discovery
favorite: false
---
# 富集跑分曲线与条码图

![[templates/gsea-running-enrichment/preview.png]]

<!-- facts:start -->
- 来源：[[methods/gene-set-enrichment|基因集富集分析]]
- 语言：python
- 标签：transcriptomics
- 图型：[[chart-types/gsea-curve]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/gene-set-enrichment|基因集富集分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-21 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：全基因排序 GSEA 富集分析的逐位置 Running Enrichment Score 曲线、峰值位置、命中条码与 NES/FDR 统计可整理为 default 跑分曲线图；模板不重算 GSEA 置换检验。；前提：须明确基因排序依据（如 DESeq2 Wald stat / log2FC）及 GSEA 统计摘要中的基因集名称、NES 与校正口径。；适配：导出 gsea_running_es_curves.csv（x, runningScore, position, 可选 panel）与 gsea_summary.csv（Description, NES, p.adjust）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/gsea-running-enrichment/spec.json；templates/gsea-running-enrichment/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

展示基因集富集分析（GSEA）的经典单通路累计富集跑分曲线（Running Enrichment Score）：含 `y = 0` 虚线基准、峰值位置垂直虚线导引、底部命中基因位置条形码（barcode rug）以及右上角 `FDR` / `P` 与 `NES` 统计标注。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6E / Fig. S6C / Fig. S7B 同质归并画风。

## 不适用

不适用于超几何检验（ORA）的多通路气泡矩阵或横向条形图（请分别使用 [[templates/kegg-cluster-bubble]] 与 [[templates/cluster-kegg-bars]]）；本模板直接渲染 `clusterProfiler::GSEA` 导出的排秩曲线与统计摘要，不在模板内部重算置换检验。示例数据直接切片自 `pmc9167783` 实测 `gsea_running_es_curves.csv`（保留全部命中基因位置并等距抽样使文件 `< 500 KB`）与 `gsea_summary.csv`。

## 知识关联检查

2026-11-21：将 Nirmal 2022 中 3 个同质 GSEA 面板（Fig. 6E, S6C, S7B）归并提炼为 1 套代表性模板，主归属方法 [[methods/gene-set-enrichment]]，挂入输出槽位 `(gene-set-enrichment, gsea-curve)`。因该槽位此前为空槽位，本模板置为 `style_tier: default`（`journal_style: Cancer Discovery`），受控标签为 `[transcriptomics]`。

## 数据要求

### curves（gsea_running_es_curves.csv）：GSEA 逐排秩基因 running enrichment score 曲线与命中位置表（x, runningScore, position, 可选 panel/pathway） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| x | int | 必需 | 排序基因列表中的位置索引 |
| runningScore | float | 必需 | 累计富集得分（Running Enrichment Score） |
| position | int | 必需 | 是否命中目标基因集（1=命中，0=未命中） |
| panel | str | 可选 | 面板或通路筛选标识（多曲线表时用于按 panel 选择） |

### summary（gsea_summary.csv）：GSEA 通路富集统计摘要表（含 Description, NES, p.adjust / pvalue, 可选 panel） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| Description | str | 必需 | 基因集名称 |
| NES | float | 必需 | 标准化富集得分（Normalized Enrichment Score） |
| p.adjust | float | 可选 | 多重检验校正后 FDR/padj 值 |

### 可覆盖的 style

- `panel_id`：`"Fig6E"`
- `title`：`""`
- `line_color`：`"#E35B3A"`
- `rug_color`：`"#3A3A3A"`
- `p_label_mode`：`"fdr"`
- `dpi`：`300`
- `width_in`：`3.0`
- `height_in`：`2.9`
- `rect`：`[0.22, 0.2, 0.72, 0.68]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
