---
type: template
id: coexpr-module-enrich-bars
title: 共表达模块功能富集分面条图
status: ready
layouts: []
sources:
- layouts/2026-11-19-hdwgcna-network__fig02
panels: []
language: r
primary_method: coexpression-ppi-network
data_domains:
- single-cell
- bulk-transcriptomics
tags:
- single-cell
chart_types:
- bar
keywords:
- hdWGCNA
- WGCNA
- enrichR
- GO
- patchwork
favorite: false
---
# 共表达模块功能富集分面条图

![[templates/coexpr-module-enrich-bars/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-11-19-hdwgcna-network__fig02|hdWGCNA 模块 GO 富集分面条图]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/bar]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/gene-set-enrichment|基因集富集分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：WGCNA 或共表达模块富集条形图可切换为 variant 模块配色条形图；模板不执行富集检验。；前提：明确模块归属与统一校正口径（FDR / p.adjust）。；适配：导出模块富集 CSV（module, term, count, p_adjust）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/coexpr-module-enrich-bars/spec.json；运行证据：无
<!-- facts:end -->

## 适用

- 展示多模块 `hdWGCNA` / `WGCNA` 经 `RunEnrichr` 或 ORA 富集后各模块的 Top N 通路（`-log10(P-value)`），常与左图 [[templates/coexpr-sphere-network]]（球体共表达网络）拼图联动展示。
- 仅需整理好的 `enrich_plot_dat.csv`（`module`、`Term`、`log10p`、可选 `color`），支持任意模块数 `n` 自适应分面行高与深浅 strip 自动反白文字。

## 不适用

- 不直接执行线上 Enrichr 富集检验，需在上游完成 `RunEnrichr` 与 `P < 0.05` Top N 筛选后输入。

## 知识关联检查

2026-11-18：新建模板主归属方法 [[methods/coexpression-ppi-network]]，作为 [[templates/coexpr-sphere-network]] 的右半 Panel B 配套富集条图（可单独出图，也可通过 `patchwork` 拼为双面板组合图）。示例数据基于原图 0–8 刻度估读整理（`estimated`）。

## 数据要求

### enrich（enrich_plot_dat.csv）：模块富集分析整理表（每个模块 Top N 显著通路：module、Term、log10p、可选 color） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| module | str | 必需 | 共表达模块名（如 Agrp_M1、ME1） |
| Term | str | 必需 | 富集通路或 GO Term 名称 |
| log10p | float | 必需 | -log10(P-value) 显著性数值 |
| color | str | 可选 | 模块十六进制配色（与网络图保持一致；缺省自动配色） |

### 可覆盖的 style

- `width_in`：`6.0`
- `height_in`：`11.8`
- `dpi`：`300`
- `ncol`：`2`
- `bar_alpha`：`0.52`
- `bar_width`：`0.72`
- `term_size`：`2.45`
- `strip_text_size`：`8.2`
- `max_term_chars`：`46`
- `x_lab`：`"-log10(P-value)"`

## 使用记录

<!-- user:start -->
<!-- user:end -->
