---
type: recipe
id: figureya-112venn
title: 四组韦恩图占比渐变填色
status: ready
source:
  id: figureya
  item: FigureYa112venn
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa112venn.Rmd
inputs: []
outputs: []
packages:
  cran:
  - Cairo
  - RColorBrewer
  - VennDiagram
  - dplyr
  - ggplot2
  - grDevices
  - magrittr
  - purrr
  - readr
  - stringr
  - tibble
  - tidyr
  bioc: []
  github: []
  library:
  - VennDiagram
  - ggplot2
  - dplyr
  - magrittr
  - readr
  - purrr
  - RColorBrewer
  - Cairo
  - stringr
  - tibble
  - tidyr
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- VennDiagram
- colorfulVennPlot
- Cairo
- RColorBrewer
- Venn
- magrittr
- purrr
- readr
- stringr
- tibble
chart_types:
- venn
summary: 输入四个基因列表，自算15个子区域元素数与占比，按占比给每个区域做渐变色填充，输出PDF矢量韦恩图。
favorite: false
---
# 四组韦恩图占比渐变填色

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa112venn` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa112venn.Rmd`）
- 依赖：CRAN Cairo, RColorBrewer, VennDiagram, dplyr, ggplot2, grDevices, magrittr, purrr, readr, stringr, tibble, tidyr
- 最近运行：pass（as-is，2026-11-11 05:22 UTC，3.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `venn_num.pdf` 第 1 页）：

![[recipes/figureya-112venn/preview.png]]
<!-- facts:end -->

## 用途

输入四个基因列表，自算15个子区域元素数与占比，按占比给每个区域做渐变色填充，输出PDF矢量韦恩图。

## 适用

展示4组元素（如多个分组/处理得到的差异基因）之间的重叠关系，想用颜色深浅直观表现各交集大小。

## 不适用

子区域计算固定按4个列表写死（2^4-1），改成3组或5组以上要重写区域编码逻辑；画图依赖随附的plotVenn4d.R（colorfulVennPlot函数），非CRAN直接安装。

## 输入

- 见 Rmd“输入文件”节（适配器未识别出文件名）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-112venn`
- 用到课题：`wiki.py use figureya-112venn --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig12-venn--venn|多集合交集维恩图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
