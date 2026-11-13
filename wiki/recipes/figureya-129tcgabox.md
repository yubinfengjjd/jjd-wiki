---
type: recipe
id: figureya-129tcgabox
title: 跨分期基因表达分组箱图
status: draft
source:
  id: figureya
  item: FigureYa129TCGAbox
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa129TCGAbox.Rmd
inputs:
- file: HiSeqV2.gz
  note: gene expression RNAseq，IlluminaHiSeq (n=702) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/HiSeqV2.gz>
- file: mutation.gz
  note: somatic non-silent mutation (gene-level)，PANCAN AWG (n=461) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/mutation.gz>
- file: GBMLGG_clinicalMatrix.gz
  note: phenotype，Phenotypes (n=1,148) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/GBMLGG_clinicalMatrix.gz>
- file: LGG_clinicalMatrix.gz
  note: phenotype，Phenotypes (n=1,148) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/GBMLGG_clinicalMatrix.gz>
outputs:
- PD-L1.pdf
packages:
  cran:
  - remotes
  - data.table
  - ggplot2
  - ggpubr
  - ggsignif
  - gtools
  - tidyverse
  bioc: []
  github: []
  library:
  - tidyverse
  - ggplot2
  - ggpubr
  - data.table
  - gtools
  - ggsignif
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- TCGA
- UCSC Xena
- CD274
- IDH1
- ggpubr
- ggsignif
- data.table
- gtools
- tidyverse
chart_types:
- boxplot
summary: 整合Xena下载的TCGA表达、突变、临床三表，画某基因在各病理分期下按突变/亚型分组的箱图叠加散点，并标注Wilcoxon显著性。
favorite: false
---
# 跨分期基因表达分组箱图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa129TCGAbox` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa129TCGAbox.Rmd`）
- 依赖：CRAN remotes, data.table, ggplot2, ggpubr, ggsignif, gtools, tidyverse
- 最近运行：fail（as-is，2026-11-04 11:00 UTC，16.8 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

整合Xena下载的TCGA表达、突变、临床三表，画某基因在各病理分期下按突变/亚型分组的箱图叠加散点，并标注Wilcoxon显著性。

## 适用

看某个基因的表达能否在不同分期/分级中区分亚型或突变状态；也可写循环批量筛有分型能力的基因。

## 不适用

输入绑定TCGA Xena特定数据集结构（表达、突变、临床三表手工下载解压），换数据需自行改造合并逻辑；只做组间表达比较，不含生存或ROC分析。

## 输入

- ⚠️ 本配方部分输入为**合成输入**（格式相符的构造数据），仅用于执行验证，不构成真实数据分析结论；明细见 `repair/SYNTHETIC_INPUTS.md`。
- `HiSeqV2.gz`：gene expression RNAseq，IlluminaHiSeq (n=702) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/HiSeqV2.gz>
- `mutation.gz`：somatic non-silent mutation (gene-level)，PANCAN AWG (n=461) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/mutation.gz>
- `GBMLGG_clinicalMatrix.gz`：phenotype，Phenotypes (n=1,148) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/GBMLGG_clinicalMatrix.gz>
- `LGG_clinicalMatrix.gz`：phenotype，Phenotypes (n=1,148) TCGA hub，下载地址：<https://tcga.xenahubs.net/download/TCGA.GBMLGG.sampleMap/GBMLGG_clinicalMatrix.gz>

表达/突变矩阵行为基因、首列sample、列为样本；三表样本ID须一致，grade等分组列按所关注表型准备。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-129tcgabox`
- 用到课题：`wiki.py use figureya-129tcgabox --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：HiSeqV2、mutation、clinicalMatrix等.gz需从tcga.xenahubs手工下载（数百MB）并解压后再fread；代码本身不联网下载。

## 输出

- `PD-L1.pdf`

## 知识关联检查

2026-11-12：作者 jb 接受的结论是 repair-pass，不是 as-is pass。最新 as-is 收据 `runs/20261104T110018Z.json` 仍为 fail，原因是缺输入文件（File 'mutation' does not exist or is non-readable）。修补副本收据 `repair-runs/20261111T064730Z.json`（scope=repair）为 pass，只证明修补副本在记录环境可执行。catalog 的 `run` 保持该 as-is 收据的 fail，不改成 pass。

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
