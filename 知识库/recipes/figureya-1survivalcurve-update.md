---
type: recipe
id: figureya-1survivalcurve-update
title: 多组 KM 生存曲线与风险表
status: ready
source:
  id: figureya
  item: FigureYa1survivalCurve_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa1survivalCurve_update.Rmd
inputs:
- file: not_easy_input.txt
  note: ''
- file: easy_input_2.txt
  note: ''
- file: easy_input_3.txt
  note: ''
outputs:
- survivalcurve_2.pdf
- survivalcurve_2_table.pdf
- survivalcurve_3.pdf
- survivalcurve_3_table.pdf
packages:
  cran:
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
- survminer
- Kaplan-Meier
- log-rank
- number at risk
- survival
chart_types:
- km-curve
summary: 用自己的生存数据画两组或多组 Kaplan-Meier 曲线，附 log-rank P 值与 number-at-risk 风险表。
favorite: false
---
# 多组 KM 生存曲线与风险表

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa1survivalCurve_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa1survivalCurve_update.Rmd`）
- 依赖：CRAN survival, survminer
- 最近运行：pass（as-is，2026-10-27 12:46 UTC，5.2 秒）
- 派生模板（L2）：[[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]（ready）
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-1survivalcurve-update/preview.png]]
<!-- facts:end -->

## 用途

用自己的生存数据画两组或多组 Kaplan-Meier 曲线，附 log-rank P 值与 number-at-risk 风险表。

## 适用

每行一个样本，有随访时间、结局事件（0/1）和一个分组变量；组数 2 个或更多。

## 不适用

存在竞争风险（应做累积发生率曲线）；时间依赖协变量；只有分组汇总数据、没有个体随访记录。

## 输入

- `not_easy_input.txt`：见 Rmd“输入文件”节
- `easy_input_2.txt`：见 Rmd“输入文件”节
- `easy_input_3.txt`：见 Rmd“输入文件”节

上游示例：easy_input_2/3.txt 为两组/三组的个体随访表，not_easy_input.txt 演示从原始表整理。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-1survivalcurve-update`
- 用到课题：`wiki.py use figureya-1survivalcurve-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `survivalcurve_2.pdf`
- `survivalcurve_2_table.pdf`
- `survivalcurve_3.pdf`
- `survivalcurve_3_table.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
