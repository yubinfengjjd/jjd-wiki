---
type: recipe
id: figureya-307cnvheatmap
title: 基因组拷贝数变异热图
status: draft
source:
  id: figureya
  item: FigureYa307CNVHeatmap
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa307CNVHeatmap.Rmd
inputs:
- file: TCGA_BLCA.all_thresholded.by_genes.txt
  note: 这里以TCGA数据为例。TCGA_BLCA.all_thresholded.by_genes.txt，该文件为GISTIC算法的输出文件之一，也可在<http://firebrowse.org/>中获取已经分析好的GISTIC结果。
outputs:
- CNVheatmap.pdf
packages:
  cran:
  - RColorBrewer
  - dplyr
  - ggplot2
  bioc:
  - TxDb.Hsapiens.UCSC.hg19.knownGene
  - TxDb.Hsapiens.UCSC.hg38.knownGene
  - trackViewer
  - ComplexHeatmap
  - TCGAbiolinks
  - circlize
  - org.Hs.eg.db
  github: []
  library:
  - ComplexHeatmap
  - TxDb.Hsapiens.UCSC.hg38.knownGene
  - TxDb.Hsapiens.UCSC.hg19.knownGene
  - trackViewer
  - org.Hs.eg.db
  - ggplot2
  - TCGAbiolinks
  - dplyr
  - RColorBrewer
  - circlize
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- GISTIC
- TCGAbiolinks
- trackViewer
- TxDb.Hsapiens.UCSC.hg19.knownGene
- org.Hs.eg.db
- ComplexHeatmap
- circlize
- RColorBrewer
- TxDb.Hsapiens.UCSC.hg38.knownGene
chart_types:
- heatmap
summary: 读GISTIC的all_thresholded.by_genes输出，按染色体位置排布基因画CNV增益/缺失热图，列按分子亚型分块、行按染色体分块，叠加临床注释
favorite: false
---
# 基因组拷贝数变异热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa307CNVHeatmap` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa307CNVHeatmap.Rmd`）
- 依赖：CRAN RColorBrewer, dplyr, ggplot2；Bioconductor TxDb.Hsapiens.UCSC.hg19.knownGene, TxDb.Hsapiens.UCSC.hg38.knownGene, trackViewer, ComplexHeatmap, TCGAbiolinks, circlize, org.Hs.eg.db
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

读GISTIC的all_thresholded.by_genes输出，按染色体位置排布基因画CNV增益/缺失热图，列按分子亚型分块、行按染色体分块，叠加临床注释与每基因变异计数条。

## 适用

展示大队列全基因组拷贝数格局（按亚型分层），如TCGA膀胱癌的CNV景观图。

## 不适用

输入必须是GISTIC的all_thresholded.by_genes.txt格式（前三列Gene Symbol/Locus ID/Cytoband）；样本名按TCGA条码截12位；亚型取自TCGAquery_subtype，非TCGA数据需改；只画chr1-22、人hg19/hg38。

## 输入

- `TCGA_BLCA.all_thresholded.by_genes.txt`：这里以TCGA数据为例。TCGA_BLCA.all_thresholded.by_genes.txt，该文件为GISTIC算法的输出文件之一，也可在<http://firebrowse.org/>中获取已经分析好的GISTIC结果。

GISTIC矩阵行=基因列=样本，列名截前12位后与亚型表的patient列匹配取交集。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-307cnvheatmap`
- 用到课题：`wiki.py use figureya-307cnvheatmap --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：TCGAquery_subtype需联网获取TCGA分子亚型表；基因定位依赖TxDb.Hsapiens与org.Hs.eg.db注释包。

## 输出

- `CNVheatmap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
