---
type: template
id: monochrome-deseq-volcano
title: 极简棕褐单色差异表达火山图
status: draft
layouts: []
sources:
- methods/differential-expression
panels: []
language: python
primary_method: differential-expression
style_tier: variant
journal_style: Cancer Discovery
tags:
- transcriptomics
chart_types:
- volcano
keywords:
- DESeq2
- volcano
- differential-expression
- PickSeq
favorite: false
---
# 极简棕褐单色差异表达火山图

![[templates/monochrome-deseq-volcano/preview.png]]

<!-- facts:start -->
- 来源：[[methods/differential-expression|差异表达分析]]
- 语言：python
- 标签：transcriptomics
- 图型：[[chart-types/volcano]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/differential-expression|差异表达分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：DESeq2 差异表达结果表可切换为 Cancer Discovery 极简棕褐单色显著点（#9E623E）+ 浅灰背景 + 斜体 Top 基因标注火山图。；前提：log2FoldChange 与 padj 由上游 DESeq2/limma 给定，模板不重跑差异检验。；适配：导出 deseq2_volcano_results.csv（gene_symbol, log2FoldChange, padj）。
    - 关系证据：methods/differential-expression.md#输出；templates/monochrome-deseq-volcano/spec.json；运行证据：无
<!-- facts:end -->

## 适用

以《Cancer Discovery》极简双色风格展示 DESeq2 / limma 差异表达分析结果：所有显著差异基因（`|log2FC| >= lfc_cutoff` 且 `padj < padj_cutoff`）统一用暖棕褐色（`#9E623E`）高亮，背景非显著基因用浅灰（`#BDBDBD`）渲染，配十字虚线阈值线与自动防重叠斜体 Top 基因名标注。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6D 画风。

## 不适用

不适用于需要区分上调红/下调蓝或多阈值分级点大小的火山图（请切换至同槽位默认模板 [[templates/bulk-de-volcano]]）或单细胞阳性率差值火山图（请用 [[templates/scp-de-volcano]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/differential-expression]]，挂入 `(differential-expression, volcano)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与同槽位默认模板 [[templates/bulk-de-volcano]]（`Standard`）、[[templates/fy-bubble-volcano]]（`FigureYa`）及 [[templates/scp-de-volcano]]（`SCP`）对齐主标签 `transcriptomics`。

## 数据要求

### deg（deseq2_volcano_results.csv）：DESeq2 差异表达结果表（gene_symbol, log2FoldChange, padj，可选 baseMean, pvalue） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene_symbol | str | 必需 | 基因符号 |
| log2FoldChange | float | 必需 | log2 倍数变化 |
| padj | float | 必需 | 多重检验校正后 P 值（FDR） |
| baseMean | float | 可选 | 平均归一化计数 |
| pvalue | float | 可选 | 原始 P 值 |

### 可覆盖的 style

- `lfc_cutoff`：`2.0`
- `padj_cutoff`：`0.05`
- `sig_color`：`"#9E623E"`
- `nonsig_color`：`"#BDBDBD"`
- `top_n_each_side`：`6`
- `dpi`：`300`
- `width_in`：`4.2`
- `height_in`：`3.4`
- `rect`：`[0.18, 0.16, 0.76, 0.76]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
