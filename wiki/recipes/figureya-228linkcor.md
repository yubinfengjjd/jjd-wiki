---
type: recipe
id: figureya-228linkcor
title: 相关热图与连线蝴蝶图
status: ready
source:
  id: figureya
  item: FigureYa228linkCor
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa228linkCor.Rmd
inputs:
- file: tcga_blca_fpkm.txt
  note: tcga_blca_fpkm.txt，基因表达矩阵。
- file: immunotherapy predicted pathways.txt
  note: immunotherapy predicted pathways.txt，治疗签名，用于绘制(D) Correlations between Siglec15
    and the enrichment scores of immunotherapy-predicted pathways。整理自例文的Table S9.xlsx，Therapeutic
    predicted pathways，选取Descr
- file: bladder cancer signature.txt
  note: bladder cancer signature.txt，膀胱癌相关签名，每行一个通路，第一列为通路名（Signature），第二列为基因（Genes）。用于绘制(C)
    Correlations between Siglec15 and the steps of the cancer immunity cycle。出自例文的Table
    S9.xlsx，Bladder cancer signatur
- file: easy_input_gene.csv
  note: ''
- file: easy_input_immPath.txt
  note: ''
- file: easy_input_blcaPath.txt
  note: ''
outputs:
- ggcor plot in bottom left.pdf
- ggcor plot in top right.pdf
packages:
  cran:
  - ade4
  - data.table
  - ggnewscale
  bioc:
  - GSVA
  github: []
  library:
  - data.table
  - GSVA
  - ggplot2
  - ggcor
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- ggcor
- Mantel-like link
- butterfly plot
- GSVA
- data.table
chart_types:
- heatmap
- network
summary: 用三角热图展示两组通路各自的自相关，再用连线展示一个基因与这些通路的相关（实线正、虚线负、颜色为 P 值），拼成蝴蝶图。
favorite: false
---
# 相关热图与连线蝴蝶图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa228linkCor` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa228linkCor.Rmd`）
- 依赖：CRAN ade4, data.table, ggnewscale；Bioconductor GSVA
- 最近运行：pass（as-is，2026-11-04 04:21 UTC，41.9 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-228linkcor/preview.png]]
<!-- facts:end -->

## 用途

用三角热图展示两组通路各自的自相关，再用连线展示一个基因与这些通路的相关（实线正、虚线负、颜色为 P 值），拼成蝴蝶图。

## 适用

一个（或少数）焦点基因与两组特征（通路、基因）的相关分析；表达矩阵与通路评分。

## 不适用

多个焦点变量对多组特征的大规模相关；需要偏相关或校正混杂时要先确认。

## 输入

- `tcga_blca_fpkm.txt`：tcga_blca_fpkm.txt，基因表达矩阵。
- `signature.txt`：bladder cancer signature.txt，膀胱癌相关签名，每行一个通路，第一列为通路名（Signature），第二列为基因（Genes）。用于绘制(C) Correlations between Siglec15 and the steps of the cancer immunity cycle。出自例文的Table S9.xlsx，Bladder cancer signatur
- `S9.xlsx`：bladder cancer signature.txt，膀胱癌相关签名，每行一个通路，第一列为通路名（Signature），第二列为基因（Genes）。用于绘制(C) Correlations between Siglec15 and the steps of the cancer immunity cycle。出自例文的Table S9.xlsx，Bladder cancer signatur
- `pathways.txt`：immunotherapy predicted pathways.txt，治疗签名，用于绘制(D) Correlations between Siglec15 and the enrichment scores of immunotherapy-predicted pathways。整理自例文的Table S9.xlsx，Therapeutic predicted pathways，选取Descr
- `c5.all.v7.4.symbols.gmt`：对于自己的数据，你可能想提取自己感兴趣的通路计算通路的富集得分。可以从[msigdb](http://www.gsea-msigdb.org/gsea/downloads.jsp)下载gmt文件`c5.all.v7.4.symbols.gmt`，提取自己感兴趣的通路及其对应的基因，计算富集得分。
- `immunotherapy predicted pathways.txt`：immunotherapy predicted pathways.txt，治疗签名，用于绘制(D) Correlations between Siglec15 and the enrichment scores of immunotherapy-predicted pathways。整理自例文的Table S9.xlsx，Therapeutic predicted pathways，选取Descr
- `bladder cancer signature.txt`：bladder cancer signature.txt，膀胱癌相关签名，每行一个通路，第一列为通路名（Signature），第二列为基因（Genes）。用于绘制(C) Correlations between Siglec15 and the steps of the cancer immunity cycle。出自例文的Table S9.xlsx，Bladder cancer signatur
- `easy_input_gene.csv`：见 Rmd“输入文件”节
- `easy_input_immPath.txt`：见 Rmd“输入文件”节
- `easy_input_blcaPath.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-228linkcor`
- 用到课题：`wiki.py use figureya-228linkcor --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：ggcor 随模块以本地 tar 包提供（ggcor-master.tar.gz），需要装进 Wiki 专用 R 库。

## 输出

- `ggcor plot in bottom left.pdf`
- `ggcor plot in top right.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
