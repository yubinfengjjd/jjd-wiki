---
type: method
id: scp-annotation-projection
title: 单细胞自动注释与参考投影
status: ready
tags:
- 单细胞分析
keywords:
- SCP
- Seurat
- RunSingleR
- RunKNNPredict
- RunScmap
- RunKNNMap
- RunPCAMap
- RunSeuratMap
- RunSymphonyMap
- RunCSSMap
- SingleR
- scmap
- Symphony
- 细胞类型注释
- 参考投影
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
summary: SCP 自动注释与参考投影的原始脚本和作者实现记录；分析问题见细胞类型注释与参考映射家族。
data_contract:
  input: SCP/Seurat 查询与参考对象、作者提供的参考标签列；原脚本参数在 source/ 中。
  output: 原始 SCP 注释/投影对象与结果表；本页不重新运行，不产生新的分析结论。
---
# 单细胞自动注释与参考投影

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
> 当前分析问题见：[[methods/cell-type-annotation|细胞类型注释]]、[[methods/reference-mapping|参考图谱映射]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用 SCP 的注释/投影函数把查询细胞的类型标签从参考数据转移过来，或把查询细胞投影到参考嵌入：

- `RunSingleR()`：SingleR 相关性注释（cluster 或 cell 级别）。
- `RunKNNPredict()`：KNN 注释，支持单细胞参考或 bulk 参考、查询聚类、概率和距离。
- `RunScmap()`：scmap-cluster/scmap-cell 注释。
- `RunKNNMap()`、`RunPCAMap()`、`RunSeuratMap()`、`RunSymphonyMap()`、`RunCSSMap()`：把查询投影到参考嵌入并可选转移标签。
- 参考图谱数据对象 `ref_scHCL`、`ref_scMCA`、`ref_scZCL` 在上游包中；本知识库未带入。

## 原始实现与家族范围

来源是 SCP v0.5.6 的 `R/SCP-cell_annotation.R` 与 `R/SCP-projection.R`。家族限定为“基于参考数据的标签转移/投影”：

- 注释：SingleR、scmap、KNNPredict（scRNA 或 bulk）。
- 投影：KNN、PCA、Seurat anchors、Symphony、CSS；输出 `ref.embeddings`，可选 `predicted_<ref_group>`。
- 标签来源必须是参考对象的 metadata 列或 bulk 参考的列名；参考与查询的物种/基因命名要匹配。
- 参考图谱（HCL/MCA/ZCL）是上游包的数据对象，不在本地化源码包内；需要时从上游获取。

代码已本地化到 `code/SCP-local/R/SCP-cell_annotation.R`、`SCP-projection.R`；补丁见 [[methods/scp-local-source|SCP 源码本地化]]。

## 适用

- 查询和参考同物种、同组织/发育阶段，基因命名可对齐；参考标签可信且覆盖查询的主要类型。
- 需要快速把查询细胞映射到已知参考类型，或用参考嵌入做可视化/比较。
- 有 bulk 参考矩阵（行=基因，列=细胞类型）时可用 `RunKNNPredict(bulk_ref=...)`。
- 需要多种注释方法交叉检查，而不是只信一个算法。

## 不适用

- 参考与查询物种/组织/发育阶段不匹配时，标签转移会给出看似合理但错误的类型。
- 参考中没有的新类型会被强行分配到某个已知类型；需要 unknown/out-of-distribution 处理和 marker 检查。
- 标签转移不是验证；必须用 marker、形态/空间信息或独立数据核验。
- 不能把投影嵌入当作整合结果；投影不校正查询内部批次，也不改变查询的生物学分组。
- `scmap`/`Symphony`/`CSS` 需要额外包；`RunKNNPredict` 的 bulk 参考需要匹配基因和归一化方式。
- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；注释准确率、投影质量和参考适用性未验证。2026-10-23 当前规范家族验证：SingleR 分支 `not_run`（缺包）；Seurat 标签转移 `verified`；SCP `RunSeuratMap` UMAP 投影 `not_run`（`dim.` 错误）。见 [[methods/cell-type-annotation]]、[[methods/reference-mapping]]；旧记录不扩为所有注释/投影分支可用。

## 输入

- 查询 Seurat 对象；参考 Seurat 对象或 bulk 矩阵。
- `query_group`/`ref_group`：查询/参考的分组列；注释时参考标签列不能有 NA。
- `query_assay`/`ref_assay`；`query_reduction`/`ref_reduction`、`query_dims`/`ref_dims`。
- KNN 参数：`features`/`features_type`/`feature_source`/`nfeatures`、`k`、`distance_metric`、`filter_lowfreq`、`return_full_distance_matrix`。
- 投影参数：`ref_pca`/`ref_umap`/`ref_harmony`/`ref_css`、`projection_method`、`k.anchor`/`k.filter`/`k.score`/`k.weight`、`vote_fun`。
- 一行代表一个细胞（bulk 参考一行/列代表一个类型或样本，需按函数文档确认方向）；基因 ID 与参考一致。

## 怎么做

1. 对齐基因：统一大小写/物种/ID；检查查询与参考的特征交集；交集过小时停止，不要硬投影。
2. 选参考：同组织/同物种优先；跨物种需要 ortholog 映射并重新评估。bulk 参考要确认行=基因、列=类型。
3. 选方法：SingleR 适合有表达参考的快速注释；scmap 适合 cluster/cell 级；KNNPredict 适合 scRNA/bulk 且可给概率/距离；投影方法适合需要参考嵌入的场景。
4. 跑注释/投影；检查 `singler_annotation`/`singler_score`、`KNNPredict_classification`/`_prob`/`_simil`/`_dist`、`scmap_annotation`/`scmap_score`、`ref.embeddings`、`predicted_<ref_group>`。
5. 用 marker 检查预测类型：每个预测类型是否有对应 marker；与聚类/手工注释是否一致；看低置信度/`unreliable` 细胞。
6. 多方法交叉：SingleR vs scmap vs KNNPredict 的一致/不一致；不一致的细胞优先复查。
7. 记录参考版本、基因映射、方法、参数和置信度阈值；不要把预测标签当金标准。

## 代码

- 原始字节：`source/SCP-cell_annotation.R`、`source/SCP-projection.R`（只读归档，未修改）。
- 本地化副本：`code/SCP-local/R/SCP-cell_annotation.R`、`SCP-projection.R`；辅助函数在 `utils.R`、`Seurat-function.R`。加载方式：
  ```r
  source("path/to/SCP-local/load_scp_local.R")
  srt <- SCP_local$RunSingleR(srt_query = srt, srt_ref = ref, ref_group = "celltype")
  srt <- SCP_local$RunKNNPredict(srt_query = srt, srt_ref = ref, ref_group = "celltype",
                                 filter_lowfreq = 20)
  srt <- SCP_local$RunKNNMap(srt_query = srt, srt_ref = ref, ref_umap = "refUMAP")
  ```
  这只是调用模式，不是已跑通的本机示例。
- 依赖：Seurat、SeuratObject、SingleR、scmap、symphony、S4Vectors、SingleCellExperiment、SummarizedExperiment、proxyC；投影另需对应方法包。完整清单见 [[methods/scp-local-source|SCP 源码本地化]]。
- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时注释/投影依赖未安装、未运行。2026-10-23 当前范围见 [[methods/cell-type-annotation]] 与 [[methods/reference-mapping]] 的收据：SingleR not_run；标签转移 verified；UMAP 投影 not_run。
- 本地化未改变注释/投影算法；只去掉 `SCP::`/包路径。

## 输出

Seurat `meta.data`/`reductions`/`tools` 中新增（列名以运行结果为准）：

- `RunSingleR()`：`singler_annotation`、`singler_score`；cluster 级注释时按 query cluster 广播到细胞。
- `RunKNNPredict()`：`KNNPredict_classification`、`KNNPredict_prob`、`KNNPredict_simil`/`KNNPredict_dist`；tools `KNNPredict_classification` 含 match 结果、距离矩阵（可选）。
- `RunScmap()`：`scmap_annotation`、`scmap_score`；tools `scmapCluster_results`/`scmapCell_results`。
- 投影：reduction `ref.embeddings`；metadata `predicted_<ref_group>`；`ref.embeddings@misc$reduction.model` 记录参考 UMAP。
- 下游表：
  - `render-umap-groups.csv`：`cell_id, umap_1, umap_2, group`（group=预测 celltype），供 fig01。
  - `render-umap-feature-long.csv`：`cell_id, umap_1, umap_2, group, feature, value`（marker 表达），供 fig02。
  - `render-dotplot-long.csv`：`group, feature, avg_expression, pct_expressed, target_group`（预测类型×marker），供 fig03。
  - `render-cell-proportions.csv`：`group, celltype, proportion`（样本/条件×预测类型），供 fig04。
  - 适配函数见 [[methods/scp-visualization-interface|SCP 可视化函数族与接口映射]]：`scp_umap_groups()`、`scp_umap_feature_long()`、`scp_dotplot_long()`、`scp_cell_proportions()`。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/cell-type-annotation|细胞类型注释]]、[[methods/reference-mapping|参考图谱映射]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页；归档 `SCP-cell_annotation.R`、`SCP-projection.R` 原字节，本地化副本进入共享源码包；按作者代签授权标为 ready；验收记录见 `acceptance.json`。

<!-- user:start -->
<!-- user:end -->
