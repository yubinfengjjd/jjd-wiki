---
type: recipe
id: figureya-41geo2lncrna-update
title: GEO芯片lncRNA表达提取
status: draft
source:
  id: figureya
  item: FigureYa41GEO2lncRNA_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa41GEO2lncRNA_update.Rmd
inputs:
- file: easy_input.csv
  note: 用【模块一】获得的`easy_input.csv`作为输入，基因名是gene symbol；
- file: mRNA.list.txt
  note: 基因列表：mRNA.list.txt。【模块二】的输出文件。包含一列基因名，可以是gene symbol，或者ensembl_gene_id，要跟表达矩阵的基因名一致。
- file: lncRNA.list.txt
  note: ''
outputs: []
packages:
  cran:
  - dplyr
  bioc:
  - Biobase
  - GEOquery
  - biomaRt
  github: []
  library:
  - Biobase
  - GEOquery
  - biomaRt
  - dplyr
  namespaced:
  - knitr
  - BiocManager
tags:
- transcriptomics
keywords:
- GEOquery
- biomaRt
- Biobase
- lncRNA
- Ensembl
- gene_biotype
- microarray
chart_types:
- table
summary: 三个独立模块：GEOquery下载芯片表达矩阵并注释基因名，biomaRt按gene_biotype区分lncRNA/mRNA/miRNA，按基因列表提取对应表
favorite: false
---
# GEO芯片lncRNA表达提取

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa41GEO2lncRNA_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa41GEO2lncRNA_update.Rmd`）
- 依赖：CRAN dplyr；Bioconductor Biobase, GEOquery, biomaRt
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

三个独立模块：GEOquery下载芯片表达矩阵并注释基因名，biomaRt按gene_biotype区分lncRNA/mRNA/miRNA，按基因列表提取对应表达矩阵。

## 适用

需要分别获得lncRNA/mRNA/miRNA表达矩阵做相关性或靶基因分析；或TCGA样本不足时改用GEO芯片数据补充。

## 不适用

芯片需带gene symbol或与Ensembl共有ID，否则要自行序列比对（本代码不含）；从普通芯片提取的miRNA只是前体杂交信号，要成熟体得找专门miRNA芯片；模块一只支持芯片不含测序数据。

## 输入

- `easy_input.csv`：用【模块一】获得的`easy_input.csv`作为输入，基因名是gene symbol；
- `mRNA.list.txt`：基因列表：mRNA.list.txt。【模块二】的输出文件。包含一列基因名，可以是gene symbol，或者ensembl_gene_id，要跟表达矩阵的基因名一致。
- `lncRNA.list.txt`：见 Rmd“输入文件”节

基因列表一行一个基因，symbol或ensembl_gene_id须与表达矩阵基因名同源；GEO下载必须同时给对GSE和对应GPL。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-41geo2lncrna-update`
- 用到课题：`wiki.py use figureya-41geo2lncrna-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：getGEO下载与biomaRt在线注释均需联网，国外服务可能慢或断线需重试。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
