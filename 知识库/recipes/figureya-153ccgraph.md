---
type: recipe
id: figureya-153ccgraph
title: 层级关系同心环网络图
status: draft
source:
  id: figureya
  item: FigureYa153ccgraph
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa153ccgraph.Rmd
inputs:
- file: very_easy_input.csv
  note: 如果你的数据已经整理成`very_easy_input.csv`的格式，就可以跳过这步，直接进入“输入文件预处理”。
- file: gene_special.txt
  note: gene_special.txt，要突出显示的基因。第一列是基因名，第二列是类型（例如基因家族信息）。
- file: easy_input_rnk.txt
  note: ''
- file: microbiome.csv
  note: ''
outputs:
- ccgraph_color.pdf
- ccgraph.pdf
- ccgraph_microbiome.pdf
packages:
  cran:
  - GOplot
  - class
  - data.table
  - ggraph
  - order
  - phylum
  - tidygraph
  - tidyverse
  bioc:
  - clusterProfiler
  github: []
  library:
  - clusterProfiler
  - GOplot
  - tidyverse
  - data.table
  - ggraph
  - tidygraph
  namespaced: []
tags:
- multi-omics
keywords:
- ccgraph
- ggraph
- hierarchy
- circle packing
- GOplot
- clusterProfiler
- data.table
- tidygraph
- tidyverse
chart_types:
- network
summary: 用“圆环套圆环”的布局展示层级结构，例如基因—突变、调控因子—靶基因或物种分类丰度。
favorite: false
---
# 层级关系同心环网络图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa153ccgraph` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa153ccgraph.Rmd`）
- 依赖：CRAN GOplot, class, data.table, ggraph, order, phylum, tidygraph, tidyverse；Bioconductor clusterProfiler
- 最近运行：fail（as-is，2026-10-27 12:37 UTC，6.3 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用“圆环套圆环”的布局展示层级结构，例如基因—突变、调控因子—靶基因或物种分类丰度。

## 适用

两层或多层的父子关系表，叶节点有一个非负数值（点大小）。

## 不适用

需要表达正负方向（点大小只能表示正值或绝对值）；非层级的网络关系。

## 输入

- `very_easy_input.csv`：如果你的数据已经整理成`very_easy_input.csv`的格式，就可以跳过这步，直接进入“输入文件预处理”。
- `gene_special.txt`：gene_special.txt，要突出显示的基因。第一列是基因名，第二列是类型（例如基因家族信息）。
- `easy_input_rnk.txt`：见 Rmd“输入文件”节
- `microbiome.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-153ccgraph`
- 用到课题：`wiki.py use figureya-153ccgraph --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `ccgraph_color.pdf`
- `ccgraph.pdf`
- `ccgraph_microbiome.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
