---
type: recipe
id: figureya-42oncoprintv2-update
title: 按通路分组的突变瀑布图
status: draft
source:
  id: figureya
  item: FigureYa42oncoprintV2_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa42oncoprintV2_update.Rmd
inputs:
- file: easy_input.csv
  note: '`easy_input.csv`，01矩阵，每行一个基因，每列一个sample。01矩阵代表基因在这个sample里是否变异。'
- file: easy_input_cli.csv
  note: '`easy_input_cli.csv`，临床信息，例如人种、病史、治疗方式等。'
- file: onco_matrix.txt
  note: '`onco_matrix.txt`，基因变异矩阵，此处以FigureYa18的输出文件作为输入；'
- file: easy_input_pathway.csv
  note: ''
outputs:
- oncoprint_cli.pdf
- oncoprint_cli_nobar.pdf
- oncoprint_cli_multi.pdf
packages:
  cran: []
  bioc:
  - ComplexHeatmap
  github: []
  library:
  - ComplexHeatmap
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- ComplexHeatmap
- oncoPrint
- pathway
- 01矩阵
chart_types:
- oncoprint
summary: 用ComplexHeatmap把基因×样本的01矩阵或多类型变异矩阵画成oncoprint，按pathway行分割，上下挂临床信息注释条。
favorite: false
---
# 按通路分组的突变瀑布图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa42oncoprintV2_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa42oncoprintV2_update.Rmd`）
- 依赖：Bioconductor ComplexHeatmap
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用ComplexHeatmap把基因×样本的01矩阵或多类型变异矩阵画成oncoprint，按pathway行分割，上下挂临床信息注释条。

## 适用

只有基因是否变异的01矩阵（如基因检测报告汇总），或FigureYa18输出的多类型变异矩阵，需叠临床信息展示时。

## 不适用

需变异矩阵、pathway映射、临床注释三个文件且基因名/样本ID完全一致；remove_empty_columns与column_order参数需在多个oncoPrint调用间保持一致，否则临床条与样本错位。

## 输入

- `easy_input.csv`：`easy_input.csv`，01矩阵，每行一个基因，每列一个sample。01矩阵代表基因在这个sample里是否变异。
- `easy_input_pathway.txt`：`easy_input_pathway.txt`，基因所在的pathway；
- `easy_input_cli.csv`：`easy_input_cli.csv`，临床信息，例如人种、病史、治疗方式等。
- `onco_matrix.txt`：`onco_matrix.txt`，基因变异矩阵，此处以FigureYa18的输出文件作为输入；
- `easy_input_pathway.csv`：见 Rmd“输入文件”节

easy_input.csv行基因列样本（01或变异类型字符串）；pathway表行名须与矩阵基因一致；cli表sample列须与矩阵列名一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-42oncoprintv2-update`
- 用到课题：`wiki.py use figureya-42oncoprintv2-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `oncoprint_cli.pdf`
- `oncoprint_cli_nobar.pdf`
- `oncoprint_cli_multi.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
