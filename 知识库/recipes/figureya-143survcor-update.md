---
type: recipe
id: figureya-143survcor-update
title: 相关性散点叠加最佳截断四象限
status: draft
source:
  id: figureya
  item: FigureYa143survCor_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa143survCor_update.Rmd
inputs:
- file: survival_SKCM_survival.txt
  note: phenotype, Curated survival data (n=479) TCGA Hub, survival_SKCM_survival.txt
- file: survival_COADREAD_survival.txt
  note: phenotype, Curated survival data (n=728) TCGA Hub, survival_COADREAD_survival.txt
outputs: []
packages:
  cran:
  - shape
  - KMsurv
  - km.ci
  - survMisc
  - survival
  bioc: []
  github: []
  library:
  - survival
  - survMisc
  - shape
  namespaced:
  - knitr
  - ggplot2
tags:
- survival-analysis
- transcriptomics
keywords:
- log-rank statistic
- best cut-off
- MSI/MSS
- survMisc
- shape
- survival
chart_types:
- scatter
summary: 在两基因表达散点图上同时展示相关系数、按 log-rank 统计找到的最佳截断、四象限分组占比和 MSI/MSS 状态。
favorite: false
---
# 相关性散点叠加最佳截断四象限

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa143survCor_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa143survCor_update.Rmd`）
- 依赖：CRAN shape, KMsurv, km.ci, survMisc, survival
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，35.9 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

在两基因表达散点图上同时展示相关系数、按 log-rank 统计找到的最佳截断、四象限分组占比和 MSI/MSS 状态。

## 适用

TCGA 类表达矩阵与生存表，两个目标基因，想结合相关与生存截断解读。

## 不适用

只要相关散点（见 FigureYa92immune_gene_update）；最佳截断有过拟合风险，用于正式结论前需验证。

## 输入

- `TCGA.SKCM.sampleMap_HiSeqV2.gz`：gene expression RNAseq, IlluminaHiSeq (n=474) TCGA Hub, TCGA.SKCM.sampleMap_HiSeqV2.gz
- `survival_SKCM_survival.txt`：phenotype, Curated survival data (n=479) TCGA Hub, survival_SKCM_survival.txt
- `TCGA.COADREAD.sampleMap_HiSeqV2.gz`：gene expression RNAseq, ployA+ IlluminaHiSeq pancan normalized (n=434) TCGA Hub, TCGA.COADREAD.sampleMap_HiSeqV2.gz
- `survival_COADREAD_survival.txt`：phenotype, Curated survival data (n=728) TCGA Hub, survival_COADREAD_survival.txt

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-143survcor-update`
- 用到课题：`wiki.py use figureya-143survcor-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
