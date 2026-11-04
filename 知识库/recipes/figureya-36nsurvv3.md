---
type: recipe
id: figureya-36nsurvv3
title: 双基因高低分组生存曲线
status: draft
source:
  id: figureya
  item: FigureYa36nSurvV3
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa36nSurvV3.Rmd
inputs:
- file: easy_input.csv
  note: ''
outputs:
- nSurv.pdf
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
- transcriptomics
keywords:
- survival
- survminer
- logrank
- coxph
- KM
chart_types:
- km-curve
summary: 按两个基因各自的高/低表达把样本分成4组，画KM生存曲线，图例标注各组HR（coxph）和两两logrank的显著P值。
favorite: false
---
# 双基因高低分组生存曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa36nSurvV3` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa36nSurvV3.Rmd`）
- 依赖：CRAN survival, survminer
- 最近运行：pass（as-is，2026-11-04 11:13 UTC，14.8 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `nSurv.pdf` 第 1 页）：

![[recipes/figureya-36nsurvv3/preview.png]]
<!-- facts:end -->

## 用途

按两个基因各自的高/低表达把样本分成4组，画KM生存曲线，图例标注各组HR（coxph）和两两logrank的显著P值。

## 适用

比较两个因素联合分组对生存的影响，如基因A、B都高表达 vs 都低表达。

## 不适用

输入列序固定（sample/Time/Death/基因A/基因B），生存列名写死futime/fustat；两基因各只分高低两档共4组、cut阈值需手工填入；两两比较循环按4组写死，组数变化要改代码。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节

easy_input.csv至少5列依次为样本名、生存时间、结局、两个基因表达量，顺序不可变。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-36nsurvv3`
- 用到课题：`wiki.py use figureya-36nsurvv3 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `nSurv.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
