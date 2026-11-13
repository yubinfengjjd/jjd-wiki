---
type: recipe
id: figureya-23count2tpm
title: RNA-seq计数转TPM换算
status: ready
source:
  id: figureya
  item: FigureYa23count2TPM
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa23count2TPMv2.Rmd
inputs:
- file: easy_input.txt
  note: ''
- file: eff_length.csv
  note: ''
- file: TCGA_FPKM2TPM.genes.txt
  note: ''
outputs: []
packages:
  cran: []
  bioc: []
  github: []
  library:
  - biomaRt
  - TCGAbiolinks
  namespaced:
  - knitr
  - R.utils
  - BiocInstaller
tags:
- transcriptomics
keywords:
- TPM
- FPKM
- biomaRt
- TCGAbiolinks
- GENCODE
- GTF
- effective length
chart_types:
- table
summary: 用基因有效长度把read count矩阵换算成TPM；长度可直接用随附eff_length.csv，或用GTF/biomaRt两种模式自行计算。
favorite: false
---
# RNA-seq计数转TPM换算

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa23count2TPM` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa23count2TPMv2.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-11-04 15:08 UTC，17.4 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用基因有效长度把read count矩阵换算成TPM；长度可直接用随附eff_length.csv，或用GTF/biomaRt两种模式自行计算。

## 适用

手里只有RNA-seq read count，需要TPM量纲做样本间比较或对接其他流程。

## 不适用

基因ID必须与有效长度表行名一致（示例按"."去Ensembl版本号）；属近似换算，有条件应直接用Salmon/kallisto/RSEM从FASTQ定量；CDS模式不统计非编码RNA。

## 输入

- `easy_input.txt`：见 Rmd“输入文件”节
- `eff_length.csv`：见 Rmd“输入文件”节
- `TCGA_FPKM2TPM.genes.txt`：见 Rmd“输入文件”节

表达矩阵第一列基因ID、行为样本；eff_length.csv行名为基因ID且须与矩阵同源。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-23count2tpm`
- 用到课题：`wiki.py use figureya-23count2tpm --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：基因长度计算耗时且步骤依赖联网：biomaRt查询、download.file下载GTF（示例还有TCGAbiolinks GDC下载）；TCGA人源数据可直接用随附eff_length.csv跳过该步。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
