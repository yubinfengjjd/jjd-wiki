---
type: recipe
id: figureya-131cmap-update
title: 泛癌CMap化合物富集与机制图
status: draft
source:
  id: figureya
  item: FigureYa131CMap_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa131CMap_update.Rmd
inputs:
- file: pandif_mRNAsi.xlsx
  note: ''
- file: ACC_CMap_result.xls
  note: ''
- file: Connectivity_Map_Output.xlsx
  note: ''
- file: moa_target_export.txt
  note: ''
outputs:
- CMap_heatmap.pdf
- MoA.pdf
packages:
  cran:
  - plyr
  - tidyverse
  - xlsx
  - ComplexHeatmap
  - circlize
  bioc:
  - GEOquery
  github: []
  library:
  - xlsx
  - tidyverse
  - GEOquery
  - plyr
  - circlize
  - ComplexHeatmap
  namespaced:
  - knitr
  - openxlsx
  - reshape2
tags:
- computational-drug-design
- transcriptomics
keywords:
- ComplexHeatmap
- GEOquery
- circlize
- plyr
- tidyverse
- xlsx
- CMap
- clue.io
chart_types:
- heatmap
- dotplot
summary: 整理CMap查询结果，画各癌种中显著富集化合物的enrichment热图（顶部带富集癌种数条形注释），以及化合物作用机制MoA的oncoPrint点阵图。
favorite: false
---
# 泛癌CMap化合物富集与机制图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa131CMap_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa131CMap_update.Rmd`）
- 依赖：CRAN plyr, tidyverse, xlsx, ComplexHeatmap, circlize；Bioconductor GEOquery
- 最近运行：pass（as-is，2026-11-11 06:54 UTC，76.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `CMap_heatmap.pdf` 第 1 页）：

![[recipes/figureya-131cmap-update/preview.png]]
<!-- facts:end -->

## 用途

整理CMap查询结果，画各癌种中显著富集化合物的enrichment热图（顶部带富集癌种数条形注释），以及化合物作用机制MoA的oncoPrint点阵图。

## 适用

已有各癌种差异基因、并在CMap build 02/clue.io网页端完成查询拿到结果文件后，复现泛癌药物富集与MoA机制汇总图。

## 不适用

Rmd本身不做在线CMap查询，需先手工上传grp格式探针列表并导出结果；输入依赖33个癌种sheet的xlsx附件等固定结构；grp文件要求GPL96平台探针ID。

## 输入

- `pandif_mRNAsi.xlsx`：见 Rmd“输入文件”节
- `ACC_CMap_result.xls`：见 Rmd“输入文件”节
- `Connectivity_Map_Output.xlsx`：见 Rmd“输入文件”节
- `moa_target_export.txt`：见 Rmd“输入文件”节

pandif_mRNAsi.xlsx需含33个癌种sheet（列名GeneSymbol/logFC）；Connectivity_Map_Output.xlsx除结果sheet外第34个sheet为MoA表。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-131cmap-update`
- 用到课题：`wiki.py use figureya-131cmap-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需Java环境（xlsx包读.xls，已设-Xmx8000m）；GEOquery运行时联网下载GPL96注释；CMap/MoA查询须在网页端完成。

## 输出

- `CMap_heatmap.pdf`
- `MoA.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
