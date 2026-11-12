---
type: recipe
id: figureya-63pubmedminingv2
title: PubMed批量检索与词频挖掘
status: draft
source:
  id: figureya
  item: FigureYa63pubmedMiningV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa63pubmedMiningV2.Rmd
inputs:
- file: common_words_new.v2.txt
  note: ''
- file: HGNCdata.rda
  note: ''
outputs: []
packages:
  cran:
  - data.table
  - DT
  - ggplot2
  - htmlwidgets
  - pubmed.mineR
  - rentrez
  - stringr
  bioc: []
  github: []
  library:
  - data.table
  - stringr
  - ggplot2
  - rentrez
  - pubmed.mineR
  - DT
  - htmlwidgets
  namespaced:
  - knitr
tags:
- other
keywords:
- rentrez
- pubmed.mineR
- PubMed
- MeSH
- DT
- htmlwidgets
- HGNC
- entrez
- data.table
- stringr
chart_types:
- trend
- table
summary: 用rentrez按检索词批量查PubMed：画年度发文趋势、导出文章清单、统计摘要中的基因/词频找共现分子，输出交互表格。
favorite: false
---
# PubMed批量检索与词频挖掘

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa63pubmedMiningV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa63pubmedMiningV2.Rmd`）
- 依赖：CRAN data.table, DT, ggplot2, htmlwidgets, pubmed.mineR, rentrez, stringr
- 最近运行：pass（as-is，2026-11-11 06:08 UTC，33.1 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-63pubmedminingv2/preview.png]]
<!-- facts:end -->

## 用途

用rentrez按检索词批量查PubMed：画年度发文趋势、导出文章清单、统计摘要中的基因/词频找共现分子，输出交互表格。

## 适用

想快速摸清陌生基因的研究热度、代表文献及其常共现的分子，辅助选题和机制假设。

## 不适用

全程依赖NCBI E-utilities联网，示例retmax=200只抓前200篇；词频基于英文摘要且依赖停用词表与HGNC别名表，摘要未提及的关系抓不到；检索词质量直接决定结果。

## 输入

- `common_words_new.v2.txt`：见 Rmd“输入文件”节
- `HGNCdata.rda`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-63pubmedminingv2`
- 用到课题：`wiki.py use figureya-63pubmedminingv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需联网调用NCBI API；检索量大时注意限速与API key。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
