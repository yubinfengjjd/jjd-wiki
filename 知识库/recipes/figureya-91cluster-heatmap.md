---
type: recipe
id: figureya-91cluster-heatmap
title: 聚类热图与样本顺序导出
status: draft
source:
  id: figureya
  item: FigureYa91cluster_heatmap
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa91cluster_heatmap.Rmd
inputs:
- file: easy_input_expr.csv
  note: ''
- file: easy_input_annotation.csv
  note: ''
- file: sample_order.csv
  note: ''
outputs: []
packages:
  cran:
  - ClassDiscovery
  - gplots
  - pheatmap
  bioc: []
  github: []
  library:
  - ClassDiscovery
  - pheatmap
  - gplots
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- pheatmap
- hclust
- ClassDiscovery
- cutree
- 样本排序
- gplots
chart_types:
- heatmap
summary: 演示pheatmap的多种玩法：外部hclust聚类切2/3类写入注释条、隐藏树状图、导出聚类后样本顺序、按文件顺序固定样本排列。
favorite: false
---
# 聚类热图与样本顺序导出

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa91cluster_heatmap` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa91cluster_heatmap.Rmd`）
- 依赖：CRAN ClassDiscovery, gplots, pheatmap
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

演示pheatmap的多种玩法：外部hclust聚类切2/3类写入注释条、隐藏树状图、导出聚类后样本顺序、按文件顺序固定样本排列。

## 适用

想用颜色条代替树标注聚类分组，或要把聚类/自定义样本顺序固定进热图并导出供下游（如亚型生存分析）使用。

## 不适用

只是热图绘制技巧合集，不含聚类方法学选择建议；表达矩阵、注释表、顺序文件的样本名须一致且顺序文件需覆盖全部样本。

## 输入

- `easy_input_expr.csv`：见 Rmd“输入文件”节
- `easy_input_annotation.csv`：见 Rmd“输入文件”节
- `sample_order.csv`：见 Rmd“输入文件”节

expr行基因列样本；annotation行样本列注释；sample_order.csv含sample/group列，行序即绘图列序。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-91cluster-heatmap`
- 用到课题：`wiki.py use figureya-91cluster-heatmap --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
