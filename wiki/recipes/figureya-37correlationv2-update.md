---
type: recipe
id: figureya-37correlationv2-update
title: 圆形布局基因相关连线图
status: ready
source:
  id: figureya
  item: FigureYa37correlationV2_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa37correlationV2_update.Rmd
inputs:
- file: not_easy_input.csv
  note: not_easy_input.csv，基因表达矩阵。每行一个sample，每列一个基因。
- file: easy_input.txt
  note: ''
- file: easy_input_V2.txt
  note: ''
outputs:
- correlation.pdf
packages:
  cran:
  - ggsci
  - parallel
  bioc:
  - circlize
  github: []
  library:
  - circlize
  - ggsci
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- circular correlation
- co-expression
- circlize
- ggsci
chart_types:
- chord
- network
summary: 把基因放在圆周上，两两之间用连线表示相关，连线颜色和宽度代表相关系数。
favorite: false
---
# 圆形布局基因相关连线图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa37correlationV2_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa37correlationV2_update.Rmd`）
- 依赖：CRAN ggsci, parallel；Bioconductor circlize
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，3.7 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-37correlationv2-update/preview.png]]
<!-- facts:end -->

## 用途

把基因放在圆周上，两两之间用连线表示相关，连线颜色和宽度代表相关系数。

## 适用

一组基因（约 5–30 个）的表达矩阵或已算好的相关系数表。

## 不适用

基因数很多（连线过密）；需要网络拓扑分析（用 WGCNA 等）。

## 输入

- `not_easy_input.csv`：not_easy_input.csv，基因表达矩阵。每行一个sample，每列一个基因。
- `easy_input.txt`：见 Rmd“输入文件”节
- `easy_input_V2.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-37correlationv2-update`
- 用到课题：`wiki.py use figureya-37correlationv2-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `correlation.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
