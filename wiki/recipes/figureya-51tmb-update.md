---
type: recipe
id: figureya-51tmb-update
title: 基因表达分组的TMB箱图
status: ready
source:
  id: figureya
  item: FigureYa51TMB_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa51TMB_update.Rmd
inputs:
- file: mutation-load.txt
  note: mutation-load.txt，TCGA的TMB，来源于2018年的这篇文献：The Immune Landscape of Cancer <https://pubmed.ncbi.nlm.nih.gov/29628290/>，我们直接拿来用就好。
- file: easy_input_expr.csv
  note: ''
- file: easy_input_group_2.csv
  note: ''
- file: easy_input_group_3.csv
  note: ''
outputs:
- TMB_dot.pdf
- TMB_point.pdf
packages:
  cran:
  - darkorchid3
  - dplyr
  - ggplot2
  - ggpubr
  - stringr
  bioc:
  - TCGAbiolinks
  - biomaRt
  github: []
  library:
  - TCGAbiolinks
  - dplyr
  - stringr
  - ggplot2
  - ggpubr
  namespaced:
  - knitr
  - data.table
tags:
- multi-omics
- transcriptomics
keywords:
- TMB
- TCGA
- ggpubr
- wilcox.test
- mutation-load
- TCGAbiolinks
- stringr
chart_types:
- boxplot
summary: 按某基因表达量中位数（或自定义cutoff）把样本分2-3组，画各组TMB箱图叠加散点/dotplot并用wilcox或kruskal算P值。
favorite: false
---
# 基因表达分组的TMB箱图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa51TMB_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa51TMB_update.Rmd`）
- 依赖：CRAN darkorchid3, dplyr, ggplot2, ggpubr, stringr；Bioconductor TCGAbiolinks, biomaRt
- 最近运行：pass（as-is，2026-11-04 15:08 UTC，20.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-51tmb-update/preview.png]]
<!-- facts:end -->

## 用途

按某基因表达量中位数（或自定义cutoff）把样本分2-3组，画各组TMB箱图叠加散点/dotplot并用wilcox或kruskal算P值。

## 适用

把基因表达与肿瘤突变负荷、免疫治疗响应关联起来，也可接下去按TMB高低分组做生存分析。

## 不适用

依赖现成的TMB表（mutation-load.txt，源自2018泛癌文献），非任意队列可直接算；分组表与TMB表样本ID须可按TCGA barcode前12位匹配，非TCGA体系需自行对齐。

## 输入

- `mutation-load.txt`：mutation-load.txt，TCGA的TMB，来源于2018年的这篇文献：The Immune Landscape of Cancer <https://pubmed.ncbi.nlm.nih.gov/29628290/>，我们直接拿来用就好。
- `easy_input_expr.csv`：见 Rmd“输入文件”节
- `easy_input_group_2.csv`：见 Rmd“输入文件”节
- `easy_input_group_3.csv`：见 Rmd“输入文件”节

expr两列（样本ID、表达值），group两列（样本ID、分组标签）；TMB表按Patient_ID与样本ID inner_join。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-51tmb-update`
- 用到课题：`wiki.py use figureya-51tmb-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `TMB_dot.pdf`
- `TMB_point.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
