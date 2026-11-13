---
type: recipe
id: figureya-95pairwise
title: 配对样本距离相关散点图
status: ready
source:
  id: figureya
  item: FigureYa95pairwise
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa95pairwise.Rmd
inputs:
- file: easy_input_expr1.csv
  note: easy_input_expr1.csv，easy_input_expr2.csv，TCGA的表达数据。数据下载可参考FigureYa34count2FPKMv2。
- file: easy_input_expr2.csv
  note: easy_input_expr1.csv，easy_input_expr2.csv，TCGA的表达数据。数据下载可参考FigureYa34count2FPKMv2。
- file: easy_input_maf1.txt
  note: easy_input_maf1.txt，easy_input_maf2.txt，TCGA的突变数据。数据下载可参考FigureYa18oncoplot。
- file: easy_input_maf2.txt
  note: easy_input_maf1.txt，easy_input_maf2.txt，TCGA的突变数据。数据下载可参考FigureYa18oncoplot。
- file: immunitygene.csv
  note: immunitygene.csv，免疫细胞marker基因，这里用GSVA。还可以用MCPcounter，可参考FigureYa56immune_inflitration，或FigureYa71ssGSEA。
outputs:
- correlation plot between two distance factors.pdf
packages:
  cran:
  - ClassDiscovery
  - vegan
  bioc:
  - GSVA
  github: []
  library:
  - GSVA
  - ClassDiscovery
  - vegan
  namespaced:
  - knitr
  - ggplot2
tags:
- multi-omics
- transcriptomics
keywords:
- GSVA
- ssGSEA
- ClassDiscovery
- vegan
- Jaccard
- MAF
- LUAD
- LUSC
chart_types:
- scatter
summary: maf转二元突变矩阵算Jaccard距离、表达谱算ssGSEA免疫浸润得分后算欧氏距离，把两两样本对的两种距离画成相关散点图并标注Pearson相关与p值。
favorite: false
---
# 配对样本距离相关散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa95pairwise` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa95pairwise.Rmd`）
- 依赖：CRAN ClassDiscovery, vegan；Bioconductor GSVA
- 最近运行：pass（as-is，2026-11-04 11:20 UTC，63.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `correlation plot between two distance factors.pdf` 第 1 页）：

![[recipes/figureya-95pairwise/preview.png]]
<!-- facts:end -->

## 用途

maf转二元突变矩阵算Jaccard距离、表达谱算ssGSEA免疫浸润得分后算欧氏距离，把两两样本对的两种距离画成相关散点图并标注Pearson相关与p值。

## 适用

在同一队列内比较基因组距离与免疫浸润距离等两类样本间距离的关联程度（多维异质性/免疫编辑研究）。

## 不适用

需同一癌种的表达矩阵+maf成套且样本可交集；示例写死LUAD/LUSC两套数据；maf需标准三列；突变矩阵行名转大写、表达矩阵行名需自行保证symbol一致；双重循环生成n(n-1)/2个点，大队列很慢。

## 输入

- `easy_input_expr1.csv`：easy_input_expr1.csv，easy_input_expr2.csv，TCGA的表达数据。数据下载可参考FigureYa34count2FPKMv2。
- `easy_input_expr2.csv`：easy_input_expr1.csv，easy_input_expr2.csv，TCGA的表达数据。数据下载可参考FigureYa34count2FPKMv2。
- `easy_input_maf1.txt`：easy_input_maf1.txt，easy_input_maf2.txt，TCGA的突变数据。数据下载可参考FigureYa18oncoplot。
- `easy_input_maf2.txt`：easy_input_maf1.txt，easy_input_maf2.txt，TCGA的突变数据。数据下载可参考FigureYa18oncoplot。
- `immunitygene.csv`：immunitygene.csv，免疫细胞marker基因，这里用GSVA。还可以用MCPcounter，可参考FigureYa56immune_inflitration，或FigureYa71ssGSEA。

maf需含Tumor_Sample_Barcode/Hugo_Symbol/Variant_Classification列；immunitygene.csv需CellType+Symbol列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-95pairwise`
- 用到课题：`wiki.py use figureya-95pairwise --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：maf2binary与dist2xy均为逐样本对循环实现，样本量大时明显耗时。

## 输出

- `correlation plot between two distance factors.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
