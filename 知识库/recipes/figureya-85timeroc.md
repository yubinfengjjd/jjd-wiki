---
type: recipe
id: figureya-85timeroc
title: 多模型时间依赖 ROC 曲线
status: ready
source:
  id: figureya
  item: FigureYa85timeROC
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa85timeROC.Rmd
inputs:
- file: easy_input.csv
  note: ''
outputs:
- timeROC.pdf
packages:
  cran:
  - survival
  - timeROC
  bioc: []
  github: []
  library:
  - timeROC
  - survival
  namespaced:
  - knitr
tags:
- diagnostic-roc
- survival-analysis
keywords:
- timeROC
- time-dependent AUC
- survival
chart_types:
- roc
summary: 对不同拟合模型（或评分）计算并画指定时间点的时间依赖 ROC 曲线与 AUC。
favorite: false
---
# 多模型时间依赖 ROC 曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa85timeROC` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa85timeROC.Rmd`）
- 依赖：CRAN survival, timeROC
- 最近运行：pass（as-is，2026-10-27 15:02 UTC，1.4 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `timeROC.pdf` 第 1 页）：

![[recipes/figureya-85timeroc/preview.png]]
<!-- facts:end -->

## 用途

对不同拟合模型（或评分）计算并画指定时间点的时间依赖 ROC 曲线与 AUC。

## 适用

个体随访时间、事件与一个或多个连续风险评分。

## 不适用

无随访时间的二分类诊断（用普通 ROC）；需要 AUC 随时间变化曲线时要确认上游是否输出。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-85timeroc`
- 用到课题：`wiki.py use figureya-85timeroc --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `timeROC.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- figureya-selection:start -->
## 样式筛选记录

2026-11-02 整理时，此配方对应的 FigureYa 模块已被作者从样式候选中移除，不再作为默认推荐。

本页、原始源码和既有运行收据保留；原确认状态不代表当前样式仍被选用。当前取舍以 `sources/figureya-curation.json` 为准，可在前端恢复。
<!-- figureya-selection:end -->

<!-- user:start -->
<!-- user:end -->
