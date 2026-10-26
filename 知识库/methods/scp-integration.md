---
type: method
id: scp-integration
title: 单细胞多样本整合
status: ready
tags:
- 单细胞分析
keywords:
- SCP
- Seurat
- Integration_SCP
- Harmony
- scVI
- MNN
- fastMNN
- Scanorama
- BBKNN
- CSS
- LIGER
- Conos
- ComBat
- 批次校正
inputs: []
outputs: []
source:
  kind: repo
  url: https://github.com/zhanghao-njmu/scp
  commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
license: GPL-3
cite: []
favorite: false
method_kind: technical
summary: SCP 单细胞多样本整合的原始脚本与作者实现记录；分析问题见批次整合家族。
data_contract:
  input: 含 batch 列的 Seurat 对象或批次对象列表；原脚本参数在 source/ 中。
  output: SCP 整合对象与嵌入；本页不重新运行。
---
# 单细胞多样本整合

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

> **资料类型：技术/来源资料，不是默认分析家族。**
> 当前分析问题见：[[methods/batch-integration|单细胞批次整合]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用 SCP 的 `Integration_SCP()` 对多个样本/批次跑统一预处理，并调用 12 种整合方法之一，产出带方法前缀的 reduction、cluster 和默认嵌入；用于比较批次混合与细胞类型保留，而不是替代生物学分组。

## 原始实现与家族范围

来源是 SCP v0.5.6 的 `R/SCP-workflow.R`。家族限定为“Seurat 对象的多批次整合”：

- 支持 `Uncorrected`、`Seurat`、`scVI`、`MNN`、`fastMNN`、`Harmony`、`Scanorama`、`BBKNN`、`CSS`、`LIGER`、`Conos`、`ComBat`。
- `srtMerge` + `batch` 或 `srtList`；`append=TRUE` 保留原对象并追加整合结果。
- 统一做归一化、HVF、缩放、线性降维、近邻、聚类、非线性降维；方法特有参数通过 `...` 或 `*_params` 列表传入。
- Python 侧：`scVI`（scvi-tools）、`Scanorama`、`BBKNN`、`leiden`（leidenalg）；R 侧：`batchelor`（MNN/fastMNN）、`harmony`、`rliger`、`conos`、`sva`（ComBat）、CSS（simspec）。

代码已本地化到 `code/SCP-local/R/SCP-workflow.R`；补丁见 [[methods/scp-local-source|SCP 源码本地化]]。

## 适用

- 多个样本/批次、同一物种/组织、特征有足够重叠；需要减少技术批次对聚类和嵌入的影响。
- 批次标签明确（`batch` 列），且批次与生物学条件不是完全混杂；完全混杂时整合不能救。
- 需要比较多种整合方法的批次混合与细胞类型保留，而不是只看 UMAP 美观。
- 需要保留原始 counts/元数据，同时得到可复用的整合嵌入。

## 不适用

- 不能修复批次与条件完全混杂的设计（例如所有病例在一个批次、所有对照在另一个批次）；整合会把生物学差异当批次去掉。
- 不能替代差异表达、细胞类型注释或轨迹分析；整合只改变嵌入/近邻。
- 不能把 UMAP 混合程度当唯一评价；需要批次混合指标和细胞类型保留检查。
- 不是所有方法都适合所有数据规模/模态；scVI/Scanorama/BBKNN 需要 Python 环境，LIGER/Conos 需要额外 R 包。
- 过度整合会抹掉真实亚群；`HVF_min_intersection`、`k.anchor`、`theta` 等参数需要检查。
- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；方法可用性和数值表现未验证。2026-10-23 当前规范家族：Seurat 锚点分支 `verified`；Harmony `not_run`（缺包）；scVI/MNN/fastMNN/Scanorama/BBKNN/CSS/LIGER/Conos/ComBat 未运行。见 [[methods/batch-integration]]。

## 输入

- `srtMerge` + `batch` 列（推荐）或 `srtList`；每个对象含 raw counts，细胞 ID 唯一。
- `integration_method`；`assay`；`do_normalization`、`normalization_method`、`do_HVF_finding`、`HVF_source`、`HVF_min_intersection`、`nHVF`。
- `do_scaling`、`vars_to_regress`、`scale_within_batch`；`linear_reduction`、`linear_reduction_dims`、`linear_reduction_dims_use`。
- `nonlinear_reduction`、`nonlinear_reduction_dims`、`neighbor_*`、`cluster_*`、`seed`。
- 方法特有参数：例如 `FindIntegrationAnchors_params`、`k.anchor`、`k.weight`、`theta`、`n_pcs`、`n_neighbors` 等；不同方法不同，需查对应 `*_integrate()` 文档。
- 一行代表一个细胞；`batch` 不能有 NA；样本级协变量（条件、受试者）应保留用于评价。

## 怎么做

1. 检查每个 batch 的细胞数、基因数、批次与条件是否混杂；记录每个样本的技术信息。
2. 合并对象，保留 `batch` 和生物学分组；不要先做会改变 counts 的整合再回来做 QC。
3. 选方法：小数据/快速基线可用 `Harmony`/`Seurat`；跨平台/大数据可试 `scVI`/`Scanorama`/`BBKNN`；需要 R 侧多方法比较可用 `MNN`/`fastMNN`/`ComBat`/`LIGER`/`Conos`。
4. 设 `HVF_source`（separate/merge）和 `HVF_min_intersection`；批次间基因重叠不足时先处理基因命名/物种问题。
5. 跑 `Integration_SCP()`；确认返回对象中的方法前缀 reduction/cluster；`append=TRUE` 时检查对象大小和原数据是否保留。
6. 评价：批次混合（如 batch entropy、kBET、LISI，若环境有）、细胞类型保留（marker 表达、注释一致性）、聚类稳定性；不要只看 UMAP。
7. 选最终嵌入用于下游；在方法/图注中记录方法、版本、关键参数和评价指标。
8. 导出 UMAP 分组表、细胞类型比例表；进入注释、DE 或轨迹。

## 代码

- 原始字节：`source/SCP-workflow.R`（只读归档，未修改）。
- 本地化副本：`code/SCP-local/R/SCP-workflow.R`；辅助函数在 `Seurat-function.R`、`utils.R`。加载方式：
  ```r
  source("path/to/SCP-local/load_scp_local.R")
  srt <- SCP_local$Integration_SCP(
    srtMerge = srt,
    batch = "sample",
    integration_method = "Harmony",
    linear_reduction_dims_use = 1:30,
    nonlinear_reduction = "umap",
    cluster_resolution = 0.6,
    seed = 11
  )
  ```
  这只是调用模式，不是已跑通的本机示例；方法特有参数需按文档补。
- 依赖：Seurat、SeuratObject、BiocParallel、uwot、Matrix；按方法加 `harmony`、`batchelor`、`rliger`、`conos`、`sva`、`simspec`；Python 侧加 reticulate、scvi-tools、scanorama、bbknn、leidenalg。完整清单见 [[methods/scp-local-source|SCP 源码本地化]]。
- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时 `Integration_SCP()` 及 12 种方法依赖未安装、未运行。2026-10-23 当前收据见 [[methods/batch-integration]]：Seurat verified、Harmony not_run；其他方法未运行。
- 本地化未改变整合算法或默认参数；只去掉 `SCP::`/包路径。

## 输出

Seurat 对象中新增（以 `integration_method="Harmony"` 为例）：

- reduction：`Harmonypca`、`HarmonyUMAP2D`、`HarmonyUMAP3D` 等；命名规则是 `integration_method + 降维名`。
- 元数据：`Harmonypca_clusters`、`Harmonyclusters` 等；`srt@misc$Default_reduction` 指向最后一种非线性降维。
- `append=TRUE` 时保留原始 assay/reduction，并追加整合结果；具体槽位以运行结果为准。
- 下游表：
  - `render-umap-groups.csv`：`cell_id, umap_1, umap_2, group`（group=batch 或 celltype），供 fig01。
  - `render-cell-proportions.csv`：`group, celltype, proportion`（group=batch/样本），供 fig04。
  - 表适配函数：`scp_umap_groups()`、`scp_cell_proportions()`，见 [[methods/scp-visualization-interface|SCP 可视化函数族与接口映射]]。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/batch-integration|单细胞批次整合]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页；归档 `SCP-workflow.R` 原字节，本地化副本进入共享源码包；按作者代签授权标为 ready；验收记录见 `acceptance.json`。

<!-- user:start -->
<!-- user:end -->
