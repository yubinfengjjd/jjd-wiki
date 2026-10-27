---
type: recipe
id: figureya-236circgroup
title: 分型对应关系圈状热图
status: ready
source:
  id: figureya
  item: FigureYa236circGroup
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa236circGroup.Rmd
inputs:
- file: easy_input.txt
  note: easy_input.txt，多组分类信息。也可用于FigureYa25Sankey，画成桑基图。
outputs: []
packages:
  cran:
  - grid
  - gridBase
  - SimDesign
  bioc:
  - circlize
  - ComplexHeatmap
  github: []
  library:
  - circlize
  - gridBase
  - ComplexHeatmap
  - SimDesign
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- subtype concordance
- circular annotation
- circlize
- ComplexHeatmap
- SimDesign
- gridBase
chart_types:
- radial
summary: 把多个分型（或分类变量）之间的对应关系画成圈状热图注释，直观看一致性。
favorite: false
---
# 分型对应关系圈状热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa236circGroup` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa236circGroup.Rmd`）
- 依赖：CRAN grid, gridBase, SimDesign；Bioconductor circlize, ComplexHeatmap
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，7.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-236circgroup/preview.png]]
<!-- facts:end -->

## 用途

把多个分型（或分类变量）之间的对应关系画成圈状热图注释，直观看一致性。

## 适用

每行一个样本，若干列是不同来源的分型标签。

## 不适用

需要一致性统计量（如 ARI、kappa）时另行计算；连续变量。

## 输入

- `easy_input.txt`：easy_input.txt，多组分类信息。也可用于FigureYa25Sankey，画成桑基图。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-236circgroup`
- 用到课题：`wiki.py use figureya-236circgroup --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
