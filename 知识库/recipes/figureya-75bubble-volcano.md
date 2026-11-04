---
type: recipe
id: figureya-75bubble-volcano
title: 分组气泡火山图
status: draft
source:
  id: figureya
  item: FigureYa75bubble_volcano
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa75bubble_volcano.Rmd
inputs:
- file: easy_input.csv
  note: ''
outputs:
- base_volcano.pdf
packages:
  cran: []
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- base R
- volcano plot
- Bonferroni
chart_types:
- volcano
- bubble
summary: 用base plot画火山图：score对-log10P散点，点大小映射size、颜色映射group，叠加p=0.05与Bonferroni校正阈值线并给显著条
favorite: false
---
# 分组气泡火山图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa75bubble_volcano` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa75bubble_volcano.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-11-04 11:19 UTC，4.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `base_volcano.pdf` 第 1 页）：

![[recipes/figureya-75bubble-volcano/preview.png]]
<!-- facts:end -->

## 用途

用base plot画火山图：score对-log10P散点，点大小映射size、颜色映射group，叠加p=0.05与Bonferroni校正阈值线并给显著条目标名字。

## 适用

想在一张散点上同时呈现P值、校正P值、分组和size等多维信息，差异基因或富集结果均可；想用ggplot2请改用FigureYa59Volcano。

## 不适用

输入列名固定须含score、-log10P、group、size、pval；需要高亮的组名在代码里写死（PathwayA/C/H/E），换数据要手改。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节

第一列为条目名（作行名），其后五列依次为score、-log10P、group、size、pval。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-75bubble-volcano`
- 用到课题：`wiki.py use figureya-75bubble-volcano --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `base_volcano.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]] · [[templates/figureya-59volcanov2--volcano|bulk 差异火山图（分级着色）]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
