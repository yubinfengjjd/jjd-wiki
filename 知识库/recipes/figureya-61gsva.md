---
type: recipe
id: figureya-61gsva
title: GSVA 通路评分与组间差异
status: draft
source:
  id: figureya
  item: FigureYa61GSVA
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa61GSVA.Rmd
inputs:
- file: hallmark.gs.RData
  note: hallmark.gs.RData：“整理通路里的基因列表”这部分生成的，同一物种同一版本注释可重复使用。
- file: easy_input_expr.csv
  note: easy_input_expr.csv：基因表达矩阵，每行一个基因，每列一个sample。
- file: easy_input2_for39bar.csv
  note: ''
outputs:
- gsva.pdf
packages:
  cran:
  - data.table
  - dplyr
  - ggplot2
  - msigdbr
  - stringr
  bioc:
  - GSVA
  - limma
  github: []
  library:
  - msigdbr
  - dplyr
  - data.table
  - GSVA
  - limma
  - stringr
  - ggplot2
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- GSVA
- msigdbr
- Hallmark
- limma
- data.table
- stringr
chart_types:
- bar
summary: 把“样本×基因”表达矩阵用 GSVA 转成“样本×通路”评分，用 limma 找组间差异通路，结果可接 FigureYa39bar 画图。
favorite: false
---
# GSVA 通路评分与组间差异

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa61GSVA` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa61GSVA.Rmd`）
- 依赖：CRAN data.table, dplyr, ggplot2, msigdbr, stringr；Bioconductor GSVA, limma
- 最近运行：pass（as-is，2026-11-04 04:21 UTC，15.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-61gsva/preview.png]]
<!-- facts:end -->

## 用途

把“样本×基因”表达矩阵用 GSVA 转成“样本×通路”评分，用 limma 找组间差异通路，结果可接 FigureYa39bar 画图。

## 适用

表达矩阵（基因符号为行名）与样本分组，基因集用 Hallmark 或自定义 gmt。

## 不适用

单样本或极少样本；基因 ID 不是 symbol 时需先转换。

## 输入

- `hallmark.gs.RData`：hallmark.gs.RData：“整理通路里的基因列表”这部分生成的，同一物种同一版本注释可重复使用。
- `easy_input_expr.csv`：easy_input_expr.csv：基因表达矩阵，每行一个基因，每列一个sample。
- `Hallmark.gs.RData`：Hallmark.gs.RData: This section generates a list of genes in the pathway, and annotations for the same species and version can be reused.
- `Easyinput-expr.csv`：Easyinput-expr.csv: Gene expression matrix, with one gene per row and one sample per column.
- `easy_input2_for39bar.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-61gsva`
- 用到课题：`wiki.py use figureya-61gsva --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `gsva.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
