---
type: method
id: dimensionality-reduction
title: 单细胞降维分析
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
summary: 在标准化/缩放后的表达上计算 PCA 与 UMAP，为聚类、可视化和轨迹提供低维表示。
data_contract:
  input: 已标准化、选 HVF 并缩放的 Seurat 对象；features 或 reduction_use 显式。
  output: PCA/UMAP 嵌入，每细胞一行坐标。
implementations:
- id: scp-dimreduction
  title: SCP RunDimReduction 封装
  language: R
  entrypoint: code/analysis.R:run_dimensionality_reduction
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  - data.table
  - uwot
  - intrinsicDimension
  verification: verification/scp-dimreduction-standalone.json
keywords:
- PCA
- UMAP
- RunDimReduction
- HVF
- 降维
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: Standard_SCP 产出 StandardUMAP2D，可作为 UMAP 分组着色；模板只画表，不降维。
  prerequisites:
  - 坐标与 group 来自同一嵌入；cell_id 唯一；坐标无 NA。
  - group 明确为 cluster 或 celltype；group_levels 由课题给出。
  adaptation: 导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）。
  evidence:
  - methods/dimensionality-reduction.md#输出
  - methods/scp-standard-workflow.md#知识关联检查
  - methods/scp-standard-workflow.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap
  compatibility: adaptable
  reason: 降维嵌入可与 marker 表达长表拼成特征 UMAP 网格；模板不重做降维或表达。
  prerequisites:
  - UMAP 坐标与表达来自同一 Seurat 对象；cell_id 一致。
  - 目标细胞类型映射由注释步骤给出；每个 feature 至少有一个正表达细胞。
  adaptation: 导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature,
    value）。
  evidence:
  - methods/dimensionality-reduction.md#输出
  - methods/scp-standard-workflow.md#知识关联检查
  - methods/scp-standard-workflow.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 单细胞降维分析

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
- 代码模板：[methods/dimensionality-reduction/code/analysis.R](/files/wiki/methods/dimensionality-reduction/code/analysis.R) · [methods/dimensionality-reduction/code/dimreduction_native.R](/files/wiki/methods/dimensionality-reduction/code/dimreduction_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：Standard_SCP 产出 StandardUMAP2D，可作为 UMAP 分组着色；模板只画表，不降维。；前提：坐标与 group 来自同一嵌入；cell_id 唯一；坐标无 NA。；group 明确为 cluster 或 celltype；group_levels 由课题给出。；适配：导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）。
    - 关系证据：methods/dimensionality-reduction.md#输出；methods/scp-standard-workflow.md#知识关联检查；methods/scp-standard-workflow.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：降维嵌入可与 marker 表达长表拼成特征 UMAP 网格；模板不重做降维或表达。；前提：UMAP 坐标与表达来自同一 Seurat 对象；cell_id 一致。；目标细胞类型映射由注释步骤给出；每个 feature 至少有一个正表达细胞。；适配：导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature, value）。
    - 关系证据：methods/dimensionality-reduction.md#输出；methods/scp-standard-workflow.md#知识关联检查；methods/scp-standard-workflow.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

把高维表达压缩到 PCA/UMAP，用于可视化、聚类和轨迹。PCA 保留线性方差结构，UMAP 强调局部邻域；两者都是表示，不是生物学距离的绝对度量。

## 原理与选择

SCP `RunDimReduction` 支持 PCA/SVD/ICA/NMF/MDS/glmpca 等线性降维和 UMAP/tSNE/DM/PHATE 等非线性降维；本页只验证 PCA + UMAP。非线性降维需要先有 features 或已有 reduction；数据未缩放时 Seurat 会拒绝。HVF 数、PC 数、邻居数和 UMAP 参数都会改变图形，必须记录。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDimReduction` 的 PCA + UMAP | [[methods/scp-standard-workflow]]；`SCP-local/R/SCP-workflow.R` | 标准化/缩放对象/HVF；嵌入 | 已封装并 verified（200 细胞/100 HVF/20 PC） |
| 其他线性/非线性分支 | 同上 | ICA/NMF/tSNE/DM/PHATE 等 | 未运行；不能因 PCA/UMAP 通过而声称全部支持 |
| 青光眼 `preprocess.R` 的 PCA/UMAP/Harmony | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | Seurat 流程 | 原脚本未函数化；未在本库验证 |
## 适用

- 已归一化、选 HVF 并缩放的 Seurat 对象；需要低维表示做聚类/可视化。
- 有明确的 features 或已存在的 reduction；参数可追溯。
- 用于探索结构和生成假设，后续用 marker/独立数据验证。

## 不适用

- raw counts 未标准化/缩放，或基因数远少于目标 PC 数。
- 把 UMAP 欧氏距离当真实转录距离、把 UMAP 分离当细胞类型差异。
- 只展示一个随机种子/参数的结果，不检查稳定性。

## 输入

Seurat 对象、`features` 或 `reduction_use`/`reduction_dims`、`linear_reduction`、`nonlinear_reduction`、dims 和 seed。每个细胞一行嵌入；细胞身份必须保留。

## 怎么做

1. 完成归一化、HVF 和缩放；检查 HVF 是否被批次/技术基因主导。
2. 选择线性/非线性方法和维度；显式设置 `features` 或已有 reduction。
3. 运行后检查 PCA 方差、UMAP 邻域结构、参数/种子敏感性；与已知 marker 对照。
4. 把嵌入交给聚类/轨迹，但不要用 UMAP 图形反推统计显著性。
5. 其他降维方法未在本页验证，不能因 PCA/UMAP 通过就声称全部支持。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/dimensionality-reduction/code/analysis.R:run_dimensionality_reduction(srt, bundle = NULL, parameters)`，封装 SCP `RunDimReduction`。2026-10-23 在 `pancreas_sub` 200 细胞、100 HVF、20 PC 上实际调用；PCA 与 UMAP 嵌入与保留的完整 bundle 参考一致（异目录复制、新进程、仅必需包）。scope 仅软件调用；测试数据已显式缩放，函数本身不替调用方做预处理。

其他线性/非线性分支未运行。

## 输出

Seurat 对象增加 `PCA`/`UMAP` 等 reduction；每细胞一行坐标。可导出 `cell_id, umap_1, umap_2` 供模板；本页不强制 CSV。

## 知识关联检查

2026-10-23 检查了 UMAP 分组和特征 UMAP 模板。降维坐标可按 cluster/样本着色，或与 marker 长表拼成特征网格；均为 adaptable。没有 direct：模板不读 Seurat reduction，需先导出接口表。UMAP 图不证明聚类或生物学差异显著。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunDimsReduction`、`RunPCA`、`RunUMAP`、`RunLargeVis`、`RunFR`。RunFR 是图布局；低维图相邻不等于生物学相近或完成批次校正。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：在隔离 R 环境用 `pancreas_sub` 200 细胞实际运行 PCA/UMAP 并与上游比较；未做真实课题参数选择。

## 本机组学课题来源增量（2026-11-02）

PCA/UMAP 来源与参数配置；不按课题新建降维方法，也不授予来源脚本已验证。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

<!-- user:start -->
<!-- user:end -->
