---
type: recipe
id: figureya-221tenfoldrf
title: 随机森林十折交叉验证筛基因
status: draft
source:
  id: figureya
  item: FigureYa221tenFoldRF
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa221tenFoldRF.Rmd
inputs:
- file: InnateDB_genes.csv
  note: InnateDB_genes.csv，免疫基因集。数据来自<https://www.innatedb.com/redirect.do?go=resourcesGeneLists>
    Immunogenetic Related Information Source (IRIS)
- file: easy_input_expr.txt
  note: easy_input_expr.txt，表达谱。
- file: easy_input_surv.txt
  note: easy_input_surv.txt，生存数据。
outputs:
- accuracy.pdf
- KM.pdf
packages:
  cran:
  - caret
  - shape
  - survival
  bioc: []
  github: []
  library:
  - caret
  - survival
  - shape
  namespaced:
  - knitr
tags:
- machine-learning
- survival-analysis
keywords:
- caret
- 随机森林
- RFE
- 10折交叉验证
- InnateDB
- coxph
- shape
- survival
chart_types:
- trend
- km-curve
summary: 先用单因素Cox筛预后相关基因，再用caret随机森林RFE十折交叉验证按准确率选最小特征子集，画准确率曲线与高低风险KM曲线。
favorite: false
---
# 随机森林十折交叉验证筛基因

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa221tenFoldRF` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa221tenFoldRF.Rmd`）
- 依赖：CRAN caret, shape, survival
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

先用单因素Cox筛预后相关基因，再用caret随机森林RFE十折交叉验证按准确率选最小特征子集，画准确率曲线与高低风险KM曲线。

## 适用

从候选基因集（如免疫基因）中按分类准确率而非重要性评分筛选预后签名，作为RFSurv之外的另一种筛法。

## 不适用

RFE步长为1时全量迭代约2小时；示例因变量是肿瘤/正常组织类型（按TCGA条码14-15位=11取正常样本），无正常样本或改用生存结局时方案需重写且准确率可能很低。

## 输入

- `InnateDB_genes.csv`：InnateDB_genes.csv，免疫基因集。数据来自<https://www.innatedb.com/redirect.do?go=resourcesGeneLists> Immunogenetic Related Information Source (IRIS)
- `easy_input_expr.txt`：easy_input_expr.txt，表达谱。
- `easy_input_surv.txt`：easy_input_surv.txt，生存数据。

expr文件行基因列样本（代码内转置），surv行名样本ID含OS/OS.time，免疫基因集提供name列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-221tenfoldrf`
- 用到课题：`wiki.py use figureya-221tenfoldrf --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：十折RFE逐特征迭代耗时长（作者注释约2小时），运行前需确认候选基因数量。

## 输出

- `accuracy.pdf`
- `KM.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]] · [[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
