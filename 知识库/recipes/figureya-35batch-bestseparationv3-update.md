---
type: recipe
id: figureya-35batch-bestseparationv3-update
title: 批量最佳切点生存曲线
status: draft
source:
  id: figureya
  item: FigureYa35batch_bestSeparationV3_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa35batch_bestSeparationV3_update.Rmd
inputs:
- file: easy_input.csv
  note: ''
outputs:
- bestSurvPlot.pdf
- bestSurvPlot_event.pdf
packages:
  cran:
  - KMsurv
  - survival
  - survminer
  bioc: []
  github: []
  library:
  - survival
  - survminer
  namespaced:
  - knitr
tags:
- survival-analysis
keywords:
- survival
- survminer
- surv_cutpoint
- best separation
chart_types:
- km-curve
summary: 对输入表全部基因批量用surv_cutpoint找最佳分组cutoff（minprop≥0.3），只给p<0.05基因画KM生存曲线与事件发生率曲线（标注HR/
favorite: false
---
# 批量最佳切点生存曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa35batch_bestSeparationV3_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa35batch_bestSeparationV3_update.Rmd`）
- 依赖：CRAN KMsurv, survival, survminer
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对输入表全部基因批量用surv_cutpoint找最佳分组cutoff（minprop≥0.3），只给p<0.05基因画KM生存曲线与事件发生率曲线（标注HR/95%CI/组内样本数），拼图输出并导出统计表。

## 适用

想批量评估连续表达量基因对生存的影响、找最佳二分组并一次出图；后续可接双基因组合生存分析。

## 不适用

只能分高低两组；输入前两列固定为生存时间/结局、第三列起为基因列；基因名会被make.names改写；默认只输出p<0.05的图，想全出要删筛选行。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节

csv第1列futime、第2列fustat、第3列起为基因表达列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-35batch-bestseparationv3-update`
- 用到课题：`wiki.py use figureya-35batch-bestseparationv3-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `bestSurvPlot.pdf`
- `bestSurvPlot_event.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
