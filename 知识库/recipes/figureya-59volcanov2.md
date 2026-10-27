---
type: recipe
id: figureya-59volcanov2
title: 差异表达火山图（经典与进阶）
status: draft
source:
  id: figureya
  item: FigureYa59volcanoV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa59volcanoV2.Rmd
inputs:
- file: easy_input_limma.csv
  note: easy_input_limma.csv，此处用limma结果，还可以用EdgeR、DESeq2等工具获得的差异分析结果作为输入。
- file: easy_input_selected.csv
  note: easy_input_selected.csv，有时希望突出显示几个基因，例如后文进行功能验证的基因。会在突出显示的基因外面画黑色圆圈，并标出基因名。
outputs:
- volcano_classic.pdf
- Volcano_advanced.pdf
packages:
  cran:
  - ggplot2
  - ggrepel
  - ggthemes
  - gridExtra
  bioc: []
  github: []
  library:
  - ggplot2
  - ggrepel
  - ggthemes
  - gridExtra
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- limma
- ggrepel
- log2FC
- adjusted P
- ggthemes
- gridExtra
chart_types:
- volcano
summary: 用 limma 差异结果画经典火山图和标注选定基因的进阶火山图。
favorite: false
---
# 差异表达火山图（经典与进阶）

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa59volcanoV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa59volcanoV2.Rmd`）
- 依赖：CRAN ggplot2, ggrepel, ggthemes, gridExtra
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，7.6 秒）
- 派生模板（L2）：[[templates/figureya-59volcanov2--volcano|bulk 差异火山图（分级着色）]]（draft）
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-59volcanov2/preview.png]]
<!-- facts:end -->

## 用途

用 limma 差异结果画经典火山图和标注选定基因的进阶火山图。

## 适用

已有差异分析表（基因、log2FC、P 值/校正 P 值），两组比较。

## 不适用

多组同时比较（见 FigureYa135multiVolcano）；还没有做差异分析（先做 limma/DESeq2）。

## 输入

- `easy_input_limma.csv`：easy_input_limma.csv，此处用limma结果，还可以用EdgeR、DESeq2等工具获得的差异分析结果作为输入。
- `easy_input_selected.csv`：easy_input_selected.csv，有时希望突出显示几个基因，例如后文进行功能验证的基因。会在突出显示的基因外面画黑色圆圈，并标出基因名。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-59volcanov2`
- 用到课题：`wiki.py use figureya-59volcanov2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `volcano_classic.pdf`
- `Volcano_advanced.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
