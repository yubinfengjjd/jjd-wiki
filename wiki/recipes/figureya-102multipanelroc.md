---
type: recipe
id: figureya-102multipanelroc
title: 多变量 Logistic 模型训练/测试 ROC
status: ready
source:
  id: figureya
  item: FigureYa102multipanelROC
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa102multipanelROC.Rmd
inputs:
- file: easy_input_train.txt
  note: easy_input_train.txt，easy_input_test.txt，训练集和测试集，格式一致。第一列是样本ID，第二列为分组（二分类），之后各列是基因表达量。不仅限于基因表达量，还可以是其他量化指标。
- file: easy_input_test.txt
  note: easy_input_train.txt，easy_input_test.txt，训练集和测试集，格式一致。第一列是样本ID，第二列为分组（二分类），之后各列是基因表达量。不仅限于基因表达量，还可以是其他量化指标。
outputs:
- multipanelROC.pdf
packages:
  cran:
  - pROC
  bioc: []
  github: []
  library:
  - pROC
  namespaced:
  - knitr
  - ggplot2
tags:
- diagnostic-roc
keywords:
- multivariate logistic
- pROC
- train test
chart_types:
- roc
summary: 用训练集构建多变量二分类 Logistic 模型，应用到测试集，并把训练、测试的 ROC 画在一起。
favorite: false
---
# 多变量 Logistic 模型训练/测试 ROC

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa102multipanelROC` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa102multipanelROC.Rmd`）
- 依赖：CRAN pROC
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，2.5 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-102multipanelroc/preview.png]]
<!-- facts:end -->

## 用途

用训练集构建多变量二分类 Logistic 模型，应用到测试集，并把训练、测试的 ROC 画在一起。

## 适用

训练、测试两张表，列为同一组 biomarker 与二分类结局。

## 不适用

单个 biomarker 的 ROC（见 FigureYa24ROC）；生存结局（用时间依赖 ROC）。

## 输入

- `easy_input_train.txt`：easy_input_train.txt，easy_input_test.txt，训练集和测试集，格式一致。第一列是样本ID，第二列为分组（二分类），之后各列是基因表达量。不仅限于基因表达量，还可以是其他量化指标。
- `easy_input_test.txt`：easy_input_train.txt，easy_input_test.txt，训练集和测试集，格式一致。第一列是样本ID，第二列为分组（二分类），之后各列是基因表达量。不仅限于基因表达量，还可以是其他量化指标。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-102multipanelroc`
- 用到课题：`wiki.py use figureya-102multipanelroc --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `multipanelROC.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
