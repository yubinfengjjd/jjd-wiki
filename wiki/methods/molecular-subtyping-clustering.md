---
type: method
id: molecular-subtyping-clustering
title: 表达谱无监督聚类、分子分型与降维排序
status: ready
tags:
- transcriptomics
- multi-omics
data_domains:
- bulk-transcriptomics
- multi-omics
inputs: []
outputs:
- subgroup-effect-table
- pathway-score-table
render_bridges: []
source:
  kind: written
license: none
cite:
- Wilkerson MD, Hayes DN. ConsensusClusterPlus: a class discovery tool with confidence assessments and item tracking. Bioinformatics, 2010.
- Anderson MJ. A new method for non-parametric multivariate analysis of variance (PERMANOVA/Adonis). Austral Ecology, 2001.
favorite: false
method_kind: analysis
purposes:
- 降维与聚类
summary: 面向 Bulk 转录组或多组学矩阵执行无监督分层聚类、共识聚类（ConsensusClusterPlus / MOVICS 等分子分型）以及 PCA/PCoA/PERMANOVA(Adonis) 群落与亚型方差解释分析，输出分组效应与通路/主成分得分表；本库尚未封装独立可执行实现。
data_contract:
  input: 标准化且经批次核查的样本×特征矩阵（单组学高变基因/通路谱，或多组学对齐特征列表），含待检验的样本元信息表。
  output: subgroup-effect-table（样本分子亚型归属与组间效应汇总）与 pathway-score-table（含 PC1/签名得分或组间方差解释度）。
keywords:
- ConsensusClusterPlus
- molecular subtyping
- PCA
- PCoA
- Adonis
- PERMANOVA
- heatmap
- 分子分型
- 共识聚类
figure_relations: []
next_steps:
- direction: 方向 1：检验分子亚型之间的临床生存预后差异
  when: 基于共识聚类确定稳健分子亚型后，比较不同亚型的生存曲线与预后风险比时
  analysis_templates:
  - methods/survival-prognosis-analysis
  intermediate_interface: survival-time-event-group
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
- direction: 方向 2：对比不同分子亚型间的肿瘤微环境与免疫浸润特征
  when: 刻画各分子亚型在免疫细胞丰度、免疫检查点与免疫分型上的异质性时
  analysis_templates:
  - methods/immune-infiltration-tme
  intermediate_interface: pathway-score-table
  viz_templates: []
- direction: 方向 3：识别各分子亚型的特异性标记基因与差异通路
  when: 通过一对多差异分析与功能富集解释各分型的分子生物学特征时
  analysis_templates:
  - methods/differential-expression
  - methods/gene-set-enrichment
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/bulk-de-volcano
---
# 表达谱无监督聚类、分子分型与降维排序

<!-- facts:start -->
<!-- facts:end -->

## 用途

在无先验分型标签或需要发现新异质性亚群时，利用表达谱或多组学矩阵进行共识聚类（Consensus Clustering）、层次聚类热图与主成分/主坐标（PCA / PCoA / PERMANOVA）分析，量化样本间总体结构与分组解释方差。

## 适用

- 经过同一平台归一化且无显著技术批次混杂的疾病队列（如 TCGA/GEO 肿瘤队列）。
- 从预设生物通路或高变异基因出发进行稳定 $K$ 值分子分型，以及通过 Adonis 评估临床/组学因子的结构解释度。

## 不适用

- **样本仅来自未去批次的多队列直接聚类**：聚类结果往往主要反映测序中心/平台而非生物学亚型。
- **使用测试集内部拟合的聚类质心泄露到模型性能评价**。
- **未检验聚类稳定性（PAC / 轮廓系数）仅凭视觉热图主观定分型**。

## 输入

对齐样本 ID 的标准化 Bulk/多组学特征矩阵（及用于 PCoA/Adonis 的临床或环境因子表）。

## 怎么做

1. **特征选择与尺度标准化**：在训练集或独立预处理队列内筛选高变/目标通路基因（行 z-score 或相异度矩阵计算）。
2. **稳健分型与排序**：通过 `ConsensusClusterPlus` 重抽样评估不同 $K$（2–6）的 CDF 曲线与 PAC 指标确定最优亚型数；对样本结构运行 PCA/PCoA 与 `vegan::adonis2` 置换检验。
3. **跨分型与外部队列验证**：将确定的亚型标签写入 [[interfaces/subgroup-effect-table|亚型分组效应表]]，并在独立验证集上验证特征模式与临床结局可重复性。

## 代码

本锚点页当前尚未封装独立可运行的本库 R/Python 分析模块。请参考下方的 FigureYa L1 参考源码配方（如 `figureya-69cancersubtype`、`figureya-202consensusgene`、`figureya-38pca`、`figureya-229pcoa`、`figureya-48adonis`、`figureya-91cluster-heatmap`）查看共识聚类与降维排序实现。

## 输出

输出 [[interfaces/subgroup-effect-table|亚型分组效应表]] 与 [[interfaces/pathway-score-table|排序/签名得分表]]，串联生存、免疫微环境与亚型差异分析。

## 参数

- `maxK`、`reps`、`pItem`、`clusterAlg`：共识聚类的候选簇数、重抽样次数及聚类算法。
- `distance`：降维/热图/PERMANOVA 的距离度量（如 `euclidean`、`pearson`、`bray`）。

## 上一步 / 下一步

- 上一步可来自 [[methods/bulk-expression-preprocessing]]；下一步推荐进入 [[methods/survival-prognosis-analysis]]、[[methods/immune-infiltration-tme]] 或 [[methods/differential-expression]]。

## 知识关联检查

已核对 [[interfaces/subgroup-effect-table]] 与 [[interfaces/pathway-score-table]] 输出契约，与下游 [[methods/survival-prognosis-analysis]]、[[methods/immune-infiltration-tme]] 和 [[methods/differential-expression]] 衔接清晰。

## 使用记录

<!-- user:start -->
<!-- user:end -->
