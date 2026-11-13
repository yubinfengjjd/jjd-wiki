---
type: recipe
id: figureya-147plus-string
title: STRING互作证据打分网络图
status: ready
source:
  id: figureya
  item: FigureYa147Plus_STRING
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa147Plus_STRING.Rmd
inputs:
- file: easy_input.txt
  note: 把表格复制到 txt 文件，命名为 easy_input.txt。
outputs:
- interaction.pdf
packages:
  cran:
  - ggplot2
  - igraph
  - magrittr
  - reshape2
  - tidyr
  bioc: []
  github: []
  library:
  - tidyr
  - scales
  - ggplot2
  - reshape2
  - igraph
  - magrittr
  namespaced:
  - knitr
  - RColorBrewer
tags:
- proteomics
- multi-omics
keywords:
- STRING
- igraph
- FOXP3
- PPI
- magrittr
- reshape2
- scales
chart_types:
- network
summary: 把STRING查询得到的互作表画成igraph网络：中心源节点，连线颜色区分证据来源（Loc列），score决定布局距离，证据可分拆成多条边。
favorite: false
---
# STRING互作证据打分网络图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa147Plus_STRING` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa147Plus_STRING.Rmd`）
- 依赖：CRAN ggplot2, igraph, magrittr, reshape2, tidyr
- 最近运行：pass（as-is，2026-11-04 11:00 UTC，13.9 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `interaction.pdf` 第 1 页）：

![[recipes/figureya-147plus-string/preview.png]]
<!-- facts:end -->

## 用途

把STRING查询得到的互作表画成igraph网络：中心源节点，连线颜色区分证据来源（Loc列），score决定布局距离，证据可分拆成多条边。

## 适用

展示一个中心分子与其互作对象的关系及证据类型和打分，如PPI、转录因子-靶基因、miRNA-靶基因。

## 不适用

输入需先手工在STRING chat查询并复制整理成四列表格，不能自动抓取；布局与文字位置通常需在Illustrator等软件里后期调整；一次只画一个中心节点。

## 输入

- `easy_input.txt`：把表格复制到 txt 文件，命名为 easy_input.txt。

easy_input.txt四列：source、target、Loc（证据类型，可多值逗号分隔后拆分）、score（0-1）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-147plus-string`
- 用到课题：`wiki.py use figureya-147plus-string --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `interaction.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
