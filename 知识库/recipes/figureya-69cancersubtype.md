---
type: recipe
id: figureya-69cancersubtype
title: 多组学共识聚类分子分型
status: draft
source:
  id: figureya
  item: FigureYa69cancerSubtype
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa69cancerSubtype.Rmd
inputs:
- file: GeneExp.txt
  note: ''
- file: miRNAExp.txt
  note: ''
- file: survinfo.txt
  note: ''
outputs:
- SNFCC.pdf
- CC.pdf
- CNMF.pdf
packages:
  cran:
  - data.table
  - stringr
  - survival
  - cluster
  - impute
  - CancerSubtypes
  - ConsensusClusterPlus
  bioc:
  - impute
  - ConsensusClusterPlus
  github:
  - taoshengxu/CancerSubtypes
  library:
  - stringr
  - CancerSubtypes
  namespaced:
  - knitr
tags:
- multi-omics
- machine-learning
- survival-analysis
keywords:
- CancerSubtypes
- ConsensusClusterPlus
- SNF
- NMF
- iCluster
- FSbyCox
- consensus clustering
- stringr
chart_types:
- heatmap
- km-curve
summary: 用CancerSubtypes对多组学矩阵做SNF.CC、CC、CNMF等共识聚类分型，Cox筛生存相关特征，并用KM曲线+logrank检验评估分型预后价值。
favorite: false
---
# 多组学共识聚类分子分型

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa69cancerSubtype` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa69cancerSubtype.Rmd`）
- 依赖：CRAN data.table, stringr, survival, cluster, impute, CancerSubtypes, ConsensusClusterPlus；Bioconductor impute, ConsensusClusterPlus；GitHub taoshengxu/CancerSubtypes
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用CancerSubtypes对多组学矩阵做SNF.CC、CC、CNMF等共识聚类分型，Cox筛生存相关特征，并用KM曲线+logrank检验评估分型预后价值。

## 适用

有mRNA/miRNA等多组学数据加生存信息，想系统比较几种无监督分型算法并验证亚型生存差异。

## 不适用

所有组学与生存表的样本名和顺序必须完全一致（包本身不校验样本名）；聚类有随机性、对特征筛选和参数敏感需反复调试；NMF很耗时而示例只用筛选后少量基因；clusterNum需预设。

## 输入

- `GeneExp.txt`：见 Rmd“输入文件”节
- `miRNAExp.txt`：见 Rmd“输入文件”节
- `survinfo.txt`：见 Rmd“输入文件”节

组学矩阵行特征列样本；survinfo行名为样本、含futime/fustat两列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-69cancersubtype`
- 用到课题：`wiki.py use figureya-69cancersubtype --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：CancerSubtypes需从GitHub（taoshengxu/CancerSubtypes）安装；reps=500的共识聚类与NMF计算量大。

## 输出

- `SNFCC.pdf`
- `CC.pdf`
- `CNMF.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]] · [[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
