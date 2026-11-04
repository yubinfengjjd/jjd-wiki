---
type: recipe
id: figureya-97correlationv3
title: 基因免疫浸润相关热图
status: draft
source:
  id: figureya
  item: FigureYa97correlationV3
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa97correlationV3.Rmd
inputs:
- file: ssGSEA_output.csv
  note: ssGSEA_output.csv，免疫细胞矩阵，列是免疫细胞，行是样本，由FigureYa71ssGSEA产生。如果对免疫浸润不感兴趣，就把ssGSEA_output.csv换成其他类型的数据，例如临床指标什么的，只要保证样品名跟easy_input_expr.csv一致就好了。
- file: easy_input_expr.csv
  note: ssGSEA_output.csv，免疫细胞矩阵，列是免疫细胞，行是样本，由FigureYa71ssGSEA产生。如果对免疫浸润不感兴趣，就把ssGSEA_output.csv换成其他类型的数据，例如临床指标什么的，只要保证样品名跟easy_input_expr.csv一致就好了。
- file: genelist.txt
  note: genelist.txt，基因名，将要计算这些基因跟免疫浸润的相关性。要求跟easy_input_expr.csv里的基因名一致。
outputs:
- correlation.pdf
packages:
  cran:
  - dplyr
  - ggplot2
  bioc: []
  github: []
  library:
  - ggplot2
  - dplyr
  namespaced:
  - knitr
  - data.table
tags:
- transcriptomics
- experimental-statistics
keywords:
- ssGSEA
- spearman
- ggplot2
- geom_tile
- data.table
chart_types:
- heatmap
summary: 批量算基因列表中每个基因与免疫细胞矩阵的spearman相关和P值，ggplot2 geom_tile画相关热图，格内打*/**标显著性。
favorite: false
---
# 基因免疫浸润相关热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa97correlationV3` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa97correlationV3.Rmd`）
- 依赖：CRAN dplyr, ggplot2
- 最近运行：pass（as-is，2026-11-04 11:20 UTC，14.9 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-97correlationv3/preview.png]]
<!-- facts:end -->

## 用途

批量算基因列表中每个基因与免疫细胞矩阵的spearman相关和P值，ggplot2 geom_tile画相关热图，格内打*/**标显著性。

## 适用

筛与免疫浸润（或临床表型等其他连续变量）相关的候选基因，一侧输入可灵活替换。

## 不适用

两个矩阵样本名必须一致（一个行=样本一个列=样本）；genelist基因须命中表达矩阵行名；星号按原始P值、无多重校正；细胞顺序需手改factor levels。

## 输入

- `ssGSEA_output.csv`：ssGSEA_output.csv，免疫细胞矩阵，列是免疫细胞，行是样本，由FigureYa71ssGSEA产生。如果对免疫浸润不感兴趣，就把ssGSEA_output.csv换成其他类型的数据，例如临床指标什么的，只要保证样品名跟easy_input_expr.csv一致就好了。
- `easy_input_expr.csv`：ssGSEA_output.csv，免疫细胞矩阵，列是免疫细胞，行是样本，由FigureYa71ssGSEA产生。如果对免疫浸润不感兴趣，就把ssGSEA_output.csv换成其他类型的数据，例如临床指标什么的，只要保证样品名跟easy_input_expr.csv一致就好了。
- `genelist.txt`：genelist.txt，基因名，将要计算这些基因跟免疫浸润的相关性。要求跟easy_input_expr.csv里的基因名一致。
- `easy_input-expr.csv`：genelist.txt， The gene names will be used to calculate the correlation between these genes and immune infiltration. Require the gene name to be consistent with the one in easy_input-expr.csv.

ssGSEA_output.csv行=样本列=细胞（行名点号自动换连字符）；easy_input_expr.csv行=基因列=样本；genelist.txt单列基因名。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-97correlationv3`
- 用到课题：`wiki.py use figureya-97correlationv3 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `correlation.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
