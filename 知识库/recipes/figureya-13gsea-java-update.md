---
type: recipe
id: figureya-13gsea-java-update
title: Java GSEA 结果多通路美化图
status: ready
source:
  id: figureya
  item: FigureYa13GSEA_Java_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa13GSEA_Java_update.Rmd
inputs: []
outputs:
- ppoint2.pdf
- prettyGSEApoint.pdf
- prettyGSEAline.pdf
- prettyGSEAbar.pdf
packages:
  cran:
  - RColorBrewer
  - blueviolet
  - chocolate4
  - cowplot
  - ggplot2
  - grid
  - gridExtra
  - plyr
  bioc: []
  github: []
  library:
  - plyr
  - ggplot2
  - RColorBrewer
  - gridExtra
  - cowplot
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- GSEA
- Java GSEA
- barcode
- running enrichment score
- RColorBrewer
- cowplot
- gridExtra
- plyr
chart_types:
- gsea-curve
- dotplot
summary: 读取 Java 版 GSEA 的输出，把多个通路画进一张图：点图+条码、线图+条码、条码+热图三种样式。
favorite: false
---
# Java GSEA 结果多通路美化图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa13GSEA_Java_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa13GSEA_Java_update.Rmd`）
- 依赖：CRAN RColorBrewer, blueviolet, chocolate4, cowplot, ggplot2, grid, gridExtra, plyr
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，4.1 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-13gsea-java-update/preview.png]]
<!-- facts:end -->

## 用途

读取 Java 版 GSEA 的输出，把多个通路画进一张图：点图+条码、线图+条码、条码+热图三种样式。

## 适用

已用 Broad Java GSEA 跑完、保留了其输出目录结构。

## 不适用

用 clusterProfiler 做的 GSEA（见 FigureYa60GSEA_clusterProfilerV2）；还没做富集分析。

## 输入

- 见 Rmd“输入文件”节（适配器未识别出文件名）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-13gsea-java-update`
- 用到课题：`wiki.py use figureya-13gsea-java-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `ppoint2.pdf`
- `prettyGSEApoint.pdf`
- `prettyGSEAline.pdf`
- `prettyGSEAbar.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
