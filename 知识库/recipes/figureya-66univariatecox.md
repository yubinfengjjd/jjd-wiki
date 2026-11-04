---
type: recipe
id: figureya-66univariatecox
title: 批量单基因Cox森林图
status: draft
source:
  id: figureya
  item: FigureYa66UnivariateCox
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa66UnivariateCox.Rmd
inputs:
- file: cox_output.csv
  note: 如果你的数据已经整理成cox_output.csv的格式，就可以跳过这步，直接进入“开始画图”。
- file: samplepair.txt
  note: ''
- file: TCGA_phenotype_denseDataOnlyDownload.tsv
  note: ''
- file: easy_input_expr.csv
  note: ''
- file: easy_input_4cox.csv
  note: 如果你的数据已经整理成easy_input_4cox.csv的格式，就可以跳过这步，直接进入“单因素cox分析”。
- file: suptable2LUAD.csv
  note: ''
outputs:
- plot1.pdf
- plot2.pdf
- plot3.pdf
- sameplot.pdf
packages:
  cran:
  - tidyverse
  - ggplot2
  - survival
  - stringr
  - viridis
  - scales
  bioc: []
  github: []
  library:
  - tidyverse
  - ggplot2
  - survival
  - stringr
  - viridis
  - scales
  namespaced:
  - knitr
tags:
- survival-analysis
- transcriptomics
keywords:
- survival
- coxph
- TCGA
- xena
- tidyverse
- viridis
- scales
- stringr
chart_types:
- forest
summary: 对表达矩阵逐列特征跑单因素Cox回归，导出含HR/z/P/95%CI的cox_output.csv，再画HR=1虚线、点染P值的森林图（三种配色可选）。
favorite: false
---
# 批量单基因Cox森林图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa66UnivariateCox` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa66UnivariateCox.Rmd`）
- 依赖：CRAN tidyverse, ggplot2, survival, stringr, viridis, scales
- 最近运行：pass（as-is，2026-11-04 11:18 UTC，23.7 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-66univariatecox/preview.png]]
<!-- facts:end -->

## 用途

对表达矩阵逐列特征跑单因素Cox回归，导出含HR/z/P/95%CI的cox_output.csv，再画HR=1虚线、点染P值的森林图（三种配色可选）。

## 适用

批量筛预后相关基因或特征，表达、甲基化、miRNA、可变剪切等连续变量均适用。

## 不适用

easy_input_4cox.csv前两列必须是OS.time、OS生存列，第3列起为特征；单因素无协变量校正；展示阈值（HR≤0.92/≥1.15）与x轴刻度写死；画图依赖本地ggscatterstats.R/theme-ggstatsplot.R。

## 输入

- `处理为cox分析需要的的easy_input.csv`：此处以LUAD为例，从TCGA下载生存资料和表达矩阵，处理为cox分析需要的的easy_input.csv。
- `easy_input_4coxv.csv`：If your data has been organized into easy_input_4coxv.csv format, you can skip this step and go directly to "Univariate Cox analysis".
- `cox_output.csv`：如果你的数据已经整理成cox_output.csv的格式，就可以跳过这步，直接进入“开始画图”。
- `easy_input.csv`：此处以LUAD为例，从TCGA下载生存资料和表达矩阵，处理为cox分析需要的的easy_input.csv。
- `samplepair.txt`：见 Rmd“输入文件”节
- `TCGA_phenotype_denseDataOnlyDownload.tsv`：见 Rmd“输入文件”节
- `easy_input_expr.csv`：见 Rmd“输入文件”节
- `easy_input_4cox.csv`：如果你的数据已经整理成easy_input_4cox.csv的格式，就可以跳过这步，直接进入“单因素cox分析”。
- `suptable2LUAD.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-66univariatecox`
- 用到课题：`wiki.py use figureya-66univariatecox --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：输入整理演示用xena手动下载的TCGA表型/生存表；绘图需同目录两个ggstatsplot派生脚本。

## 输出

- `plot1.pdf`
- `plot2.pdf`
- `plot3.pdf`
- `sameplot.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/figureya-6rhrsv2--forest|亚组分析森林图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
