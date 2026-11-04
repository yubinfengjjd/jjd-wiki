---
type: recipe
id: figureya-200pairwiseauc
title: 双队列基因预后AUC散点图
status: draft
source:
  id: figureya
  item: FigureYa200pairwiseAUC
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa200pairwiseAUC.Rmd
inputs:
- file: GSE364.expr.txt
  note: GSE364.expr.txt
- file: GSE364.sinfo.txt
  note: GSE364.sinfo.txt
- file: LIHC.expr.txt
  note: LIHC.expr.txt (TCGA)
- file: LIHC.sinfo.txt
  note: LIHC.sinfo.txt (TCGA)
- file: GSE10186.expr.txt
  note: GSE10186.expr.txt
- file: GSE10186.sinfo.txt
  note: GSE10186.sinfo.txt
outputs: []
packages:
  cran:
  - dplyr
  - ggplot2
  - gplots
  - pROC
  - pheatmap
  bioc:
  - impute
  - limma
  github: []
  library:
  - limma
  - impute
  - dplyr
  - pheatmap
  - gplots
  - pROC
  - ggplot2
  namespaced:
  - knitr
tags:
- transcriptomics
- diagnostic-roc
keywords:
- limma
- pROC
- impute
- pheatmap
- gplots
- GSE364
- GSE10186
- TCGA-LIHC
chart_types:
- scatter
- bar
summary: 训练集用limma筛转移相关差异基因画热图，再逐基因在两个测试队列计算预后事件AUC，画AUC配对散点（带阈值框）与均值条形图，找两队列判别都好的基因。
favorite: false
---
# 双队列基因预后AUC散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa200pairwiseAUC` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa200pairwiseAUC.Rmd`）
- 依赖：CRAN dplyr, ggplot2, gplots, pROC, pheatmap；Bioconductor impute, limma
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

训练集用limma筛转移相关差异基因画热图，再逐基因在两个测试队列计算预后事件AUC，画AUC配对散点（带阈值框）与均值条形图，找两队列判别都好的基因。

## 适用

已有训练集（芯片/表达谱）加两套带结局事件的表达队列，想筛跨队列预后判别稳定的候选基因。

## 不适用

结局为二分类事件（fustat）的ROC-AUC，非时间依赖生存AUC；三套数据基因ID需能取交集；示例的蛋白表达基因集是随机模拟的，须换真实注释；AUC阈值0.55写死。

## 输入

- `GSE364.expr.txt`：GSE364.expr.txt
- `GSE364.sinfo.txt`：GSE364.sinfo.txt
- `LIHC.expr.txt`：LIHC.expr.txt (TCGA)
- `LIHC.sinfo.txt`：LIHC.sinfo.txt (TCGA)
- `GSE10186.expr.txt`：GSE10186.expr.txt
- `GSE10186.sinfo.txt`：GSE10186.sinfo.txt

每队列为expr+sinfo成对文件，sinfo行名与expr列名对齐；训练集转移/原发分组靠sinfo中Title的-M/-P后缀解析。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-200pairwiseauc`
- 用到课题：`wiki.py use figureya-200pairwiseauc --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
