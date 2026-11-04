---
type: recipe
id: figureya-219gmm
title: 高斯混合模型筛选最优分类模型
status: draft
source:
  id: figureya
  item: FigureYa219GMM
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa219GMM.Rmd
inputs:
- file: BRCA-miRNA.txt
  note: BRCA-miRNA.txt，TCGA-miRNA表达矩阵。
- file: tcga.sinfo.txt
  note: tcga.sinfo.txt，TCGA数据样本信息。
- file: gse40525.expr.txt
  note: gse40525.expr.txt，GSE40525表达矩阵。
- file: gse40525.sinfo.txt
  note: gse40525.sinfo.txt，GSE40525样本信息。
- file: tcga_tnbc_limma_test_result.tumor_vs_normal.txt
  note: ''
- file: gse_tnbc_limma_test_result.tumor_vs_normal.txt
  note: ''
outputs:
- GMM cluster of all auc model combination.pdf
packages:
  cran:
  - mclust
  - pROC
  bioc:
  - miRBaseVersions.db
  - miRBaseConverter
  - SimDesign
  github: []
  library:
  - mclust
  - miRBaseVersions.db
  - miRBaseConverter
  - pROC
  - SimDesign
  namespaced:
  - knitr
tags:
- transcriptomics
- machine-learning
- diagnostic-roc
keywords:
- GMM
- mclust
- pROC
- logistic regression
- miRBaseConverter
- miRNA
- limma
- SimDesign
- miRBaseVersions.db
chart_types:
- scatter
summary: 枚举候选miRNA的全部逻辑回归组合并各算AUC，用mclust高斯混合模型对AUC模式聚类，取最高AUC簇的最优模型输出系数以计算risk score。
favorite: false
---
# 高斯混合模型筛选最优分类模型

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa219GMM` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa219GMM.Rmd`）
- 依赖：CRAN mclust, pROC；Bioconductor miRBaseVersions.db, miRBaseConverter, SimDesign
- 最近运行：pass（as-is，2026-11-04 12:16 UTC，49.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `GMM cluster of all auc model combination.pdf` 第 1 页）：

![[recipes/figureya-219gmm/preview.png]]
<!-- facts:end -->

## 用途

枚举候选miRNA的全部逻辑回归组合并各算AUC，用mclust高斯混合模型对AUC模式聚类，取最高AUC簇的最优模型输出系数以计算risk score。

## 适用

少量候选特征（约10个miRNA/基因）里穷举挑选诊断或结局分类模型并获得各特征系数。

## 不适用

模型组合数为2^n-1，候选特征一多即组合爆炸，只适合小候选集；示例还要先对TCGA与GEO两套miRNA数据分别做limma再取交集，输入准备成本高。

## 输入

- `BRCA-miRNA.txt`：BRCA-miRNA.txt，TCGA-miRNA表达矩阵。
- `tcga.sinfo.txt`：tcga.sinfo.txt，TCGA数据样本信息。
- `gse40525.expr.txt`：gse40525.expr.txt，GSE40525表达矩阵。
- `gse40525.sinfo.txt`：gse40525.sinfo.txt，GSE40525样本信息。
- `tcga_tnbc_limma_test_result.tumor_vs_normal.txt`：见 Rmd“输入文件”节
- `gse_tnbc_limma_test_result.tumor_vs_normal.txt`：见 Rmd“输入文件”节

表达矩阵行=miRNA、列=样本；样本信息行名=样本且含PAM50与事件列（OS/PFI/DFI）；两个数据集的miRNA名需统一版本（示例用v21）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-219gmm`
- 用到课题：`wiki.py use figureya-219gmm --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `GMM cluster of all auc model combination.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
