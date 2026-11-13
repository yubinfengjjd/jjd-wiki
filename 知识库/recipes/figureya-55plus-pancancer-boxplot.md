---
type: recipe
id: figureya-55plus-pancancer-boxplot
title: 泛癌肿瘤对照分组箱线图
status: ready
source:
  id: figureya
  item: FigureYa55plus_pancancer_boxplot
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa55plus_pancancer_boxplot.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，每行一个sample。第一列组织部位，第二列肿瘤/对照组，第三列基因表达量。
outputs:
- pancancer_ggpubr.pdf
- pancancer_ggplot2box.pdf
- pancancer_ggplot2boxDot.pdf
- pancancer_ggplot2boxDot_all.pdf
packages:
  cran:
  - ggplot2
  - ggpubr
  bioc: []
  github: []
  library:
  - ggpubr
  - ggplot2
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- ggpubr
- ggplot2
- TCGA
- GTEx
- wilcox.test
- compare_means
chart_types:
- boxplot
summary: 用“组织-分组-表达量”三列数据画泛癌各组织肿瘤vs对照的分组箱线图（可叠散点），自动算wilcox并标星，提供ggpubr和纯ggplot2两种实现。
favorite: false
---
# 泛癌肿瘤对照分组箱线图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa55plus_pancancer_boxplot` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa55plus_pancancer_boxplot.Rmd`）
- 依赖：CRAN ggplot2, ggpubr
- 最近运行：pass（as-is，2026-11-04 11:15 UTC，337.8 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-55plus-pancancer-boxplot/preview.png]]
<!-- facts:end -->

## 用途

用“组织-分组-表达量”三列数据画泛癌各组织肿瘤vs对照的分组箱线图（可叠散点），自动算wilcox并标星，提供ggpubr和纯ggplot2两种实现。

## 适用

已有FigureYa55panCancer_violin同款easy_input.csv，想换箱线图展示33癌种基因表达差异并标注显著性。

## 不适用

输入须恰好三列（组织/分组/表达量）；按两组比较设计（wilcox或t检验），无正常对照的癌种需剔除或单独叠加绘制。

## 输入

- `easy_input.csv`：easy_input.csv，每行一个sample。第一列组织部位，第二列肿瘤/对照组，第三列基因表达量。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-55plus-pancancer-boxplot`
- 用到课题：`wiki.py use figureya-55plus-pancancer-boxplot --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `pancancer_ggpubr.pdf`
- `pancancer_ggplot2box.pdf`
- `pancancer_ggplot2boxDot.pdf`
- `pancancer_ggplot2boxDot_all.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
