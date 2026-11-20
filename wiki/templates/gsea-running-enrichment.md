---
type: template
id: gsea-running-enrichment
title: 富集跑分曲线与条码图
status: draft
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
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

展示基因集富集分析（GSEA）的经典单通路累计富集跑分曲线（Running Enrichment Score）：含 `y = 0` 虚线基准、峰值位置垂直虚线导引、底部命中基因位置条形码（barcode rug）以及右上角 `FDR` / `P` 与 `NES` 统计标注。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6E / Fig. S6C / Fig. S7B 同质归并画风。

## 不适用

不适用于超几何检验（ORA）的多通路气泡矩阵或横向条形图（请分别使用 [[templates/kegg-cluster-bubble]] 与 [[templates/cluster-kegg-bars]]）；本模板直接渲染 `clusterProfiler::GSEA` 导出的排秩曲线与统计摘要，不在模板内部重算置换检验。示例数据直接切片自 `pmc9167783` 实测 `gsea_running_es_curves.csv`（保留全部命中基因位置并等距抽样使文件 `< 500 KB`）与 `gsea_summary.csv`。

## 知识关联检查

2026-11-21：将 Nirmal 2022 中 3 个同质 GSEA 面板（Fig. 6E, S6C, S7B）归并提炼为 1 套代表性模板，主归属方法 [[methods/gene-set-enrichment]]，挂入输出槽位 `(gene-set-enrichment, gsea-curve)`。因该槽位此前为空槽位，本模板置为 `style_tier: default`（`journal_style: Cancer Discovery`），受控标签为 `[transcriptomics]`。

## 数据要求

### curves（gsea_running_es_curves.csv）：GSEA 排秩基因跑分曲线与命中条码表 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| x | int | 排序基因列表位置 |
| runningScore | float | 累计富集得分 |
| position | int | 基因集命中标记（1=命中，0=未命中） |
| panel | str | 可选面板或通路筛选键 |

### summary（gsea_summary.csv）：GSEA 统计摘要表 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| Description | str | 基因集描述名称 |
| NES | float | 标准化富集得分 |
| p.adjust | float | 多重检验校正 FDR |

## 使用记录

<!-- user:start -->
<!-- user:end -->
