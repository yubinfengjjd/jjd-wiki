---
type: method
id: reference-mapping
title: 参考图谱映射
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
- 注释与参考映射
summary: 把查询细胞映射到参考标签并返回预测分数；Seurat 标签转移已验证，UMAP 投影分支未通过。
data_contract:
  input: query/reference Seurat 对象 + reference 标签列；reference 有 PCA，query/ref 共享特征。
  output: 每 query 细胞 predicted_id、max_score、margin；不包含 UMAP 投影（该分支未通过）。
implementations:
- id: seurat-label-transfer
  title: Seurat 锚点标签转移分支
  language: R
  entrypoint: code/transfer.R:run_reference_label_transfer
  dependencies:
  - Seurat
  - SeuratObject
  verification: verification/seurat-label-transfer-standalone.json
- id: scp-runseuratmap
  title: SCP RunSeuratMap UMAP 投影分支
  language: R
  entrypoint: code/analysis.R:run_reference_mapping
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  - data.table
  - uwot
  - intrinsicDimension
  - dplyr
  - proxyC
  verification: verification/scp-runseuratmap-standalone.json
keywords:
- reference mapping
- label transfer
- FindTransferAnchors
- TransferData
- Seurat
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: 查询细胞可按预测标签着色自身 UMAP；这不是参考 UMAP 投影，模板也不执行映射。
  prerequisites:
  - 预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。
  - 标签不是 cluster 编号；group_levels 按注释顺序给出。
  adaptation: 导出 render-umap-groups.csv（group=predicted label）；不得把查询 UMAP 说成参考投影。
  evidence:
  - methods/reference-mapping.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  compatibility: adaptable
  reason: 按样本统计预测标签比例，检查映射组成；模板不做映射或检验。
  prerequisites:
  - 每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。
  - 比例是描述性；组间差异不能由该图直接推断。
  adaptation: 导出 render-cell-proportions.csv（group=样本, celltype=predicted label, proportion）。
  evidence:
  - methods/reference-mapping.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 参考图谱映射

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析
- 分析用途：注释与参考映射
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/reference-mapping/code/analysis.R](/files/wiki/methods/reference-mapping/code/analysis.R) · [methods/reference-mapping/code/reference_native.R](/files/wiki/methods/reference-mapping/code/reference_native.R) · [methods/reference-mapping/code/transfer.R](/files/wiki/methods/reference-mapping/code/transfer.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：查询细胞可按预测标签着色自身 UMAP；这不是参考 UMAP 投影，模板也不执行映射。；前提：预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。；标签不是 cluster 编号；group_levels 按注释顺序给出。；适配：导出 render-umap-groups.csv（group=predicted label）；不得把查询 UMAP 说成参考投影。
    - 关系证据：methods/reference-mapping.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本统计预测标签比例，检查映射组成；模板不做映射或检验。；前提：每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。；比例是描述性；组间差异不能由该图直接推断。；适配：导出 render-cell-proportions.csv（group=样本, celltype=predicted label, proportion）。
    - 关系证据：methods/reference-mapping.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

把查询数据集的细胞映射到参考图谱的标签空间，返回每细胞预测类型、置信分数和 margin。用于跨数据集注释、参考图谱复用和数据整合前的标签检查。

## 原理与选择

Seurat 锚点法在 query/ref 之间找相互最近邻，再用 `TransferData` 把参考标签和分数传给查询细胞；SCP `RunSeuratMap` 还包含把查询投影到参考 UMAP 的分支。KNNMap、Symphony、scmap、CSS 等是其他映射策略。本页把“标签转移”和“UMAP 投影”分开：前者已验证，后者在 Seurat 5.6 下失败，不能混为一个通过。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| Seurat `FindTransferAnchors` + `TransferData` 标签转移 | [[methods/scp-annotation-projection]]；`SCP-local/R/SCP-projection.R` 的 `RunSeuratMap` 分支 | query/reference + ref 标签；预测标签/分数 | 已从源码提取并 verified（300 ref/700 query）；不含 UMAP 投影 |
| SCP `RunSeuratMap` 的 UMAP 投影 | 同上 | query 投影到参考 UMAP | 投影分支在 Seurat 5.6 下报 `dim.` 错误，`not_run` |
| 青光眼 marker 手工注释 | [[methods/scrna-marker-annotation]] | marker→类型 | 是注释策略，不是参考映射；不混为同一实现 |
## 适用

- query/ref 同物种、共享特征，参考有可靠标签和 PCA；查询与参考的预处理可比。
- 需要每细胞预测标签和分数，用于注释或跨数据集比较。
- 有独立 marker/组成检查验证映射结果。

## 不适用

- 参考与查询组织/平台差异大、共享特征很少，或参考标签不可靠；novel 类型可能被强行映射。
- 把标签转移分数当校准概率或因果身份；或把查询 UMAP 着色说成参考投影。
- 用映射结果替代聚类、marker 检查和实验验证。

## 输入

query/reference Seurat 对象、`ref_group_col` 标签列、`dims`；reference 需有 PCA（没有时函数会计算）。每个 query 细胞一行预测；query 顺序必须保留。

## 怎么做

1. 核对 query/ref 物种、基因标识、预处理和标签定义；检查共享特征与参考 PCA。
2. 运行 `FindTransferAnchors` + `TransferData`，保留 `predicted.id`、每类分数和 margin；不要只看标签。
3. 用 marker、组成和独立注释方法复核；低 margin 的细胞标为待定。
4. 若要投影到参考 UMAP，单独验证 `RunKNNMap`/UMAP 分支；本页的投影分支当前失败，不能声称可用。
5. 与 cell-type-annotation 区分：本页是参考映射，不是通用 marker 注释。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

- 标签转移分支：`methods/reference-mapping/code/transfer.R:run_reference_label_transfer(query, reference, ref_group_col, ...)`，从 SCP `RunSeuratMap` 提取 `FindTransferAnchors` + `TransferData`。2026-10-23 在 `pancreas_sub` 300 参考/700 查询细胞上实际运行，返回每 query 细胞预测、顺序和 anchor 数；scope 仅软件调用。该分支不包含 UMAP 投影。
- UMAP 投影分支：`methods/reference-mapping/code/analysis.R:run_reference_mapping(srt_query, srt_ref, bundle = NULL, parameters)`，封装 SCP `RunSeuratMap`；在 Seurat 5.6 下报 `Argument 'dim.' must be an integer vector of length two`，保留 `not_run`。

两个分支独立验证；标签转移通过不批准 UMAP 投影分支。

## 输出

标签转移返回 `list(table=..., scores=..., anchors=...)`：`table` 每行一个 query 细胞，含 `cell_id`、`predicted_id`、`max_score`、`margin`；`scores` 为每类预测分数。没有 UMAP 投影输出。

## 知识关联检查

2026-10-23 检查了 UMAP 分组和细胞比例模板。预测标签可着色 query 自身 UMAP、展示样本组成；均为 adaptable，模板不执行映射。没有 direct：模板不读 Seurat，也不产生参考投影。不能把 query UMAP 的标签着色图称为“参考图谱投影图”。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunReferenceMapping`、`RunLabelTransfer`、`RunSeuratMap`、`RunKNNMap`、`RunPCAMap`。投影位置、标签转移与批次整合分别解释；同一细胞同时出现在查询和参考中不是独立验证。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：标签转移分支在隔离 R 环境实际运行；SCP RunSeuratMap 投影分支在 Seurat 5.6 下失败，保留 not_run。

<!-- user:start -->
<!-- user:end -->
