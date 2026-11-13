---
type: recipe
id: figureya-293plus-binaryclassificationml
title: 多算法二分类模型评估筛选
status: draft
source:
  id: figureya
  item: FigureYa293Plus_BinaryClassificationML
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa293Plus_BinaryClassificationML.Rmd
inputs:
- file: TCGA.txt
  note: ''
- file: GSE57303.txt
  note: ''
- file: GSE62254.txt.gz
  note: ''
outputs: []
packages:
  cran:
  - BART
  - RColorBrewer
  - compareC
  - dplyr
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
  - naivebayes
  - party
  - C50
  - neuralnet
  - Boruta
  - RWekajars
  - FSelector
  - mlr3
  - mlr3learners
  - mlr3extralearners
  - caret
  - plotly
  - VIM
  - gbm
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
  - randomForest
  - glmnet
  - e1071
  - xgboost
  - gbm
  - nnet
  - MASS
  - class
  - naivebayes
  - kernlab
  - party
  - C50
  - neuralnet
  - Boruta
  - FSelector
  - mlr3
  - mlr3learners
  - mlr3extralearners
  - caret
  - pROC
  - dplyr
  - tibble
  - ggplot2
  - ggsci
  - tidyr
  - ComplexHeatmap
  - circlize
  - RColorBrewer
  - plotly
  - VIM
  - corrplot
  - doParallel
  namespaced:
  - knitr
tags:
- machine-learning
- transcriptomics
keywords:
- caret
- mlr3
- randomForest
- xgboost
- glmnet
- e1071
- gbm
- C50
- naivebayes
- neuralnet
- Boruta
- FSelector
- pROC
- doParallel
- ComplexHeatmap
- VIM
chart_types:
- bar
- heatmap
- boxplot
summary: 在训练集上跑10种分类算法，再叠加RF/Lasso/Boruta特征选择、投票集成与参数调优共100+组合，在多个验证集上算AUC/准确率等指标并可视化，挑最优
favorite: false
---
# 多算法二分类模型评估筛选

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa293Plus_BinaryClassificationML` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa293Plus_BinaryClassificationML.Rmd`）
- 依赖：CRAN BART, RColorBrewer, compareC, dplyr, ggbreak, ggplot2, ggsci, miscTools, plsRcox, randomForestSRC, rlang, superpc, survivalsvm, tibble, tidyr, naivebayes, party, C50, neuralnet, Boruta, RWekajars, FSelector, mlr3, mlr3learners, mlr3extralearners, caret, plotly, VIM, gbm, CoxBoost, survival, glmnet；Bioconductor ComplexHeatmap, circlize, mixOmics, survcomp；GitHub binderh/CoxBoost
- 最近运行：fail（as-is，2026-11-11 09:09 UTC，516.7 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

在训练集上跑10种分类算法，再叠加RF/Lasso/Boruta特征选择、投票集成与参数调优共100+组合，在多个验证集上算AUC/准确率等指标并可视化，挑最优二分类模型。

## 适用

通用二分类建模（诊断、响应、敏感/耐药、分子亚型），有独立验证集、想系统比较“特征选择×算法”组合时。

## 不适用

输入列序固定（样本名/0-1标签/特征），多数据集自动取共有特征；示例把GSE57303同时当train和test1（疑为笔误，需改回TCGA.txt）；只支持二分类；失败组合以0.5兜底易掩盖报错。

## 输入

- `TCGA.txt`：见 Rmd“输入文件”节
- `GSE57303.txt`：见 Rmd“输入文件”节
- `GSE62254.txt.gz`：见 Rmd“输入文件”节

每个输入文件行=样本，第1列样本名、第2列二分类标签、第3列起为特征；示例中第3列为生存时间，读取后被丢弃。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-293plus-binaryclassificationml`
- 用到课题：`wiki.py use figureya-293plus-binaryclassificationml --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：依赖30+个包，含本地tar.gz源码安装（RWekajars/plsRcox）、GitHub或CRAN存档装CoxBoost；RWeka需Java环境；虽用doParallel并行，全流程仍很耗时。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
