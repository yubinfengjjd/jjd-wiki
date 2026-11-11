---
type: recipe
id: figureya-310cpdbchordgramv2
title: 细胞通讯配体受体弦图
status: draft
source:
  id: figureya
  item: FigureYa310CPDBChordGramV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa310CPDBChordGramV2.Rmd
inputs:
- file: pvalues.txt
  note: 运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
- file: significant_means.txt
  note: 运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
- file: deconvoluted.txt
  note: 运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
- file: means.txt
  note: 运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
outputs:
- cpdb.chordgram.pdf
packages:
  cran:
  - RColorBrewer
  - Seurat
  - ggraph
  - ggrepel
  - grid
  - igraph
  - reshape2
  bioc:
  - SingleCellExperiment
  github:
  - satijalab/seurat-data
  library:
  - SingleCellExperiment
  - reshape2
  - Seurat
  - igraph
  - ggraph
  - ggrepel
  - RColorBrewer
  - SeuratData
  namespaced:
  - knitr
tags:
- single-cell
- transcriptomics
keywords:
- CellPhoneDB
- ggraph
- igraph
- Seurat
- ligand-receptor
- geom_conn_bundle
- RColorBrewer
- SeuratData
- SingleCellExperiment
- ggrepel
- reshape2
chart_types:
- chord
summary: 读CellPhoneDB输出的means/pvalues结果文件，结合Seurat两组间差异分析，用ggraph圆形捆绑图展示细胞类型间配体-受体互作的方向与组
favorite: false
---
# 细胞通讯配体受体弦图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa310CPDBChordGramV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa310CPDBChordGramV2.Rmd`）
- 依赖：CRAN RColorBrewer, Seurat, ggraph, ggrepel, grid, igraph, reshape2；Bioconductor SingleCellExperiment；GitHub satijalab/seurat-data
- 最近运行：fail（as-is，2026-11-11 05:30 UTC，13.2 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

读CellPhoneDB输出的means/pvalues结果文件，结合Seurat两组间差异分析，用ggraph圆形捆绑图展示细胞类型间配体-受体互作的方向与组间差异。

## 适用

已在终端跑完CellPhoneDB，且单细胞数据含两组条件（如STIM vs CTRL），要看各细胞类型L-R互作的上调/下调差异。

## 不适用

必须先在外部运行CellPhoneDB得到out/四个结果文件；只做两组对比；Seurat对象须含细胞注释列和分组列；箭头大小图例需手工补加。

## 输入

- `ifnb.rds`：ifnb.rds，A Seurat object。如果你还没有这个文件，可以使用下面的代码从SeuratData包加载示例数据并保存为rds文件。
- `里面有四个文件means.txt`：运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
- `pvalues.txt`：运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
- `significant_means.txt`：运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
- `deconvoluted.txt`：运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt
- `means.txt`：运行完，会在当前文件夹下产生一个'out'文件夹，里面有四个文件means.txt、pvalues.txt、significant_means.txt、deconvoluted.txt

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-310cpdbchordgramv2`
- 用到课题：`wiki.py use figureya-310cpdbchordgramv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：CellPhoneDB为Python命令行工具（Linux/Mac或WSL，pip安装）；示例ifnb.rds需从GitHub安装SeuratData或用自带文件。

## 输出

- `cpdb.chordgram.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
