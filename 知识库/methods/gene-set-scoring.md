---
type: method
id: gene-set-scoring
title: 基因集与通路签名打分
status: ready
tags:
- 单细胞分析
- 转录组
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
- 差异与功能分析
summary: 按命名基因集给每个细胞打相对签名分数，用于描述状态差异；分数不是通路活性或富集显著性。
data_contract:
  input: Seurat 对象 + 命名基因集列表；同一数据集、同一 assay/slot 内比较。
  output: 每细胞×基因集的相对分数（Seurat metadata）或长表；不产出富集 p 值。
implementations:
- id: scp-cellscoring
  title: SCP CellScoring 的 Seurat/AddModuleScore 分支
  language: R
  entrypoint: code/analysis.R:run_gene_set_scoring
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - BiocParallel
  - rlang
  - ggplot2
  verification: verification/scp-cellscoring-standalone.json
keywords:
- AddModuleScore
- AUCell
- UCell
- ssGSEA
- singscore
- pathway score
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
  compatibility: adaptable
  reason: 通路签名分数按细胞类型/组展示分布，可复用小提琴模板；模板不重算分数或检验。
  prerequisites:
  - 同一 pathway 定义和单位；celltype/group 标签一致。
  - p/mean/SD 由分析阶段预计算并说明来源；细胞水平 p 仅作描述，不能当样本级推断。
  adaptation: 导出 render-grouped-values.csv 和可选的 render-group-summaries.csv；细胞级 p 只作描述。
  evidence:
  - methods/gene-set-scoring.md#输出
  - methods/scrna-pathway-signature-ensemble.md#知识关联检查
  - methods/scrna-pathway-signature-ensemble.md#输出
  - layouts/2026-10-22-glaucoma-scrna__fig06-pathway-violin.md#适用
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 基因集与通路签名打分

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析、转录组
- 分析用途：差异与功能分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/gene-set-scoring/code/analysis.R](/files/wiki/methods/gene-set-scoring/code/analysis.R) · [methods/gene-set-scoring/code/scoring_native.R](/files/wiki/methods/gene-set-scoring/code/scoring_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：通路签名分数按细胞类型/组展示分布，可复用小提琴模板；模板不重算分数或检验。；前提：同一 pathway 定义和单位；celltype/group 标签一致。；p/mean/SD 由分析阶段预计算并说明来源；细胞水平 p 仅作描述，不能当样本级推断。；适配：导出 render-grouped-values.csv 和可选的 render-group-summaries.csv；细胞级 p 只作描述。
    - 关系证据：methods/gene-set-scoring.md#输出；methods/scrna-pathway-signature-ensemble.md#知识关联检查；methods/scrna-pathway-signature-ensemble.md#输出；layouts/2026-10-22-glaucoma-scrna__fig06-pathway-violin.md#适用；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

用一组先验基因给每个细胞计算相对签名分数，描述细胞在某个通路/状态上的相对高低。常用于在 UMAP 或分组分布中查看候选签名，不用于证明通路被激活或组间有统计差异。

## 原理与选择

Seurat `AddModuleScore` 用同表达量分箱的对照基因校正背景；AUCell/UCell/ssGSEA/singscore 是其他打分策略。不同方法的尺度不可直接比较，同一方法跨数据集也受测序深度和基因集覆盖影响。SCP `CellScoring` 支持 Seurat、AUCell、UCell 分支；本页只验证 Seurat 分支，AUCell/UCell 因缺包未运行。原始课题脚本把五种分数直接相加，是本课题的特定组合，不是通用标准实现，本页不复制该求和逻辑。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `CellScoring` 的 Seurat/AddModuleScore 分支 | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | Seurat + 命名基因集；每细胞分数 | 已封装并 verified（显式 `name="X"`） |
| AUCell / UCell 分支 | 同上 | 排序或签名分数 | 未运行；依赖缺失 |
| 青光眼 `score_pathway_signatures.R` 的五种分数相加 | [[methods/scrna-pathway-signature-ensemble]]；`source/score_pathway_signatures.R` | AddModuleScore/AUCell/ssGSEA/UCell/singscore 求和 | 课题特定组合，不是通用标准；原脚本未函数化、未验证 |
## 适用

- 有明确的基因集定义、基因标识与表达矩阵；同一数据集内做相对比较。
- 用于探索性可视化、聚类注释辅助或生成假设。
- 需要比较多个签名时，使用同一打分方法和同一背景。

## 不适用

- 把分数当绝对通路活性、因果机制或临床生物标志物。
- 跨数据集/平台直接比较分数绝对值；或把不同打分方法的分数相加/平均而不说明。
- 基因集与细胞类型 marker 完全重叠时，把分数差异当作独立通路证据。

## 输入

Seurat 对象、命名基因集列表（list）、`assay`/`slot`；基因集内基因需与对象基因标识一致。输出每行一个细胞×基因集；细胞身份、基因集版本和打分方法必须保留。

## 怎么做

1. 明确基因集来源、版本和基因标识；检查基因在对象中的覆盖率。
2. 选择一种打分方法，固定 assay/slot 和参数；本页 Seurat 分支调用时显式 `name="X"`，避免上游空 name 在 Seurat 5 下产生列名不匹配。
3. 运行后检查分数分布、与 marker 表达的一致性、批次/测序深度影响。
4. 组间比较优先在样本级汇总或使用适当模型；细胞级检验只作描述。
5. 不把五种分数相加的课题脚本冒充通用实现；需要组合时单独说明权重与验证。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/gene-set-scoring/code/analysis.R:run_gene_set_scoring(srt, bundle = NULL, parameters)`，封装 SCP `CellScoring` 的 Seurat 分支。2026-10-23 在 `pancreas_sub` 80 细胞、两个命名基因集上实际调用，分数与保留的完整 bundle 参考一致（异目录复制、新进程、`BiocParallel::SerialParam()`）；调用参数含 `name="X"`，这是对上游空 name 列名缺陷的显式适配，不改变打分算法。

AUCell、UCell 分支未运行（本机缺包）；原始课题的五种分数求和脚本保留在来源页，不作为本页通用实现。

## 输出

返回 Seurat 对象；`result@meta.data` 增加 `X_<基因集>` 分数列，一行一个细胞。可整理为长表 `cell_id, set, score` 供小提琴/热图模板；本页不强制 CSV。

## 知识关联检查

2026-10-23 检查了分组小提琴模板。签名分数可按 celltype/group 展示分布，关系为 adaptable；模板不重算分数或检验。没有 direct：模板不读 Seurat metadata，需先导出 `render-grouped-values`。细胞级 p 值不能当样本级推断，图注需说明。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`CellScoring`、`RunGSVA`、`RunMetabolism`。各打分方法的量纲和假设不同，不能将分数相加或直接作相同尺度比较。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：在隔离 R 环境用两个命名基因集实际运行 Seurat 打分并与上游比较；AUCell/UCell 未运行，未安装。

<!-- user:start -->
<!-- user:end -->
