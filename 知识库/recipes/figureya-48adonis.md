---
type: recipe
id: figureya-48adonis
title: Adonis因子解释度条形图
status: draft
source:
  id: figureya
  item: FigureYa48Adonis
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa48Adonis.Rmd
inputs:
- file: easy_input_meta.txt
  note: ''
- file: easy_input_factors.txt
  note: ''
- file: easy_input_factor.group.txt
  note: ''
outputs:
- adonis_barplot.pdf
packages:
  cran:
  - ggplot2
  - vegan
  bioc: []
  github: []
  library:
  - vegan
  - ggplot2
  namespaced:
  - knitr
tags:
- multi-omics
- experimental-statistics
keywords:
- vegan
- adonis2
- PERMANOVA
- Bray-Curtis
- UniFrac
- R2
- FDR
chart_types:
- bar
summary: 用vegan::adonis2对每个因子做PERMANOVA，按FDR筛显著因子后按R2画横条图，并可按因子类别着色分组。
favorite: false
---
# Adonis因子解释度条形图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa48Adonis` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa48Adonis.Rmd`）
- 依赖：CRAN ggplot2, vegan
- 最近运行：pass（as-is，2026-11-04 11:14 UTC，9.1 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-48adonis/preview.png]]
<!-- facts:end -->

## 用途

用vegan::adonis2对每个因子做PERMANOVA，按FDR筛显著因子后按R2画横条图，并可按因子类别着色分组。

## 适用

量化宿主表型、环境因子对群落或组学样本间差异的解释度，如临床指标对肠道菌群变异的贡献排序。

## 不适用

因子表与丰度表的样本名必须完全一致；一次一个因子解释边际效应，不替代多因子联合模型；因子数多而样本少时置换检验功效受限。

## 输入

- `easy_input_meta.txt`：见 Rmd“输入文件”节
- `easy_input_factors.txt`：见 Rmd“输入文件”节
- `easy_input_factor.group.txt`：见 Rmd“输入文件”节

meta表行微生物列样本（内部转置）；factors表行样本列因子；factor.group可选项，两列factor/group用于着色。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-48adonis`
- 用到课题：`wiki.py use figureya-48adonis --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `adonis_barplot.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
