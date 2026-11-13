---
type: recipe
id: figureya-193risktable
title: 训练与验证集风险评分多因素森林表
status: ready
source:
  id: figureya
  item: FigureYa193RiskTable
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa193RiskTable.Rmd
inputs:
- file: tcga.expr.txt
  note: tcga.expr.txt，TCGA的表达矩阵；/ the expression matrix of TCGA.
- file: tcga.surv.txt
  note: tcga.surv.txt，TCGA的生存数据。/ survival data of TCGA.
- file: gse39582.expr.txt
  note: gse39582.expr.txt，GEO的表达矩阵；/ the expression matrix of GEO.
- file: gse39582.surv.txt
  note: gse39582.surv.txt，GEO的生存数据。/ survival data of GEO.
outputs:
- forestplot of risk table.pdf
packages:
  cran:
  - forestplot
  - glmnet
  - survival
  bioc: []
  github: []
  library:
  - survival
  - glmnet
  - forestplot
  namespaced:
  - knitr
tags:
- survival-analysis
- transcriptomics
keywords:
- riskscore
- multivariate Cox
- TCGA
- GEO validation
- forestplot
- glmnet
- survival
chart_types:
- forest
summary: 在训练集（TCGA）构建 riskscore，并在 GEO 验证集验证，用多因素 Cox 检验预后独立性，画上下两段的森林表。
favorite: false
---
# 训练与验证集风险评分多因素森林表

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa193RiskTable` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa193RiskTable.Rmd`）
- 依赖：CRAN forestplot, glmnet, survival
- 最近运行：pass（as-is，2026-11-04 04:21 UTC，631.1 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `forestplot of risk table.pdf` 第 1 页）：

![[recipes/figureya-193risktable/preview.png]]
<!-- facts:end -->

## 用途

在训练集（TCGA）构建 riskscore，并在 GEO 验证集验证，用多因素 Cox 检验预后独立性，画上下两段的森林表。

## 适用

有训练、验证两套表达矩阵与生存表，基因名一致；想展示 riskscore 校正临床因素后的独立预后价值。

## 不适用

只有一套队列；riskscore 已由别的方法算好且不想重算（需改代码）；非生存结局。

## 输入

- `tcga.expr.txt`：tcga.expr.txt，TCGA的表达矩阵；/ the expression matrix of TCGA.
- `tcga.surv.txt`：tcga.surv.txt，TCGA的生存数据。/ survival data of TCGA.
- `gse39582.expr.txt`：gse39582.expr.txt，GEO的表达矩阵；/ the expression matrix of GEO.
- `gse39582.surv.txt`：gse39582.surv.txt，GEO的生存数据。/ survival data of GEO.

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-193risktable`
- 用到课题：`wiki.py use figureya-193risktable --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `forestplot of risk table.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
