---
type: recipe
id: figureya-38pca
title: PCA降维置信椭圆图
status: draft
source:
  id: figureya
  item: FigureYa38PCA
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa38PCA.Rmd
inputs:
- file: easy_input_expr.csv
  note: 表达量矩阵：easy_input_expr.csv，第一列是样品名，后续几列是各个基因的表达量，或者其他属性
- file: easy_input_meta.csv
  note: 样品分组：easy_input_meta.csv，第一列是样品名，第二列是分组
outputs:
- PCA_classic.pdf
- PCA_allgenes_topNarrows.pdf
- PCA_DIY1.pdf
- PCA_DIY2.pdf
packages:
  cran:
  - dplyr
  - ggplot2
  - plyr
  - ggrepel
  bioc: []
  github: []
  library:
  - ggplot2
  - plyr
  - dplyr
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- prcomp
- ggord
- geom_ord_ellipse
- ggplot2
- plyr
chart_types:
- pca
summary: 对表达矩阵做prcomp降维并画PCA散点，按分组着色，叠加95%/98%置信椭圆或Top贡献基因载荷箭头。
favorite: false
---
# PCA降维置信椭圆图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa38PCA` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa38PCA.Rmd`）
- 依赖：CRAN dplyr, ggplot2, plyr, ggrepel
- 最近运行：pass（as-is，2026-11-04 11:13 UTC，14.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-38pca/preview.png]]
<!-- facts:end -->

## 用途

对表达矩阵做prcomp降维并画PCA散点，按分组着色，叠加95%/98%置信椭圆或Top贡献基因载荷箭头。

## 适用

高维数据降维展示样本聚类、识别离群样本与批次效应；不只限测序数据。

## 不适用

纯可视化不含统计检验；组内样本≤2时无法画置信椭圆；箭头版需手工改rotation只留Top基因。

## 输入

- `easy_input_expr.csv`：表达量矩阵：easy_input_expr.csv，第一列是样品名，后续几列是各个基因的表达量，或者其他属性
- `easy_input_meta.csv`：样品分组：easy_input_meta.csv，第一列是样品名，第二列是分组

easy_input_expr.csv行=样本列=特征；easy_input_meta.csv两列（样本名/分组），两表样本名须一一对应。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-38pca`
- 用到课题：`wiki.py use figureya-38pca --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `PCA_classic.pdf`
- `PCA_allgenes_topNarrows.pdf`
- `PCA_DIY1.pdf`
- `PCA_DIY2.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
