---
type: recipe
id: figureya-59plus-geo2deg
title: GEO芯片差异表达与火山图
status: ready
source:
  id: figureya
  item: FigureYa59Plus_GEO2DEG
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa59Plus_GEO2DEG.Rmd
inputs:
- file: easy_input_expr.csv
  note: 如果你的数据已经整理成“easy_input_expr.csv”和“easy_input_pheno.csv”的格式，包含所有基因的表达矩阵，每行一个基因，每列一个sample，就可以跳过这步，直接进入“输入数据预处理”；
- file: easy_input_limma.csv
  note: 如果已经整理成“easy_input_limma.csv”的格式，包含所有基因的差异表达分析结果，每行一个基因，第一列是基因名，后面包含log2foldchange、P.value或adj.Pvalue，就直接跳到“开始画图”。
- file: easy_input_pheno.txt
  note: easy_input_pheno.txt，样品分组，第一列是sample ID，第二列是分组
- file: gplTOgene.csv
  note: ''
outputs: []
packages:
  cran:
  - ggplot2
  - ggrepel
  - ggthemes
  - dplyr
  - tidyr
  - readr
  - GEOquery
  - limma
  bioc:
  - GEOquery
  - limma
  github: []
  library:
  - GEOquery
  - limma
  - ggplot2
  - ggrepel
  - ggthemes
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- GEOquery
- limma
- GPL
- ggrepel
- ggthemes
chart_types:
- volcano
- boxplot
summary: getGEO下载GEO芯片表达矩阵与GPL平台注释，探针转symbol、log2+分位数标准化、去离群样本后limma差异分析，输出easy_input_lim
favorite: false
---
# GEO芯片差异表达与火山图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa59Plus_GEO2DEG` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa59Plus_GEO2DEG.Rmd`）
- 依赖：CRAN ggplot2, ggrepel, ggthemes, dplyr, tidyr, readr, GEOquery, limma；Bioconductor GEOquery, limma
- 最近运行：pass（as-is，2026-11-04 11:16 UTC，72.8 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-59plus-geo2deg/preview.png]]
<!-- facts:end -->

## 用途

getGEO下载GEO芯片表达矩阵与GPL平台注释，探针转symbol、log2+分位数标准化、去离群样本后limma差异分析，输出easy_input_limma.csv对接火山图。

## 适用

GEO芯片（microarray）数据从下载、注释到差异表的一条龙预处理。

## 不适用

只覆盖GEO芯片矩阵数据，RNA-seq/其他来源需跳过下载段自备expr+pheno；GPL注释列位置按GPL3921写死，换平台要核对列号；分组示例rep(c(a,b),each=3)需按实际设计改；火山图代码在另一模块。

## 输入

- `easy_input_expr.csv`：如果你的数据已经整理成“easy_input_expr.csv”和“easy_input_pheno.csv”的格式，包含所有基因的表达矩阵，每行一个基因，每列一个sample，就可以跳过这步，直接进入“输入数据预处理”；
- `easy_input_pheno.csv`：如果你的数据已经整理成“easy_input_expr.csv”和“easy_input_pheno.csv”的格式，包含所有基因的表达矩阵，每行一个基因，每列一个sample，就可以跳过这步，直接进入“输入数据预处理”；
- `easy_input_limma.csv`：如果已经整理成“easy_input_limma.csv”的格式，包含所有基因的差异表达分析结果，每行一个基因，第一列是基因名，后面包含log2foldchange、P.value或adj.Pvalue，就直接跳到“开始画图”。
- `easy_input_pheno.txt`：easy_input_pheno.txt，样品分组，第一列是sample ID，第二列是分组
- `gplTOgene.csv`：见 Rmd“输入文件”节

可中途接入：已备好easy_input_expr.csv+easy_input_pheno.txt可直接进差异分析；已有easy_input_limma.csv可直接画图。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-59plus-geo2deg`
- 用到课题：`wiki.py use figureya-59plus-geo2deg --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：getGEO需联网下载GSE表达矩阵和GPL注释，结果缓存为本地.RData。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] · [[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]] · [[templates/figureya-59volcanov2--volcano|bulk 差异火山图（分级着色）]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
