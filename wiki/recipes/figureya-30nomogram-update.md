---
type: recipe
id: figureya-30nomogram-update
title: Cox/Logistic 列线图与校准曲线
status: ready
source:
  id: figureya
  item: FigureYa30nomogram_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa30nomogram_update.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs:
- nomogram_classical.pdf
- nomogram_regplot_cox.pdf
- nomogram_regplot_glm.pdf
- calibration_5y.pdf
- calibration_8y.pdf
- calibration_compare.pdf
packages:
  cran:
  - nomogramEx
  - regplot
  - rms
  - survival
  bioc: []
  github: []
  library:
  - survival
  - regplot
  - rms
  - nomogramEx
  namespaced:
  - knitr
tags:
- survival-analysis
- diagnostic-roc
keywords:
- rms
- regplot
- nomogram
- calibration
- nomogramEx
- survival
chart_types:
- nomogram
- calibration
summary: 把 Cox 或 Logistic 回归结果画成经典列线图和 regplot 交互式列线图，并画 5 年/8 年校准曲线与比较图。
favorite: false
---
# Cox/Logistic 列线图与校准曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa30nomogram_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa30nomogram_update.Rmd`）
- 依赖：CRAN nomogramEx, regplot, rms, survival
- 最近运行：pass（as-is，2026-10-27 15:01 UTC，25.7 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `nomogram_classical.pdf` 第 1 页）：

![[recipes/figureya-30nomogram-update/preview.png]]
<!-- facts:end -->

## 用途

把 Cox 或 Logistic 回归结果画成经典列线图和 regplot 交互式列线图，并画 5 年/8 年校准曲线与比较图。

## 适用

已有回归用的个体数据（结局、时间、若干预测变量），变量已筛选好（如 lasso_output.txt）。

## 不适用

变量筛选尚未做（先做 LASSO 等）；需要外部验证集校准（上游为内部 bootstrap）；多分类结局。

## 输入

- `easy_input.csv`：至少要有临床信息`easy_input.csv`，还可以把`FigureYa31lasso`输出的`lasso_output.txt`作为一列添加进来。
- `lasso_output.txt`：至少要有临床信息`easy_input.csv`，还可以把`FigureYa31lasso`输出的`lasso_output.txt`作为一列添加进来。
- `easy_input.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-30nomogram-update`
- 用到课题：`wiki.py use figureya-30nomogram-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `nomogram_classical.pdf`
- `nomogram_regplot_cox.pdf`
- `nomogram_regplot_glm.pdf`
- `calibration_5y.pdf`
- `calibration_8y.pdf`
- `calibration_compare.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
