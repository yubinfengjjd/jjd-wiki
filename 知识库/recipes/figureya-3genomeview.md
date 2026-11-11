---
type: recipe
id: figureya-3genomeview
title: 基因组区域信号轨迹图
status: draft
source:
  id: figureya
  item: FigureYa3genomeView
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa3genomeView.Rmd
inputs:
- file: loci.bed
  note: 需要展示的区域loci.bed
- file: easy_input.txt
  note: bigwig文件描述easy_input.txt
outputs:
- loci.pdf
packages:
  cran:
  - RColorBrewer
  - data.table
  bioc:
  - Gviz
  - TxDb.Hsapiens.UCSC.hg38.knownGene
  - org.Hs.eg.db
  github: []
  library:
  - data.table
  - Gviz
  - RColorBrewer
  - TxDb.Hsapiens.UCSC.hg38.knownGene
  - org.Hs.eg.db
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- Gviz
- bigwig
- ChIP-seq
- ATAC-seq
- DNase-seq
- TxDb.Hsapiens.UCSC.hg38.knownGene
- org.Hs.eg.db
- RColorBrewer
- data.table
chart_types:
- genome-track
summary: 用Gviz把loci.bed指定区域的染色体示意图、坐标轴、基因结构和多条bigwig信号轨画成一张矢量轨道图。
favorite: false
---
# 基因组区域信号轨迹图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa3genomeView` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa3genomeView.Rmd`）
- 依赖：CRAN RColorBrewer, data.table；Bioconductor Gviz, TxDb.Hsapiens.UCSC.hg38.knownGene, org.Hs.eg.db
- 最近运行：fail（as-is，2026-11-11 06:09 UTC，142.8 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用Gviz把loci.bed指定区域的染色体示意图、坐标轴、基因结构和多条bigwig信号轨画成一张矢量轨道图。

## 适用

需要ChIP-seq/DNase/ATAC-seq/RNA-seq信号的可编辑矢量图（替代IGV/UCSC截图），用于验证启动子、增强子、TF结合等。

## 不适用

基因组版本固定hg38（TxDb.Hsapiens.UCSC.hg38.knownGene）；一次只展示一个区域（按loci.bed取chr/start/end再按倍数扩展）；easy_input.txt的行名必须与bw文件名去掉.bw后缀一致。

## 输入

- `需要展示的区域loci.bed`：需要展示的区域loci.bed
- `bigwig文件TAL1.bw`：bigwig文件TAL1.bw，POLR2A.bw
- `POLR2A.bw`：bigwig文件TAL1.bw，POLR2A.bw
- `bigwig文件描述easy_input.txt`：bigwig文件描述easy_input.txt
- `loci.bed`：需要展示的区域loci.bed
- `TAL1.bw`：bigwig文件TAL1.bw，POLR2A.bw
- `easy_input.txt`：bigwig文件描述easy_input.txt

easy_input.txt无表头：行名=bw文件名（不带.bw）、唯一一列为展示轨名；loci.bed为chr/start/end/strand四列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-3genomeview`
- 用到课题：`wiki.py use figureya-3genomeview --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需自备bigwig(.bw)文件；依赖TxDb.Hsapiens.UCSC.hg38.knownGene与org.Hs.eg.db等大型注释包。

## 输出

- `loci.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
