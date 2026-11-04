---
type: recipe
id: figureya-248mutlandscape
title: 多组学突变景观组合热图
status: draft
source:
  id: figureya
  item: FigureYa248MutLandscape
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa248MutLandscape.Rmd
inputs:
- file: mutation.txt
  note: ''
- file: TMB.txt
  note: ''
- file: mutationsignature.cosmic2013.csv
  note: ''
- file: all_lesions.conf_90.txt
  note: ''
- file: all_thresholded.by_genes.txt
  note: ''
- file: subtype.txt
  note: ''
outputs:
- mutational landscape in TCGA.pdf
packages:
  cran:
  - RColorBrewer
  bioc:
  - ComplexHeatmap
  github: []
  library:
  - ComplexHeatmap
  - RColorBrewer
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- ComplexHeatmap
- TMB
- mutational signature
- GISTIC2
- MOVICS
- APOBEC
- RColorBrewer
chart_types:
- oncoprint
summary: 用ComplexHeatmap把突变01矩阵、顶部TMB柱图与突变signature堆积图、拷贝数oncoprint和右侧亚型百分比堆积条拼成一整张分子分型突变
favorite: false
---
# 多组学突变景观组合热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa248MutLandscape` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa248MutLandscape.Rmd`）
- 依赖：CRAN RColorBrewer；Bioconductor ComplexHeatmap
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用ComplexHeatmap把突变01矩阵、顶部TMB柱图与突变signature堆积图、拷贝数oncoprint和右侧亚型百分比堆积条拼成一整张分子分型突变景观图。

## 适用

分子分型文章中按亚型并排展示突变谱、突变签名、拷贝数变异等多层基因组信息；模式也适用于其他多层组合热图。

## 不适用

只做展示不做上游分析：突变矩阵、TMB、signature权重、GISTIC2区域/基因两个输出和亚型表需预先备好且样本名完全一致；亚型配色与展示基因需手工指定。

## 输入

- `mutation.txt`：见 Rmd“输入文件”节
- `TMB.txt`：见 Rmd“输入文件”节
- `mutationsignature.cosmic2013.csv`：见 Rmd“输入文件”节
- `mutsig.weightMatrix.txt`：见 Rmd“输入文件”节
- `all_lesions.conf_90.txt`：见 Rmd“输入文件”节
- `all_thresholded.by_genes.txt`：见 Rmd“输入文件”节
- `subtype.txt`：见 Rmd“输入文件”节

所有矩阵行/列名（基因、样本、亚型、lesion名）须互相对齐；整体列顺序由mutsig内APOBEC签名与subtype排序决定。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-248mutlandscape`
- 用到课题：`wiki.py use figureya-248mutlandscape --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `mutational landscape in TCGA.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
