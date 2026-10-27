---
type: recipe
id: figureya-39bar
title: 分组着色柱图与正负富集柱图
status: draft
source:
  id: figureya
  item: FigureYa39bar
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa39bar.Rmd
inputs:
- file: easy_input1.csv
  note: ''
- file: easy_input2.csv
  note: ''
- file: easy_input3.csv
  note: ''
outputs:
- CancerBar.pdf
- CancerBar_label.pdf
- GObar.pdf
- GObar_pval.pdf
packages:
  cran:
  - ggplot2
  bioc: []
  github: []
  library:
  - ggplot2
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- waterfall
- GSVA score
- diverging bar
chart_types:
- bar
- waterfall
summary: 场景一：各肿瘤（或样本）某指标的瀑布式排序柱图，按类别着色；场景二：GO/KEGG/GSVA 结果正负方向左右分开的发散柱图，不显著显示灰色。
favorite: false
---
# 分组着色柱图与正负富集柱图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa39bar` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa39bar.Rmd`）
- 依赖：CRAN ggplot2
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

场景一：各肿瘤（或样本）某指标的瀑布式排序柱图，按类别着色；场景二：GO/KEGG/GSVA 结果正负方向左右分开的发散柱图，不显著显示灰色。

## 适用

每行一个对象（肿瘤、样本或通路）和一个数值指标，可选分组与 P 值。

## 不适用

需要误差棒或组间检验的柱图；本模块不做 GSVA 计算（见 FigureYa61GSVA）。

## 输入

- `easy_input1.csv`：见 Rmd“输入文件”节
- `easy_input2.csv`：见 Rmd“输入文件”节
- `easy_input3.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-39bar`
- 用到课题：`wiki.py use figureya-39bar --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `CancerBar.pdf`
- `CancerBar_label.pdf`
- `GObar.pdf`
- `GObar_pval.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
