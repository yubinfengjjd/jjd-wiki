---
type: method
id: scp-trajectory-velocity
title: 单细胞轨迹推断与 RNA 速度
status: ready
tags:
- 单细胞分析
keywords:
- SCP
- Seurat
- RunSlingshot
- RunMonocle2
- RunMonocle3
- RunPAGA
- RunSCVELO
- RunPalantir
- RunWOT
- RNA velocity
- pseudotime
- lineage
- PAGA
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
summary: SCP 轨迹与 RNA 速度的原始脚本和作者实现记录；分析问题见轨迹、速度和动态特征家族。
data_contract:
  input: Seurat 对象、UMAP、cluster/pseudotime 及 spliced/unspliced layers；原脚本参数在 source/
    中。
  output: SCP 轨迹/速度对象与结果；本页不重新运行。
---
# 单细胞轨迹推断与 RNA 速度

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
> 当前分析问题见：[[methods/trajectory-inference|拟时序与轨迹推断]]、[[methods/rna-velocity|RNA 速度分析]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用 SCP 的轨迹/速度函数推断细胞状态转换、pseudotime 和 lineage，或估计 RNA 速度：

- `RunSlingshot()`：在降维空间上跑 Slingshot，产出 lineage 和 pseudotime。
- `RunMonocle2()` / `RunMonocle3()`：DDRTree/Monocle3 轨迹、State/partition/cluster 和 pseudotime。
- `RunPAGA()`：Python scanpy PAGA 图、connectivities 和可选 pseudotime。
- `RunSCVELO()`：Python scVelo RNA 速度（需要 spliced/unspliced）。
- `RunPalantir()`：Palantir pseudotime 和命运概率。
- `RunWOT()`：WOT 时间序列 transport map（需要时间字段）。
- `RunCellRank()` 在源码中存在但当前 NAMESPACE 未导出，不在本页主范围。

## 原始实现与家族范围

来源是 SCP v0.5.6 的 `R/SCP-analysis.R`。家族限定为“Seurat 对象上的轨迹/速度推断”：

- R 侧：Slingshot、Monocle2/3；依赖 `slingshot`、`monocle`、`DDRTree`、`destiny` 等。
- Python 侧：PAGA、scVelo、Palantir、WOT；通过 reticulate 调用 `inst/python/SCP_analysis.py`，需要 scanpy/scvelo/palantir/wot/cellrank 等。
- 轨迹结果以 metadata 列、reduction、`srt@tools` 或 `srt@misc` 返回；具体名称随函数不同。
- 速度需要 spliced/unspliced 层；没有这两层时不能估计。

代码已本地化到 `code/SCP-local/R/SCP-analysis.R`，Python 文件在 `code/SCP-local/python/`；补丁见 [[methods/scp-local-source|SCP 源码本地化]]。

## 适用

- Seurat 对象已有聚类/细胞类型、降维（PCA/UMAP）和足够的细胞数；lineage 的起点/终点可定义或可检验。
- Slingshot/Monocle 适合有连续结构的发育/分化数据；PAGA 适合离散群之间的连接；Palantir 适合有早期细胞和终末群的命运分析。
- scVelo/WOT 需要 spliced/unspliced 或时间序列数据；普通 10x counts 不能直接做速度。
- 需要把 pseudotime/lineage 作为下游动态特征（`RunDynamicFeatures()`）的输入。

## 不适用

- 不能把 pseudotime 当真实时间或因果顺序；它只是沿推断轨迹的排序。
- 不能把 lineage 曲线当证实的分化路径；需要 marker、独立样本或实验验证。
- 不能在离散/无连续结构的数据上强行拟合轨迹；先检查是否值得做。
- scVelo 需要 spliced/unspliced；没有 velocity 层时不能运行。WOT 需要时间字段和足够时间点。
- PAGA/Palantir/WOT 依赖 Python 环境；本地化包只改路径，不创建环境。
- 轨迹对降维、聚类分辨率、起点/终点和参数敏感；换参数可能得到不同拓扑。
- 2026-10-22 历史记录：当时未在安装 Seurat/SCP/Python 依赖的环境中运行；拓扑、pseudotime 和速度未验证。2026-10-23 当前规范家族：Slingshot `verified`；scVelo `not_run`（Python 后端缺失）；Monocle/PAGA/Palantir/WOT 未运行。见 [[methods/trajectory-inference]]、[[methods/rna-velocity]]。

## 输入

- Seurat 对象；`assay`、`slot`；聚类/细胞类型列；降维名称和维度。
- Slingshot：`group.by`、`reduction`、`dims`、`start`、`end`、`prefix`、`reverse`、`align_start`。
- Monocle2：`expressionFamily`、`features`/`feature_type`、`disp_filter`、`max_components`、`reduction_method`、`norm_method`、`root_state`。
- Monocle3：`reduction`、`clusters`、`graph`、`partition_qval`、`k`、`cluster_method`、`num_iter`、`resolution`、`use_partition`、`close_loop`、`root_pr_nodes`/`root_cells`。
- PAGA：`group_by`、`linear_reduction`/`nonlinear_reduction`、`n_pcs`、`n_neighbors`、`use_rna_velocity`、`embedded_with_PAGA`、`threshold`、`infer_pseudotime`、`root_group`/`root_cell`。
- scVelo：`assay_X`/`slot_X`、`assay_layers=c("spliced","unspliced")`、`mode`、`n_pcs`、`n_neighbors`、`min_shared_counts`。
- Palantir：`early_group`/`early_cell`、`terminal_groups`/`terminal_cells`、`dm_*`、`num_waypoints`。
- WOT：`time_field`、`time_from`/`time_to`、`growth_iters`、`tmap_out`。
- 一行一个细胞；lineage/pseudotime 列与细胞 ID 对齐；速度层与 counts 对齐。

## 怎么做

1. 先确认聚类/注释和降维稳定；轨迹不应该用来弥补聚类问题。
2. 选方法：有明确起点/终点且结构连续时用 Slingshot/Monocle；需要群间连接图用 PAGA；需要命运概率用 Palantir；有时间序列用 WOT；有 spliced/unspliced 用 scVelo。
3. Slingshot：指定 `group.by`、`reduction`、`dims`、`start`/`end`；检查 lineage 数量和 pseudotime 分布。
4. Monocle2/3：设 `root_state`/`root_pr_nodes`/`root_cells`；检查 State/partition/cluster 和 pseudotime 是否与 marker 一致。
5. PAGA：设 `group_by`、`n_pcs`、`n_neighbors`、`threshold`；检查 connectivities 和 draw_graph。
6. scVelo：确认 spliced/unspliced；设 `mode`、`min_shared_counts`、`n_pcs`、`n_neighbors`；检查 velocity 置信度/长度和流向。
7. Palantir：设早期细胞/群和终末群；检查 pseudotime、diff_potential 和命运概率。
8. 必要诊断：轨迹拓扑对参数的敏感性、pseudotime 与 marker 的一致性、lineage 的最小细胞数、速度箭头与已知 marker 方向是否冲突。
9. 导出 UMAP 分组/特征长表、动态特征表；进入 [[methods/scp-de-enrichment-dynamic|动态特征]]。

## 代码

- 原始字节：`source/SCP-analysis.R`（只读归档，未修改）；Python 原字节在共享源码包 `source/inst/python/`。
- 本地化副本：`code/SCP-local/R/SCP-analysis.R`；Python 在 `code/SCP-local/python/`。加载方式：
  ```r
  source("path/to/SCP-local/load_scp_local.R")
  srt <- SCP_local$RunSlingshot(srt, group.by = "celltype", reduction = "UMAP")
  srt <- SCP_local$RunMonocle3(srt, reduction = "UMAP")
  srt <- SCP_local$RunPAGA(srt, group_by = "celltype",
                           linear_reduction = "PCA", nonlinear_reduction = "UMAP")
  srt <- SCP_local$RunSCVELO(srt, group_by = "celltype",
                             assay_layers = c("spliced", "unspliced"),
                             linear_reduction = "PCA", nonlinear_reduction = "UMAP")
  ```
  这只是调用模式，不是已跑通的本机示例。
- 依赖：Seurat、SeuratObject、slingshot、monocle、DDRTree、destiny、igraph；Python 侧 reticulate、scanpy、scvelo、cellrank、palantir、wot、matplotlib、numpy、pandas。完整清单见 [[methods/scp-local-source|SCP 源码本地化]]。
- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时所有轨迹/速度函数依赖未安装、未运行。2026-10-23 当前范围见 [[methods/trajectory-inference]]（Slingshot verified）与 [[methods/rna-velocity]]（scVelo not_run）；其他轨迹/速度分支未运行。
- 本地化未改变轨迹/速度算法；只把 Python 路径从 `system.file(package="SCP")` 改到本地 `python/`。

## 输出

Seurat 对象中新增（列名以运行结果为准）：

- `RunSlingshot()`：metadata `Lineage1`、`Lineage2`…（pseudotime）、`BranchID`；tools `Slingshot_<group_by>_<reduction>`。
- `RunMonocle2()`：metadata `Monocle2_State`、`Monocle2_Pseudotime`；reduction `DDRTree`；tools `Monocle2`（cds、features、trajectory）。
- `RunMonocle3()`：metadata `Monocle3_clusters`、`Monocle3_partitions`、`Monocle3_Pseudotime`；tools `Monocle3`（cds、trajectory、milestones）。
- `RunPAGA()`：`srt@misc$paga`、reductions（如 `paga`、`draw_graph_fr`）、connectivities/distances；可选 pseudotime。
- `RunSCVELO()`：velocity 相关 metadata（默认 `stochastic_length`、`stochastic_confidence`、`stochastic_pseudotime` 等）、velocity 数组/layers；`VelocityPlot()` 读取。
- `RunPalantir()`：metadata `palantir_pseudotime`、`palantir_diff_potential`、`<group>_diff_potential`；相关 reduction。
- `RunWOT()`：transport map（`tmap_out` 路径）和 trajectory/fate 结果；具体列以运行结果为准。
- 下游表：
  - `render-umap-groups.csv`：`cell_id, umap_1, umap_2, group`（group=cluster/lineage 分组），供 fig01；模板不画 lineage 曲线。
  - `render-umap-feature-long.csv`：`cell_id, umap_1, umap_2, group, feature, value`（pseudotime/动态特征），供 fig02。
  - `render-grouped-values.csv`：`celltype, group, value`（动态特征/pseudotime 按 cluster 分组），供 fig06。
  - 适配函数见 [[methods/scp-visualization-interface|SCP 可视化函数族与接口映射]]：`scp_umap_groups()`、`scp_umap_feature_long()`、`scp_grouped_values()`。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/trajectory-inference|拟时序与轨迹推断]]、[[methods/rna-velocity|RNA 速度分析]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页；归档 `SCP-analysis.R` 原字节，本地化副本进入共享源码包；按作者代签授权标为 ready；验收记录见 `acceptance.json`。

<!-- user:start -->
<!-- user:end -->
