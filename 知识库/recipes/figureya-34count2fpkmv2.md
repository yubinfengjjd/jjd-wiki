---
type: recipe
id: figureya-34count2fpkmv2
title: RNA-seq读数转FPKM换算
status: draft
source:
  id: figureya
  item: FigureYa34count2FPKMv2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa34count2FPKMv2.Rmd
inputs:
- file: easy_input.csv
  note: ''
- file: gene_length.csv
  note: ''
- file: TCGA_FPKM.csv
  note: ''
outputs: []
packages:
  cran:
  - parallel
  - plyr
  bioc: []
  github: []
  library:
  - GenomicFeatures
  - TCGAbiolinks
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- FPKM
- read count
- GenomicFeatures
- GENCODE
- TCGAbiolinks
chart_types:
- table
- scatter
summary: 用基因有效长度把RNA-seq read count矩阵换算成FPKM，并与TCGA官方FPKM做相关性验证。
favorite: false
---
# RNA-seq读数转FPKM换算

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa34count2FPKMv2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa34count2FPKMv2.Rmd`）
- 依赖：CRAN parallel, plyr
- 最近运行：pass（as-is，2026-11-04 15:08 UTC，4.7 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用基因有效长度把RNA-seq read count矩阵换算成FPKM，并与TCGA官方FPKM做相关性验证。

## 适用

只能拿到read count却需要FPKM口径做下游分析或作图；基因长度表算一次即可长期复用。

## 不适用

必须提供与计数矩阵同一注释版本的有效基因长度表（示例gencode.v22对应TCGA）；只是近似换算，要精确FPKM应从FASTQ重定量；GTF基因数少于矩阵时会丢弃部分基因。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节
- `gene_length.csv`：见 Rmd“输入文件”节
- `TCGA_FPKM.csv`：见 Rmd“输入文件”节

表达矩阵行基因列样本；ensembl带版本号的基因ID需去小数点后缀才能匹配长度表行名。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-34count2fpkmv2`
- 用到课题：`wiki.py use figureya-34count2fpkmv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：基因长度计算（GenomicFeatures+parallel）耗时但只需跑一次；TCGA演示数据与GTF需TCGAbiolinks联网/GDC手工下载。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
