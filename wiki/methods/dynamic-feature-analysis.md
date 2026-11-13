---
type: method
id: dynamic-feature-analysis
title: 拟时序动态特征分析
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
- 轨迹与动态分析
summary: 沿 pseudotime 拟合每个特征的平滑趋势，输出变化显著性、解释度和峰/谷时间。
data_contract:
  input: Seurat 对象 + pseudotime/lineage 列 + 候选 features；pseudotime 必须来自轨迹推断。
  output: 每 feature 的 GAM 表：features、exp_ncells、r.sq、dev.expl、peaktime、valleytime、pvalue、padjust。
implementations:
- id: scp-dynamicfeatures
  title: SCP RunDynamicFeatures 封装
  language: R
  entrypoint: code/analysis.R:run_dynamic_feature_analysis
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - BiocParallel
  - mgcv
  - rlang
  verification: verification/scp-dynamicfeatures-standalone.json
keywords:
- GAM
- mgcv
- pseudotime
- dynamic features
- RunDynamicFeatures
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap
  compatibility: adaptable
  reason: 动态特征值可作为 feature 长表画在 UMAP 上；模板只画值，不拟合 GAM。
  prerequisites:
  - 值与 UMAP 坐标来自同一细胞集合；cell_id 一致。
  - value 的含义/单位明确；无 NA。
  adaptation: 导出 render-umap-feature-long.csv（feature=基因/特征, value=表达或拟合值）。
  evidence:
  - methods/dynamic-feature-analysis.md#输出
  - methods/scp-de-enrichment-dynamic.md#知识关联检查
  - methods/scp-de-enrichment-dynamic.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
  compatibility: adaptable
  reason: 动态特征或 pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。
  prerequisites:
  - 同一 pseudotime/lineage 定义；celltype/group 标签一致。
  - p/mean/SD 若展示，由分析阶段预计算；细胞级 p 不能当样本级推断。
  adaptation: 导出 render-grouped-values.csv（group=cluster/lineage, value=特征值/pseudotime）。
  evidence:
  - methods/dynamic-feature-analysis.md#输出
  - methods/scp-trajectory-velocity.md#知识关联检查
  - methods/scp-trajectory-velocity.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 拟时序动态特征分析

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析、转录组
- 分析用途：轨迹与动态分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/dynamic-feature-analysis/code/analysis.R](/files/wiki/methods/dynamic-feature-analysis/code/analysis.R) · [methods/dynamic-feature-analysis/code/dynamic_native.R](/files/wiki/methods/dynamic-feature-analysis/code/dynamic_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：动态特征值可作为 feature 长表画在 UMAP 上；模板只画值，不拟合 GAM。；前提：值与 UMAP 坐标来自同一细胞集合；cell_id 一致。；value 的含义/单位明确；无 NA。；适配：导出 render-umap-feature-long.csv（feature=基因/特征, value=表达或拟合值）。
    - 关系证据：methods/dynamic-feature-analysis.md#输出；methods/scp-de-enrichment-dynamic.md#知识关联检查；methods/scp-de-enrichment-dynamic.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：动态特征或 pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。；前提：同一 pseudotime/lineage 定义；celltype/group 标签一致。；p/mean/SD 若展示，由分析阶段预计算；细胞级 p 不能当样本级推断。；适配：导出 render-grouped-values.csv（group=cluster/lineage, value=特征值/pseudotime）。
    - 关系证据：methods/dynamic-feature-analysis.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

在轨迹 pseudotime 上拟合每个基因/特征的平滑趋势，找出随轨迹显著变化的特征，输出解释度、p 值、峰/谷时间和拟合曲线。用于描述分化/激活过程中的动态基因，不是因果或时间序列证据。

## 原理与选择

SCP `RunDynamicFeatures` 用 mgcv GAM（默认 `s(x, bs="cs")`）拟合特征随 pseudotime 的变化；计数数据可用负二项等 family，连续/归一化数据用 Gaussian。pseudotime 来自轨迹模型，其不确定性不会自动传入 GAM；特征选择、family、细胞数和光滑度都会影响结果。本页只验证了归一化数据/Gaussian 分支和软件夹具 pseudotime。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDynamicFeatures` 的 mgcv GAM | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | Seurat + pseudotime/lineage + features；GAM 表 | 已封装并 verified（80 细胞 + 夹具 pseudotime，Gaussian） |
| 计数/负二项 family、多个 lineage、自动 HVF | 同上 | counts/多个轨迹 | 未运行；不能因 Gaussian 通过而声称全部支持 |
| 青光眼课题 | `source/` 中未发现独立动态特征脚本 | — | 不声称有独立课题实现 |
## 适用

- 已有轨迹 pseudotime/lineage，且细胞覆盖轨迹主要区间。
- 特征在足够细胞中表达/可测；需要描述趋势和峰/谷时间。
- 结果用独立时间点、marker 或扰动实验验证。

## 不适用

- 没有可靠 pseudotime，或把离散分组当连续轨迹。
- 用 GAM p 值证明因果、真实时间或治疗效应；pseudotime 本身不确定。
- 细胞数很少、特征稀疏时强行拟合复杂曲线；或只看 p 值不看解释度和曲线。

## 输入

Seurat 对象、`lineages`（pseudotime 列名，可多个）、`features`、`slot`、family 参数。每个 feature×lineage 一行结果；pseudotime 必须与细胞身份同源。

## 怎么做

1. 先完成轨迹推断并检查 pseudotime 覆盖和不确定性；不要把 cluster 序号当 pseudotime。
2. 选择候选特征（HVF/先验基因）和 family；计数与归一化数据的 family 不同。
3. 运行 `RunDynamicFeatures`，检查 `pvalue`、`padjust`、`r.sq`、`dev.expl`、峰/谷时间和拟合曲线。
4. 做特征集、平滑度、pseudotime 版本敏感性分析；用独立数据验证关键趋势。
5. 本页未验证计数/负二项分支；需要时另行运行并写收据。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/dynamic-feature-analysis/code/analysis.R:run_dynamic_feature_analysis(srt, bundle = NULL, parameters)`，封装 SCP `RunDynamicFeatures`。2026-10-23 在 `pancreas_sub` 80 细胞、显式 fixture pseudotime、`Gcg`/`Krt19` 上实际调用；`DynamicFeatures` 表与保留的完整 bundle 参考一致（异目录复制、新进程、`BiocParallel::SerialParam()`）。fixture pseudotime 只用于软件验证，不代表真实轨迹；scope 仅此。

计数/负二项、多个 lineage、特征自动选择分支未运行。

## 输出

`result@tools$DynamicFeatures_<lineage>$DynamicFeatures` 为 data.frame，一行一个 feature，含 `features`、`exp_ncells`、`r.sq`、`dev.expl`、`peaktime`、`valleytime`、`pvalue`、`padjust`；同一 tools 还保存 raw/fitted/upr/lwr 矩阵。没有强制 CSV；出图前显式导出长表。

## 知识关联检查

2026-10-23 检查了特征 UMAP 和分组小提琴模板。动态特征值可作 feature 长表或分组分布；均为 adaptable，模板不拟合 GAM 或轨迹。没有 direct；pseudotime/动态特征图不能替代轨迹曲线或因果验证。

复用分组小提琴模板时，当前 spec 要求同时提供 [[interfaces/render-grouped-values]] 与 [[interfaces/render-group-summaries]]。摘要表的均值、SD、p 标签及标注位置须由课题上游明确提供，并核对同源数据、分组及推断层级；本方法不自动生成这些统计或补值。缺少合法摘要时，当前模板不能直接调用；关系仍为 adaptable，未验证真实课题分析到绘图。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunDynamicFeatures`、`RunDynamicEnrichment`。拟时序必须来自已说明的上游；模型 family、counts/归一化层和趋势不确定性分别核对。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：在隔离 R 环境用软件夹具 pseudotime 实际运行并与上游比较；未做真实轨迹或计数模型验证。

## 本机组学课题来源增量（2026-11-02）

DynamicPlotMonocle2 在绘图内重拟合 mgcv GAM，并有 fallback；与 SCP 原生动态入口单列实现来源，未运行、未改算法。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

<!-- user:start -->
<!-- user:end -->
