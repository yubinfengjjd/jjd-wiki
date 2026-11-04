---
type: recipe
id: figureya-147interaction
title: 带证据评分的放射互作网络图
status: draft
source:
  id: figureya
  item: FigureYa147interaction
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa147interaction.Rmd
inputs:
- file: easy_input.csv
  note: 如果你已经获得interaction关系，就把自己的数据整理成easy_input.csv文件的格式，跳过这步，直接进入“开始画图”。
- file: comppi--interactors_of_Q0GN75.txt
  note: comppi--interactors_of_Q0GN75.txt，上一步获得的interaction信息。每行一个蛋白质，所有证据和分数都在Major.Loc.With.Loc.Score里面，用｜分隔，需要拆开成每条证据单独一行。
outputs:
- interaction.pdf
packages:
  cran:
  - ggplot2
  - igraph
  - magrittr
  - reshape2
  bioc:
  - clusterProfiler
  - org.Hs.eg.db
  github: []
  library:
  - org.Hs.eg.db
  - clusterProfiler
  - ggplot2
  - reshape2
  - igraph
  - magrittr
  namespaced:
  - knitr
  - RColorBrewer
tags:
- multi-omics
keywords:
- ComPPI
- igraph
- clusterProfiler
- org.Hs.eg.db
- PD-L1
- PPI
- magrittr
- reshape2
chart_types:
- network
summary: 以相互作用关系表为输入，用igraph画中心节点辐射网络：连线长度对应互作评分，连线颜色/数量对应不同证据来源。
favorite: false
---
# 带证据评分的放射互作网络图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa147interaction` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa147interaction.Rmd`）
- 依赖：CRAN ggplot2, igraph, magrittr, reshape2；Bioconductor clusterProfiler, org.Hs.eg.db
- 最近运行：pass（as-is，2026-11-04 11:01 UTC，40.7 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `interaction.pdf` 第 1 页）：

![[recipes/figureya-147interaction/preview.png]]
<!-- facts:end -->

## 用途

以相互作用关系表为输入，用igraph画中心节点辐射网络：连线长度对应互作评分，连线颜色/数量对应不同证据来源。

## 适用

展示蛋白-蛋白、转录因子-靶基因、miRNA-靶基因等一对多互作，并同时呈现证据类型与综合打分。

## 不适用

只支持单一中心节点的星型布局，不适合大规模全网展示；ComPPI原始证据列需先按|拆成长表，且需自行定义证据权重与评分公式。

## 输入

- `easy_input.csv`：如果你已经获得interaction关系，就把自己的数据整理成easy_input.csv文件的格式，跳过这步，直接进入“开始画图”。
- `comppi--interactors_of_Q0GN75.txt`：comppi--interactors_of_Q0GN75.txt，上一步获得的interaction信息。每行一个蛋白质，所有证据和分数都在Major.Loc.With.Loc.Score里面，用｜分隔，需要拆开成每条证据单独一行。

easy_input.csv需含source、target、Loc（证据类型）、score四列；score决定边权重/布局长度。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-147interaction`
- 用到课题：`wiki.py use figureya-147interaction --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：示例互作文件需从ComPPI网站（comppi.linkgroup.hu）手工检索下载；UNIPROT→SYMBOL转换依赖org.Hs.eg.db。

## 输出

- `interaction.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
