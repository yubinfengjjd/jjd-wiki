---
type: recipe
id: figureya-199crosslink
title: 分组节点跨列连线图
status: draft
source:
  id: figureya
  item: FigureYa199crosslink
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa199crosslink.Rmd
inputs:
- file: easy_input_nodes.csv
  note: easy_input_nodes.csv，每个节点为一行。第一列是节点id，之后是其类别type、颜色color、大小size、透明度alpha和形状shape。例如一个节点代表一个基因；type列就写gene；颜色、大小、透明度和形状都可以代表基因的某一特征值，例如表达量等。
- file: easy_input_edges.csv
  note: easy_input_edges.csv，每两个被连起来的节点为一行，前两列是两个节点的id，之后是颜色color、类型type、透明度alpha和粗细size，这些外观信息可以代表每两个节点之间关系的强度、类型等。
- file: easy_input2_nodes.csv
  note: ''
- file: easy_input2_edges.csv
  note: ''
outputs:
- crosslink_file.pdf
- crosslink_par.pdf
- crosslink_multiCol.pdf
packages:
  cran: []
  bioc: []
  github: []
  library:
  - dplyr
  - ggplot2
  - scales
  namespaced:
  - knitr
  - RColorBrewer
tags:
- experimental-statistics
- single-cell
keywords:
- crosslink
- CellChat
- ggplot2
- columnCross2
- scales
chart_types:
- network
summary: 把不同类型节点排在竖列里、列间画连线；节点颜色/大小/形状/透明度与连线颜色/粗细/类型可编码任意属性，同类节点可拆多列。
favorite: false
---
# 分组节点跨列连线图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa199crosslink` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa199crosslink.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-11-04 11:01 UTC，19.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-199crosslink/preview.png]]
<!-- facts:end -->

## 用途

把不同类型节点排在竖列里、列间画连线；节点颜色/大小/形状/透明度与连线颜色/粗细/类型可编码任意属性，同类节点可拆多列。

## 适用

展示两组或多组实体间的关系及强弱类别（如细胞通讯、调控因子-通路相关），需要同时编码节点和边多重属性的场景。

## 不适用

需自备nodes和edges两张表，外观要么逐行写进文件要么画图时设参，需理解两种模式；节点排序与分列方式要手工指定；依赖随附源码非CRAN包。

## 输入

- `easy_input_nodes.csv`：easy_input_nodes.csv，每个节点为一行。第一列是节点id，之后是其类别type、颜色color、大小size、透明度alpha和形状shape。例如一个节点代表一个基因；type列就写gene；颜色、大小、透明度和形状都可以代表基因的某一特征值，例如表达量等。
- `easy_input_edges.csv`：easy_input_edges.csv，每两个被连起来的节点为一行，前两列是两个节点的id，之后是颜色color、类型type、透明度alpha和粗细size，这些外观信息可以代表每两个节点之间关系的强度、类型等。
- `easy_input2_nodes.csv`：见 Rmd“输入文件”节
- `easy_input2_edges.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-199crosslink`
- 用到课题：`wiki.py use figureya-199crosslink --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：crosslink.R等源码由随附的crosslinks-master.tar.gz解压而来（GitHub包zzwch/crosslink），以source本地文件方式使用。

## 输出

- `crosslink_file.pdf`
- `crosslink_par.pdf`
- `crosslink_multiCol.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
