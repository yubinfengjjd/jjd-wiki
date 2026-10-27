---
type: recipe
id: figureya-33dca-update
title: 决策曲线与净获益分析
status: ready
source:
  id: figureya
  item: FigureYa33DCA_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa33DCA_update.Rmd
inputs:
- file: easy_input.txt
  note: easy_input.txt，跟`FigureYa30nomogram`里的easy_input.txt是同一个文件，来自`survival`包。
outputs:
- net_benefit.pdf
- net_reduction.pdf
packages:
  cran:
  - cmprsk
  - cowplot
  - ggplotify
  - magick
  - survival
  bioc: []
  github: []
  library:
  - survival
  - ggplotify
  - magick
  - cowplot
  namespaced:
  - knitr
tags:
- diagnostic-roc
- survival-analysis
keywords:
- DCA
- net benefit
- stdca
- MSKCC
- cowplot
- ggplotify
- magick
- survival
chart_types:
- decision-curve
summary: 画二分类或生存结局的决策曲线（net benefit）和 net reduction 曲线，比较多个模型的临床获益。
favorite: false
---
# 决策曲线与净获益分析

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa33DCA_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa33DCA_update.Rmd`）
- 依赖：CRAN cmprsk, cowplot, ggplotify, magick, survival
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，3.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-33dca-update/preview.png]]
<!-- facts:end -->

## 用途

画二分类或生存结局的决策曲线（net benefit）和 net reduction 曲线，比较多个模型的临床获益。

## 适用

已有模型预测概率或可拟合模型的个体数据；生存数据用上游的 stdca.R。

## 不适用

只有 AUC 等汇总指标、没有个体预测；需要校准或区分度评价（用校准曲线/ROC）。

## 输入

- `easy_input.txt`：easy_input.txt，跟`FigureYa30nomogram`里的easy_input.txt是同一个文件，来自`survival`包。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-33dca-update`
- 用到课题：`wiki.py use figureya-33dca-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `net_benefit.pdf`
- `net_reduction.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
