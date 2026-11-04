---
type: recipe
id: figureya-77basezoom
title: 局部放大气泡散点图
status: draft
source:
  id: figureya
  item: FigureYa77baseZoom
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa77baseZoom.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，提供分组、个数及总数（用于计算百分比）、pvalue：
outputs:
- baseZoom.pdf
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
- base plot
- zoom-in
- bubble
- pvalue
chart_types:
- bubble
- scatter
summary: 用base graphics画双组占比气泡图：整图+局部放大两联幅，颜色表类别、点大小表pvalue，解决密集点看不清、难标label的问题。
favorite: false
---
# 局部放大气泡散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa77baseZoom` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa77baseZoom.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-11-04 11:19 UTC，4.7 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-77basezoom/preview.png]]
<!-- facts:end -->

## 用途

用base graphics画双组占比气泡图：整图+局部放大两联幅，颜色表类别、点大小表pvalue，解决密集点看不清、难标label的问题。

## 适用

展示多个条目在两组中的占比差异（如两类肿瘤中各基因变异频率），且低值区域点过于密集需要放大局部。

## 不适用

输入列结构固定（基因名/分组/两组各自数量与总数/pvalue）；放大区域xlim/ylim和标签位置需在代码里手调；base plot无主题系统，细调外观较繁琐。

## 输入

- `easy_input.csv`：easy_input.csv，提供分组、个数及总数（用于计算百分比）、pvalue：

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-77basezoom`
- 用到课题：`wiki.py use figureya-77basezoom --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `baseZoom.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
