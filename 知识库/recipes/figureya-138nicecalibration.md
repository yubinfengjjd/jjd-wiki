---
type: recipe
id: figureya-138nicecalibration
title: Logistic 模型校准曲线与 HL 检验
status: draft
source:
  id: figureya
  item: FigureYa138NiceCalibration
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa138NiceCalibration.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs:
- calibration_for full model.pdf
packages:
  cran:
  - ResourceSelection
  - rms
  - scales
  bioc: []
  github: []
  library:
  - rms
  - scales
  - ResourceSelection
  namespaced:
  - knitr
tags:
- diagnostic-roc
keywords:
- Hosmer-Lemeshow
- rms
- calibration
- logistic regression
- ResourceSelection
- scales
chart_types:
- calibration
summary: 为二分类 Logistic 诊断模型画校准曲线，并给出 Hosmer-Lemeshow 拟合优度检验。
favorite: false
---
# Logistic 模型校准曲线与 HL 检验

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa138NiceCalibration` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa138NiceCalibration.Rmd`）
- 依赖：CRAN ResourceSelection, rms, scales
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

为二分类 Logistic 诊断模型画校准曲线，并给出 Hosmer-Lemeshow 拟合优度检验。

## 适用

二分类结局（0/1）与若干预测变量，评价诊断模型的预测概率与实际一致性。

## 不适用

预后/生存模型（上游明确说不能用于预后模型）；多分类或连续结局。

## 输入

- `easy_input.csv`：easy_input.csv，每行一个sample。
- `easy_input.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-138nicecalibration`
- 用到课题：`wiki.py use figureya-138nicecalibration --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `calibration_for full model.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
