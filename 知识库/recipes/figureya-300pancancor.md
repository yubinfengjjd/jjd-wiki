---
type: recipe
id: figureya-300pancancor
title: 泛癌签名得分相关散点图
status: draft
source:
  id: figureya
  item: FigureYa300pancanCor
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa300pancanCor.Rmd
inputs:
- file: merged_sample_quality_annotations.tsv
  note: merged_sample_quality_annotations.tsv，肿瘤注释文件。下载自<https://gdc.cancer.gov/about-data/publications/pancanatlas>。
- file: table s6 risk coefficients.txt
  note: table s6 risk coefficients.txt，风险基因以及对应系数，来自原文补充材料表格Table S6。
outputs:
- correlation scatter plot of zscored oncogenic and NETs in pancancer.pdf
- correlation scatter plot of zscored Angiogenesis and NETs in pancancer.pdf
- correlation scatter plot of zscored EMT and NETs in pancancer.pdf
- combined correlation scatter plot of zscored oncogenic and NETs in pancancer.pdf
packages:
  cran:
  - SimDesign
  - cowplot
  - data.table
  - ggplot2
  - rstatix
  - ggpubr
  - tidyr
  bioc:
  - GSVA
  github: []
  library:
  - ggplot2
  - data.table
  - cowplot
  - ggpubr
  - GSVA
  - SimDesign
  - tidyr
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- GSVA
- ssGSEA
- z-score
- NETs
- TCGA PanCanAtlas
- SimDesign
- ggpubr
- cowplot
- data.table
chart_types:
- scatter
summary: 在32个TCGA癌种中先用cox系数算签名得分排序癌种，再用GSVA z-score算签名与通路得分，画泛癌相关性散点图。
favorite: false
---
# 泛癌签名得分相关散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa300pancanCor` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa300pancanCor.Rmd`）
- 依赖：CRAN SimDesign, cowplot, data.table, ggplot2, rstatix, ggpubr, tidyr；Bioconductor GSVA
- 最近运行：pass（as-is，2026-11-11 07:25 UTC，20.5 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `correlation scatter plot of zscored oncogenic and NETs in pancancer.pdf` 第 1 页）：

![[recipes/figureya-300pancancor/preview.png]]
<!-- facts:end -->

## 用途

在32个TCGA癌种中先用cox系数算签名得分排序癌种，再用GSVA z-score算签名与通路得分，画泛癌相关性散点图。

## 适用

已有签名基因+系数和泛癌表达矩阵，想展示该得分与若干致癌通路活性在各癌种间的相关性。

## 不适用

输入文件体积大且绑定特定数据源（PanCanAtlas+xena生存表）；样本按TCGA barcode前15位截取匹配，换数据源需改匹配逻辑；换签名要同步改gmt和系数表；打分流程按原文设计不易泛化。

## 输入

- `coefficients.txt`：table s6 risk coefficients.txt，风险基因以及对应系数，来自原文补充材料表格Table S6。
- `merged_sample_quality_annotations.tsv`：merged_sample_quality_annotations.tsv，肿瘤注释文件。下载自<https://gdc.cancer.gov/about-data/publications/pancanatlas>。
- `EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv`：EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv，表达矩阵，第一列是基因，之后是其在每个样本中的表达量。下载自<https://gdc.cancer.gov/about-data/publications/pancanatlas>。
- `table s6 risk coefficients.txt`：table s6 risk coefficients.txt，风险基因以及对应系数，来自原文补充材料表格Table S6。

表达矩阵第一列为"gene|id"形式需按|取基因名；注释表生成simple_barcode；另需生存表筛样本、oncogenic.gmt定义通路。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-300pancancor`
- 用到课题：`wiki.py use figureya-300pancancor --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：EBPlusPlusAdjustPANCAN表达矩阵等大文件需自行从GDC PanCanAtlas页面下载，目录中未附带；逐癌种跑GSVA z-score耗时较长。

## 输出

- `correlation scatter plot of zscored oncogenic and NETs in pancancer.pdf`
- `correlation scatter plot of zscored Angiogenesis and NETs in pancancer.pdf`
- `correlation scatter plot of zscored EMT and NETs in pancancer.pdf`
- `combined correlation scatter plot of zscored oncogenic and NETs in pancancer.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
