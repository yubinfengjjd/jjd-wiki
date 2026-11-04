---
type: recipe
id: figureya-45v2
title: 多组学整合聚类分型
status: draft
source:
  id: figureya
  item: FigureYa45V2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa45iClusterV2.Rmd
inputs:
- file: gbm_mut.txt
  note: 'gbm_mut.txt: 体细胞突变数据. 来自于三个芯片平台(Agilent 244K, SNP6, Illumina 550K), 0表示无，1表示有'
- file: gbm_exp.txt
  note: 'gbm_exp.txt: 来自于不同平台的基因表达量归一化后数据'
- file: gbm_seg.txt
  note: 'gbm_seg.txt: DNA 拷贝数变异. Level 3经标准化和片段化(normalized and segmented)数据集.'
- file: Bayfit.RData
  note: ''
outputs: []
packages:
  cran:
  - gplots
  - lattice
  - magrittr
  bioc:
  - iClusterPlus
  - DNAcopy
  - GenomicRanges
  github: []
  library:
  - iClusterPlus
  - DNAcopy
  - GenomicRanges
  - magrittr
  - lattice
  - gplots
  namespaced:
  - knitr
tags:
- machine-learning
- multi-omics
keywords:
- iClusterPlus
- iClusterBayes
- DNAcopy
- CNregions
- GenomicRanges
- BIC
- gplots
- lattice
- magrittr
chart_types:
- heatmap
- trend
summary: 用iClusterBayes对突变/CNV/表达等多类型组学矩阵做联合潜变量聚类，按BIC与偏差比选K，输出样本分型与特征基因供画亚型热图。
favorite: false
---
# 多组学整合聚类分型

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa45V2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa45iClusterV2.Rmd`）
- 依赖：CRAN gplots, lattice, magrittr；Bioconductor iClusterPlus, DNAcopy, GenomicRanges
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用iClusterBayes对突变/CNV/表达等多类型组学矩阵做联合潜变量聚类，按BIC与偏差比选K，输出样本分型与特征基因供画亚型热图。

## 适用

整合2–6层组学数据（binary/categorical/count/continuous型）识别肿瘤分子亚型。

## 不适用

各数据层须为矩阵且样本名完全一致；CNV需先用DNAcopy分段并去生殖系CNV；K只能预设或tune遍历、prior.gamma靠试；Windows不支持多核并行。

## 输入

- `gbm_mut.txt`：gbm_mut.txt: 体细胞突变数据. 来自于三个芯片平台(Agilent 244K, SNP6, Illumina 550K), 0表示无，1表示有
- `gbm_exp.txt`：gbm_exp.txt: 来自于不同平台的基因表达量归一化后数据
- `gbm_seg.txt`：gbm_seg.txt: DNA 拷贝数变异. Level 3经标准化和片段化(normalized and segmented)数据集.
- `Gbm_mut.txt`：Gbm_mut.txt: Somatic mutation data From three chip platforms (Agilent 244K, SNP6, Illumina 550K), 0 represents none, 1 represents present
- `Gbm_exp.txt`：Gbm_exp.txt: Normalized gene expression data from different platforms
- `Gbm_seg.txt`：Gbm_seg.txt: DNA copy number variation Level 3 is a standardized and segmented dataset
- `Bayfit.RData`：见 Rmd“输入文件”节

输入矩阵行=样本列=基因组特征；三个数据集的行名（样本ID）必须完全一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-45v2`
- 用到课题：`wiki.py use figureya-45v2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：tune.iClusterBayes遍历K极耗时（示例约40分钟起，Windows仅单核建议用Mac/服务器）；快照提供预计算的Bayfit.RData可直接载入。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
