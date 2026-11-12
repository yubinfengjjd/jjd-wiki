---
type: recipe
id: figureya-2ggtree-pheatmap-msa
title: 进化树表达热图与序列比对
status: draft
source:
  id: figureya
  item: FigureYa2ggtree+pheatmap+msa
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa2ggtree+pheatmap+msa.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs:
- heatmap.pdf
- ggtree.pdf
packages:
  cran:
  - ape
  - ggtree
  - pheatmap
  - seqinr
  - ggplot2
  - tidyr
  - dplyr
  bioc:
  - Biostrings
  - msa
  - ggtree
  - treeio
  github: []
  library:
  - pheatmap
  - msa
  - seqinr
  - ape
  - ggtree
  namespaced:
  - knitr
tags:
- transcriptomics
- multi-omics
keywords:
- ggtree
- msa
- ape
- seqinr
- pheatmap
- NJ tree
- fasta
chart_types:
- heatmap
- dendrogram
summary: 对基因家族分别绘制表达谱聚类热图、多序列比对PDF和NJ进化树三张独立PDF（不组图）。
favorite: false
---
# 进化树表达热图与序列比对

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa2ggtree+pheatmap+msa` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa2ggtree+pheatmap+msa.Rmd`）
- 依赖：CRAN ape, ggtree, pheatmap, seqinr, ggplot2, tidyr, dplyr；Bioconductor Biostrings, msa, ggtree, treeio
- 最近运行：pass（as-is，2026-11-11 09:08 UTC，9.4 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-2ggtree-pheatmap-msa/preview.png]]
<!-- facts:end -->

## 用途

对基因家族分别绘制表达谱聚类热图、多序列比对PDF和NJ进化树三张独立PDF（不组图）。

## 适用

想判断cluster中功能未知基因是否属于某基因家族，或新鉴定因子与已知成员在序列和表达谱上是否一致。

## 不适用

本文档三图分开输出、不做组图（组图见cowplot版文档）；比对与建树输入为fasta序列（示例借用msa内置exampleAA.fasta）；表达热图的分组注释按样本数硬编码。

## 输入

- `easy_input.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-2ggtree-pheatmap-msa`
- 用到课题：`wiki.py use figureya-2ggtree-pheatmap-msa --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：msaPrettyPrint输出比对PDF需要系统安装LaTeX（如MacTeX/TeX Live）。

## 输出

- `heatmap.pdf`
- `ggtree.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
