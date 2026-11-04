---
type: recipe
id: figureya-47hrtable
title: 单多因素Cox回归三线表
status: draft
source:
  id: figureya
  item: FigureYa47HRtable
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa47HRtable.Rmd
inputs:
- file: easy_input.csv
  note: ''
outputs: []
packages:
  cran:
  - kableExtra
  - officer
  - survival
  bioc: []
  github: []
  library:
  - survival
  - caret
  - kableExtra
  - officer
  namespaced:
  - knitr
  - dplyr
tags:
- survival-analysis
- experimental-statistics
keywords:
- coxph
- survival
- HR
- officer
- kableExtra
- caret
- createDataPartition
chart_types:
- table
summary: 对临床因子和基因表达批量做单因素Cox回归，取p<0.05的变量再拟合多因素Cox，把HR(95%CI)和p值输出成论文三线表（html/csv/word），并
favorite: false
---
# 单多因素Cox回归三线表

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa47HRtable` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa47HRtable.Rmd`）
- 依赖：CRAN kableExtra, officer, survival
- 最近运行：pass（as-is，2026-11-04 11:14 UTC，11.8 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对临床因子和基因表达批量做单因素Cox回归，取p<0.05的变量再拟合多因素Cox，把HR(95%CI)和p值输出成论文三线表（html/csv/word），并演示70%随机拆分验证集。

## 适用

要评估各临床/分子因素对预后（OS）的独立影响并生成出版格式Table 2，如TCGA队列加独立验证队列。

## 不适用

变量取列位置硬编码（第2:9和12,13列）、结局用OS/EVENT固定列名，换数据要改代码；连续变量须先离散化转因子；只出表格不出图。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-47hrtable`
- 用到课题：`wiki.py use figureya-47hrtable --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
