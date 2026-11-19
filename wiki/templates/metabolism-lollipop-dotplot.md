---
type: template
id: metabolism-lollipop-dotplot
title: 多亚群代谢通路棒棒糖图
status: ready
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
- lollipop
keywords: []
favorite: false
style_tier: variant
journal_style: Cai2026-npjPO
---
# 多亚群代谢通路棒棒糖图

![[templates/metabolism-lollipop-dotplot/preview.png]]

<!-- facts:start -->
- 来源：[[methods/gene-set-enrichment|基因集富集分析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/lollipop]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/gene-set-enrichment|基因集富集分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：代谢通路富集结果（Fold enrichment + -log10(P) + 亚群彩点）可切换为 variant 棒棒糖点图展示；模板不执行富集检验。；前提：GeneRatio 与 BgRatio 比值计算透明一致，不混用原始 P 与校正 P。；适配：导出 metabolism_lollipop.csv（cluster, pathway, neg_log10_pval, fold_enrichment）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/metabolism-lollipop-dotplot/spec.json；运行证据：无
  - [[methods/gene-set-scoring|基因集与通路签名打分]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各亚群 Top 代谢通路富集/打分强度与倍数变化可切换为 variant 棒棒糖点图；模板不重算打分。；前提：统一背景与归一化口径；相同通路跨亚群横向比较须保持同一评分标准。；适配：导出 metabolism_lollipop.csv（cluster, pathway, neg_log10_pval, fold_enrichment）。
    - 关系证据：methods/gene-set-scoring.md#输出；templates/metabolism-lollipop-dotplot/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按亚群比较代谢通路富集的显著性及效应量，横轨显示该通路最强的显著性位置。参考 Cai 等主图 4K、5K 和附图 2E 的版式。

## 不适用

不要把 KEGG 富集代理解释为代谢通量或 scMetabolism 活性。不同检验或不同含义的点径值应分开绘制。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/gene-set-enrichment]]。

## 数据要求

### metab（metabolism_lollipop.csv）：多亚群代谢通路棒棒糖表（pathway、cluster、neg_log10_p、score） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| pathway | str | 代谢通路名称 |
| cluster | str | 细胞亚群名 |
| neg_log10_p | float | -log10(P-value) 或 logp |
| score | float | 点大小数值（如 FoldEnrichment / logFC） |

### 可覆盖的 style

- `top_n`：`18`
- `dpi`：`300`
- `width_in`：`8.4`
- `height_in`：`5.8`

## 使用记录

<!-- user:start -->
<!-- user:end -->
