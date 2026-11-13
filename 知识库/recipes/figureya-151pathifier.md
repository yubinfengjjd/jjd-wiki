---
type: recipe
id: figureya-151pathifier
title: Pathifier通路失调得分热图
status: ready
source:
  id: figureya
  item: FigureYa151pathifier
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa151pathifier.Rmd
inputs:
- file: easy_input_expr.txt
  note: easy_input_expr.txt，基因表达矩阵。
- file: easy_input_info.txt
  note: easy_input_info.txt，样本信息。
outputs:
- pathifier.pdf
packages:
  cran:
  - data.table
  - gplots
  - pheatmap
  - devtools
  bioc:
  - pathifier
  github: []
  library:
  - pathifier
  - data.table
  - pheatmap
  - gplots
  namespaced:
  - knitr
  - BiocManager
tags:
- transcriptomics
keywords:
- pathifier
- PDS
- gmt
- pheatmap
- quantify_pathways_deregulation
- data.table
- gplots
chart_types:
- heatmap
summary: 用pathifier按通路基因集把基因表达矩阵换算成通路失调得分（PDS）矩阵，再画通路×样本热图直接观察目标通路。
favorite: false
---
# Pathifier通路失调得分热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa151pathifier` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa151pathifier.Rmd`）
- 依赖：CRAN data.table, gplots, pheatmap, devtools；Bioconductor pathifier
- 最近运行：pass（as-is，2026-11-04 12:16 UTC，1023.1 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-151pathifier/preview.png]]
<!-- facts:end -->

## 用途

用pathifier按通路基因集把基因表达矩阵换算成通路失调得分（PDS）矩阵，再画通路×样本热图直接观察目标通路。

## 适用

富集分析或GSEA因参数设置看不到目标通路时，把表达谱转成通路层面矩阵盯住感兴趣的通路；功能类似GSVA。

## 不适用

算法要求normals指示向量，即必须含正常/对照样本才能算分；gmt通路多时极慢，应先裁剪到目标通路；只得分不做显著性检验。

## 输入

- `easy_input_expr.txt`：easy_input_expr.txt，基因表达矩阵。
- `easy_input_info.txt`：easy_input_info.txt，样本信息。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-151pathifier`
- 用到课题：`wiki.py use figureya-151pathifier --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：pathifier耗时随通路/基因数增长，千篇级gmt（如c5）可能跑10天以上；gmt文件需自备（GSEA网站下载或自建）。

## 输出

- `pathifier.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
