---
type: recipe
id: figureya-284pairwiselogrank
title: 三组以上 KM 曲线与两两比较表
status: ready
source:
  id: figureya
  item: FigureYa284pairwiseLogrank
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa284pairwiseLogrank.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs:
- km curve with pairwise logrank test.pdf
packages:
  cran:
  - RColorBrewer
  - ggpp
  - survival
  - survminer
  - tibble
  bioc: []
  github: []
  library:
  - survival
  - survminer
  - RColorBrewer
  - tibble
  - ggpp
  namespaced:
  - knitr
tags:
- survival-analysis
keywords:
- pairwise log-rank
- MOVICS compSurv
- survminer
- RColorBrewer
- ggpp
- survival
- tibble
chart_types:
- km-curve
summary: 对 3 个及以上亚组画 KM 曲线，并在图中嵌入两两 log-rank 比较的 P 值表。
favorite: false
---
# 三组以上 KM 曲线与两两比较表

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa284pairwiseLogrank` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa284pairwiseLogrank.Rmd`）
- 依赖：CRAN RColorBrewer, ggpp, survival, survminer, tibble
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，5.5 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-284pairwiselogrank/preview.png]]
<!-- facts:end -->

## 用途

对 3 个及以上亚组画 KM 曲线，并在图中嵌入两两 log-rank 比较的 P 值表。

## 适用

亚组（如分子分型）≥3 个、每组有个体随访时间与事件；想同时报告总体与两两比较。

## 不适用

只有两组（用多组 KM 曲线即可）；需要多重比较校正方式与上游不同时要先确认；竞争风险数据。

## 输入

- `easy_input.csv`：easy_input.csv，生存和分组信息，这里是乳腺癌数据。
- `easy_input.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-284pairwiselogrank`
- 用到课题：`wiki.py use figureya-284pairwiselogrank --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `km curve with pairwise logrank test.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
