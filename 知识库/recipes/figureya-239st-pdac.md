---
type: recipe
id: figureya-239st-pdac
title: 空间转录组单细胞MIA整合图
status: draft
source:
  id: figureya
  item: FigureYa239ST_PDAC
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa239ST_PDAC.Rmd
inputs:
- file: GSM3036911_PDAC-A-ST1-filtered.txt
  note: ''
- file: GSE111672_PDAC-A-indrop-filtered-expMat.txt
  note: ''
- file: GSM3405534_PDAC-B-ST1-filtered.txt
  note: ''
- file: GSE111672_PDAC-B-indrop-filtered-expMat.txt
  note: ''
outputs:
- PRSS1_A.pdf
- region_A.pdf
- MUC4_B.pdf
- region_B.pdf
packages:
  cran:
  - Cancer
  - Duct
  - Pancreatic
  - Seurat
  - Stroma
  - data.table
  - ggplot2
  - tidyHeatmap
  - tidyverse
  bioc: []
  github: []
  library:
  - data.table
  - Seurat
  - tidyverse
  - ggplot2
  - tidyHeatmap
  namespaced:
  - knitr
tags:
- single-cell
- transcriptomics
keywords:
- Seurat
- MIA
- multimodal intersection analysis
- spatial transcriptomics
- scRNA-seq
- tidyHeatmap
- GSE111672
- PDAC
- data.table
- tidyverse
chart_types:
- spatial-map
- heatmap
summary: 用Seurat分别处理ST spot和scRNA-seq细胞并找marker，按超几何分布做MIA推断各细胞类型在组织区域中的富集/缺失，画空间表达spot图、
favorite: false
---
# 空间转录组单细胞MIA整合图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa239ST_PDAC` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa239ST_PDAC.Rmd`）
- 依赖：CRAN Cancer, Duct, Pancreatic, Seurat, Stroma, data.table, ggplot2, tidyHeatmap, tidyverse
- 最近运行：pass（as-is，2026-11-11 09:45 UTC，167.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-239st-pdac/preview.png]]
<!-- facts:end -->

## 用途

用Seurat分别处理ST spot和scRNA-seq细胞并找marker，按超几何分布做MIA推断各细胞类型在组织区域中的富集/缺失，画空间表达spot图、区域聚类图和MIA热图。

## 适用

同一样本/模型兼有scRNA-seq与空间转录组数据，想把单细胞分辨率的细胞类型映射回空间区域。

## 不适用

需要成对的sc与ST输入；ST spot坐标编码在表达矩阵列名（行x列格式）；marker阈值与原文不同，复现结果与例图有出入。

## 输入

- `GSM3036911_PDAC-A-ST1-filtered.txt`：见 Rmd“输入文件”节
- `GSE111672_PDAC-A-indrop-filtered-expMat.txt`：见 Rmd“输入文件”节
- `GSM3405534_PDAC-B-ST1-filtered.txt`：见 Rmd“输入文件”节
- `GSE111672_PDAC-B-indrop-filtered-expMat.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-239st-pdac`
- 用到课题：`wiki.py use figureya-239st-pdac --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：示例数据需手工从GEO下载GSE111672_RAW.rar并解压后按指定文件名放置。

## 输出

- `PRSS1_A.pdf`
- `region_A.pdf`
- `MUC4_B.pdf`
- `region_B.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
