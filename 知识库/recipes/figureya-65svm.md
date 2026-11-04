---
type: recipe
id: figureya-65svm
title: LASSO与SVM-RFE特征筛选图
status: draft
source:
  id: figureya
  item: FigureYa65SVM
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa65SVM.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，带有分组信息的矩阵。此处用例文自带的GSE75041，经过处理后得到，处理过程见文件夹中的HowToGetEasyInput.R。
- file: featsweep.RData
  note: ''
- file: example_lasso.txt
  note: ''
- file: example_SVM-RFE.txt
  note: ''
- file: example_overlap.txt
  note: ''
outputs:
- A_lasso.pdf
- B_svm-error.pdf
- B_svm-accuracy.pdf
- C_lasso_SVM_venn.pdf
packages:
  cran: []
  bioc: []
  github:
  - drjitendra/sigFeature
  library:
  - tidyverse
  - glmnet
  - VennDiagram
  - sigFeature
  - e1071
  - caret
  namespaced:
  - knitr
tags:
- machine-learning
keywords:
- glmnet
- e1071
- caret
- sigFeature
- VennDiagram
- SVM-RFE
- LASSO
- msvmRFE
- tidyverse
chart_types:
- lasso-path
- venn
- trend
summary: 同一份分组表达矩阵分别用LASSO logistic和SVM-RFE做特征筛选，画系数路径、CV误差曲线、SVM错误/准确率曲线及两法特征的Venn重叠图。
favorite: false
---
# LASSO与SVM-RFE特征筛选图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa65SVM` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa65SVM.Rmd`）
- 依赖：GitHub drjitendra/sigFeature
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

同一份分组表达矩阵分别用LASSO logistic和SVM-RFE做特征筛选，画系数路径、CV误差曲线、SVM错误/准确率曲线及两法特征的Venn重叠图。

## 适用

二分类样本的特征基因筛选，想用两种机器学习算法互相佐证挑特征、构建分类模型时。

## 不适用

分组最好是二分类变量；SVM-RFE结果有随机性，两种方法选出的特征重叠可能很低；示例只在训练集自评，须另备验证集；输入为ID+group+特征列的固定结构。

## 输入

- `easy_input.csv`：easy_input.csv，带有分组信息的矩阵。此处用例文自带的GSE75041，经过处理后得到，处理过程见文件夹中的HowToGetEasyInput.R。
- `featsweep.RData`：见 Rmd“输入文件”节
- `example_lasso.txt`：见 Rmd“输入文件”节
- `example_SVM-RFE.txt`：见 Rmd“输入文件”节
- `example_overlap.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-65svm`
- 用到课题：`wiki.py use figureya-65svm --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需本地脚本msvmRFE.R；sigFeature为GitHub包（remotes安装）；featsweep全扫300个特征约需9小时，示例直接加载预存的featsweep.RData。

## 输出

- `A_lasso.pdf`
- `B_svm-error.pdf`
- `B_svm-accuracy.pdf`
- `C_lasso_SVM_venn.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]] · [[templates/2026-10-22-scp-example__fig12-venn--venn|多集合交集维恩图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
