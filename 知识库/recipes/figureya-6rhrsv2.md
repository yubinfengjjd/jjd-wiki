---
type: recipe
id: figureya-6rhrsv2
title: 临床亚组分析森林图
status: ready
source:
  id: figureya
  item: FigureYa6rHRsV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa6rHRsV2.Rmd
inputs:
- file: easy_input.csv
  note: 测试用数据文件为easy_input.csv，分类、样本数、风险比及置信区间(上限及下限)对应的列名分别是Variable、Count、Point.Estimate、Low和High
outputs:
- forestplot.pdf
packages:
  cran:
  - checkmate
  - forestplot
  bioc: []
  github: []
  library:
  - forestplot
  namespaced:
  - knitr
tags:
- survival-analysis
keywords:
- subgroup analysis
- forestplot
- hazard ratio
chart_types:
- forest
summary: 把已经算好的各亚组 HR 与 95% CI（及例数、P 值）画成带表格列的临床亚组森林图。
favorite: false
---
# 临床亚组分析森林图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa6rHRsV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa6rHRsV2.Rmd`）
- 依赖：CRAN checkmate, forestplot
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，1.0 秒）
- 派生模板（L2）：[[templates/figureya-6rhrsv2--forest|亚组分析森林图]]（ready）
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-6rhrsv2/preview.png]]
<!-- facts:end -->

## 用途

把已经算好的各亚组 HR 与 95% CI（及例数、P 值）画成带表格列的临床亚组森林图。

## 适用

每个亚组一行，已有 HR、下限、上限（如 FigureYa66UnivariateCox 的 cox_output.csv 改列名后）。

## 不适用

需要从原始数据计算 HR 或交互作用检验（本模块只画图，计算见 FigureYa66/FigureYa90）；OR 或均值差等非比值效应需先确认坐标轴含义。

## 输入

- `测试用数据文件为easy_input.csv`：测试用数据文件为easy_input.csv，分类、样本数、风险比及置信区间(上限及下限)对应的列名分别是Variable、Count、Point.Estimate、Low和High
- `easy_input.csv`：测试用数据文件为easy_input.csv，分类、样本数、风险比及置信区间(上限及下限)对应的列名分别是Variable、Count、Point.Estimate、Low和High

只从形式上复现：输入是已汇总的亚组效应表，模块不做 Cox 回归。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-6rhrsv2`
- 用到课题：`wiki.py use figureya-6rhrsv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `forestplot.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
