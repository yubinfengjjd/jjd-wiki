---
type: method
id: batch-integration
title: 单细胞批次整合
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
- 整合与批次校正
summary: 在保留生物差异的前提下对齐样本/技术批次，产出整合嵌入与聚类，供跨样本比较。
data_contract:
  input: 含明确 batch 列的 Seurat 原始 counts（batch 是样本/技术批次，不是生物学分组）。
  output: 整合后的 Seurat 对象（Seuratpca、SeuratUMAP2D、Seuratclusters）或每细胞嵌入表。
implementations:
- id: scp-seurat
  title: SCP Seurat_integrate 锚点分支
  language: R
  entrypoint: code/analysis.R:run_seurat_integration
  dependencies: &id001
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  - data.table
  - uwot
  - intrinsicDimension
  - proxyC
  - dplyr
  - future
  - future.apply
  verification: verification/scp-seurat-standalone.json
- id: scp-harmony
  title: SCP Harmony_integrate 分支
  language: R
  entrypoint: code/analysis.R:run_batch_integration
  dependencies: *id001
  verification: verification/scp-harmony-standalone.json
keywords:
- batch
- integration
- Seurat
- Harmony
- 锚点
- 批次校正
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: 整合后的嵌入可按 batch 或 celltype 着色，复用现有 UMAP 单 panel；模板不做整合。
  prerequisites:
  - 坐标与 group 来自同一整合嵌入；cell_id 唯一；坐标无 NA。
  - group 明确为 batch 或 celltype；group_levels 由课题给出。
  adaptation: 导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）；模板不读 RDS。
  evidence:
  - methods/batch-integration.md#输出
  - methods/scp-integration.md#知识关联检查
  - methods/scp-integration.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  compatibility: adaptable
  reason: 按 batch/样本统计细胞类型比例，可检查整合前后组成是否被过度改变；模板不做统计检验。
  prerequisites:
  - 每个 group 的比例归一化到 1；group 为 batch/样本，celltype 为注释类型。
  - 比例是描述性；组间差异不能由该图直接推断。
  adaptation: 导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。
  evidence:
  - methods/batch-integration.md#输出
  - methods/scp-integration.md#知识关联检查
  - methods/scp-integration.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 单细胞批次整合

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析
- 分析用途：整合与批次校正
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/batch-integration/code/analysis.R](/files/wiki/methods/batch-integration/code/analysis.R) · [methods/batch-integration/code/integration_native.R](/files/wiki/methods/batch-integration/code/integration_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：整合后的嵌入可按 batch 或 celltype 着色，复用现有 UMAP 单 panel；模板不做整合。；前提：坐标与 group 来自同一整合嵌入；cell_id 唯一；坐标无 NA。；group 明确为 batch 或 celltype；group_levels 由课题给出。；适配：导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）；模板不读 RDS。
    - 关系证据：methods/batch-integration.md#输出；methods/scp-integration.md#知识关联检查；methods/scp-integration.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按 batch/样本统计细胞类型比例，可检查整合前后组成是否被过度改变；模板不做统计检验。；前提：每个 group 的比例归一化到 1；group 为 batch/样本，celltype 为注释类型。；比例是描述性；组间差异不能由该图直接推断。；适配：导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。
    - 关系证据：methods/batch-integration.md#输出；methods/scp-integration.md#知识关联检查；methods/scp-integration.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

把来自不同样本、测序批次或技术平台的细胞放进同一个嵌入，减少批次带来的分离，同时保留真实的细胞类型和状态差异。输出是整合对象、嵌入和聚类，供跨样本比较与出图。

## 原理与选择

Seurat 锚点法先找跨批次相互最近的细胞对，再校正表达；Harmony 在 PCA 空间迭代校正。两者都假设批次间存在可对齐的共享细胞类型；如果批次与疾病/处理完全混杂，整合不能替代研究设计。SCP `Integration_SCP` 还提供 scVI、MNN、fastMNN、Scanorama、BBKNN、CSS、LIGER、Conos、ComBat 等分支；本页只验证 Seurat 分支，Harmony 分支因缺包未运行。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `Seurat_integrate` 锚点法 | [[methods/scp-integration]]；`SCP-local/R/SCP-workflow.R` | 含 batch 列的 counts；整合嵌入与聚类 | 已封装并 verified（120 细胞/2 批） |
| SCP `Harmony_integrate` | 同上 | PCA + batch；Harmony 嵌入 | 已封装；harmony 缺失，`not_run` |
| 青光眼 `preprocess.R` 的 Harmony | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | Seurat 流程 + Harmony | 原脚本未函数化；未在本库验证 |
## 适用

- 多个样本/技术批次，存在重叠细胞类型，且 batch 列与生物学分组可区分。
- 需要联合聚类、跨样本 UMAP 或比较细胞类型比例。
- 有明确的批次定义和足够的跨批次锚点。

## 不适用

- 只有单一批次，或 batch 与疾病/处理完全重合：整合会掩盖真实差异。
- 细胞类型完全不重叠、物种不同或基因标识不可比时，锚点法不适用。
- 不能用整合后的“混合得更好”证明生物学差异消失或数据质量更高。

## 输入

一个带 `batch` 元数据列的 Seurat 对象（原始 counts），或按批次拆分的对象列表；`batch` 必须显式给出，不能从文件名猜。每个细胞一行嵌入，需保留原始样本/批次身份。

## 怎么做

1. 明确 batch 是技术批次还是样本；检查 batch 与分组是否完全混杂。
2. 按 SCP/Seurat 分支做归一化、HVF、锚点、整合、PCA/UMAP；参数（HVF 数、dims、k.weight）显式记录。
3. 同时看整合前后 batch 混合、细胞类型 marker 是否保留、比例是否被过度改变。
4. 与未整合/其他方法做敏感性比较；不能只挑混合最好的一张图。
5. Harmony、scVI 等分支只有在依赖可用且实际运行后才可声称支持。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

- Seurat 分支：`methods/batch-integration/code/analysis.R:run_seurat_integration(srt, batch, bundle = NULL, parameters)`，封装 SCP `Seurat_integrate`。2026-10-23 在 `pancreas_sub` 120 细胞、两个显式批次、300 HVF、20 PC、`k.weight=30` 上实际调用；封装与上游 UMAP 一致，输出 `Seuratpca`、`SeuratUMAP2D`、`Seuratclusters`。scope 仅软件夹具。
- Harmony 分支：同文件 `run_batch_integration(srt, bundle = NULL, parameters)`，封装 `Harmony_integrate`；本机无 harmony，`not_run`，精确错误 `Missing R dependency: harmony; automatic installation is disabled`。

两个分支独立验证；Seurat 分支通过不批准 Harmony 分支。

## 输出

Seurat 分支返回 `list(result=Seurat, diagnostics=...)`；`result` 含整合 assay、`Seuratpca`、`SeuratUMAP2D`、`Seuratclusters`。可另导出每细胞 `cell_id, batch, umap_1, umap_2` 供模板使用。Harmony 分支当前无输出。

## 知识关联检查

2026-10-23 检查了 UMAP 分组图与细胞比例图。整合嵌入可按 batch/celltype 着色，比例图可检查组成变化；两者都是 adaptable，模板不执行整合。没有 direct。不能把“整合后 UMAP 混合”当作批次校正成功的唯一证据，仍需 marker 与比例检查。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunIntegration`、`Seurat_integrate`、`Harmony_integrate`、`WNN_integrate`、`GLUE_integrate`。单模态批次校正与 RNA/ATAC 多模态整合的输入、目标不同；每个后端另验。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：Seurat 分支在隔离 R 环境实际运行并与上游比较；Harmony 分支缺包保留 not_run，未安装。

<!-- user:start -->
<!-- user:end -->
