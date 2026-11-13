---
type: recipe
id: figureya-26circos-r
title: 分组环形连线关系图
status: ready
source:
  id: figureya
  item: FigureYa26circos_R
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa26circos_R.Rmd
inputs:
- file: Gene_ID.txt
  note: Gene_ID.txt，组，此处一个Gene为一组；
- file: Gene_feature.txt
  note: Gene_feature.txt，亚组，Gene内包含多个Subgroup；
- file: Links.txt
  note: Links.txt，Subgroup之间的links。
outputs:
- circlize.pdf
packages:
  cran:
  - graphics
  - stringi
  - GlobalOptions
  bioc:
  - circlize
  github: []
  library:
  - stringi
  - circlize
  namespaced:
  - knitr
tags:
- experimental-statistics
- multi-omics
keywords:
- circlize
- circos.link
- links
- stringi
chart_types:
- chord
summary: 用circlize把“组-亚组-亚组间连线”三层结构画成环状图，同组同色方块，正/负关系用两色连线区分。
favorite: false
---
# 分组环形连线关系图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa26circos_R` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa26circos_R.Rmd`）
- 依赖：CRAN graphics, stringi, GlobalOptions；Bioconductor circlize
- 最近运行：pass（as-is，2026-11-04 11:09 UTC，8.5 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `circlize.pdf` 第 1 页）：

![[recipes/figureya-26circos-r/preview.png]]
<!-- facts:end -->

## 用途

用circlize把“组-亚组-亚组间连线”三层结构画成环状图，同组同色方块，正/负关系用两色连线区分。

## 适用

展示多对多的归属加相互作用关系，如基因融合片段连接、分组间正负调控或功能连接；网状关系比直线sankey更合适。

## 不适用

三个输入文件列结构固定，links在亚组内的相对坐标需手算；只表达关系本身，不映射流量/数值宽度。

## 输入

- `Gene_ID.txt`：Gene_ID.txt，组，此处一个Gene为一组；
- `Gene_feature.txt`：Gene_feature.txt，亚组，Gene内包含多个Subgroup；
- `Links.txt`：Links.txt，Subgroup之间的links。

Gene_ID.txt给组名+起止位置，Gene_feature.txt给亚组名+起止位置+可选bar_col颜色，Links.txt给两端亚组及相对位置+可选link_col/link_height；颜色列为十六进制但不带#。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-26circos-r`
- 用到课题：`wiki.py use figureya-26circos-r --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `circlize.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
