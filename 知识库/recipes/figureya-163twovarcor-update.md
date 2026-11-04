---
type: recipe
id: figureya-163twovarcor-update
title: 分组相关性散点与系数差异检验
status: draft
source:
  id: figureya
  item: FigureYa163twoVarCor_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa163twoVarCor_update.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，第一列和第二列是连续变量，分别对应图上的横纵坐标，第三列是分组。
outputs:
- TwoVarCor.pdf
packages:
  cran: []
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
  - ggplot2
tags:
- experimental-statistics
- transcriptomics
keywords:
- Fisher's r-to-z transformation
- cor.test
- pearson
chart_types:
- scatter
summary: 两个连续变量画分组相关性散点图：颜色区分组、点大小表示两变量差值、加回归线和边际rug；附Fisher r-to-z检验比较两组相关系数差异。
favorite: false
---
# 分组相关性散点与系数差异检验

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa163twoVarCor_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa163twoVarCor_update.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

两个连续变量画分组相关性散点图：颜色区分组、点大小表示两变量差值、加回归线和边际rug；附Fisher r-to-z检验比较两组相关系数差异。

## 适用

展示两个基因/性状在不同分组中的相关性，或审稿要求给出两个相关系数差异的显著性检验。

## 不适用

各组横纵坐标必须是同一对变量，坐标不同的两组数据不适用；test2cor一次只比较两个相关系数，多组需逐对调用；点大小映射公式需按自己数据改。

## 输入

- `easy_input.csv`：easy_input.csv，第一列和第二列是连续变量，分别对应图上的横纵坐标，第三列是分组。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-163twovarcor-update`
- 用到课题：`wiki.py use figureya-163twovarcor-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `TwoVarCor.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
