---
type: method
id: cell-clustering
title: 单细胞聚类分析
status: ready
tags:
- 单细胞分析
inputs: []
outputs: []
source:
  kind: repo
  url: https://github.com/zhanghao-njmu/scp
  commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
license: GPL-3
cite:
- 'SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)'
favorite: false
method_kind: analysis
purposes:
- 降维与聚类
summary: 在低维嵌入上构建邻居图并划分 cluster；cluster 是分析单位，不是细胞类型。
data_contract:
  input: 已有 PCA/UMAP 嵌入的 Seurat 对象；dims、resolution、algorithm 显式。
  output: 每细胞 cluster 标签；cluster 不是细胞类型。
implementations:
- id: seurat-findclusters
  title: SCP Standard_SCP 聚类分支
  language: R
  entrypoint: code/clustering.R:run_seurat_clustering
  dependencies:
  - Seurat
  - SeuratObject
  verification: verification/seurat-findclusters.json
keywords:
- FindClusters
- Louvain
- Leiden
- resolution
- cluster
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: cluster 标签可作为 UMAP 着色变量；模板不聚类。
  prerequisites:
  - celltype 标签与 UMAP 坐标来自同一 Seurat 对象；cell_id 一致。
  - group_levels 按注释顺序给出；不得把 cluster 编号直接当 celltype。
  adaptation: 导出 render-umap-groups.csv（group=cluster）；cluster 编号不是细胞类型。
  evidence:
  - methods/cell-clustering.md#输出
  - methods/scrna-marker-annotation.md#知识关联检查
  - methods/scrna-marker-annotation.md#输出
  - layouts/2026-10-22-glaucoma-scrna__fig01-cns-umap.md#适用
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  compatibility: adaptable
  reason: 按样本/条件统计 cluster 比例，检查组成；模板不做聚类或检验。
  prerequisites:
  - 每个 group 的比例归一化到 1；group/celltype 完整，无缺组。
  - 流带仅作视觉插值，不是统计估计或细胞轨迹。
  adaptation: 导出 render-cell-proportions.csv（group=样本, celltype=cluster, proportion）。
  evidence:
  - methods/cell-clustering.md#输出
  - methods/scrna-marker-annotation.md#知识关联检查
  - methods/scrna-marker-annotation.md#输出
  - layouts/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow.md#适用
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 单细胞聚类分析

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析
- 分析用途：降维与聚类
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/cell-clustering/code/clustering.R](/files/wiki/methods/cell-clustering/code/clustering.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：cluster 标签可作为 UMAP 着色变量；模板不聚类。；前提：celltype 标签与 UMAP 坐标来自同一 Seurat 对象；cell_id 一致。；group_levels 按注释顺序给出；不得把 cluster 编号直接当 celltype。；适配：导出 render-umap-groups.csv（group=cluster）；cluster 编号不是细胞类型。
    - 关系证据：methods/cell-clustering.md#输出；methods/scrna-marker-annotation.md#知识关联检查；methods/scrna-marker-annotation.md#输出；layouts/2026-10-22-glaucoma-scrna__fig01-cns-umap.md#适用；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本/条件统计 cluster 比例，检查组成；模板不做聚类或检验。；前提：每个 group 的比例归一化到 1；group/celltype 完整，无缺组。；流带仅作视觉插值，不是统计估计或细胞轨迹。；适配：导出 render-cell-proportions.csv（group=样本, celltype=cluster, proportion）。
    - 关系证据：methods/cell-clustering.md#输出；methods/scrna-marker-annotation.md#知识关联检查；methods/scrna-marker-annotation.md#输出；layouts/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow.md#适用；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

在降维嵌入上把细胞分成离散 cluster，作为 marker 检查、注释和组成比较的分析单位。输出是每细胞 cluster 标签；cluster 本身不是细胞类型。

## 原理与选择

Seurat 先 `FindNeighbors` 构建 SNN 图，再用 Louvain/Leiden 等算法划分；`resolution` 控制 cluster 数，算法和随机种子会影响结果。SCP `Standard_SCP`/`Seurat_integrate` 内部使用同一套 FindNeighbors/FindClusters 分支；本页把它显式抽出，不包含预处理、降维或整合。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 显式 Seurat `FindNeighbors` + `FindClusters`（SCP Standard_SCP 分支） | [[methods/scp-standard-workflow]]；`SCP-local/R/SCP-workflow.R` | 已有 PCA/UMAP、dims/resolution；cluster 标签 | 已提炼并 verified（200 细胞/PCA 1:20） |
| 青光眼 `preprocess.R` 的 FindClusters/clustree | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | Seurat 流程、多分辨率 | 原脚本未函数化；未在本库验证 |
| Louvain/Leiden/SLM | Seurat 分支 | 图聚类算法 | 仅验证默认 Louvain 分支；其他未运行 |
## 适用

- 已有稳定 PCA/UMAP 嵌入的 Seurat 对象；需要 cluster 做注释/组成分析。
- 明确 resolution、dims、algorithm 和 seed，并做敏感性分析。
- cluster 结果用 marker 和独立注释验证。

## 不适用

- raw counts 或未降维数据；或把 cluster 编号直接当细胞类型。
- 只报一个 resolution/seed，把 cluster 数当生物学真相。
- 用 cluster 比例差异直接做样本级统计推断而不考虑样本重复。

## 输入

Seurat 对象、`reduction`、`dims`、`resolution`、`algorithm`、`seed`。每个细胞一行 cluster；嵌入必须来自同一对象。

## 怎么做

1. 先检查嵌入质量和 dims；确定 resolution 扫描范围。
2. 运行 FindNeighbors/FindClusters，保留 cluster 标签和参数。
3. 做 resolution/seed 敏感性分析；用 marker 检查每个 cluster 是否可解释。
4. 注释后比较样本/条件组成；细胞级比例只作描述，样本级推断需按样本汇总。
5. 不把 cluster 通过当成注释或治疗分组通过。

## 代码

入口 `methods/cell-clustering/code/clustering.R:run_seurat_clustering(object, reduction, dims, resolution, algorithm, seed)`，显式复用 SCP `Standard_SCP` 中的 FindNeighbors/FindClusters 分支；不包含预处理、降维或整合。2026-10-23 在 `pancreas_sub` 200 细胞、PCA 1:20、resolution 0.5 上实际运行，并与相同 Seurat 调用逐标签比较；scope 仅软件调用。

该分支不是独立 SCP 函数封装；说明见 `code/clustering.R` 的 source mapping。

## 输出

data.frame，一行一个细胞：`cell_id`、`cluster`、`reduction`、`resolution`。cluster 为字符型，避免被误当连续变量；可另导出 UMAP 分组表或比例表。

## 知识关联检查

2026-10-23 检查了 UMAP 分组和细胞比例模板。cluster 可着色 UMAP、展示样本组成；均为 adaptable。没有 direct；cluster 编号不等于细胞类型，图注必须说明 resolution 和注释来源。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`FindNeighbors`、`FindClusters`、`RunCHOIR`。聚类标签不是细胞类型；图构建、分辨率与显著性聚类路径分别核对。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：在隔离 R 环境用 `pancreas_sub` 200 细胞实际运行并与相同 Seurat 调用比较；未做真实课题 resolution 选择。

## 本机组学课题来源增量（2026-11-02）

FindNeighbors/FindClusters 来源；ConsensusClusterPlus 样本分型与 Mclust 模型性能分组不归为同一实现。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

<!-- user:start -->
<!-- user:end -->
