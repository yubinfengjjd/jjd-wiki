---
type: recipe
id: figureya-120multiclassedger
title: 多组edgeR配对差异分析
status: ready
source:
  id: figureya
  item: FigureYa120MulticlassedgeR
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa120MulticlassedgeR.Rmd
inputs:
- file: easy_input_counts.txt
  note: ''
- file: easy_input_subtype.txt
  note: ''
outputs: []
packages:
  cran:
  - pheatmap
  - RColorBrewer
  - gplots
  bioc:
  - edgeR
  github: []
  library:
  - edgeR
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- edgeR
chart_types:
- table
summary: 用edgeR对三个及以上亚型逐组做"该组vs其余样本"的差异表达分析，每组输出一个DEG结果表，可对接亚型GSEA或marker筛选。
favorite: false
---
# 多组edgeR配对差异分析

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa120MulticlassedgeR` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa120MulticlassedgeR.Rmd`）
- 依赖：CRAN pheatmap, RColorBrewer, gplots；Bioconductor edgeR
- 最近运行：pass（as-is，2026-11-04 10:59 UTC，18.8 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用edgeR对三个及以上亚型逐组做"该组vs其余样本"的差异表达分析，每组输出一个DEG结果表，可对接亚型GSEA或marker筛选。

## 适用

手里是RNA-seq原始read count矩阵加分组表，需要批量拿到每个亚型相对其他样本的差异基因列表。

## 不适用

只接受raw count输入，FPKM/RPKM或芯片数据需换limma/DESeq2版本；createList里亚型名硬编码（immune/keratin/MITF-low），换数据必须改写；不做批次效应校正，有批次需自行纳入设计矩阵。

## 输入

- `easy_input_counts.txt`：见 Rmd“输入文件”节
- `easy_input_subtype.txt`：见 Rmd“输入文件”节

counts矩阵行为基因、列为样本；subtype表行名为样本名且须与矩阵列名一致，含TCGA_Subtype分组列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-120multiclassedger`
- 用到课题：`wiki.py use figureya-120multiclassedger --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
