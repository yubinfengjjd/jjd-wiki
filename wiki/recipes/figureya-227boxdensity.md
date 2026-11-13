---
type: recipe
id: figureya-227boxdensity
title: 箱线图叠加密度分布图
status: ready
source:
  id: figureya
  item: FigureYa227boxdensity
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa227boxdensity.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs:
- boxdensity.pdf
packages:
  cran:
  - aplot
  - data.table
  - dplyr
  - ggplot2
  - ggpubr
  bioc: []
  github: []
  library:
  - ggplot2
  - data.table
  - aplot
  - ggpubr
  - dplyr
  namespaced:
  - knitr
tags:
- experimental-statistics
keywords:
- drug sensitivity
- IC50
- box density
- aplot
- data.table
- ggpubr
chart_types:
- boxplot
- density
summary: 比较两组的连续指标（如药物敏感性 IC50），箱线图与密度分布叠加展示。
favorite: false
---
# 箱线图叠加密度分布图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa227boxdensity` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa227boxdensity.Rmd`）
- 依赖：CRAN aplot, data.table, dplyr, ggplot2, ggpubr
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，3.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-227boxdensity/preview.png]]
<!-- facts:end -->

## 用途

比较两组的连续指标（如药物敏感性 IC50），箱线图与密度分布叠加展示。

## 适用

两组比较、每组样本量足以估计密度。

## 不适用

多于两组时需改配色与布局；本模块不做药敏预测（见 FigureYa212drugTargetV2）。

## 输入

- `easy_input.csv`：easy_input.csv，包含三列，后两列必需：分组信息Subtype和每个sample对应的AUC。
- `easy_input.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-227boxdensity`
- 用到课题：`wiki.py use figureya-227boxdensity --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `boxdensity.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
