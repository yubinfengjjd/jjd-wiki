---
type: recipe
id: figureya-119multiclasslimma
title: 多亚型limma差异表达分析
status: draft
source:
  id: figureya
  item: FigureYa119Multiclasslimma
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa119Multiclasslimma.Rmd
inputs:
- file: easy_input_FPKM.txt
  note: ''
- file: easy_input_subtype.txt
  note: ''
outputs: []
packages:
  cran: []
  bioc:
  - affy
  - affyPLM
  - limma
  github: []
  library:
  - limma
  - affy
  - affyPLM
  namespaced:
  - knitr
  - BiocManager
tags:
- transcriptomics
keywords:
- limma
- affy
- affyPLM
- eBayes
- makeContrasts
chart_types:
- table
summary: 用limma对“每个亚型vs其余样本”逐一做差异表达分析，输出各亚型的差异基因结果表，可对接FigureYa109SubtypeGSEA或FigureYa116
favorite: false
---
# 多亚型limma差异表达分析

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa119Multiclasslimma` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa119Multiclasslimma.Rmd`）
- 依赖：Bioconductor affy, affyPLM, limma
- 最近运行：pass（as-is，2026-11-04 12:16 UTC，13.2 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用limma对“每个亚型vs其余样本”逐一做差异表达分析，输出各亚型的差异基因结果表，可对接FigureYa109SubtypeGSEA或FigureYa116supervisedCluster做下游分析。

## 适用

已有≥3个亚型的分型标签和FPKM/RPKM或芯片表达矩阵，需要筛各亚型特异的差异基因。

## 不适用

只产出差异分析表、不画图；不处理批次效应（需自行在设计矩阵中加入batch）；read count输入请改用DESeq2版；亚型名称和组数要在createList函数里手动改写。

## 输入

- `easy_input_FPKM.txt`：见 Rmd“输入文件”节
- `easy_input_subtype.txt`：见 Rmd“输入文件”节

表达矩阵行=基因、列=样本；亚型表行名=样本且含TCGA_Subtype列，样本名须与矩阵列名对应；示例为加速只取方差top25%基因。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-119multiclasslimma`
- 用到课题：`wiki.py use figureya-119multiclasslimma --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
