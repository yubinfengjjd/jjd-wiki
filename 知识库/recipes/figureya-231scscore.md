---
type: recipe
id: figureya-231scscore
title: 单细胞通路得分降维图
status: draft
source:
  id: figureya
  item: FigureYa231scScore
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa231scScore.Rmd
inputs:
- file: unnormalized_counts_ctrl_gbm.RData
  note: ''
- file: metadata-ctrl-gbm.RData
  note: ''
- file: SignatureExamples_SeuratObj.tsv
  note: ''
outputs:
- scScore.pdf
packages:
  cran:
  - RColorBrewer
  - Seurat
  - tidyverse
  bioc:
  - GO.db
  - biomaRt
  github: []
  library:
  - tidyverse
  - Seurat
  - GO.db
  - biomaRt
  - RColorBrewer
  namespaced:
  - knitr
tags:
- single-cell
- transcriptomics
keywords:
- Seurat
- Single-Cell Signature Explorer
- GO.db
- biomaRt
- t-SNE
- RColorBrewer
- tidyverse
chart_types:
- umap
summary: 标准Seurat流程跑t-SNE后，用Single-Cell Signature Explorer计算各细胞GO通路得分，并在降维图上按分组着色或渐变色展示通路
favorite: false
---
# 单细胞通路得分降维图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa231scScore` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa231scScore.Rmd`）
- 依赖：CRAN RColorBrewer, Seurat, tidyverse；Bioconductor GO.db, biomaRt
- 最近运行：fail（as-is，2026-11-11 06:09 UTC，41.3 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

标准Seurat流程跑t-SNE后，用Single-Cell Signature Explorer计算各细胞GO通路得分，并在降维图上按分组着色或渐变色展示通路活性。

## 适用

在t-SNE图上展示细胞类群、分组信息，或通路/marker基因在细胞群上的活性分布。

## 不适用

通路打分依赖外部独立软件SingleCellSignatureScorer（下载可执行文件在R外手动跑）；仅做着色展示不做差异统计检验。

## 输入

- `unnormalized_counts_ctrl_gbm.RData`：见 Rmd“输入文件”节
- `metadata-ctrl-gbm.RData`：见 Rmd“输入文件”节
- `SeuratObj.rds`：见 Rmd“输入文件”节
- `SignatureExamples_SeuratObj.tsv`：见 Rmd“输入文件”节

给Scorer的输入为细胞×基因的tsv（矩阵需转置写出）；geneset文件每个GO term一个txt、每行一个基因名。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-231scscore`
- 用到课题：`wiki.py use figureya-231scscore --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：GO基因集经biomaRt在线查询Ensembl获取；演示数据从作者GitHub仓库下载；打分软件需单独下载安装。

## 输出

- `scScore.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]] · [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
