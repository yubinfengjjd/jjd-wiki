---
type: recipe
id: figureya-31lasso-update
title: LASSO Cox 系数路径与交叉验证图
status: ready
source:
  id: figureya
  item: FigureYa31lasso_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa31lasso_update.Rmd
inputs:
- file: easy_input_suv.csv
  note: 输入文件有两个，一个是生存信息`easy_input_suv.csv`，一个是基因表达矩阵`easy_input_exp.csv`。
- file: easy_input_exp.csv
  note: 输入文件有两个，一个是生存信息`easy_input_suv.csv`，一个是基因表达矩阵`easy_input_exp.csv`。
outputs:
- lasso_name.pdf
- lasso_legend.pdf
packages:
  cran:
  - glmnet
  - survival
  bioc: []
  github: []
  library:
  - glmnet
  - survival
  namespaced:
  - knitr
tags:
- survival-analysis
- machine-learning
keywords:
- LASSO
- glmnet
- signature
- cross-validation
- survival
chart_types:
- lasso-path
summary: 用 LASSO Cox 从候选基因中筛选预后签名，画系数路径图（标注基因顺序）和交叉验证曲线，并合成一个签名变量。
favorite: false
---
# LASSO Cox 系数路径与交叉验证图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa31lasso_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa31lasso_update.Rmd`）
- 依赖：CRAN glmnet, survival
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，1.8 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-31lasso-update/preview.png]]
<!-- facts:end -->

## 用途

用 LASSO Cox 从候选基因中筛选预后签名，画系数路径图（标注基因顺序）和交叉验证曲线，并合成一个签名变量。

## 适用

高维、强相关、小样本的生存数据：候选基因表达矩阵 + 个体随访时间与事件。

## 不适用

二分类结局（需改 family）；需要稳定性筛选或重复 LASSO（见 FigureYa220repeatedLasso）。

## 输入

- `easy_input_suv.csv`：输入文件有两个，一个是生存信息`easy_input_suv.csv`，一个是基因表达矩阵`easy_input_exp.csv`。
- `easy_input_exp.csv`：输入文件有两个，一个是生存信息`easy_input_suv.csv`，一个是基因表达矩阵`easy_input_exp.csv`。
- `suv.csv`：输入文件有两个，一个是生存信息`easy_input_suv.csv`，一个是基因表达矩阵`easy_input_exp.csv`。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-31lasso-update`
- 用到课题：`wiki.py use figureya-31lasso-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `lasso_name.pdf`
- `lasso_legend.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
