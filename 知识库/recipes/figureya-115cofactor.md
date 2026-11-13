---
type: recipe
id: figureya-115cofactor
title: ChIP-seq样本相关性聚类热图
status: ready
source:
  id: figureya
  item: FigureYa115cofactor
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa115cofactor.Rmd
inputs:
- file: Intervene_pairwise_frac_matrix.txt
  note: ''
outputs:
- Intervene_pairwise_frac.pdf
- Intervene_pairwise_frac_plus.pdf
packages:
  cran:
  - RColorBrewer
  - corrplot
  - pheatmap
  bioc: []
  github: []
  library:
  - corrplot
  - RColorBrewer
  - pheatmap
  namespaced:
  - knitr
tags:
- experimental-statistics
keywords:
- intervene
- corrplot
- pheatmap
- RColorBrewer
chart_types:
- heatmap
summary: 对多个ChIP-seq样品的peak重叠矩阵算两两相关（pearson）并聚类，用corrplot或pheatmap重画相关性热图。
favorite: false
---
# ChIP-seq样本相关性聚类热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa115cofactor` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa115cofactor.Rmd`）
- 依赖：CRAN RColorBrewer, corrplot, pheatmap
- 最近运行：pass（as-is，2026-11-04 10:59 UTC，9.5 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-115cofactor/preview.png]]
<!-- facts:end -->

## 用途

对多个ChIP-seq样品的peak重叠矩阵算两两相关（pearson）并聚类，用corrplot或pheatmap重画相关性热图。

## 适用

比较转录因子/调控蛋白结合谱的相似性，找cofactor，或看过表达/敲降后结合谱变得跟谁更像。

## 不适用

R部分只负责把算好的相关矩阵画成图；相关矩阵需先用intervene等外部工具从peak.bed生成，不直接吃表达矩阵或bw文件。

## 输入

- `Intervene_pairwise_frac_matrix.txt`：见 Rmd“输入文件”节

输入为intervene输出的Intervene_pairwise_frac_matrix.txt，样本×样本的peak重叠比例方阵。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-115cofactor`
- 用到课题：`wiki.py use figureya-115cofactor --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：相关矩阵需在终端用intervene计算（bioconda安装、Python 2.7环境），GEO数据下载、tar/gunzip解压和sort均在bash完成，非纯R流程。

## 输出

- `Intervene_pairwise_frac.pdf`
- `Intervene_pairwise_frac_plus.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
