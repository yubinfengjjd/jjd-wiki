---
type: method
id: trajectory-inference
title: 拟时序与轨迹推断
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
- 轨迹与动态分析
summary: 在低维嵌入上连接细胞群，推断 lineage 与 pseudotime；轨迹是模型假设，不是真实时间。
data_contract:
  input: 共同前提是表达矩阵/counts、细胞元数据、稳定低维嵌入、分组/状态标签和明确的根或起点。Slingshot 入口接受 Seurat 对象；Monocle2/3
    分析核心直接接受表达矩阵 + 元数据（Monocle3 还要求已有的、细胞顺序一致的 UMAP/嵌入），Seurat 适配入口接受 Seurat。cluster/State
    是轨迹状态，不是细胞类型断言。
  output: 共同语义是每细胞 pseudotime/State 与轨迹对象，但各实现返回结构不同：Slingshot 写 Seurat metadata（Lineage/BranchID）和
    tools 曲线；Monocle2/3 core 返回 CDS、State、Pseudotime 和嵌入，Seurat 适配入口再写回 metadata。不能用一张标准表冒充所有实现。
implementations:
- id: scp-slingshot
  title: SCP RunSlingshot 封装
  language: R
  entrypoint: code/analysis.R:run_trajectory_inference
  dependencies:
  - slingshot
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  verification: verification/scp-slingshot-standalone.json
- id: scp-monocle2
  title: Monocle2 Seurat 适配分支
  language: R
  entrypoint: code/monocle2.R:run_trajectory_monocle2
  dependencies:
  - monocle
  - DDRTree
  - VGAM
  - BiocGenerics
  - Biobase
  - igraph
  - Matrix
  - rlang
  - Seurat
  - SeuratObject
  verification: verification/scp-monocle2-standalone.json
- id: scp-monocle3
  title: Monocle3 Seurat 适配分支
  language: R
  entrypoint: code/monocle3.R:run_trajectory_monocle3
  dependencies:
  - monocle3
  - SingleCellExperiment
  - SummarizedExperiment
  - igraph
  - Matrix
  - Seurat
  - SeuratObject
  verification: verification/scp-monocle3-standalone.json
- id: scp-monocle2-core
  title: Monocle2 分析核心（counts + 元数据）
  language: R
  entrypoint: code/monocle2_core.R:run_monocle2_core
  dependencies:
  - monocle
  - DDRTree
  - VGAM
  - BiocGenerics
  - Biobase
  - igraph
  - Matrix
  - rlang
  verification: verification/scp-monocle2-core-standalone.json
- id: scp-monocle3-core
  title: Monocle3 分析核心（counts + 元数据）
  language: R
  entrypoint: code/monocle3_core.R:run_monocle3_core
  dependencies:
  - monocle3
  - SingleCellExperiment
  - SummarizedExperiment
  - igraph
  - Matrix
  verification: verification/scp-monocle3-core-standalone.json
keywords:
- Slingshot
- pseudotime
- lineage
- Monocle
- PAGA
- 轨迹
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: 轨迹分组/lineage 标签可作为 UMAP 着色变量；现有模板不画 lineage 曲线。
  prerequisites:
  - UMAP 坐标与 group 来自同一对象；cell_id 一致。
  - group 为 cluster/lineage 分组；group_levels 由课题给出。
  adaptation: 导出 render-umap-groups.csv（group=cluster/lineage）；曲线需另建模板。
  evidence:
  - methods/trajectory-inference.md#输出
  - methods/scp-trajectory-velocity.md#知识关联检查
  - methods/scp-trajectory-velocity.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap
  compatibility: adaptable
  reason: pseudotime 可作为 feature 长表画在 UMAP 上；模板不拟合轨迹。
  prerequisites:
  - 值与 UMAP 坐标来自同一细胞集合；cell_id 一致。
  - value 的含义/单位明确；无 NA。
  adaptation: 导出 render-umap-feature-long.csv（feature=pseudotime, value=Lineage1）。
  evidence:
  - methods/trajectory-inference.md#输出
  - methods/scp-trajectory-velocity.md#知识关联检查
  - methods/scp-trajectory-velocity.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
  compatibility: adaptable
  reason: pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。
  prerequisites:
  - 同一 pseudotime/lineage 定义；celltype/group 标签一致。
  - p/mean/SD 若展示，由分析阶段预计算；细胞级 p 不能当样本级推断。
  adaptation: 导出 render-grouped-values.csv（celltype/group, value=pseudotime）。
  evidence:
  - methods/trajectory-inference.md#输出
  - methods/scp-trajectory-velocity.md#知识关联检查
  - methods/scp-trajectory-velocity.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 拟时序与轨迹推断

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析
- 分析用途：轨迹与动态分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/trajectory-inference/code/analysis.R](/files/wiki/methods/trajectory-inference/code/analysis.R) · [methods/trajectory-inference/code/data/palette_list.rda](/files/wiki/methods/trajectory-inference/code/data/palette_list.rda) · [methods/trajectory-inference/code/monocle2.R](/files/wiki/methods/trajectory-inference/code/monocle2.R) · [methods/trajectory-inference/code/monocle2_core.R](/files/wiki/methods/trajectory-inference/code/monocle2_core.R) · [methods/trajectory-inference/code/monocle2_core_helpers.R](/files/wiki/methods/trajectory-inference/code/monocle2_core_helpers.R) · [methods/trajectory-inference/code/monocle3.R](/files/wiki/methods/trajectory-inference/code/monocle3.R) · [methods/trajectory-inference/code/monocle3_core.R](/files/wiki/methods/trajectory-inference/code/monocle3_core.R) · [methods/trajectory-inference/code/slingshot_native.R](/files/wiki/methods/trajectory-inference/code/slingshot_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：轨迹分组/lineage 标签可作为 UMAP 着色变量；现有模板不画 lineage 曲线。；前提：UMAP 坐标与 group 来自同一对象；cell_id 一致。；group 为 cluster/lineage 分组；group_levels 由课题给出。；适配：导出 render-umap-groups.csv（group=cluster/lineage）；曲线需另建模板。
    - 关系证据：methods/trajectory-inference.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：pseudotime 可作为 feature 长表画在 UMAP 上；模板不拟合轨迹。；前提：值与 UMAP 坐标来自同一细胞集合；cell_id 一致。；value 的含义/单位明确；无 NA。；适配：导出 render-umap-feature-long.csv（feature=pseudotime, value=Lineage1）。
    - 关系证据：methods/trajectory-inference.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。；前提：同一 pseudotime/lineage 定义；celltype/group 标签一致。；p/mean/SD 若展示，由分析阶段预计算；细胞级 p 不能当样本级推断。；适配：导出 render-grouped-values.csv（celltype/group, value=pseudotime）。
    - 关系证据：methods/trajectory-inference.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

在细胞群之间建立有序轨迹，给每个细胞一个 lineage 上的 pseudotime 和分支标签，用于描述分化、激活或损伤修复等连续过程。输出是模型推断的顺序，不是采样时间。

## 原理与选择

Slingshot 在嵌入空间对 cluster 建最小生成树，再拟合 lineage 曲线；Monocle2/3、PAGA、Palantir、WOT 等是其他实现，假设和输入不同。SCP `RunSlingshot` 封装 slingshot，需指定 `group.by`、`reduction`、`dims` 和可选起点/终点。轨迹方向依赖起点和 cluster 结构，换嵌入/分辨率可能改变结论。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunSlingshot` | [[methods/scp-trajectory-velocity]]；`SCP-local/R/SCP-analysis.R` | 嵌入 + cluster + 起点/终点；lineage/pseudotime | 已封装并 verified（80 细胞，CellType 分组） |
| Monocle2 / Monocle3 / PAGA / Palantir / WOT | 同上 | 不同轨迹模型与输入 | Monocle2/3 已从固定源码提取核心与 Seurat 适配入口，本机缺包 `not_run`；PAGA/Palantir/WOT 未实现。不能与 Slingshot 互换 |
| 青光眼课题 | `source/` 中未发现独立轨迹脚本 | — | 不声称有独立课题实现 |
## 适用

- 有连续过程假设、相对稳定的嵌入和 cluster，且 cluster 能覆盖轨迹上的状态。
- 起点/终点有生物学依据或明确说明是探索性选择。
- 用于生成 pseudotime 供动态特征分析，而不是单独证明分化方向。

## 不适用

- 离散细胞类型、没有连续过程假设，或 cluster 主要由批次/技术因素驱动。
- 把 pseudotime 当真实时间、把 lineage 当因果谱系；没有谱系追踪时不能证明祖先关系。
- 只选一个起点/嵌入报告结果，不做敏感性分析。

## 输入

Slingshot 入口：Seurat 对象、`group.by` cluster 列、`reduction`（如 UMAP/PCA）、`dims`、可选 `start`/`end`。Monocle2/3 分析核心：表达矩阵/counts + 细胞元数据；Monocle2 还要 features 和最终 `root_state`，Monocle3 还要已有的、与细胞顺序一致的 UMAP/嵌入、`use_partition` 和 `root_pr_nodes`/`root_cells`；Seurat 适配入口在课题中从 Seurat 提取这些输入。每个细胞一行 pseudotime；cluster/State、嵌入和根必须同源。

## 怎么做

1. 先确定轨迹假设和 cluster 分辨率；检查嵌入是否被批次主导。
2. 指定起点/终点（或有依据地探索），运行 Slingshot；保留 lineage 曲线和 BranchID。
3. 检查 pseudotime 与关键 marker 的单调性、lineage 是否覆盖预期状态；换嵌入/分辨率做敏感性分析。
4. 轨迹结果再交给动态特征分析；不要用 pseudotime 反向证明 cluster 注释正确。
5. Monocle2/3 已提取分析核心和 Seurat 适配入口；绘图函数未注册为分析实现，不计入 verified/推荐门槛。本机缺 `monocle`/`monocle3`，保持精确 `not_run`。PAGA 等分支未实现。不能因 Slingshot 通过就声称支持其他轨迹模型。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/trajectory-inference/code/analysis.R:run_trajectory_inference(srt, bundle = NULL, parameters)`，封装 SCP `RunSlingshot`。2026-10-23 在 `pancreas_sub` 80 细胞、CellType 分组、UMAP 1:2 上实际调用；封装与上游 `Lineage1`、`BranchID` 一致。scope 仅软件调用，起点和 cluster 结构是示例，不代表真实轨迹。

Monocle2/Monocle3 已从固定版本 SCP 原函数 `RunMonocle2`/`RunMonocle3` 拆分并提取，未新写轨迹算法：`code/monocle2_core.R`/`monocle3_core.R` 是分析核心（counts/表达矩阵 + 元数据，不依赖 Seurat 或绘图），`code/monocle2.R`/`monocle3.R` 是 Seurat 适配入口（提取 counts/嵌入、写回 State/Pseudotime）。核心保留原来的两步排序：第一次按原版无根状态参数（`root_state=NULL`）做初步排序并产生 State，第二次才用调用者显式给出的 `root_state` 做最终定根；最终根不得通过 `select.list` 或静默猜测。初步排序的随机性/seed 保留，不能把初步图当作作者最终生物学根选择。Monocle3 核心要求已有的、与细胞顺序一致的 UMAP/嵌入，不自行补降维。绘图不注册为本页分析实现；需要时在课题中使用 Monocle 官方绘图或已有技术资料，不把绘图通过当作轨迹分析通过。本机缺 `monocle`/`monocle3`，独立复制后的新进程在包检查处准确 `not_run`；PAGA 等未入库分支仍未运行。

## 输出

Slingshot：Seurat metadata 增加 `Lineage1`（pseudotime）和 `BranchID`，`result@tools` 保存曲线。Monocle2/3 core：返回 `cds`、`State`、`Pseudotime` 和嵌入；Seurat 适配入口再写回 `Monocle2/3_State`、`Monocle2/3_Pseudotime` 等 metadata 和 tools。可导出 `cell_id, pseudotime, branch/state, umap_1, umap_2` 供模板；不同实现的列名和对象不同，本页不强制 CSV，也不把 CDS 输出冒充标准表。

## 知识关联检查

2026-10-23 检查了 UMAP 分组、特征 UMAP 和分组小提琴模板。cluster/lineage 可着色 UMAP，pseudotime 可作 feature 或分组分布；均为 adaptable。现有模板不画 lineage 曲线/箭头，不能把普通 UMAP 分组图当作轨迹图。动态特征分析见 [[methods/dynamic-feature-analysis]]。

复用分组小提琴模板时，当前 spec 要求同时提供 [[interfaces/render-grouped-values]] 与 [[interfaces/render-group-summaries]]。摘要表的均值、SD、p 标签及标注位置须由课题上游明确提供，并核对同源数据、分组及推断层级；本方法不自动生成这些统计或补值。缺少合法摘要时，当前模板不能直接调用；关系仍为 adaptable，未验证真实课题分析到绘图。

## 使用记录

2026-10-23：在隔离 R 环境用 `pancreas_sub` 80 细胞实际运行 Slingshot 并与上游比较；未做真实轨迹方向论证。

<!-- user:start -->
<!-- user:end -->
