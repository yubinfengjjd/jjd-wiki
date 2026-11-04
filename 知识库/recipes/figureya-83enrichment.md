---
type: recipe
id: figureya-83enrichment
title: 基因集富集耦合热图
status: draft
source:
  id: figureya
  item: FigureYa83enrichment
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa83enrichment.Rmd
inputs:
- file: easy_input_TF.csv
  note: easy_input_TF.csv，此处用201个转录因子的gene symbol，可以替换成你感兴趣的基因的gene symbol，例如差异表达基因、差异表达lncRNA等。
- file: easy_input_bg.csv
  note: easy_input_bg.csv，背景gene sybol，可以替换成与你感兴趣的基因相对应的背景基因，例如基因组上的全部基因、全部lncRNA等。
- file: Interactions.RData
  note: 如果你有自己的相互作用的基因list，保存在Interactions.RData里，就可以跳过这步，直接进入“Fisher's Exact Test”。
outputs:
- Enrichment_baseplot.pdf
packages:
  cran:
  - RColorBrewer
  - corrplot
  - ggplot2
  - ggthemes
  - rentrez
  bioc: []
  github: []
  library:
  - rentrez
  - RColorBrewer
  - corrplot
  - ggplot2
  - ggthemes
  namespaced:
  - knitr
  - XML
tags:
- transcriptomics
- experimental-statistics
keywords:
- Fisher's exact test
- hypergeometric
- corrplot
- rentrez
- odds ratio
- RColorBrewer
- ggthemes
chart_types:
- heatmap
summary: 对基因集两两做Fisher精确/超几何检验算富集odds ratio与FDR，取上三角画耦合热图并用符号标显著性层级。
favorite: false
---
# 基因集富集耦合热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa83enrichment` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa83enrichment.Rmd`）
- 依赖：CRAN RColorBrewer, corrplot, ggplot2, ggthemes, rentrez
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对基因集两两做Fisher精确/超几何检验算富集odds ratio与FDR，取上三角画耦合热图并用符号标显著性层级。

## 适用

分析任意基因集合间关系：TF共调控、差异基因×通路富集、ATAC peak邻近基因×表达基因等。

## 不适用

需每个集合的基因list（Interactions.RData）加统一背景基因表；集合多时两两检验慢且多重比较阈值硬编码；上下三角只做一半展示。

## 输入

- `easy_input_TF.csv`：easy_input_TF.csv，此处用201个转录因子的gene symbol，可以替换成你感兴趣的基因的gene symbol，例如差异表达基因、差异表达lncRNA等。
- `easy_input_bg.csv`：easy_input_bg.csv，背景gene sybol，可以替换成与你感兴趣的基因相对应的背景基因，例如基因组上的全部基因、全部lncRNA等。
- `Interactions.RData`：如果你有自己的相互作用的基因list，保存在Interactions.RData里，就可以跳过这步，直接进入“Fisher's Exact Test”。

背景表与各基因集须同一ID体系（如均为gene symbol）；可先按背景过滤集合大小（示例100–2000）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-83enrichment`
- 用到课题：`wiki.py use figureya-83enrichment --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：从NCBI Gene构建TF相互作用list的rentrez流程需联网（示例已存Interactions.RData可跳过）。

## 输出

- `Enrichment_baseplot.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
