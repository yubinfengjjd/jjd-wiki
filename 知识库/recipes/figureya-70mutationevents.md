---
type: recipe
id: figureya-70mutationevents
title: 突变共现互斥气泡矩阵图
status: draft
source:
  id: figureya
  item: FigureYa70mutationEvents
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa70mutationEvents.Rmd
inputs:
- file: easy_input_mutation.csv
  note: 如果你的数据已经保存为“easy_input_mutation.csv”，就可以跳过这步，直接进入“Co-occurrence/mutual exclusivity分析”。
- file: 41586_2018_623_MOESM4_ESM.xlsx
  note: 输入数据来源：例文的Source Data Fig. 1，<https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-018-0623-z/MediaObjects/41586_2018_623_MOESM4_ESM.xlsx>，Tab
    C。
- file: easy_input.csv
  note: easy_input.csv，只需要4列，前两列是基因名，第三列决定点的大小和“***”符号（此处是p value），第四列决定点的颜色（此处是odd
    ratio）。根据自己的需要填后两列的数值。
- file: samplepair.txt
  note: ''
- file: GTEX_phenotype.tsv
  note: ''
- file: TCGA_phenotype_denseDataOnlyDownload.tsv
  note: ''
outputs: []
packages:
  cran:
  - reshape2
  - RColorBrewer
  - Cairo
  - readr
  - corrplot
  - openxlsx
  - data.table
  bioc: []
  github: []
  library:
  - reshape2
  - RColorBrewer
  - Cairo
  - readr
  - corrplot
  - openxlsx
  - data.table
  namespaced:
  - knitr
tags:
- multi-omics
- experimental-statistics
keywords:
- DISCOVER
- corrplot
- co-occurrence
- mutual exclusivity
- odds ratio
- TCGA mc3
- Cairo
- RColorBrewer
- data.table
- openxlsx
- readr
- reshape2
chart_types:
- heatmap
summary: 对基因×样本01突变矩阵用随附的DISCOVER脚本做成对共现/互斥检验，再用corrplot画odds ratio着色的气泡矩阵并以星号标P值显著性。
favorite: false
---
# 突变共现互斥气泡矩阵图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa70mutationEvents` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa70mutationEvents.Rmd`）
- 依赖：CRAN reshape2, RColorBrewer, Cairo, readr, corrplot, openxlsx, data.table
- 最近运行：fail（as-is，2026-11-11 07:10 UTC，71.6 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对基因×样本01突变矩阵用随附的DISCOVER脚本做成对共现/互斥检验，再用corrplot画odds ratio着色的气泡矩阵并以星号标P值显著性。

## 适用

在TCGA等突变谱中筛高频突变基因，看哪些基因倾向共突变或互斥，提示同通路或协同致癌关系。

## 不适用

需先筛高频突变基因（示例>25例）否则检验效能低；DISCOVER只输出P值不输出odds ratio，后两列数值需自行计算填入；全基因组两两检验计算量大。

## 输入

- `easy_input_mutation.csv`：如果你的数据已经保存为“easy_input_mutation.csv”，就可以跳过这步，直接进入“Co-occurrence/mutual exclusivity分析”。
- `41586_2018_623_MOESM4_ESM.xlsx`：输入数据来源：例文的Source Data Fig. 1，<https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-018-0623-z/MediaObjects/41586_2018_623_MOESM4_ESM.xlsx>，Tab C。
- `easy_input.csv`：easy_input.csv，只需要4列，前两列是基因名，第三列决定点的大小和“***”符号（此处是p value），第四列决定点的颜色（此处是odd ratio）。根据自己的需要填后两列的数值。
- `mc3.v0.2.8.PUBLIC.nonsilentGene.xena`：见 Rmd“输入文件”节
- `samplepair.txt`：见 Rmd“输入文件”节
- `GTEX_phenotype.tsv`：见 Rmd“输入文件”节
- `TCGA_phenotype_denseDataOnlyDownload.tsv`：见 Rmd“输入文件”节

突变矩阵行基因列样本、取值0/1；画图输入easy_input.csv四列（Gene1、Gene2、P值、odds ratio），且两个矩阵行列顺序必须一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-70mutationevents`
- 用到课题：`wiki.py use figureya-70mutationevents --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：mc3泛癌突变文件很大读取慢，xena突变/表型文件与GTEx表需预先下载；例文Source Data为xlsx需openxlsx读取；DISCOVER以包内data.R/analysis.R脚本形式提供而非安装包。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
