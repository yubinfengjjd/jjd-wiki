---
type: recipe
id: figureya-99smoothhrv2
title: 限制性立方样条 HR 曲线
status: draft
source:
  id: figureya
  item: FigureYa99smoothHRv2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa99smoothHRv2.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，因为是生存分析的风险计算，所以生存状态（fstat），生存时间（lenfol），以及至少一个协变量（连续变量bmi）是必须的，此处还加了个协变量（二分类变量gender）。
outputs:
- smooth HR with RCS.pdf
packages:
  cran:
  - Hmisc
  - rms
  - smoothHR
  - survival
  bioc: []
  github: []
  library:
  - smoothHR
  - survival
  - Hmisc
  namespaced:
  - knitr
  - ggplot2
tags:
- survival-analysis
keywords:
- RCS
- restricted cubic spline
- smoothHR
- rms
- Hmisc
- survival
chart_types:
- spline-hr
summary: 用限制性立方样条（RCS）展示连续变量与风险比的非线性关系，以参考点为基线画 HR 及置信带。
favorite: false
---
# 限制性立方样条 HR 曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa99smoothHRv2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa99smoothHRv2.Rmd`）
- 依赖：CRAN Hmisc, rms, smoothHR, survival
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，2.1 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用限制性立方样条（RCS）展示连续变量与风险比的非线性关系，以参考点为基线画 HR 及置信带。

## 适用

个体随访数据，关注一个连续暴露变量（如年龄、指标值）对风险的剂量—反应关系。

## 不适用

暴露为分类变量；需要 Logistic 结局的 OR 曲线时要确认代码分支；节点数与参考点含义须作者确认后再改。

## 输入

- `easy_input.csv`：easy_input.csv，因为是生存分析的风险计算，所以生存状态（fstat），生存时间（lenfol），以及至少一个协变量（连续变量bmi）是必须的，此处还加了个协变量（二分类变量gender）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-99smoothhrv2`
- 用到课题：`wiki.py use figureya-99smoothhrv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `smooth HR with RCS.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
