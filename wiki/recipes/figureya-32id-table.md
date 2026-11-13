---
type: recipe
id: figureya-32id-table
title: 按基因列表提取表达矩阵
status: draft
source:
  id: figureya
  item: FigureYa32ID_table
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa32ID_table.Rmd
inputs:
- file: not_easy_input_expr.txt
  note: 表达矩阵文件，`not_easy_input_expr.txt`或`easy_input_expr.txt`。
- file: easy_input_expr.txt
  note: 表达矩阵文件，`not_easy_input_expr.txt`或`easy_input_expr.txt`。
- file: not_easy_input_GO.txt
  note: ''
outputs: []
packages:
  cran:
  - dplyr
  - tibble
  - tidyr
  bioc: []
  github: []
  library:
  - dplyr
  - tidyr
  - tibble
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- GO
- gene list
- dplyr
- tibble
- tidyr
chart_types:
- table
summary: 把GO富集结果拆成逐term基因列表文件，按列表从表达矩阵中批量提取子矩阵输出csv；含按表达量排序、重名基因加后缀等辅助步骤。
favorite: false
---
# 按基因列表提取表达矩阵

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa32ID_table` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa32ID_table.Rmd`）
- 依赖：CRAN dplyr, tibble, tidyr
- 最近运行：fail（as-is，2026-11-04 11:13 UTC，15.9 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

把GO富集结果拆成逐term基因列表文件，按列表从表达矩阵中批量提取子矩阵输出csv；含按表达量排序、重名基因加后缀等辅助步骤。

## 适用

富集分析后想按GO term或自有分类基因列表拿到对应表达矩阵，供下游热图、boxplot等模块使用。

## 不适用

纯数据整理不画任何图；基因ID必须与表达矩阵行名完全一致；GO结果文件需第8列geneID以"/"分隔的固定结构。

## 输入

- `not_easy_input.txt`：基因列表文件，`not_easy_input.txt`或`GO*.txt`
- `not_easy_input_expr.txt`：表达矩阵文件，`not_easy_input_expr.txt`或`easy_input_expr.txt`。
- `easy_input_expr.txt`：表达矩阵文件，`not_easy_input_expr.txt`或`easy_input_expr.txt`。
- `not_easy_input_GO.txt`：见 Rmd“输入文件”节

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-32id-table`
- 用到课题：`wiki.py use figureya-32id-table --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
