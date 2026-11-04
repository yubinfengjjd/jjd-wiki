---
type: recipe
id: figureya-109subtypegsea-update
title: 多亚型GSEA富集对角热图
status: draft
source:
  id: figureya
  item: FigureYa109SubtypeGSEA_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa109SubtypeGSEA_update.Rmd
inputs:
- file: easy_input_expr.csv
  note: easy_input_expr.csv，表达矩阵
- file: easy_input_subtype.txt
  note: easy_input_subtype.txt，分组信息，此处是3种亚型
outputs: []
packages:
  cran:
  - gplots
  - pheatmap
  - magick
  bioc:
  - clusterProfiler
  - GSVA
  - SpatialExperiment
  github: []
  library:
  - clusterProfiler
  - GSVA
  - pheatmap
  - gplots
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- clusterProfiler
- GSVA
- pheatmap
- gplots
- MSigDB
- GSEA
chart_types:
- heatmap
summary: 对每个亚型做“一组vs其余组”的差异分析，分别跑clusterProfiler的GSEA并挑各组top通路，再用GSVA打分画带亚型注释的对角式热图。
favorite: false
---
# 多亚型GSEA富集对角热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa109SubtypeGSEA_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa109SubtypeGSEA_update.Rmd`）
- 依赖：CRAN gplots, pheatmap, magick；Bioconductor clusterProfiler, GSVA, SpatialExperiment
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对每个亚型做“一组vs其余组”的差异分析，分别跑clusterProfiler的GSEA并挑各组top通路，再用GSVA打分画带亚型注释的对角式热图。

## 适用

想并排比较多组（如各亚型）各自特异的富集通路，同时看到同一通路在其他组里的富集状态时。

## 不适用

需表达矩阵+分组表且须另备MSigDB的gmt基因集；差异分析是逐基因t检验、GSEA带置换检验，基因/样本多时很慢；不适合直接拿现成富集结果画图。

## 输入

- `easy_input_expr.csv`：easy_input_expr.csv，表达矩阵
- `easy_input_subtype.txt`：easy_input_subtype.txt，分组信息，此处是3种亚型

easy_input_expr.csv行=基因列=样本；easy_input_subtype.txt以样本为行名、含TCGA_Subtype分组列，行名须与矩阵列名一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-109subtypegsea-update`
- 用到课题：`wiki.py use figureya-109subtypegsea-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：逐基因t检验按组数循环+GSEA置换检验，大矩阵耗时长；magick包需系统libmagick++。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
