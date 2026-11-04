---
type: recipe
id: figureya-81immune-network
title: 免疫细胞相关预后网络图
status: draft
source:
  id: figureya
  item: FigureYa81immune_network
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa81immune_network.Rmd
inputs:
- file: easy_input_immune.csv
  note: 至少要提供easy_input_immune.csv文件，例如免疫细胞矩阵，或基因表达矩阵（把这里的免疫细胞替换成基因即可）。如果没有生存分析结果，可以用其他pvalue代替。
- file: easy_input_HR.csv
  note: easy_input_HR.csv，生存分析结果，需要HR（节点圆心点的颜色，用AI来加）和p value（节点圆的大小）列。可通过FigureYa47HR2table计算获得。
outputs:
- Immune_network.pdf
packages:
  cran:
  - corrplot
  - igraph
  - plyr
  - reshape2
  bioc: []
  github: []
  library:
  - reshape2
  - corrplot
  - plyr
  - igraph
  namespaced:
  - knitr
tags:
- survival-analysis
- transcriptomics
keywords:
- igraph
- corrplot
- CIBERSORT
- MCPcounter
- logrank
- spearman
- plyr
- reshape2
chart_types:
- network
summary: 由免疫细胞（或基因）矩阵算spearman相关与P值，聚类分4簇，igraph画圆形网络：点色=簇、点大小=logrank P、边色=相关正负、边粗=-log1
favorite: false
---
# 免疫细胞相关预后网络图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa81immune_network` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa81immune_network.Rmd`）
- 依赖：CRAN corrplot, igraph, plyr, reshape2
- 最近运行：pass（as-is，2026-11-04 11:19 UTC，7.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-81immune-network/preview.png]]
<!-- facts:end -->

## 用途

由免疫细胞（或基因）矩阵算spearman相关与P值，聚类分4簇，igraph画圆形网络：点色=簇、点大小=logrank P、边色=相关正负、边粗=-log10P。

## 适用

一张网络图同时展示变量间相关关系、聚类归属和与预后的关联（HR/logrank）。

## 不适用

两输入文件的细胞/基因名须一致；簇数（4）、细胞→S编号映射、个别细胞簇归属均写死并手工调整；HR圆心点不在R输出里需Illustrator后补；边只保留P<0.0001且按weight去重，会丢并列边。

## 输入

- `easy_input_immune.csv`：至少要提供easy_input_immune.csv文件，例如免疫细胞矩阵，或基因表达矩阵（把这里的免疫细胞替换成基因即可）。如果没有生存分析结果，可以用其他pvalue代替。
- `easy_input_HR.csv`：easy_input_HR.csv，生存分析结果，需要HR（节点圆心点的颜色，用AI来加）和p value（节点圆的大小）列。可通过FigureYa47HR2table计算获得。

easy_input_immune.csv行=样本列=细胞；easy_input_HR.csv需含ID（同细胞名）、HR、log_rank_p列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-81immune-network`
- 用到课题：`wiki.py use figureya-81immune-network --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `Immune_network.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
