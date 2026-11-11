---
type: recipe
id: figureya-215dnaage
title: 甲基化年龄加速分析
status: draft
source:
  id: figureya
  item: FigureYa215DNAage
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa215DNAage.Rmd
inputs:
- file: easy_input_age.txt
  note: easy_input_age.txt，临床真实年龄。
outputs:
- barplot for DNA methylation acceleration.pdf
packages:
  cran:
  - data.table
  - wateRmelon
  - minfi
  - ENmix
  - methylumi
  - DMRcate
  - limma
  bioc:
  - limma
  - impute
  - preprocessCore
  - sva
  - IlluminaHumanMethylation450kmanifest
  - IlluminaHumanMethylationEPICmanifest
  github:
  - YuanTian1991/ChAMP
  library:
  - ChAMP
  - wateRmelon
  - data.table
  namespaced:
  - knitr
  - ggplot2
tags:
- multi-omics
keywords:
- ChAMP
- wateRmelon
- agep
- BMIQ
- DNAmAge
- HumanMethylation450
- data.table
chart_types:
- bar
summary: 由甲基化芯片beta值经ChAMP过滤+BMIQ标准化后用wateRmelon::agep算DNA甲基化年龄，与真实年龄求差划分加速/减速组并画双向柱图。
favorite: false
---
# 甲基化年龄加速分析

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa215DNAage` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa215DNAage.Rmd`）
- 依赖：CRAN data.table, wateRmelon, minfi, ENmix, methylumi, DMRcate, limma；Bioconductor limma, impute, preprocessCore, sva, IlluminaHumanMethylation450kmanifest, IlluminaHumanMethylationEPICmanifest；GitHub YuanTian1991/ChAMP
- 最近运行：fail（as-is，2026-11-11 06:07 UTC，20.6 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

由甲基化芯片beta值经ChAMP过滤+BMIQ标准化后用wateRmelon::agep算DNA甲基化年龄，与真实年龄求差划分加速/减速组并画双向柱图。

## 适用

量化样本表观遗传年龄加速，用于后续与临床、免疫激活、预后等特征的关联分析。

## 不适用

仅适用450K/27K芯片beta矩阵，不支持EPIC 850K；需另备真实年龄表且样本名能对齐；依赖ChAMP等较重的甲基化包。

## 输入

- `easy_input_age.txt`：easy_input_age.txt，临床真实年龄。

beta矩阵行=探针列=样本，示例按TCGA条码第14-15位（01肿瘤/11癌旁）筛样本；年龄表行名须与样本名一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-215dnaage`
- 用到课题：`wiki.py use figureya-215dnaage --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：HumanMethylation450矩阵需自行从UCSC Xena下载（快照未含）；ChAMP可能需Bioconductor旧版本或GitHub安装；BMIQ标准化约30分钟。

## 输出

- `barplot for DNA methylation acceleration.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
