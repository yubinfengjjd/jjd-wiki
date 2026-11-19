---
type: template
id: kegg-cluster-bubble
title: 多亚群KEGG通路气泡矩阵
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
- dotplot
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 多亚群KEGG通路气泡矩阵

<!-- facts:start -->
- 来源：[[methods/gene-set-enrichment|基因集富集分析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/dotplot]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/gene-set-enrichment|基因集富集分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：多亚群 KEGG/GO 通路富集结果可整理为气泡矩阵（default 主推跨亚群对比画风）；模板不执行富集检验。；前提：所有亚群须采用一致的背景基因集、显著性阈值与多重检验校正规则。；适配：导出 kegg_cluster_bubble.csv（pathway, cluster, count, logp）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/kegg-cluster-bubble/spec.json；运行证据：无
<!-- facts:end -->

## 适用

比较各细胞亚群的 KEGG 通路富集结果。Cai 等附图 2D 使用气泡矩阵展示 Fib 的富集条目。

## 不适用

输入仅含基因列表或活性分数时需先做富集分析。比较各亚群时应统一背景集、检验及多重校正规则。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/gene-set-enrichment]]。

## 数据要求

`kegg_cluster_bubble.csv` 每行一个 `pathway` × `cluster` 组合，含 `count`（命中基因数）及 `logp`（−log10(P) 或 −log10(校正 P)，全表二选一）。缺失的组合留空。

## 使用记录

<!-- user:start -->
<!-- user:end -->
