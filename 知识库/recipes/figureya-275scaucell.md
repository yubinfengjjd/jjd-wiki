---
type: recipe
id: figureya-275scaucell
title: 单细胞AUCell基因集评分
status: draft
source:
  id: figureya
  item: FigureYa275scAUCell
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa275scAUCell.Rmd
inputs:
- file: ISG_genelist.csv
  note: ''
outputs:
- ./immune.combined.UMAP.pdf
- cells_assignment.pdf
- UMAP_AUC_value.pdf
- UMAP_AUC_value_label.pdf
- immune.combined.ISGs.type.UMAP.pdf
packages:
  cran:
  - AUCell
  - RColorBrewer
  - Seurat
  - dplyr
  - ggplot2
  - magrittr
  - patchwork
  - pheatmap
  - remotes
  - devtools
  - SeuratData
  bioc:
  - Eryth
  github: []
  library:
  - Seurat
  - SeuratData
  - patchwork
  - RColorBrewer
  - pheatmap
  - dplyr
  - magrittr
  - AUCell
  - ggplot2
  namespaced:
  - knitr
  - viridis
tags:
- single-cell
- transcriptomics
keywords:
- AUCell
- Seurat
- SeuratData
- UMAP
- ISG
- ifnb
- gene set score
- RColorBrewer
- magrittr
- patchwork
- pheatmap
chart_types:
- umap
- density
summary: 用AUCell对单细胞表达矩阵按自定义基因集逐细胞打AUC评分，画评分阈值分布直方图，并把AUC值映射到UMAP上高亮高活性细胞。
favorite: false
---
# 单细胞AUCell基因集评分

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa275scAUCell` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa275scAUCell.Rmd`）
- 依赖：CRAN AUCell, RColorBrewer, Seurat, dplyr, ggplot2, magrittr, patchwork, pheatmap, remotes, devtools, SeuratData；Bioconductor Eryth
- 最近运行：fail（as-is，2026-11-11 06:09 UTC，20.5 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用AUCell对单细胞表达矩阵按自定义基因集逐细胞打AUC评分，画评分阈值分布直方图，并把AUC值映射到UMAP上高亮高活性细胞。

## 适用

想在单细胞数据中量化某个基因集/签名（如ISG、regulon、代谢通路）的细胞级活性并圈出高评分亚群。

## 不适用

需预处理好的Seurat对象（含PCA/UMAP与细胞类型注释）；AUC阈值由本数据分布决定，示例阈值不可跨数据集套用；基因集基因名须与表达矩阵行名一致。

## 输入

- `ISG_genelist.csv`：见 Rmd“输入文件”节
- `immune.combined.rds`：见 Rmd“输入文件”节

immune.combined.rds是Seurat预处理中间结果；ISG_genelist.csv用到GeneName列。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-275scaucell`
- 用到课题：`wiki.py use figureya-275scaucell --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：immune.combined.rds（192MB）超出 GitHub 单文件上限，不入库；可通过 Rmd 整合段（预处理块）对 SeuratData ifnb 数据重建获得，或自备同结构 rds 直接跳到评分；本仓库验证使用重建对象运行通过。预处理段eval=FALSE：示例ifnb数据需SeuratData联网InstallData，或自备rds直接跳到评分；AUCell默认nCores=10并行。

## 输出

- `./immune.combined.UMAP.pdf`
- `cells_assignment.pdf`
- `UMAP_AUC_value.pdf`
- `UMAP_AUC_value_label.pdf`
- `immune.combined.ISGs.type.UMAP.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]] · [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
