---
type: recipe
id: figureya-304magic
title: 单细胞MAGIC协同表达热图
status: draft
source:
  id: figureya
  item: FigureYa304MAGIC
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa304MAGIC.Rmd
inputs:
- file: gene.info.rds
  note: ''
- file: TableS12.csv
  note: ''
outputs:
- MAGICHeatmap.pdf
packages:
  cran:
  - Seurat
  - SeuratDisk
  - hdf5r
  - reticulate
  - ggplot2
  - dplyr
  - Rmagic
  - biomaRt
  bioc:
  - biomaRt
  - AnnotationDbi
  - org.Hs.eg.db
  github:
  - mojaveazure/seurat-disk
  library:
  - biomaRt
  - SeuratDisk
  - Seurat
  - tidyverse
  - ComplexHeatmap
  namespaced:
  - knitr
  - Matrix
  - Rmagic
  - arrow
  - dendextend
  - ggsci
  - circlize
tags:
- single-cell
keywords:
- MAGIC
- knnDREMI
- Rmagic
- Seurat
- SeuratDisk
- biomaRt
- reticulate
- PLCG2
- SCLC
- ComplexHeatmap
- tidyverse
chart_types:
- heatmap
- density
summary: 对单细胞counts做MAGIC插补并计算knnDREMI，筛与目标基因高协同的基因模块，画按目标基因表达排序、经滑窗平滑的模块热图。
favorite: false
---
# 单细胞MAGIC协同表达热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa304MAGIC` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa304MAGIC.Rmd`）
- 依赖：CRAN Seurat, SeuratDisk, hdf5r, reticulate, ggplot2, dplyr, Rmagic, biomaRt；Bioconductor biomaRt, AnnotationDbi, org.Hs.eg.db；GitHub mojaveazure/seurat-disk
- 最近运行：fail（as-is，2026-11-11 08:46 UTC，18.7 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对单细胞counts做MAGIC插补并计算knnDREMI，筛与目标基因高协同的基因模块，画按目标基因表达排序、经滑窗平滑的模块热图。

## 适用

单细胞数据中度量基因间关系、找随时序/梯度变化的协同表达模块（如PLCG2相关基因模块）。

## 不适用

环境重：需Python（reticulate装magic-impute）、SeuratDisk转h5ad、hdf5r系统库；流程示例只支持单source基因，且imputation结果复现性有限、需先验定目标基因。

## 输入

- `SCLC_epithelial_cells.cellmeta.rds`：见 Rmd“输入文件”节
- `gene.info.rds`：见 Rmd“输入文件”节
- `PLCG2.DREMI.tsv`：见 Rmd“输入文件”节
- `TableS12.csv`：见 Rmd“输入文件”节
- `SCLC_epithelial_cells.MAGIC_RNA.feather.cellnames.txt`：见 Rmd“输入文件”节

需Seurat对象（含counts和meta）+ensembl到symbol的gene.info映射（与矩阵行名一致）；只保留在>500细胞中表达的基因。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-304magic`
- 用到课题：`wiki.py use figureya-304magic --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：运行时联网下载cellxgene的.h5ad并经SeuratDisk转换，biomaRt在线注释；Rmagic经reticulate调Python包；全基因knnDREMI扫描用多核（示例n.cores=20）耗时长。

## 输出

- `MAGICHeatmap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
