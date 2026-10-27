---
type: recipe
id: figureya-173fancybar
title: 含亚组的多组均值柱图与比较
status: draft
source:
  id: figureya
  item: FigureYa173fancybar
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa173fancybar.Rmd
inputs: []
outputs:
- fancybar.pdf
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
keywords:
- mean ± se
- subgroup
- base graphics
chart_types:
- bar
- errorbar
summary: 画多组柱状图（mean ± se），部分大组含同色系亚组，同时做组间与亚组内比较标注。
favorite: false
---
# 含亚组的多组均值柱图与比较

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa173fancybar` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa173fancybar.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

画多组柱状图（mean ± se），部分大组含同色系亚组，同时做组间与亚组内比较标注。

## 适用

实验分组数据，有大组与亚组层级，每组若干重复。

## 不适用

期刊要求用 SD 时需改误差棒定义（先问作者）；小样本只画均值柱会掩盖分布；坐标与文字位置需手调。

## 输入

- 见 Rmd“输入文件”节（适配器未识别出文件名）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-173fancybar`
- 用到课题：`wiki.py use figureya-173fancybar --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `fancybar.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
