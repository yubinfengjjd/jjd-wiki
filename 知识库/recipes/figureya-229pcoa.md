---
type: recipe
id: figureya-229pcoa
title: PCoA分组均值误差线图
status: draft
source:
  id: figureya
  item: FigureYa229PCOA
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa229PCOA.Rmd
inputs:
- file: easy_input_expr.txt
  note: easy_input_expr.txt，表达矩阵。
- file: easy_input_sinfo.txt
  note: easy_input_sinfo.txt，样本信息，第一列是sample ID，跟表达矩阵一致，第二列是第一种分组方式（这里是亚型），第三列是二种分组方式（这里是队列），这里对比两个队列。
outputs:
- basic scatter plot.pdf
- PCoA.pdf
packages:
  cran:
  - RColorBrewer
  - ape
  - usedist
  - vegan
  bioc: []
  github: []
  library:
  - vegan
  - ape
  - RColorBrewer
  - usedist
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- vegan
- ape
- usedist
- RColorBrewer
- PCoA
- PERMANOVA
- adonis2
- PAM50
chart_types:
- scatter
- errorbar
summary: 基于距离矩阵做PCoA降维，按亚型×队列分组计算坐标均值±标准差，画带误差线的实心/空心大圆散点，并用adonis2做PERMANOVA组间检验。
favorite: false
---
# PCoA分组均值误差线图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa229PCOA` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa229PCOA.Rmd`）
- 依赖：CRAN RColorBrewer, ape, usedist, vegan
- 最近运行：pass（as-is，2026-11-04 11:04 UTC，264.4 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `basic scatter plot.pdf` 第 1 页）：

![[recipes/figureya-229pcoa/preview.png]]
<!-- facts:end -->

## 用途

基于距离矩阵做PCoA降维，按亚型×队列分组计算坐标均值±标准差，画带误差线的实心/空心大圆散点，并用adonis2做PERMANOVA组间检验。

## 适用

样本多使PCoA/PCA/UMAP散点重叠时，用组均值+误差线方式展示多组样本相对位置及队列间一致性。

## 不适用

分组组合、颜色与缩写标签在代码里写死（5亚型×2队列、Paired色板最多12组）；均值±SD会掩盖组内离群样本；示例用欧氏距离（等价PCA），Bray-Curtis需非负矩阵且要改vegdist参数。

## 输入

- `easy_input_expr.txt`：easy_input_expr.txt，表达矩阵。
- `easy_input_sinfo.txt`：easy_input_sinfo.txt，样本信息，第一列是sample ID，跟表达矩阵一致，第二列是第一种分组方式（这里是亚型），第三列是二种分组方式（这里是队列），这里对比两个队列。

sinfo行名=样本ID且与expr列名一致；第2列分组一（亚型PAM50）、第3列分组二（队列Cohort）列名写死。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-229pcoa`
- 用到课题：`wiki.py use figureya-229pcoa --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `basic scatter plot.pdf`
- `PCoA.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
