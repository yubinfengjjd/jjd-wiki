---
type: recipe
id: figureya-293machinelearning
title: 多算法组合预后模型 C 指数比较
status: draft
source:
  id: figureya
  item: FigureYa293machineLearning
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa293machineLearning.Rmd
inputs:
- file: TCGA.txt
  note: TCGA.txt，GSE57303.txt，GSE62254.txt，数据集。行为样本，第一列为样本名，第二三列为生存时间和生存状态，后面的列均为基因。
- file: GSE57303.txt
  note: TCGA.txt，GSE57303.txt，GSE62254.txt，数据集。行为样本，第一列为样本名，第二三列为生存时间和生存状态，后面的列均为基因。
- file: GSE62254.txt.gz
  note: ''
outputs:
- A_lasso.pdf
- B_lasso.pdf
- ComplexHeatmap.pdf
- tcga_model_compare.pdf
- GSE57303_model_compare.pdf
- GSE62254_model_compare.pdf
packages:
  cran:
  - BART
  - RColorBrewer
  - compareC
  - dplyr
  - gbm
  - ggbreak
  - ggplot2
  - ggsci
  - miscTools
  - plsRcox
  - randomForestSRC
  - rlang
  - superpc
  - survivalsvm
  - tibble
  - tidyr
  - CoxBoost
  - survival
  - glmnet
  bioc:
  - ComplexHeatmap
  - circlize
  - mixOmics
  - survcomp
  github:
  - binderh/CoxBoost
  library:
  - survival
  - randomForestSRC
  - glmnet
  - plsRcox
  - superpc
  - gbm
  - CoxBoost
  - survivalsvm
  - dplyr
  - tibble
  - BART
  - miscTools
  - compareC
  - ggplot2
  - ggsci
  - tidyr
  - ggbreak
  - ComplexHeatmap
  - circlize
  - RColorBrewer
  namespaced:
  - knitr
tags:
- machine-learning
- survival-analysis
keywords:
- 101 combinations
- C-index
- CoxBoost
- randomForestSRC
- GBM
- plsRcox
- superpc
- survival-SVM
- BART
- ComplexHeatmap
- RColorBrewer
- circlize
- compareC
- gbm
- ggbreak
- ggsci
chart_types:
- heatmap
summary: 用 10 种生存机器学习算法及其组合在训练集建模，在多个验证集计算 C 指数，画模型比较热图与条形图。
favorite: false
---
# 多算法组合预后模型 C 指数比较

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa293machineLearning` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa293machineLearning.Rmd`）
- 依赖：CRAN BART, RColorBrewer, compareC, dplyr, gbm, ggbreak, ggplot2, ggsci, miscTools, plsRcox, randomForestSRC, rlang, superpc, survivalsvm, tibble, tidyr, CoxBoost, survival, glmnet；Bioconductor ComplexHeatmap, circlize, mixOmics, survcomp；GitHub binderh/CoxBoost
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用 10 种生存机器学习算法及其组合在训练集建模，在多个验证集计算 C 指数，画模型比较热图与条形图。

## 适用

一个训练队列加若干验证队列，基因一致的表达矩阵与随访数据；需要大批模型横向比较。

## 不适用

单一队列或小样本；计算资源有限（耗时长）；部分模型 C 指数为 0.5 表示未得到结果，不是模型效果。

## 输入

- `TCGA.txt`：TCGA.txt，GSE57303.txt，GSE62254.txt，数据集。行为样本，第一列为样本名，第二三列为生存时间和生存状态，后面的列均为基因。
- `GSE57303.txt`：TCGA.txt，GSE57303.txt，GSE62254.txt，数据集。行为样本，第一列为样本名，第二三列为生存时间和生存状态，后面的列均为基因。
- `GSE62254.txt`：TCGA.txt，GSE57303.txt，GSE62254.txt，数据集。行为样本，第一列为样本名，第二三列为生存时间和生存状态，后面的列均为基因。
- `GSE62254.txt.gz`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-293machinelearning`
- 用到课题：`wiki.py use figureya-293machinelearning --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：依赖多、计算量大；部分算法对输入基因敏感会报错，上游说明属正常现象。

## 输出

- `A_lasso.pdf`
- `B_lasso.pdf`
- `ComplexHeatmap.pdf`
- `tcga_model_compare.pdf`
- `GSE57303_model_compare.pdf`
- `GSE62254_model_compare.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
