---
type: recipe
id: figureya-318genesetdedotplot
title: 单细胞通路活性差异点图
status: draft
source:
  id: figureya
  item: FigureYa318GenesetDEDotplot
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa318GenesetDEDotplot.Rmd
inputs:
- file: h.all.v7.5.1.symbols.gmt
  note: h.all.v7.5.1.symbols.gmt，基因集文件，存放基因与通路的关联关系
- file: GenesetInfo.txt
  note: GenesetInfo.txt，通路信息文件，标识通路及其所属分类
- file: marker.xlsx
  note: ''
outputs:
- hallmark.pdf
packages:
  cran:
  - Seurat
  - SeuratObject
  - cowplot
  - dplyr
  - ggplot2
  - magrittr
  - openxlsx
  - plyr
  bioc:
  - AUCell
  - clusterProfiler
  - GEOquery
  - GSVA
  - limma
  github: []
  library:
  - Seurat
  - magrittr
  - GEOquery
  - plyr
  - openxlsx
  - GSVA
  - AUCell
  - clusterProfiler
  - limma
  - ggplot2
  - dplyr
  - cowplot
  namespaced:
  - knitr
tags:
- single-cell
- transcriptomics
keywords:
- Seurat
- AUCell
- GSVA
- limma
- GEOquery
- clusterProfiler
- HALLMARK
- openxlsx
- cowplot
- magrittr
- plyr
chart_types:
- dotplot
summary: 用AUCell给每个细胞算通路活性得分，在各细胞类型内做两组间limma差异分析，画“通路×细胞类型”点图（颜色=logFC、大小=FDR档），顶部拼通路分类条
favorite: false
---
# 单细胞通路活性差异点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa318GenesetDEDotplot` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa318GenesetDEDotplot.Rmd`）
- 依赖：CRAN Seurat, SeuratObject, cowplot, dplyr, ggplot2, magrittr, openxlsx, plyr；Bioconductor AUCell, clusterProfiler, GEOquery, GSVA, limma
- 最近运行：fail（as-is，2026-11-04 11:11 UTC，142.8 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用AUCell给每个细胞算通路活性得分，在各细胞类型内做两组间limma差异分析，画“通路×细胞类型”点图（颜色=logFC、大小=FDR档），顶部拼通路分类条。

## 适用

单细胞数据里比较两种条件下不同细胞类型的通路活性差异，如AC vs PA组织。

## 不适用

需预先备好的注释Seurat对象（meta须含Group和Celltypes两列）；contrast写法固定只支持两组比较；通路分类由GenesetInfo.txt提供、预设4类；AUCell逐细胞打分耗资源。

## 输入

- `h.all.v7.5.1.symbols.gmt`：h.all.v7.5.1.symbols.gmt，基因集文件，存放基因与通路的关联关系
- `GenesetInfo.txt`：GenesetInfo.txt，通路信息文件，标识通路及其所属分类
- `marker.xlsx`：见 Rmd“输入文件”节
- `seu.rds`：见 Rmd“输入文件”节

seu.rds为含Group/Celltypes注释的Seurat对象；h.all…symbols.gmt为通路基因集；GenesetInfo.txt逗号分隔、含geneset与Classification列，决定通路顺序与分组。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-318genesetdedotplot`
- 用到课题：`wiki.py use figureya-318genesetdedotplot --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：例里seu.rds需自行构建（对应chunk为eval=FALSE），原始数据要从GEO手动下载RAW.tar和series matrix；AUCell全矩阵打分内存与耗时较大。

## 输出

- `hallmark.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
