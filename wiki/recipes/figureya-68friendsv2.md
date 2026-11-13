---
type: recipe
id: figureya-68friendsv2
title: GO语义相似度箱线云雨图
status: ready
source:
  id: figureya
  item: FigureYa68friendsV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa68friendsV2.Rmd
inputs:
- file: easy_input.csv
  note: ''
- file: fsim.rda
  note: ''
- file: very_easy_input.csv
  note: ''
outputs:
- friends_box.pdf
- friends_raincloud.pdf
- friends.pdf
packages:
  cran:
  - GOSemSim
  - cowplot
  - ggplot2
  - reshape2
  bioc:
  - org.Hs.eg.db
  github: []
  library:
  - org.Hs.eg.db
  - GOSemSim
  - reshape2
  - ggplot2
  - cowplot
  namespaced:
  - knitr
tags:
- experimental-statistics
- transcriptomics
keywords:
- GOSemSim
- GO semantic similarity
- org.Hs.eg.db
- raincloud
- ENTREZID
- geom_flat_violin
- cowplot
- reshape2
chart_types:
- violin
- boxplot
summary: 用GOSemSim算基因两两GO语义相似度（MF与CC几何均值），按平均相似度排序找“朋友”最多的hub基因，画横向箱线图和云雨图。
favorite: false
---
# GO语义相似度箱线云雨图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa68friendsV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa68friendsV2.Rmd`）
- 依赖：CRAN GOSemSim, cowplot, ggplot2, reshape2；Bioconductor org.Hs.eg.db
- 最近运行：pass（as-is，2026-11-04 11:19 UTC，60.4 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-68friendsv2/preview.png]]
<!-- facts:end -->

## 用途

用GOSemSim算基因两两GO语义相似度（MF与CC几何均值），按平均相似度排序找“朋友”最多的hub基因，画横向箱线图和云雨图。

## 适用

从差异基因、质谱pull-down或酵母双杂候选清单里，按功能相似性挑最值得验证的hub基因。

## 不适用

输入为ENTREZID+SYMBOL两列且仅限人类（org.Hs.eg.db）；无GO注释的基因会在交集中被丢弃；GO注释逐年更新，结果不能与2012年原文完全一致。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节
- `fsim.rda`：见 Rmd“输入文件”节
- `very_easy_input.csv`：见 Rmd“输入文件”节

可先算相似矩阵再转成两列（基因、相似度）的very_easy_input.csv；若直接给该两列文件可跳过计算只画云雨图。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-68friendsv2`
- 用到课题：`wiki.py use figureya-68friendsv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `friends_box.pdf`
- `friends_raincloud.pdf`
- `friends.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] · [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
