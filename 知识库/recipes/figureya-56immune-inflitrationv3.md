---
type: recipe
id: figureya-56immune-inflitrationv3
title: MCPcounter免疫浸润热图
status: draft
source:
  id: figureya
  item: FigureYa56immune_inflitrationV3
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa56immune_inflitrationV3.Rmd
inputs:
- file: easy_input_cli.csv
  note: 如果你要画出paper里那样的图，就还需要临床、突变信息：easy_input_cli.csv
- file: MCPcounter_output.csv
  note: ''
outputs: []
packages:
  cran:
  - data.table
  - pheatmap
  - stringr
  - ggplot2
  - dplyr
  - tidyr
  bioc: []
  github:
  - MCPcounter
  library:
  - MCPcounter
  - stringr
  - data.table
  - pheatmap
  namespaced:
  - knitr
tags:
- transcriptomics
- multi-omics
keywords:
- MCPcounter
- TCGA
- UCSC Xena
- pheatmap
- immune infiltration
- IDH
- data.table
- stringr
chart_types:
- heatmap
summary: 用MCPcounter从表达矩阵估计免疫/基质细胞丰度，按目标基因表达排序样本，叠加临床亚型和突变注释画浸润热图。
favorite: false
---
# MCPcounter免疫浸润热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa56immune_inflitrationV3` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa56immune_inflitrationV3.Rmd`）
- 依赖：CRAN data.table, pheatmap, stringr, ggplot2, dplyr, tidyr；GitHub MCPcounter
- 最近运行：fail（as-is，2026-11-11 05:31 UTC，1.5 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用MCPcounter从表达矩阵估计免疫/基质细胞丰度，按目标基因表达排序样本，叠加临床亚型和突变注释画浸润热图。

## 适用

肿瘤RNA-seq或芯片表达数据想刻画免疫浸润构成，及其与癌症类型、临床亚型、基因突变的关系。

## 不适用

表达量须log2转化、限人类组织（含血液）；只算浸润分数时需表达矩阵，复刻原图还要临床表型和突变文件；MCPcounter是GitHub包非CRAN。

## 输入

- `easy_input_expr.csv`：如果你的数据已经整理成“easy_input_expr.csv”的格式，就跳过这步，直接进入“计算免疫细胞”。
- `easy_input_cli.csv`：如果你要画出paper里那样的图，就还需要临床、突变信息：easy_input_cli.csv
- `easyinput-expr.csv`：If you only need to calculate immune cells, you only need to use the gene expression matrix: easyinput-expr.csv
- `easyinput_cli.csv`：If you want to draw a graph like the one in the paper, you also need clinical and mutation information: easyinput_cli.csv
- `TCGA_phenotype_denseDataOnlyDownload.tsv`：TCGA_phenotype_denseDataOnlyDownload.tsv
- `GBM_clinicalMatrix.gz`：见 Rmd“输入文件”节
- `LGG_clinicalMatrix.gz`：见 Rmd“输入文件”节
- `mc3.v0.2.8.PUBLIC.xena.gz`：见 Rmd“输入文件”节
- `MCPcounter_output.csv`：见 Rmd“输入文件”节

表达矩阵行基因列样本；完整版需cli表含样本、癌症类型、突变信息，且样本ID与表达矩阵一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-56immune-inflitrationv3`
- 用到课题：`wiki.py use figureya-56immune-inflitrationv3 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需手动从UCSC Xena下载多个大.gz文件（表达/表型/突变）；代码用system()调用head、cut等Unix命令切大矩阵，Windows需改写。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
