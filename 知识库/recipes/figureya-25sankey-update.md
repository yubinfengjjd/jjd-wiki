---
type: recipe
id: figureya-25sankey-update
title: 多层分类流向桑基图
status: draft
source:
  id: figureya
  item: FigureYa25Sankey_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa25Sankey_update.Rmd
inputs:
- file: easy_input.txt
  note: easy_input.txt，至少要有两列，想画出几列就提供几列数据。此处第一列是基因，第二列是突变，第三列是癌症亚型；想画更多层次关系就继续向后添加列。
outputs:
- sankey_stratum_3.pdf
- sankey_stratum_2.pdf
- sankey_alluvium.pdf
packages:
  cran:
  - dplyr
  - ggalluvial
  bioc: []
  github: []
  library:
  - ggalluvial
  - dplyr
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- ggalluvial
- alluvial
- subgroup distribution
chart_types:
- sankey
summary: 展示多层分类属性之间的交叉与流向，例如高频突变基因所属的分组，或 miRNA—靶基因关系。
favorite: false
---
# 多层分类流向桑基图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa25Sankey_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa25Sankey_update.Rmd`）
- 依赖：CRAN dplyr, ggalluvial
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，3.8 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-25sankey-update/preview.png]]
<!-- facts:end -->

## 用途

展示多层分类属性之间的交叉与流向，例如高频突变基因所属的分组，或 miRNA—靶基因关系。

## 适用

每行一个对象，若干列是分类属性（层），可选权重。

## 不适用

连续变量；层数或类别过多导致流线难辨。

## 输入

- `easy_input.txt`：easy_input.txt，至少要有两列，想画出几列就提供几列数据。此处第一列是基因，第二列是突变，第三列是癌症亚型；想画更多层次关系就继续向后添加列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-25sankey-update`
- 用到课题：`wiki.py use figureya-25sankey-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `sankey_stratum_3.pdf`
- `sankey_stratum_2.pdf`
- `sankey_alluvium.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig10-sankey--sankey|分组流向桑基图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
