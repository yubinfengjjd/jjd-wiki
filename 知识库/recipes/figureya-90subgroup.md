---
type: recipe
id: figureya-90subgroup
title: 亚组生存风险森林图
status: draft
source:
  id: figureya
  item: FigureYa90subgroup
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa90subgroup.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，score（连续变量）和score_binary（二分类变量）至少包含其中一列，后面分别提供两种计算方式。
- file: subgroup.csv
  note: 如果你的数据已经整理成subgroup.csv的格式，就可以跳过这步，直接进入“开始画图”。
outputs:
- subgroup.pdf
packages:
  cran:
  - forestplot
  - survival
  - tidyverse
  bioc: []
  github: []
  library:
  - tidyverse
  - survival
  - forestplot
  namespaced:
  - knitr
tags:
- survival-analysis
keywords:
- forestplot
- survival
- coxph
- hazard ratio
- tidyverse
- subgroup
chart_types:
- forest
summary: 对score（连续或二分类）在各亚组内分别做Cox回归得HR/CI/P，合并总体结果后用forestplot画带样本量和百分比的亚组森林图。
favorite: false
---
# 亚组生存风险森林图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa90subgroup` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa90subgroup.Rmd`）
- 依赖：CRAN forestplot, survival, tidyverse
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对score（连续或二分类）在各亚组内分别做Cox回归得HR/CI/P，合并总体结果后用forestplot画带样本量和百分比的亚组森林图。

## 适用

临床亚组分析，检验某指标或评分在不同人群分层中的预后效应方向与显著性是否一致。

## 不适用

输入需含固定列（OS_time_months、OS_status、score或score_binary及亚组变量）；计算依赖随附function_subgroup_survival_analysis.R；hrzl_lines、分隔行等按数据行数手调，subgroup.csv的行序与文字即图上所见。

## 输入

- `easy_input.csv`：easy_input.csv，score（连续变量）和score_binary（二分类变量）至少包含其中一列，后面分别提供两种计算方式。
- `subgroup.csv`：如果你的数据已经整理成subgroup.csv的格式，就可以跳过这步，直接进入“开始画图”。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-90subgroup`
- 用到课题：`wiki.py use figureya-90subgroup --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `subgroup.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/figureya-6rhrsv2--forest|亚组分析森林图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
