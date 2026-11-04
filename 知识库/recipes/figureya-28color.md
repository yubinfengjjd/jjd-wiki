---
type: recipe
id: figureya-28color
title: 论文图片配色提取色卡
status: draft
source:
  id: figureya
  item: FigureYa28color
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa28color.Rmd
inputs:
- file: Fig2.txt
  note: ''
outputs:
- Fig2.pdf
packages:
  cran:
  - devtools
  - ggplot2
  - stringr
  - reshape2
  - dichromat
  - EBImage
  - scales
  - rgl
  - rblocks
  - rPlotter
  bioc: []
  github:
  - rblocks
  - rPlotter
  library:
  - rPlotter
  - reshape2
  - EBImage
  - scales
  - rgl
  namespaced:
  - knitr
tags:
- other
keywords:
- rPlotter
- EBImage
- scales
- rgl
- reshape2
- extract_colours
chart_types:
- palette
summary: 用rPlotter从论文figure图片（jpg）中聚类提取配色，生成色卡PDF与色值文本，并支持插值增删颜色供其它绘图代码复用。
favorite: false
---
# 论文图片配色提取色卡

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa28color` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa28color.Rmd`）
- 依赖：CRAN devtools, ggplot2, stringr, reshape2, dichromat, EBImage, scales, rgl, rblocks, rPlotter；GitHub rblocks, rPlotter
- 最近运行：pass（as-is，2026-11-04 12:16 UTC，12.8 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-28color/preview.png]]
<!-- facts:end -->

## 用途

用rPlotter从论文figure图片（jpg）中聚类提取配色，生成色卡PDF与色值文本，并支持插值增删颜色供其它绘图代码复用。

## 适用

想模仿心仪论文的配色方案时，把代表性figure保存为jpg放目录下提取颜色；颜色需求多就选颜色丰富的图。

## 不适用

输入是图片而非数据表，提取的是量化近似色；文字/坐标轴等深色可能混入；只产色卡不出数据图。

## 输入

- `Fig2.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-28color`
- 用到课题：`wiki.py use figureya-28color --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：依赖GitHub包rPlotter与本地脚本extract_colours.R；可改读在线图片URL（默认本地jpg）；rgl三维色域展示需在Console交互运行。

## 输出

- `Fig2.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
