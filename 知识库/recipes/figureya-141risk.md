---
type: recipe
id: figureya-141risk
title: 风险评分分布与签名基因热图联图
status: draft
source:
  id: figureya
  item: FigureYa141risk
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa141risk.Rmd
inputs:
- file: easy_input_risk.csv
  note: easy_input_risk.csv，包含生存信息、表达量、risk score。其中risk score的获得，可以通过FigureYa31lasso计算并输出每个signature的系数coefficient，然后算出risk
    score，可参考这篇文章的第二步：<https://mp.weixin.qq.com/s/4s6X0dpvEqOh-KtxES3sTg>
- file: easy_input_sig.txt
  note: easy_input_sig.txt，signature。可以通过lasso、SVM等方法筛选获得，可参考FigureYa31lasso或FigureYa65SVM-RFE。
outputs:
- cox.pdf
- cox2.pdf
packages:
  cran:
  - cowplot
  - ggplot2
  - reshape2
  - scales
  bioc: []
  github: []
  library:
  - reshape2
  - ggplot2
  - scales
  - cowplot
  namespaced:
  - knitr
tags:
- survival-analysis
- transcriptomics
keywords:
- riskscore
- risk factor plot
- signature heatmap
- cowplot
- reshape2
- scales
chart_types:
- risk-plot
- heatmap
summary: 按风险评分排序样本，联合展示评分分布、生存状态和签名基因表达热图，用竖线分高低风险组。
favorite: false
---
# 风险评分分布与签名基因热图联图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa141risk` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa141risk.Rmd`）
- 依赖：CRAN cowplot, ggplot2, reshape2, scales
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，34.2 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-141risk/preview.png]]
<!-- facts:end -->

## 用途

按风险评分排序样本，联合展示评分分布、生存状态和签名基因表达热图，用竖线分高低风险组。

## 适用

已算好每个样本的 riskscore、生存时间与状态，以及签名基因表达矩阵。

## 不适用

风险评分尚未构建（先做 LASSO/Cox）；样本量很大时热图需另行抽样或调整。

## 输入

- `easy_input_risk.csv`：easy_input_risk.csv，包含生存信息、表达量、risk score。其中risk score的获得，可以通过FigureYa31lasso计算并输出每个signature的系数coefficient，然后算出risk score，可参考这篇文章的第二步：<https://mp.weixin.qq.com/s/4s6X0dpvEqOh-KtxES3sTg>
- `easy_input_sig.txt`：easy_input_sig.txt，signature。可以通过lasso、SVM等方法筛选获得，可参考FigureYa31lasso或FigureYa65SVM-RFE。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-141risk`
- 用到课题：`wiki.py use figureya-141risk --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `cox.pdf`
- `cox2.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
