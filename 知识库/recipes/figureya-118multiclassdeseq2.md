---
type: recipe
id: figureya-118multiclassdeseq2
title: 多亚型差异表达分析
status: draft
source:
  id: figureya
  item: FigureYa118MulticlassDESeq2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa118MulticlassDESeq2.Rmd
inputs:
- file: easy_input_counts.txt
  note: ''
- file: easy_input_subtype.txt
  note: ''
outputs: []
packages:
  cran: []
  bioc:
  - DESeq2
  github: []
  library:
  - DESeq2
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- DESeq2
chart_types:
- deg-table
summary: 用DESeq2对read count矩阵做"每一亚型 vs 其余样本"的配对差异表达分析，输出各亚型差异基因表供下游富集/marker分析。
favorite: false
---
# 多亚型差异表达分析

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa118MulticlassDESeq2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa118MulticlassDESeq2.Rmd`）
- 依赖：Bioconductor DESeq2
- 最近运行：pass（as-is，2026-11-04 10:59 UTC，60.9 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用DESeq2对read count矩阵做"每一亚型 vs 其余样本"的配对差异表达分析，输出各亚型差异基因表供下游富集/marker分析。

## 适用

亚型数≥3时替换FigureYa109SubtypeGSEA的差异表达步骤并与之对接，或为FigureYa116supervisedCluster提供亚型特异marker输入。

## 不适用

只接受read count矩阵（FPKM/芯片数据改用FigureYa119Multiclasslimma）；设计矩阵仅含亚型、不纳入批次效应；亚型名写死在createList函数里需按数据改写。

## 输入

- `easy_input_counts.txt`：见 Rmd“输入文件”节
- `easy_input_subtype.txt`：见 Rmd“输入文件”节

counts矩阵行=基因列=样本；subtype表样本名（行名）须与矩阵列名一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-118multiclassdeseq2`
- 用到课题：`wiki.py use figureya-118multiclassdeseq2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：逐亚型循环DESeq2耗时较长，示例为加速只取方差top25%基因；结果文件已存在时默认跳过重算（overwt=F）。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
