---
type: recipe
id: figureya-203combat
title: 跨平台表达谱批次校正
status: draft
source:
  id: figureya
  item: FigureYa203ComBat
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa203ComBat.Rmd
inputs:
- file: easy_input_TCGA.csv
  note: 如果你的表达矩阵已处理成easy_input_TCGA.csv和easy_input_GSE\*.csv的格式，就可以跳过这步，直接进入“检查数据的量级”。
- file: overlapTable27.txt
  note: ''
- file: gse41613.expr.txt
  note: ''
- file: gse65858.expr.txt
  note: ''
- file: easy_input_GSE41613.csv
  note: ''
- file: easy_input_GSE65858.csv
  note: ''
outputs: []
packages:
  cran:
  - cluster
  bioc:
  - TCGAbiolinks
  - sva
  - SummarizedExperiment
  - edgeR
  - ClassDiscovery
  - oompaBase
  github: []
  library:
  - TCGAbiolinks
  - sva
  - cluster
  - oompaBase
  - SummarizedExperiment
  - edgeR
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- sva
- ComBat
- TCGAbiolinks
- edgeR
- SummarizedExperiment
- cluster
- oompaBase
chart_types:
- pca
summary: 合并TCGA RNA-seq与多套GEO芯片表达矩阵，log转换统一量级后用sva::ComBat去批次效应，PCA图对比校正前后。
favorite: false
---
# 跨平台表达谱批次校正

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa203ComBat` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa203ComBat.Rmd`）
- 依赖：CRAN cluster；Bioconductor TCGAbiolinks, sva, SummarizedExperiment, edgeR, ClassDiscovery, oompaBase
- 最近运行：fail（as-is，2026-11-11 06:56 UTC，150.7 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

合并TCGA RNA-seq与多套GEO芯片表达矩阵，log转换统一量级后用sva::ComBat去批次效应，PCA图对比校正前后。

## 适用

跨平台/跨队列表达谱整合前的批次效应评估与校正。

## 不适用

需各矩阵已整理成easy_input_*.csv（行=基因列=样本）且取共有基因交集；只校正已知批次标签，不处理未知混杂因素。

## 输入

- `easy_input_TCGA.csv`：如果你的表达矩阵已处理成easy_input_TCGA.csv和easy_input_GSE\*.csv的格式，就可以跳过这步，直接进入“检查数据的量级”。
- `overlapTable27.txt`：见 Rmd“输入文件”节
- `gse41613.expr.txt`：见 Rmd“输入文件”节
- `gse65858.expr.txt`：见 Rmd“输入文件”节
- `easy_input_GSE41613.csv`：见 Rmd“输入文件”节
- `easy_input_GSE65858.csv`：见 Rmd“输入文件”节

三套表达矩阵须有共同基因名（示例按gene symbol聚合去重）；TCGA端需先做log2(TPM+1)对齐芯片量级。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-203combat`
- 用到课题：`wiki.py use figureya-203combat --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：示例数据获取依赖联网：TCGA经TCGAbiolinks的GDCquery/GDCdownload下载，GEO经sangerbox网页预处理；已有easy_input文件可跳过。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
