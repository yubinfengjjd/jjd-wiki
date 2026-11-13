---
type: recipe
id: figureya-64triangle
title: 三组频率三元散点图
status: ready
source:
  id: figureya
  item: FigureYa64triangle
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa64triangle.Rmd
inputs:
- file: easy_input.csv
  note: 如果你的数据已经整理成“easy_input.csv”的格式，就可以跳过这步，直接进入“输入文件”。
- file: not_easy_input.csv
  note: 下载原文的补充材料Table2.pdf，整理为"not_easy_input.csv"
outputs:
- triangle.pdf
- triangle_geom_text.pdf
- triangle_directlabels.pdf
packages:
  cran:
  - ggtern
  - directlabels
  - proto
  - scales
  - tidyverse
  - dplyr
  - grid
  - gtable
  - plyr
  - MASS
  - compositions
  - ggplot2
  bioc: []
  github: []
  library:
  - tidyverse
  - scales
  - ggplot2
  - directlabels
  - ggtern
  namespaced:
  - knitr
tags:
- experimental-statistics
- multi-omics
keywords:
- ggtern
- ternary plot
- directlabels
- GBM
- 突变频率
- scales
- tidyverse
chart_types:
- ternary
summary: 用ggtern画三元图：每个点的xyz坐标为某指标在三组中的占比/频率，点大小与颜色映射第四维数值（如总突变频率）。
favorite: false
---
# 三组频率三元散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa64triangle` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa64triangle.Rmd`）
- 依赖：CRAN ggtern, directlabels, proto, scales, tidyverse, dplyr, grid, gtable, plyr, MASS, compositions, ggplot2
- 最近运行：pass（as-is，2026-11-04 11:18 UTC，45.7 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-64triangle/preview.png]]
<!-- facts:end -->

## 用途

用ggtern画三元图：每个点的xyz坐标为某指标在三组中的占比/频率，点大小与颜色映射第四维数值（如总突变频率）。

## 适用

展示同一指标在3个疾病或3组之间的相对构成，例如基因在GBM三亚型中的突变频率分布。

## 不适用

只能比较3组；ggrepel与geom_text的check_overlap对ggtern无效，标签重叠要靠directlabels或Illustrator手工调；点大小等映射需自行分段优化。

## 输入

- `easy_input.csv`：如果你的数据已经整理成“easy_input.csv”的格式，就可以跳过这步，直接进入“输入文件”。
- `not_easy_input.csv`：下载原文的补充材料Table2.pdf，整理为"not_easy_input.csv"

easy_input.csv至少3列xyz坐标，可选第5列控制点大小。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-64triangle`
- 用到课题：`wiki.py use figureya-64triangle --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：ggtern 3.5.0与ggplot2≥4.0不兼容，install脚本会自动把ggplot2降级到3.5.x（remotes::install_version）。

## 输出

- `triangle.pdf`
- `triangle_geom_text.pdf`
- `triangle_directlabels.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
