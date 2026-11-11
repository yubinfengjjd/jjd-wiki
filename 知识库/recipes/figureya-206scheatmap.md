---
type: recipe
id: figureya-206scheatmap
title: 单细胞标记热图联富集点图
status: draft
source:
  id: figureya
  item: FigureYa206scHeatmap
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa206scHeatmap.Rmd
inputs:
- file: 1-s2.0-S0092867420300568-mmc1.xlsx
  note: ''
outputs:
- scHeatmap.pdf
packages:
  cran:
  - Hmisc
  - RColorBrewer
  - Seurat
  - aplot
  - batchelor
  - magrittr
  - patchwork
  - pheatmap
  - tidyverse
  bioc: []
  github: []
  library:
  - tidyverse
  - magrittr
  - Seurat
  - pheatmap
  - RColorBrewer
  - aplot
  - patchwork
  namespaced:
  - knitr
  - readxl
  - plyr
  - Hmisc
tags:
- single-cell
- transcriptomics
keywords:
- Seurat
- pheatmap
- aplot
- patchwork
- ToppGene
- readxl
- GSE130664
- FindAllMarkers
- RColorBrewer
- magrittr
- tidyverse
chart_types:
- heatmap
- dotplot
summary: Seurat单细胞对象做质控、分群和FindAllMarkers差异分析，左侧画各细胞类型top标记基因Z-score热图，右侧并排画GO富集点图。
favorite: false
---
# 单细胞标记热图联富集点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa206scHeatmap` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa206scHeatmap.Rmd`）
- 依赖：CRAN Hmisc, RColorBrewer, Seurat, aplot, batchelor, magrittr, patchwork, pheatmap, tidyverse
- 最近运行：fail（as-is，2026-11-11 05:30 UTC，7.2 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

Seurat单细胞对象做质控、分群和FindAllMarkers差异分析，左侧画各细胞类型top标记基因Z-score热图，右侧并排画GO富集点图。

## 适用

单细胞RNA-seq已有分群结果，想在一张图上联合展示细胞类型特异性表达谱和对应功能富集条目。

## 不适用

富集结果不在本代码内产出，需先跑ToppGene/clusterProfiler整理成指定列名（示例直接读原文附件xlsx的GO_*sheet）；输入契约重，UMI矩阵与元数据格式都要对齐。

## 输入

- `1-s2.0-S0092867420300568-mmc1.xlsx`：见 Rmd“输入文件”节
- `sc.seurat.Rdata`：见 Rmd“输入文件”节

UMI计数矩阵行基因列细胞；元数据xlsx按sheet序号/sheet名读取；Seurat对象需已含cluster注释。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-206scheatmap`
- 用到课题：`wiki.py use figureya-206scheatmap --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：GSE130664_merge_UMI_count.txt.gz需手动从GEO下载（大文件）；xlsx用readxl按sheet读取；富集分析默认走ToppGene网页手工操作。

## 输出

- `scHeatmap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
