---
type: recipe
id: figureya-255time
title: 肿瘤免疫微环境热图
status: ready
source:
  id: figureya
  item: FigureYa255TIME
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa255TIME.Rmd
inputs:
- file: tcga.mibc.anno.txt
  note: ''
- file: TCGA-BLCA.methylation450.tsv.gz
  note: ''
- file: tcga.mibc.tpm.txt
  note: ''
- file: Curated_Immune_Cell_Signature.txt
  note: ''
outputs:
- CheckPoint_heatmap.pdf
- TIMEheatmap.pdf
- MeTILheatmap.pdf
- TIME.pdf
packages:
  cran:
  - R.utils
  - viridis
  - gplots
  - data.table
  - tidyestimate
  - GSVA
  - ComplexHeatmap
  - circlize
  bioc:
  - GSVA
  - ComplexHeatmap
  - circlize
  github: []
  library:
  - GSVA
  - ComplexHeatmap
  - circlize
  - viridis
  - gplots
  - data.table
  - tidyestimate
  namespaced:
  - knitr
tags:
- transcriptomics
- multi-omics
keywords:
- MeTIL
- tidyestimate
- ESTIMATE
- GSVA
- ComplexHeatmap
- CIBERSORT
- MCPcounter
- MOVICS
- circlize
- data.table
- gplots
- viridis
chart_types:
- heatmap
summary: 由5个甲基化探针PCA算MeTIL得分、tidyestimate算免疫/基质得分、GSVA算24种免疫细胞富集，拼三张注释热图展示亚型免疫景观。
favorite: false
---
# 肿瘤免疫微环境热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa255TIME` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa255TIME.Rmd`）
- 依赖：CRAN R.utils, viridis, gplots, data.table, tidyestimate, GSVA, ComplexHeatmap, circlize；Bioconductor GSVA, ComplexHeatmap, circlize
- 最近运行：pass（as-is，2026-11-04 11:09 UTC，265.5 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-255time/preview.png]]
<!-- facts:end -->

## 用途

由5个甲基化探针PCA算MeTIL得分、tidyestimate算免疫/基质得分、GSVA算24种免疫细胞富集，拼三张注释热图展示亚型免疫景观。

## 适用

按分子亚型展示肿瘤免疫检查点表达、免疫/基质浸润与甲基化淋巴细胞定量。

## 不适用

需同时备齐表达TPM、450K甲基化（含5个MeTIL探针）、亚型注释和免疫细胞signature表；MeTIL仅适用450K数据。

## 输入

- `tcga.mibc.anno.txt`：见 Rmd“输入文件”节
- `TCGA-BLCA.methylation450.tsv.gz`：见 Rmd“输入文件”节
- `tcga.mibc.tpm.txt`：见 Rmd“输入文件”节
- `Curated_Immune_Cell_Signature.txt`：见 Rmd“输入文件”节

tpm行=基因列=样本；anno行=样本（TCGA前16位条码）与甲基化、表达矩阵样本名须可互相匹配。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-255time`
- 用到课题：`wiki.py use figureya-255time --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需ComplexHeatmap≥2.8版本；GSVA对全表达矩阵打分较慢。

## 输出

- `CheckPoint_heatmap.pdf`
- `TIMEheatmap.pdf`
- `MeTILheatmap.pdf`
- `TIME.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
