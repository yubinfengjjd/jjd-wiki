---
type: recipe
id: figureya-230immunelandscape
title: 多算法免疫浸润组合热图
status: draft
source:
  id: figureya
  item: FigureYa230immunelandscape
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa230immunelandscape.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，画热图所需的数据。这里是多种算法获得的免疫浸润数据，每行一个sample，每列一种免疫细胞。可以灵活替换为其他需要画热图的数据，例如基因表达矩阵，那么这里的免疫细胞就替换为基因/蛋白质/通路等等。
- file: easy_input_type.csv
  note: 第二种方式是提供一个文件`easy_input_type.csv`，把细胞和分类（这里指不同算法）作为两列放进去，细胞名的顺序跟easy_input.csv里的细胞顺序一致。
- file: easy_input_group.csv
  note: easy_input_group.csv，分组信息和连续变量，用于画热图上方的注释。这里的连续变量是risk score（根据它的大小为sample排序），分组信息是risk
    type。读懂之后可以按照现有的格式添加更多行注释。
outputs:
- immune heatmap by ComplexHeatmap.pdf
packages:
  cran:
  - RColorBrewer
  - gplots
  - oompaBase
  - pheatmap
  - viridis
  bioc:
  - ComplexHeatmap
  - circlize
  github: []
  library:
  - RColorBrewer
  - circlize
  - gplots
  - viridis
  - oompaBase
  - pheatmap
  - ComplexHeatmap
  namespaced:
  - knitr
tags:
- transcriptomics
- multi-omics
keywords:
- ComplexHeatmap
- pheatmap
- circlize
- CIBERSORT
- TIMER
- ssGSEA
- viridis
- oompaBase
- RColorBrewer
- gplots
chart_types:
- heatmap
summary: 把多种免疫浸润算法（TIMER/CIBERSORT/xCELL等）的得分按算法分块画成热图并纵向拼接，样本按risk score排序并加分组注释；提供pheat
favorite: false
---
# 多算法免疫浸润组合热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa230immunelandscape` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa230immunelandscape.Rmd`）
- 依赖：CRAN RColorBrewer, gplots, oompaBase, pheatmap, viridis；Bioconductor ComplexHeatmap, circlize
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

把多种免疫浸润算法（TIMER/CIBERSORT/xCELL等）的得分按算法分块画成热图并纵向拼接，样本按risk score排序并加分组注释；提供pheatmap单图和ComplexHeatmap多图拼接两种画法。

## 适用

综合展示多算法免疫评分或其他可按类别分行的矩阵（WGCNA模块、多组学结果），且顶部要叠连续变量+分组注释时。

## 不适用

只做展示，各算法得分需预先算好；7种算法名与riskScore/riskType注释写死；样本名强制拼“-01”后缀匹配TCGA条码；第二套画法依赖本地pheatmap_translate.R。

## 输入

- `easy_input.csv`：easy_input.csv，画热图所需的数据。这里是多种算法获得的免疫浸润数据，每行一个sample，每列一种免疫细胞。可以灵活替换为其他需要画热图的数据，例如基因表达矩阵，那么这里的免疫细胞就替换为基因/蛋白质/通路等等。
- `easy_input_type.csv`：第二种方式是提供一个文件`easy_input_type.csv`，把细胞和分类（这里指不同算法）作为两列放进去，细胞名的顺序跟easy_input.csv里的细胞顺序一致。
- `easy_input_group.csv`：easy_input_group.csv，分组信息和连续变量，用于画热图上方的注释。这里的连续变量是risk score（根据它的大小为sample排序），分组信息是risk type。读懂之后可以按照现有的格式添加更多行注释。

easy_input.csv行=样本列=细胞（列名可用“细胞_算法”携带分类，或由easy_input_type.csv两列提供、顺序与矩阵列一致）；easy_input_group.csv含riskScore（排序用连续值）和risk分组。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-230immunelandscape`
- 用到课题：`wiki.py use figureya-230immunelandscape --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：拼接画法需source本地pheatmap_translate.R（取自ComplexHeatmap 2.7.9源码，新版接口有bug）。

## 输出

- `immune heatmap by ComplexHeatmap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
