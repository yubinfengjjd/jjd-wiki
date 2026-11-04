---
type: recipe
id: figureya-214kegg-hierarchyv2
title: KEGG三层层级富集条形图
status: draft
source:
  id: figureya
  item: FigureYa214KEGG_hierarchyV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa214KEGG_hierarchyV2.Rmd
inputs:
- file: kegg_hierarchy.csv
  note: kegg_hierarchy.csv，前面获得的KEGG三层注释的对应关系。
- file: easy_input.txt
  note: easy_input.txt，前4列是富集分析结果，最后一列是上调/下调，对应图中文字的红绿色。这里直接使用原文的结果。平常我们做KEGG的富集分析，结果里的ID通常是“hsa+数字”，只需把hsa替换成ko即可。
outputs:
- KEGGhierarchy.pdf
packages:
  cran:
  - dplyr
  - ggplot2
  - jsonlite
  - tidyjson
  - tidyr
  - scatterpie
  - httr
  bioc:
  - clusterProfiler
  - DOSE
  - enrichplot
  - GO.db
  - GOSemSim
  - AnnotationDbi
  github: []
  library:
  - tidyjson
  - jsonlite
  - dplyr
  - tidyr
  - clusterProfiler
  - ggplot2
  namespaced:
  - knitr
  - cowplot
tags:
- transcriptomics
- experimental-statistics
keywords:
- clusterProfiler
- KEGG
- jsonlite
- tidyjson
- cowplot
chart_types:
- bar
summary: 把KEGG富集结果按level1/level2/level3三层归类，画Detected/Enriched对数条形图加三层级文字标注的组合图。
favorite: false
---
# KEGG三层层级富集条形图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa214KEGG_hierarchyV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa214KEGG_hierarchyV2.Rmd`）
- 依赖：CRAN dplyr, ggplot2, jsonlite, tidyjson, tidyr, scatterpie, httr；Bioconductor clusterProfiler, DOSE, enrichplot, GO.db, GOSemSim, AnnotationDbi
- 最近运行：pass（as-is，2026-11-04 11:03 UTC，50.4 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-214kegg-hierarchyv2/preview.png]]
<!-- facts:end -->

## 用途

把KEGG富集结果按level1/level2/level3三层归类，画Detected/Enriched对数条形图加三层级文字标注的组合图。

## 适用

富集term太多太杂时，用KEGG自带三层分类体系归并展示，比simplify/GOSemSim更直接。

## 不适用

只适配KEGG通路（ID须为koXXXXX，hsa结果要换前缀）；level1/level2排序按写死的factor水平，分类不全会丢行；不做富集计算，只吃现成结果表。

## 输入

- `kegg_hierarchy.csv`：kegg_hierarchy.csv，前面获得的KEGG三层注释的对应关系。
- `easy_input.txt`：easy_input.txt，前4列是富集分析结果，最后一列是上调/下调，对应图中文字的红绿色。这里直接使用原文的结果。平常我们做KEGG的富集分析，结果里的ID通常是“hsa+数字”，只需把hsa替换成ko即可。

easy_input.txt前4列为富集结果（含ID/Detected/Enriched），最后一列为上调/下调方向；kegg_hierarchy.csv由br08901.json解析生成。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-214kegg-hierarchyv2`
- 用到课题：`wiki.py use figureya-214kegg-hierarchyv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：如需更新三层注释，br08901.json需手动从KEGG官网（get_htext?br08901.keg）下载。

## 输出

- `KEGGhierarchy.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
