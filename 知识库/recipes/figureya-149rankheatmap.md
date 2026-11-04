---
type: recipe
id: figureya-149rankheatmap
title: 差异倍数分档注释热图
status: draft
source:
  id: figureya
  item: FigureYa149rankHeatmap
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa149rankHeatmap.Rmd
inputs:
- file: easy_input_logFc.csv
  note: easy_input_logFc.csv，差异表达分析当中的**logFC**值，还可以替换为相关分析的相关系数。
- file: easy_input_PVal.csv
  note: easy_input_PVal.csv，差异表达分析当中的**P**值。
- file: genetype.csv
  note: genetype.csv，基因的分组，用于画最左侧annotation，非必须。
outputs:
- rankHeatmap.pdf
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
- transcriptomics
- experimental-statistics
keywords:
- ComplexHeatmap
- logFC
chart_types:
- heatmap
summary: 把logFC（或相关系数）按阈值切成5档、P≥0.05归入第6档，用ComplexHeatmap画分类热图并在格内标数值，左侧可加分组注释。
favorite: false
---
# 差异倍数分档注释热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa149rankHeatmap` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa149rankHeatmap.Rmd`）
- 依赖：Bioconductor ComplexHeatmap
- 最近运行：pass（as-is，2026-11-04 11:01 UTC，15.8 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `rankHeatmap.pdf` 第 1 页）：

![[recipes/figureya-149rankheatmap/preview.png]]
<!-- facts:end -->

## 用途

把logFC（或相关系数）按阈值切成5档、P≥0.05归入第6档，用ComplexHeatmap画分类热图并在格内标数值，左侧可加分组注释。

## 适用

展示一批基因在多组/多癌种间的差异或相关结果，想弱化连续值、突出上下调档位趋势时。

## 不适用

logFC与P值两个矩阵行列名必须一一对应；分档阈值（±1/±2、P=0.05）与调色写死在代码；只做展示，不含差异分析计算。

## 输入

- `easy_input_logFc.csv`：easy_input_logFc.csv，差异表达分析当中的**logFC**值，还可以替换为相关分析的相关系数。
- `easy_input_PVal.csv`：easy_input_PVal.csv，差异表达分析当中的**P**值。
- `genetype.csv`：genetype.csv，基因的分组，用于画最左侧annotation，非必须。

logFc矩阵与PVal矩阵均为行=基因、列=分组且维度同名；genetype.csv（gene+type列）可选，用于行注释并决定行顺序。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-149rankheatmap`
- 用到课题：`wiki.py use figureya-149rankheatmap --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `rankHeatmap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
