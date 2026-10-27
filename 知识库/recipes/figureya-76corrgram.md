---
type: recipe
id: figureya-76corrgram
title: 多变量相关矩阵散点热图
status: draft
source:
  id: figureya
  item: FigureYa76corrgram
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa76corrgram.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，将计算并展示每两列之间的相关性。每列一个特征，每行一个sample。
outputs:
- corrgram.pdf
packages:
  cran: []
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
tags:
- experimental-statistics
keywords:
- corrgram
- correlation matrix
- pairs plot
chart_types:
- heatmap
- scatter
summary: 一张图里同时展示多变量两两相关：下三角散点+拟合线，上三角相关系数热图，对角线为变量名。
favorite: false
---
# 多变量相关矩阵散点热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa76corrgram` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa76corrgram.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，0.7 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

一张图里同时展示多变量两两相关：下三角散点+拟合线，上三角相关系数热图，对角线为变量名。

## 适用

少量（约 3–10 个）连续变量的样本表。

## 不适用

变量很多（格子过小）；分类变量；需要相关系数显著性校正时要另行确认。

## 输入

- `easy_input.csv`：easy_input.csv，将计算并展示每两列之间的相关性。每列一个特征，每行一个sample。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-76corrgram`
- 用到课题：`wiki.py use figureya-76corrgram --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `corrgram.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
