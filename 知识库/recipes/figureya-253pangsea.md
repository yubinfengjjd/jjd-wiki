---
type: recipe
id: figureya-253pangsea
title: 泛癌分组GSEA富集气泡图
status: draft
source:
  id: figureya
  item: FigureYa253panGSEA
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa253panGSEA.Rmd
inputs:
- file: easy_input_sample_annotation.txt
  note: easy_input_sample_annotation.txt，样本分组信息。整理自注释文件merged_sample_quality_annotations.tsv，下载自<http://api.gdc.cancer.gov/data/1a7d7be8-675d-4e60-a105-19d4121bdebf>。
- file: easy_input_genelist.txt
  note: ''
- file: h.all.v7.2.symbols.gmt
  note: ''
outputs:
- GSEA regarding enrichment score group in pancancer.pdf
packages:
  cran:
  - data.table
  - ggplot2
  - ggpubr
  bioc:
  - clusterProfiler
  - GSVA
  - limma
  github: []
  library:
  - clusterProfiler
  - limma
  - ggplot2
  - data.table
  - ggpubr
  - GSVA
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- GSVA
- ssGSEA
- clusterProfiler
- limma
- data.table
- ggpubr
- HALLMARK
- TCGA
chart_types:
- bubble
summary: 按基因集ssGSEA得分（或单基因表达）把每个癌种样本分高/低30%两组，limma差异分析后clusterProfiler跑GSEA，画“癌种×通路”的NES
favorite: false
---
# 泛癌分组GSEA富集气泡图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa253panGSEA` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa253panGSEA.Rmd`）
- 依赖：CRAN data.table, ggplot2, ggpubr；Bioconductor clusterProfiler, GSVA, limma
- 最近运行：fail（as-is，2026-11-11 07:47 UTC，32.0 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

按基因集ssGSEA得分（或单基因表达）把每个癌种样本分高/低30%两组，limma差异分析后clusterProfiler跑GSEA，画“癌种×通路”的NES气泡图。

## 适用

想回答“某基因或基因集与哪些通路相关”，并在多个癌种间横向比较时。

## 不适用

流程按TCGA泛癌定制（条码第14位筛肿瘤、cancer type列名、样本名截前15位）；分组依据须为连续得分且只支持高低两组；依赖本地twoclasslimma.R；需自备gmt背景集。

## 输入

- `easy_input_sample_annotation.txt`：easy_input_sample_annotation.txt，样本分组信息。整理自注释文件merged_sample_quality_annotations.tsv，下载自<http://api.gdc.cancer.gov/data/1a7d7be8-675d-4e60-a105-19d4121bdebf>。
- `整理自注释文件merged_sample_quality_annotations.tsv`：easy_input_sample_annotation.txt，样本分组信息。整理自注释文件merged_sample_quality_annotations.tsv，下载自<http://api.gdc.cancer.gov/data/1a7d7be8-675d-4e60-a105-19d4121bdebf>。
- `EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv`：EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv，表达矩阵，第一列是基因，之后是其在每个样本中的表达量。下载自<http://api.gdc.cancer.gov/data/3586c0da-64d0-4b74-a449-5ff4d9136611>。这里以TCGA数据为例，对于非肿瘤数据或其他物种数据，套用其格式即可，可忽略文中对筛
- `merged_sample_quality_annotations.tsv`：easy_input_sample_annotation.txt，样本分组信息。整理自注释文件merged_sample_quality_annotations.tsv，下载自<http://api.gdc.cancer.gov/data/1a7d7be8-675d-4e60-a105-19d4121bdebf>。
- `geneExp.tsv`：EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv，表达矩阵，第一列是基因，之后是其在每个样本中的表达量。下载自<http://api.gdc.cancer.gov/data/3586c0da-64d0-4b74-a449-5ff4d9136611>。这里以TCGA数据为例，对于非肿瘤数据或其他物种数据，套用其格式即可，可忽略文中对筛
- `easy_input_genelist.txt`：见 Rmd“输入文件”节
- `h.all.v7.2.symbols.gmt`：见 Rmd“输入文件”节

表达矩阵首列为“symbol|id”格式需切分取symbol；样本注释需simple_barcode+cancer type两列，与矩阵列名（前15位）匹配。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-253pangsea`
- 用到课题：`wiki.py use figureya-253pangsea --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：泛癌表达矩阵EBPlusPlusAdjustPANCAN…geneExp.tsv需手动从GDC下载且体积大；20个癌种循环limma+GSEA耗时很长。

## 输出

- `GSEA regarding enrichment score group in pancancer.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
