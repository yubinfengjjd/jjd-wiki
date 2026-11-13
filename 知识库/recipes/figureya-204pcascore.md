---
type: recipe
id: figureya-204pcascore
title: Boruta筛选与PC1签名评分
status: ready
source:
  id: figureya
  item: FigureYa204PCAscore
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa204PCAscore.Rmd
inputs:
- file: easy_input_expr.txt
  note: easy_input_expr.txt，表达矩阵，这里与原文保持一致，用了TPM，也可以用FPKM。FigureYa201ClusterCorrelation的输入文件是FPKM，同样也可以用TPM。
- file: easy_input_cluster.txt
  note: easy_input_cluster.txt，把Figure201ClusterCorrelation获得的亚型信息（ConsensusCluster文件夹里，ConsensusCluster.k=X.consensusClass.csv对应每种分类数量下sample所在的cluster）写在cluster列。其余为样本信息，跟FigureYa201ClusterCorrelation的`easy
- file: ouput_ICIsignatureGene.txt
  note: ouput_ICIsignatureGene.txt，Figure201ClusterCorrelation的ICI signature gene结果。
outputs:
- ICI_score.pdf
packages:
  cran:
  - Boruta
  - ggplot2
  - ggpubr
  - pheatmap
  bioc: []
  github: []
  library:
  - Boruta
  - ggplot2
  - ggpubr
  - pheatmap
  namespaced:
  - knitr
tags:
- transcriptomics
- machine-learning
keywords:
- Boruta
- PCA
- PC1
- ICI score
- signature
- prcomp
- ggpubr
- pheatmap
chart_types:
- violin
- boxplot
- heatmap
summary: 用Boruta对A/B两类signature基因分别做特征筛选，再各取PCA第一主成分相减得单样本ICI得分，配降维后热图和亚型分组提琴箱线图。
favorite: false
---
# Boruta筛选与PC1签名评分

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa204PCAscore` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa204PCAscore.Rmd`）
- 依赖：CRAN Boruta, ggplot2, ggpubr, pheatmap
- 最近运行：pass（as-is，2026-11-04 11:02 UTC，142.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-204pcascore/preview.png]]
<!-- facts:end -->

## 用途

用Boruta对A/B两类signature基因分别做特征筛选，再各取PCA第一主成分相减得单样本ICI得分，配降维后热图和亚型分组提琴箱线图。

## 适用

已有分型标签和候选signature基因（如FigureYa201ClusterCorrelation的输出），想做不同于lasso/线性cox系数的PCA式分子分型评分。

## 不适用

依赖上游模块的分型结果与signature基因表，非独立模块；示例按TCGA barcode第11-12位为“01”筛肿瘤样本；Boruta为随机迭代算法，较慢且须固定seed才能复现。

## 输入

- `easy_input_expr.txt`：easy_input_expr.txt，表达矩阵，这里与原文保持一致，用了TPM，也可以用FPKM。FigureYa201ClusterCorrelation的输入文件是FPKM，同样也可以用TPM。
- `easy_input_cluster.txt`：easy_input_cluster.txt，把Figure201ClusterCorrelation获得的亚型信息（ConsensusCluster文件夹里，ConsensusCluster.k=X.consensusClass.csv对应每种分类数量下sample所在的cluster）写在cluster列。其余为样本信息，跟FigureYa201ClusterCorrelation的`easy
- `easy_input_sinfo.txt`：easy_input_cluster.txt，把Figure201ClusterCorrelation获得的亚型信息（ConsensusCluster文件夹里，ConsensusCluster.k=X.consensusClass.csv对应每种分类数量下sample所在的cluster）写在cluster列。其余为样本信息，跟FigureYa201ClusterCorrelation的`easy
- `ouput_ICIsignatureGene.txt`：ouput_ICIsignatureGene.txt，Figure201ClusterCorrelation的ICI signature gene结果。
- `X.consensusClass.csv`：easy_input_cluster.txt，把Figure201ClusterCorrelation获得的亚型信息（ConsensusCluster文件夹里，ConsensusCluster.k=X.consensusClass.csv对应每种分类数量下sample所在的cluster）写在cluster列。其余为样本信息，跟FigureYa201ClusterCorrelation的`easy

easy_input_cluster.txt行名=样本且须含“Gene cluster”列（其余列作热图注释）；ouput_ICIsignatureGene.txt须含gene和direct（A/B）两列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-204pcascore`
- 用到课题：`wiki.py use figureya-204pcascore --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `ICI_score.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] · [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
