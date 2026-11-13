---
type: recipe
id: figureya-251nphsurv
title: 非比例风险亚组生存图
status: ready
source:
  id: figureya
  item: FigureYa251NPHSurv
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa251NPHSurv.Rmd
inputs:
- file: easy_input_annCol.txt
  note: easy_input_annCol.txt，亚型信息。
- file: easy_input_surv.txt
  note: easy_input_surv.txt，预后信息。
outputs:
- kaplan meier curve1.pdf
- kaplan meier curve2.pdf
packages:
  cran:
  - ggplot2
  - ggpubr
  - survminer
  bioc:
  - ComparisonSurv
  - survRM2
  github: []
  library:
  - survRM2
  - ComparisonSurv
  - ggplot2
  - ggpubr
  - survminer
  namespaced:
  - knitr
tags:
- survival-analysis
keywords:
- survRM2
- ComparisonSurv
- survminer
- ggpubr
- RMST
- NPHSurv
- IMvigor210
chart_types:
- km-curve
summary: 对多个亚型做两两配对的非比例风险生存比较：两个时间点RMST检验+延迟效应后长期生存率检验，输出三张p值矩阵，并画带参考线的KM曲线。
favorite: false
---
# 非比例风险亚组生存图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa251NPHSurv` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa251NPHSurv.Rmd`）
- 依赖：CRAN ggplot2, ggpubr, survminer；Bioconductor ComparisonSurv, survRM2
- 最近运行：pass（as-is，2026-11-04 11:08 UTC，30.9 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `kaplan meier curve1.pdf` 第 1 页）：

![[recipes/figureya-251nphsurv/preview.png]]
<!-- facts:end -->

## 用途

对多个亚型做两两配对的非比例风险生存比较：两个时间点RMST检验+延迟效应后长期生存率检验，输出三张p值矩阵，并画带参考线的KM曲线。

## 适用

免疫治疗等存在延迟效应、KM曲线交叉、比例风险假设不成立时，比较多个亚型两两间的生存差异。

## 不适用

只能做亚型两两比较（arm为二分类）；亚型名与tau1/tau2/t0时间点写死需改；出图仅基础KM，p值矩阵与延迟标注需Illustrator后期合成。

## 输入

- `easy_input_annCol.txt`：easy_input_annCol.txt，亚型信息。
- `easy_input_surv.txt`：easy_input_surv.txt，预后信息。

annCol与surv行名均为样本ID且需对应；surv需含os（单位月）与censOS列；亚型列名（CMOIC）写死。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-251nphsurv`
- 用到课题：`wiki.py use figureya-251nphsurv --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `kaplan meier curve1.pdf`
- `kaplan meier curve2.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
