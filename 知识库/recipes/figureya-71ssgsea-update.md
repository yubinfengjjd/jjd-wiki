---
type: recipe
id: figureya-71ssgsea-update
title: 免疫浸润ssGSEA注释热图
status: draft
source:
  id: figureya
  item: FigureYa71ssGSEA_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa71ssGSEA_update.Rmd
inputs:
- file: easy_input_immunity.rdata
  note: easy_input_immunity.rdata，24种免疫细胞marker genes的ENTREZ ID，保存为list。来源：[2013 Immunity那篇文章的Table
    S1](https://www.cell.com/cms/10.1016/j.immuni.2013.10.003/attachment/8dc04d32-6aff-4eda-99f5-6401bcae9751/mm
- file: easy_input_expr.csv
  note: easy_input_expr.csv，基因表达矩阵，每行一个基因，每列一个sample。第一列基因ID跟easy_input_immunity.rdata里的基因ID一致，此处都用ENTREZ
    ID。
- file: immunitygene.csv
  note: ''
- file: gtf_v22.csv
  note: ''
- file: TCGA-COAD.somaticmutation_wxs.tsv.gz
  note: ''
- file: TCGA-READ.somaticmutation_wxs.tsv.gz
  note: ''
- file: ssGSEA_output.csv
  note: ''
- file: heatmapinput.csv
  note: ''
outputs:
- ssGSEA.pdf
packages:
  cran:
  - RColorBrewer
  - circlize
  - data.table
  - dplyr
  - pheatmap
  - readr
  - stringr
  bioc:
  - ComplexHeatmap
  - GSVA
  - GenomicRanges
  - GetoptLong
  - SummarizedExperiment
  - TCGAbiolinks
  - circlize
  - clusterProfiler
  - maftools
  - matrixStats
  - org.Hs.eg.db
  - rtracklayer
  github: []
  library:
  - GSVA
  - org.Hs.eg.db
  - TCGAbiolinks
  - ComplexHeatmap
  - dplyr
  - stringr
  - rtracklayer
  - SummarizedExperiment
  - clusterProfiler
  - RColorBrewer
  - maftools
  - circlize
  - matrixStats
  - GetoptLong
  - GenomicRanges
  - data.table
  - pheatmap
  - readr
  namespaced:
  - knitr
tags:
- transcriptomics
- multi-omics
keywords:
- GSVA
- ssGSEA
- ComplexHeatmap
- TCGAbiolinks
- org.Hs.eg.db
- maftools
- immune infiltration
- GenomicRanges
- GetoptLong
- RColorBrewer
- SummarizedExperiment
- circlize
- clusterProfiler
- data.table
- matrixStats
chart_types:
- heatmap
summary: 用ssGSEA按免疫细胞marker基因集量化TCGA样本浸润得分，再整合突变/MSI/临床注释画ComplexHeatmap并聚类分高低浸润组；也可只跑到ss
favorite: false
---
# 免疫浸润ssGSEA注释热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa71ssGSEA_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa71ssGSEA_update.Rmd`）
- 依赖：CRAN RColorBrewer, circlize, data.table, dplyr, pheatmap, readr, stringr；Bioconductor ComplexHeatmap, GSVA, GenomicRanges, GetoptLong, SummarizedExperiment, TCGAbiolinks, circlize, clusterProfiler, maftools, matrixStats, org.Hs.eg.db, rtracklayer
- 最近运行：fail（as-is，2026-11-11 06:11 UTC，19.6 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用ssGSEA按免疫细胞marker基因集量化TCGA样本浸润得分，再整合突变/MSI/临床注释画ComplexHeatmap并聚类分高低浸润组；也可只跑到ssGSEA得分。

## 适用

有表达矩阵和免疫细胞marker集，想量化肿瘤免疫浸润并与突变、临床特征联合展示，复现免疫浸润分型热图。

## 不适用

ssGSEA得分不能跨数据集比较；表达矩阵行名ID类型须与marker集一致（示例为ENTREZ ID）；复现原图另需maf突变、临床matrix等TCGA配套文件；marker表需CellType+ENTREZ_GENE_ID列。

## 输入

- `easy_input_immunity.rdata`：easy_input_immunity.rdata，24种免疫细胞marker genes的ENTREZ ID，保存为list。来源：[2013 Immunity那篇文章的Table S1](https://www.cell.com/cms/10.1016/j.immuni.2013.10.003/attachment/8dc04d32-6aff-4eda-99f5-6401bcae9751/mm
- `easy_input_expr.csv`：easy_input_expr.csv，基因表达矩阵，每行一个基因，每列一个sample。第一列基因ID跟easy_input_immunity.rdata里的基因ID一致，此处都用ENTREZ ID。
- `immunitygene.csv`：见 Rmd“输入文件”节
- `gencode.v22.annotation.gtf`：见 Rmd“输入文件”节
- `not_easy_input_expr.csv`：见 Rmd“输入文件”节
- `gtf_v22.csv`：见 Rmd“输入文件”节
- `TCGA-COAD.somaticmutation_wxs.tsv.gz`：见 Rmd“输入文件”节
- `TCGA-READ.somaticmutation_wxs.tsv.gz`：见 Rmd“输入文件”节
- `ssGSEA_output.csv`：见 Rmd“输入文件”节
- `heatmapinput.csv`：见 Rmd“输入文件”节

easy_input_expr.csv行=基因、列=样本；easy_input_immunity.rdata为按细胞类型分组的ENTREZ ID list；样本ID取前12位与临床/突变对齐。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-71ssgsea-update`
- 用到课题：`wiki.py use figureya-71ssgsea-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：准备表达矩阵需gencode.v22.annotation.gtf（GENCODE FTP下载）做gene_id→ENTREZ转换，aggregate步骤耗时较长；TCGA突变/临床下载代码已注释、改用本地预置文件。

## 输出

- `ssGSEA.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
