---
type: method
id: scp-standard-workflow
title: 单细胞标准预处理、降维与聚类
status: ready
tags:
- 单细胞分析
keywords:
- SCP
- Seurat
- Standard_SCP
- RunDimReduction
- PCA
- UMAP
- tSNE
- Louvain
- Leiden
- 聚类
- 降维
inputs: []
outputs: []
source:
  kind: repo
  url: https://github.com/zhanghao-njmu/scp
  commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
license: GPL-3
cite: []
favorite: false
method_kind: workflow
summary: SCP 标准预处理、降维与聚类的组合流程记录；单步方法见质量控制、降维、聚类和整合家族。
data_contract:
  input: 原始 counts 的 Seurat 对象；流程参数在 source/ 中。
  output: Standardpca/StandardUMAP2D/Standardclusters 等流程对象；本页不重新运行。
---
# 单细胞标准预处理、降维与聚类

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：无
- 标签：单细胞分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：组合流程，不是默认分析家族。**
> 当前分析问题见：[[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]、[[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用 SCP 的 `Standard_SCP()` 在一个 Seurat 对象上跑标准单细胞流程：归一化、高变基因、缩放、线性降维、近邻图、聚类、非线性降维，产出带前缀的 reduction、cluster 列和默认 reduction。也可用 `RunDimReduction()` 单独跑某一步。

## 原始实现与家族范围

来源是 SCP v0.5.6 的 `R/SCP-workflow.R`。家族限定为“单对象、无批次校正的标准 Seurat 流程”：

- 归一化：`LogNormalize`、`SCT`、`TFIDF`（TFIDF 会切到 SVD/LSI 工作流）。
- 线性降维：`pca`、`svd`、`ica`、`nmf`、`mds`、`glmpca`（通过 `RunDimReduction()`）。
- 非线性降维：`umap`、`umap-naive`、`tsne`、`dm`、`phate`、`pacmap`、`trimap`、`largevis`、`fr`。
- 聚类：`louvain`、`slm`、`leiden`；`leiden` 需要 Python `leidenalg`。
- `Standard_SCP()` 内部用 `check_srtList(batch = "")`，不走批次整合；多用户/多样本应使用 [[methods/scp-integration|Integration_SCP]]。

代码已本地化到 `code/SCP-local/R/SCP-workflow.R`，配套 `Seurat-function.R`、`utils.R`；补丁见 [[methods/scp-local-source|SCP 源码本地化]]。

## 适用

- Seurat 对象含 raw counts；一行一个细胞，一列一个基因。
- 单一对象或已合并、但不需要批次校正的数据；需要探索性聚类、UMAP/tSNE 和 marker 检查。
- 需要把 reduction 名称、cluster 列、HVF 固定下来，供下游 DE、注释、轨迹和绘图使用。
- 需要尝试多种降维/聚类算法做敏感性比较。

## 不适用

- 不是批次校正方法；多用户/多样本、批次与条件混杂时不能用 `Standard_SCP()` 代替整合。
- 不能从 UMAP 外观或 cluster 数证明生物亚群存在；需要 marker、统计和独立验证。
- 默认 `nHVF=2000`、`linear_reduction_dims=50`、`neighbor_k=20`、`cluster_resolution=0.6` 不是通用最优；换组织/数据量要重设。
- 不能把 `RunDimReduction()` 的降维结果当差异表达或轨迹证据。
- `leiden` 需要 reticulate + `leidenalg`；2026-10-22 记录当时环境未安装、未验证；2026-10-23 未重新验证 leiden。
- 超大数据的内存/运行时间未评估；`ScaleData` 和 UMAP 可能成为瓶颈。
- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；默认参数真实表现未验证。2026-10-23 当前规范家族：PCA/UMAP `verified`、FindClusters `verified`；Standard_SCP 全流程未运行。见 [[methods/dimensionality-reduction]]、[[methods/cell-clustering]]。

## 输入

- Seurat 对象；`assay`（默认 `DefaultAssay`）；raw counts。
- `normalization_method`（`LogNormalize`/`SCT`/`TFIDF`）、`do_HVF_finding`、`HVF_method`、`nHVF` 或显式 `HVF`。
- `do_scaling`、`vars_to_regress`、`regression_model`。
- `linear_reduction`、`linear_reduction_dims`、`linear_reduction_dims_use`；`nonlinear_reduction`、`nonlinear_reduction_dims`。
- `neighbor_metric`、`neighbor_k`、`cluster_algorithm`、`cluster_resolution`、`seed`。
- 一行代表一个细胞；细胞 ID 唯一；样本/条件元数据可留在对象里，但不参与校正。

## 怎么做

1. 确认 counts 是 raw counts；如已归一化，设 `do_normalization=FALSE` 或明确使用现有数据。
2. 选归一化方法：常规 scRNA 用 `LogNormalize`；需要 SCT 时注意 `ScaleData` 会被跳过；scATAC 用 `TFIDF` + `svd`。
3. 找 HVF（`vst` 默认，2000 个）；需要回归协变量时设 `vars_to_regress`，并说明回归模型。
4. 跑线性降维；`linear_reduction_dims_use` 为 NULL 时，SCP 用 `dims_estimate` 估计使用维度；显式给出更可控。
5. `FindNeighbors()` 建 KNN/SNN 图；`FindClusters()` 跑所选算法和分辨率；`SrtReorder()` 按 HVF 表达重排 cluster 编号。
6. 在所选线性降维/SNN 图上跑非线性降维；`nonlinear_reduction_dims` 默认 `c(2,3)`，会同时产出 2D/3D。
7. 检查：dims_estimate、不同分辨率/算法的 cluster 稳定性、UMAP/tSNE 是否一致、marker 是否落在对应 cluster、最小 cluster 细胞数。
8. 导出 UMAP 坐标、cluster/celltype、marker 表达长表；进入注释、DE、轨迹或绘图。

## 代码

- 原始字节：`source/SCP-workflow.R`（只读归档，未修改）。
- 本地化副本：`code/SCP-local/R/SCP-workflow.R`；辅助函数在 `Seurat-function.R`、`utils.R`。加载方式：
  ```r
  source("path/to/SCP-local/load_scp_local.R")
  srt <- SCP_local$Standard_SCP(
    srt,
    prefix = "Standard",
    normalization_method = "LogNormalize",
    nHVF = 2000,
    linear_reduction = "pca",
    nonlinear_reduction = "umap",
    cluster_algorithm = "louvain",
    cluster_resolution = 0.6,
    seed = 11
  )
  ```
  这只是调用模式，不是已跑通的本机示例。
- 单独降维：`SCP_local$RunDimReduction(srt, prefix = "", linear_reduction = "pca", ...)`；非线性降维需给 `reduction_use`/`graph_use`。
- 依赖：Seurat、SeuratObject、uwot、BiocParallel、Matrix、future；`leiden` 需要 reticulate + leidenalg；SCT 需要 Seurat 的 SCTransform 依赖（glmGamPoi 等）。完整清单见 [[methods/scp-local-source|SCP 源码本地化]]。
- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时 Standard_SCP 依赖未安装、未运行。2026-10-23 当前范围见 [[methods/dimensionality-reduction]]（RunDimReduction verified）与 [[methods/cell-clustering]]（FindNeighbors/FindClusters verified）；Standard_SCP 组合流程本身未重新运行。
- 本地化未改变归一化、HVF、降维、聚类或重排算法；只去掉 `SCP::`/包路径。

## 输出

Seurat 对象中新增（以 `prefix="Standard"`、`linear_reduction="pca"`、`nonlinear_reduction=c("umap","tsne")` 为例）：

- reduction：`Standardpca`、`StandardUMAP2D`、`StandardUMAP3D`、`StandardTSNE2D`、`StandardTSNE3D`；命名规则是 `prefix + toupper(nonlinear_reduction) + nD`。
- 图：`Standardpca_KNN`、`Standardpca_SNN`（`FindNeighbors` 的 graph.name）。
- 元数据：`Standardpca_clusters`（每个线性降维的 cluster）、`Standardclusters`（第一个线性降维的 cluster 别名）。
- `VariableFeatures(srt)` 与 `srt@misc$Standard_HVF`；`srt@misc$Default_reduction` 指向最后一个非线性降维（如 `StandardUMAP`）。
- 下游表：
  - `render-umap-groups.csv`：`cell_id, umap_1, umap_2, group`（group=cluster/celltype/sample），供 fig01。
  - `render-umap-feature-long.csv`：`cell_id, umap_1, umap_2, group, feature, value`，供 fig02。
  - 表适配函数：`scp_umap_groups()`、`scp_umap_feature_long()`，见 [[methods/scp-visualization-interface|SCP 可视化函数族与接口映射]]。

## 知识关联检查

2026-10-23 分类为组合流程：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]、[[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页；归档 `SCP-workflow.R` 原字节，本地化副本进入共享源码包；按作者代签授权标为 ready；验收记录见 `acceptance.json`。

<!-- user:start -->
<!-- user:end -->
