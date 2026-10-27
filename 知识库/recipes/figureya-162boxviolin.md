---
type: recipe
id: figureya-162boxviolin
title: 半小提琴箱线散点组合图
status: draft
source:
  id: figureya
  item: FigureYa162boxViolin
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa162boxViolin.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，两组的DNA甲基化年龄。第一列是DNA甲基化年龄，第二列是分组。
- file: easy_input_multi.csv
  note: ''
outputs:
- boxViolin.pdf
- boxViolin_multipleGroups.pdf
packages:
  cran:
  - ggplot2
  - ggpubr
  bioc: []
  github: []
  library:
  - ggplot2
  - ggpubr
  namespaced:
  - knitr
tags:
- experimental-statistics
keywords:
- raincloud
- half violin
- group comparison
- ggpubr
chart_types:
- violin
- boxplot
summary: 比较两组或多组的一个连续变量，把原始数据点、箱线统计量和小提琴密度画在一起。
favorite: false
---
# 半小提琴箱线散点组合图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa162boxViolin` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa162boxViolin.Rmd`）
- 依赖：CRAN ggplot2, ggpubr
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，3.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-162boxviolin/preview.png]]
<!-- facts:end -->

## 用途

比较两组或多组的一个连续变量，把原始数据点、箱线统计量和小提琴密度画在一起。

## 适用

长格式表：每行一个观测，一列分组、一列数值。

## 不适用

每组样本很少（密度估计不稳）；配对或重复测量设计需要连线展示。

## 输入

- `easy_input.csv`：easy_input.csv，两组的DNA甲基化年龄。第一列是DNA甲基化年龄，第二列是分组。
- `easy_input_multi.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-162boxviolin`
- 用到课题：`wiki.py use figureya-162boxviolin --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `boxViolin.pdf`
- `boxViolin_multipleGroups.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] · [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
