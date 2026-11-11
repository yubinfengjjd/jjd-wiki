---
type: recipe
id: figureya-18oncoplot-update
title: 多样本基因突变瀑布图
status: draft
source:
  id: figureya
  item: FigureYa18oncoplot_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa18oncoplot_update.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs:
- oncoplotTop20.pdf
- oncoplotLIST.pdf
- oncoplotTop20_col.pdf
- oncoplotGroup.png
- oncoplotGroup.pdf
packages:
  cran: []
  bioc:
  - TCGAbiolinks
  - maftools
  github: []
  library:
  - TCGAbiolinks
  - maftools
  namespaced:
  - knitr
  - RColorBrewer
tags:
- multi-omics
keywords:
- TCGAbiolinks
- maftools
- TCGA
- GDC
- mutect2
chart_types:
- waterfall
summary: 用TCGAbiolinks在线下载TCGA突变maf和临床信息，maftools::oncoplot画带临床注释的突变瀑布图，支持topN、自定义基因列表和按分
favorite: false
---
# 多样本基因突变瀑布图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa18oncoplot_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa18oncoplot_update.Rmd`）
- 依赖：Bioconductor TCGAbiolinks, maftools
- 最近运行：pass（as-is，2026-11-11 09:56 UTC，15.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `oncoplotTop20.pdf` 第 1 页）：

![[recipes/figureya-18oncoplot-update/preview.png]]
<!-- facts:end -->

## 用途

用TCGAbiolinks在线下载TCGA突变maf和临床信息，maftools::oncoplot画带临床注释的突变瀑布图，支持topN、自定义基因列表和按分组排序。

## 适用

大样本量队列展示高频突变基因或某通路/基因列表的突变谱，并叠加临床或自定义分组注释。

## 不适用

演示流程直接从GDC在线取数，离线需自备maf对象；临床特征列名按TCGA字段写死，非TCGA数据须先整理成maf格式；基因列表中无突变的基因被丢弃。

## 输入

- `group.txt`：见 Rmd“输入文件”节
- `easy_input.txt`：见 Rmd“输入文件”节

easy_input.txt为想画的基因列表（每行一个基因）；group.txt为可选自定义分组，按样本条码并入临床表。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-18oncoplot-update`
- 用到课题：`wiki.py use figureya-18oncoplot-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：GDCquery/GDCdownload需联网从TCGA GDC下载临床BCR XML与masked somatic mutation数据。

## 输出

- `oncoplotTop20.pdf`
- `oncoplotLIST.pdf`
- `oncoplotTop20_col.pdf`
- `oncoplotGroup.png`
- `oncoplotGroup.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
