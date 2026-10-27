---
type: recipe
id: figureya-196panpie
title: 分组临床分期扇形矩阵图
status: ready
source:
  id: figureya
  item: FigureYa196PanPie
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa196PanPie.Rmd
inputs:
- file: easy_input.txt
  note: easy_input.txt
outputs:
- pieTable.pdf
packages:
  cran:
  - dplyr
  bioc: []
  github: []
  library:
  - dplyr
  namespaced:
  - knitr
tags:
- experimental-statistics
keywords:
- pan-cancer
- clinical stage
- pie table
chart_types:
- pie
summary: 用扇形矩阵展示不同分组在临床分期等分类变量上的构成差异。
favorite: false
---
# 分组临床分期扇形矩阵图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa196PanPie` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa196PanPie.Rmd`）
- 依赖：CRAN dplyr
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，0.9 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用扇形矩阵展示不同分组在临床分期等分类变量上的构成差异。

## 适用

分组变量与一个或多个分类临床变量的个体表或计数表。

## 不适用

类别很多（扇形难读，考虑堆叠柱）；需要检验构成差异时另做卡方/Fisher 检验。

## 输入

- `easy_input.txt`：easy_input.txt

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-196panpie`
- 用到课题：`wiki.py use figureya-196panpie --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `pieTable.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig03-pie--pie|分组构成饼图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
