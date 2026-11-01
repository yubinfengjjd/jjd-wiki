---
type: method
id: cell-type-annotation
title: 细胞类型注释
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
summary: 综合参考标签与 marker 集合给细胞分配类型；SingleR 分支未运行，青光眼 marker 手工注释尚未函数化。
data_contract:
  input: query Seurat；参考标签分支需 reference Seurat + ref_group，marker 分支需预先定义的 marker→类型映射；同物种/同基因标识。
  output: 每细胞 predicted label 与分数（SingleR 成功时），或手工 marker 注释标签表；当前无已验证输出。
implementations:
- id: scp-singler
  title: SCP RunSingleR 分支
  language: R
  entrypoint: code/analysis.R:run_cell_type_annotation
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  - SingleR
  - SingleCellExperiment
  - SummarizedExperiment
  verification: verification/scp-singler-standalone.json
keywords:
- SingleR
- marker
- cell type
- annotation
- 参考注释
- 手工注释
- SCP
- GSE251716
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: 预测细胞类型可作为 UMAP 着色变量；模板不执行注释。
  prerequisites:
  - 预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。
  - 标签不是 cluster 编号；group_levels 按注释顺序给出。
  adaptation: 导出 render-umap-groups.csv（group=predicted celltype）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap
  compatibility: adaptable
  reason: 用 marker 表达检查预测标签是否落在对应群，可复用特征 UMAP 网格；模板不做注释或检验。
  prerequisites:
  - marker 表达长表与 UMAP 坐标同源；cell_id 一致。
  - 每个 feature 至少有一个正表达细胞；目标类型在 group 中存在。
  adaptation: 导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature,
    value）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot
  compatibility: adaptable
  reason: 预测类型的 marker 平均表达/阳性比例可整理成点图，检查注释是否合理；模板不重算统计。
  prerequisites:
  - avg_expression 与 pct_expressed 由表达矩阵按预测标签计算；缩放方式说明。
  - group/feature 顺序由课题给出；target_group 只用于排序。
  adaptation: 导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed,
    target_group）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  compatibility: adaptable
  reason: 按样本/条件统计预测类型比例，检查注释组成；模板不做统计检验。
  prerequisites:
  - 每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。
  - 比例是描述性；组间差异不能由该图直接推断。
  adaptation: 导出 render-cell-proportions.csv（group, celltype, proportion）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 细胞类型注释

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
- 代码模板：[methods/cell-type-annotation/code/analysis.R](/files/wiki/methods/cell-type-annotation/code/analysis.R) · [methods/cell-type-annotation/code/annotation_native.R](/files/wiki/methods/cell-type-annotation/code/annotation_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：预测细胞类型可作为 UMAP 着色变量；模板不执行注释。；前提：预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。；标签不是 cluster 编号；group_levels 按注释顺序给出。；适配：导出 render-umap-groups.csv（group=predicted celltype）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：用 marker 表达检查预测标签是否落在对应群，可复用特征 UMAP 网格；模板不做注释或检验。；前提：marker 表达长表与 UMAP 坐标同源；cell_id 一致。；每个 feature 至少有一个正表达细胞；目标类型在 group 中存在。；适配：导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature, value）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：预测类型的 marker 平均表达/阳性比例可整理成点图，检查注释是否合理；模板不重算统计。；前提：avg_expression 与 pct_expressed 由表达矩阵按预测标签计算；缩放方式说明。；group/feature 顺序由课题给出；target_group 只用于排序。；适配：导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed, target_group）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/spec.json；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本/条件统计预测类型比例，检查注释组成；模板不做统计检验。；前提：每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。；比例是描述性；组间差异不能由该图直接推断。；适配：导出 render-cell-proportions.csv（group, celltype, proportion）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

把查询数据集的细胞分配到已知或预先定义的细胞类型。可由参考数据集的标签学习（SingleR 等），也可由作者预先定义的 marker→类型映射做手工注释；两条路线都需用 marker 表达、组成和独立方法复核，不能把标签当已验证的生物学身份。

## 原理与选择

参考标签路线用参考数据集的差异基因/标签给 query 打分（SingleR），要求 query/ref 组织、物种、平台和基因标识可比。Marker 路线用一组先验 marker 检查 cluster/细胞的表达并人工指定类型，依赖 marker 特异性和作者判断；它不需要参考数据，但不能自动发现 novel 类型。Seurat label transfer 属于 reference-mapping 家族，不应与 SingleR 或手工注释混为同一算法。

## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 参考标签注释：SCP `RunSingleR`（cell/cluster level） | [[methods/scp-annotation-projection]]；`SCP-local/R/SCP-cell_annotation.R` | query/reference Seurat + ref 标签；预测标签/分数 | 已封装；SingleR 缺失，`not_run` |
| 青光眼 marker 手工注释 | [[methods/scrna-marker-annotation]]；`source/annotation.R` | 预处理对象、作者 marker 列表/`celltype_map`；手动标签 | 原脚本硬编码 marker/映射，未函数化、未验证；不是 SingleR 替代品 |
| 参考图谱映射（Seurat 标签转移） | [[methods/reference-mapping]] | query/reference + 参考标签；预测/分数 | 属参考映射家族；本页不重复实现，也不把它当 SingleR |

## 适用

- 参考路线：有匹配组织/物种、标签可靠的 reference，且 query/ref 共享足够基因。
- Marker 路线：有组织/状态特异的 marker 列表和可解释的 cluster；作者能说明 marker→类型的依据。
- 两条路线都用 marker、组成、独立方法或人工复核交叉检查；novel 类型允许保留“未定”。

## 不适用

- SingleR 没有合适 reference 时不适用；这不等于“无参考就不能注释”，可改用有依据的 marker 路线，但必须明确其主观性和局限。
- 参考/查询组织、物种、平台差异大，或参考标签本身不可靠；novel 类型可能被强行分配到最近标签。
- 只靠 cluster 编号或单个 marker 名字猜类型；把预测标签或手工标签当已验证的生物学身份、分类概率或因果结论。

## 输入

参考路线：query/reference Seurat、`ref_group` 标签列、assay；marker 路线：query Seurat、命名 marker 列表或 `celltype_map`、cluster/细胞标签。两条路线都需同物种、同基因标识和可追踪的细胞身份。

## 怎么做

1. 先选路线：有可靠 reference 时可用 SingleR；没有 reference 但有组织特异 marker 时可用 marker 路线；两者都不可行时不要强行命名。
2. 参考路线：核对参考来源/标签/物种/平台，检查基因交集和数据尺度，运行 SingleR，保留每细胞/每 cluster 分数和 pruned label。
3. Marker 路线：先固定 marker 列表和类型映射，检查 marker 在 cluster/细胞中的表达与特异性；按预先规则分配，记录人工判断和不确定项。
4. 用 UMAP、marker 点图、样本组成和独立方法复核；低置信度/混合群保留“未定/待定”。
5. 注释结果再进入图样；不要让注释反过来证明聚类正确，也不要把手工注释写成自动算法验证。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

- 参考路线：`methods/cell-type-annotation/code/analysis.R:run_cell_type_annotation(srt_query, srt_ref, bundle = NULL, parameters)` 封装 SCP `RunSingleR`。本机 R 库没有 SingleR，实际错误为 `Missing R dependency: SingleR; automatic installation is disabled`，状态 `not_run`。
- Marker 路线：青光眼 `annotation.R` 是硬编码 marker 列表和 `celltype_map` 的课题脚本，保留在 [[methods/scrna-marker-annotation]] 的 `source/`；本轮未函数化、未验证，不提供可执行入口。
- 参考图谱映射见 [[methods/reference-mapping]]；它是另一家族，不因本页 SingleR 未运行而自动可用。

## 输出

参考路线成功时返回 SCP 上游对象/列表，含 `singler_annotation`、`singler_score` 等；marker 路线应输出 cell/cluster、label、依据 marker 和不确定标记。当前没有已验证输出；不得把参考标签或手工标签直接复制成“自动注释结果”。

## 知识关联检查

2026-10-23 检查了 UMAP 分组、特征 UMAP、气泡点图和细胞比例模板。预测标签或手工标签都可着色 UMAP、检查 marker、展示组成；均为 adaptable，模板不执行注释。没有 direct：模板不读 Seurat 注释结果。来源页 [[methods/scrna-marker-annotation]] 提供 marker 手工注释原始脚本，[[methods/scp-annotation-projection]] 提供 SCP SingleR/投影来源；双向链接已建立。注释与参考映射的区别见 [[methods/reference-mapping]]。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunSingleR`、`RunCellTypist`、`RunScmap`、`RunKNNPredict`、`RunSciBet`。核对参考物种、基因 ID、标签与查询/参考独立性；相似度不是校准概率。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：核对 SCP RunSingleR、青光眼 marker 注释脚本与本机依赖；SingleR 缺失、marker 脚本未函数化，均未写成已验证实现。

<!-- user:start -->
<!-- user:end -->
